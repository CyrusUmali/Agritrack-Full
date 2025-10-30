import 'package:flareline/pages/recommendation/api_uri.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotModel extends ChangeNotifier {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user', firstName: 'User');
  final _bot = const types.User(id: 'bot', firstName: 'AgriBot');
  bool _isTyping = false;
  String _currentModel = 'Gemini';
  bool _useStreaming = true;

  // Streaming-related properties
  StreamSubscription? _streamSubscription;
  String _currentStreamingMessageId = '';
  String _currentStreamingText = '';

  // Store suggestions from the AI response
  List<String> _latestSuggestions = [];

  // API endpoints (for non-Gemini models)
  final uri = Uri.parse(ApiConstants.chatbot);
  final streamUri = Uri.parse('${ApiConstants.baseUrl}/chat/stream');

  // Gemini setup
  late GenerativeModel _geminiModel;
  late ChatSession _geminiChatSession;
  String? _geminiApiKey;

  static const String _systemPrompt =
      '''You are AgriBot, an expert agricultural assistant specializing in:
- Crop selection and planning
- Soil health and testing
- Pest and disease management
- Water and irrigation systems
- Fertilizers and nutrient management
- Seasonal farming guides
- Weather and climate adaptation
- Harvesting and storage techniques
- Organic and sustainable farming practices
- Livestock management (cattle, poultry, goats, sheep, pigs)
- Animal nutrition and feed management
- Livestock health and disease control
- Fishery and aquaculture systems
- Fish farming techniques
- Pond management and water quality
- Fish health and disease management

Provide practical, actionable advice tailored to the user's specific needs. Always ask clarifying questions about their region, soil type, current conditions, and livestock/fishery setup when relevant. Keep responses concise but informative.

IMPORTANT: After your response, add 3-4 relevant follow-up questions that the user might want to ask. Format them at the end like this:

[FOLLOW_UP_QUESTIONS]
- Question 1?
- Question 2?
- Question 3?
- Question 4?
[/FOLLOW_UP_QUESTIONS]

Make the questions practical, concise, and directly related to your response.''';

  static const List<String> availableModels = [
    'Gemini',
    'GPT-4',
    'Claude',
    'Llama'
  ];

  List<types.Message> get messages => _messages;
  bool get isTyping => _isTyping;
  types.User get user => _user;
  types.User get bot => _bot;
  String get currentModel => _currentModel;
  List<String> get models => availableModels;
  bool get useStreaming => _useStreaming;
  List<String> get latestSuggestions => _latestSuggestions;

  static const String _geminiApiKeyValue =
      'AIzaSyCWiZmhjdh1GmYKnvJMLvgsY-bh20wYOZs';

  ChatbotModel() {
    _geminiApiKey = _geminiApiKeyValue;
    _initializeGemini(_geminiApiKeyValue);
    _addBotWelcomeMessage();
  }

  void _initializeGemini(String apiKey) {
    _geminiModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.text(_systemPrompt),
    );
    _geminiChatSession = _geminiModel.startChat();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void setModel(String model) {
    if (availableModels.contains(model)) {
      _currentModel = model;
      notifyListeners();

      final modelMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: "Switched to $model model. How can I help you now?",
      );

      _messages.insert(0, modelMessage);
      _latestSuggestions = [];
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _isTyping = false;
    _streamSubscription?.cancel();
    _currentStreamingMessageId = '';
    _currentStreamingText = '';
    _latestSuggestions = [];

    // Reinitialize Gemini chat session if using Gemini
    if (_currentModel == 'Gemini' && _geminiApiKey != null) {
      _geminiChatSession = _geminiModel.startChat();
    }

    _addBotWelcomeMessage();
  }

  void _addBotWelcomeMessage() {
    final welcomeMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text:
          "Hello! I'm AgriBot, your agriculture assistant. How can I help you today?",
    );

    _messages.insert(0, welcomeMessage);
    _latestSuggestions = [
      'Tell me about soil health',
      'What crops should I grow?',
      'How do I control pests?',
      'Best irrigation practices?'
    ];
    notifyListeners();
  }

  void addUserMessage(String text) {
    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: text,
    );

    _messages.insert(0, userMessage);
    _isTyping = true;
    _latestSuggestions = []; // Clear suggestions while processing
    notifyListeners();
  }

  // Extract suggestions from AI response
  Map<String, dynamic> _extractSuggestionsFromResponse(String fullResponse) {
    final startMarker = '[FOLLOW_UP_QUESTIONS]';
    final endMarker = '[/FOLLOW_UP_QUESTIONS]';

    if (fullResponse.contains(startMarker) &&
        fullResponse.contains(endMarker)) {
      final startIndex = fullResponse.indexOf(startMarker);
      final endIndex = fullResponse.indexOf(endMarker);

      // Extract the clean response without markers
      final cleanResponse = fullResponse.substring(0, startIndex).trim();

      // Extract suggestions section
      final suggestionsSection = fullResponse
          .substring(startIndex + startMarker.length, endIndex)
          .trim();

      // Parse suggestions (lines starting with - or numbers)
      final suggestions = suggestionsSection
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .map((line) {
            // Remove leading dash, asterisk, or number
            return line.replaceFirst(RegExp(r'^[-*•]\s*|^\d+\.\s*'), '').trim();
          })
          .where((line) => line.isNotEmpty && line.length > 5)
          .take(4)
          .toList();

      return {
        'response': cleanResponse,
        'suggestions': suggestions,
      };
    }

    // Fallback: no structured suggestions found
    return {
      'response': fullResponse,
      'suggestions': _generateFallbackSuggestions(),
    };
  }

  List<String> _generateFallbackSuggestions() {
    return [
      'Can you explain more?',
      'What are the benefits?',
      'Any alternatives?',
      'How do I start?'
    ];
  }

  Future<void> getBotResponse(String userMessage,
      {bool useStreaming = true}) async {
    if (_currentModel == 'Gemini' && _geminiApiKey != null) {
      await _getBotResponseGemini(userMessage);
    } else if (useStreaming) {
      await _getBotResponseStreaming(userMessage);
    } else {
      await _getBotResponseRegular(userMessage);
    }
  }

  // Gemini direct API response
  Future<void> _getBotResponseGemini(String userMessage) async {
    try {
      _currentStreamingMessageId = const Uuid().v4();
      _currentStreamingText = '';

      final initialMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: _currentStreamingMessageId,
        text: '',
      );

      _messages.insert(0, initialMessage);
      notifyListeners();

      final stream = _geminiChatSession.sendMessageStream(
        Content.text(userMessage),
      );

      _streamSubscription = stream.listen(
        (event) {
          final chunk = event.text ?? '';
          if (chunk.isNotEmpty) {
            _currentStreamingText += chunk;
            _updateStreamingMessage(_currentStreamingText);
          }
        },
        onError: _handleStreamError,
        onDone: () => _handleStreamDone(isGemini: true),
      );
    } catch (e) {
      print('Error in Gemini response: $e');
      _addErrorMessage('Failed to get response: $e');
    }
  }

  // Streaming response method (for custom API)
  Future<void> _getBotResponseStreaming(String userMessage) async {
    try {
      await _streamSubscription?.cancel();

      final chatHistory = _prepareChatHistory();

      _currentStreamingMessageId = const Uuid().v4();
      _currentStreamingText = '';

      final initialMessage = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: _currentStreamingMessageId,
        text: '',
      );

      _messages.insert(0, initialMessage);
      notifyListeners();

      final request = http.Request('POST', streamUri);
      request.headers.addAll({
        'Content-Type': 'application/json',
        'X-Model': _currentModel,
        'Accept': 'text/event-stream',
      });

      request.body = jsonEncode({
        'message': userMessage,
        'chat_history': chatHistory,
        'model': _currentModel,
      });

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        _streamSubscription = streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
              _handleStreamData,
              onError: _handleStreamError,
              onDone: () => _handleStreamDone(isGemini: false),
            );
      } else {
        throw Exception(
            'Stream request failed with status: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      print('Streaming error: $e');
      await _getBotResponseRegular(userMessage);
    }
  }

  void _handleStreamData(String line) {
    if (line.startsWith('data: ')) {
      final jsonStr = line.substring(6);

      if (jsonStr.trim().isEmpty) return;

      try {
        final data = jsonDecode(jsonStr);
        final chunk = data['chunk'] as String?;
        final isComplete = data['is_complete'] as bool? ?? false;

        if (chunk != null && chunk.isNotEmpty) {
          _currentStreamingText += chunk;
          _updateStreamingMessage(_currentStreamingText);
        }

        if (isComplete) {
          _finishStreaming();
        }
      } catch (e) {
        print('Error parsing stream data: $e');
      }
    }
  }

  void _updateStreamingMessage(String text) {
    final messageIndex = _messages.indexWhere(
      (msg) => msg.id == _currentStreamingMessageId,
    );

    if (messageIndex != -1) {
      // For display, show text without suggestion markers
      String displayText = text;
      if (text.contains('[FOLLOW_UP_QUESTIONS]')) {
        displayText =
            text.substring(0, text.indexOf('[FOLLOW_UP_QUESTIONS]')).trim();
      }

      final updatedMessage = types.TextMessage(
        author: _bot,
        createdAt: _messages[messageIndex].createdAt,
        id: _currentStreamingMessageId,
        text: displayText,
      );

      _messages[messageIndex] = updatedMessage;
      notifyListeners();
    }
  }

  void _finishStreaming() {
    // Extract suggestions from the complete response
    final extracted = _extractSuggestionsFromResponse(_currentStreamingText);

    // Update the message with clean response
    final messageIndex = _messages.indexWhere(
      (msg) => msg.id == _currentStreamingMessageId,
    );

    if (messageIndex != -1) {
      final updatedMessage = types.TextMessage(
        author: _bot,
        createdAt: _messages[messageIndex].createdAt,
        id: _currentStreamingMessageId,
        text: extracted['response'] as String,
      );

      _messages[messageIndex] = updatedMessage;
    }

    // Update suggestions
    _latestSuggestions = extracted['suggestions'] as List<String>;

    _isTyping = false;
    _currentStreamingMessageId = '';
    _currentStreamingText = '';
    notifyListeners();
  }

  void _handleStreamError(error) {
    print('Stream error: $error');
    _isTyping = false;
    _latestSuggestions = _generateFallbackSuggestions();
    _addErrorMessage('Failed to get streaming response. Please try again.');
    notifyListeners();
  }

  void _handleStreamDone({required bool isGemini}) {
    if (_isTyping) {
      _finishStreaming();
    }
  }

  Future<void> _getBotResponseRegular(String userMessage) async {
    try {
      final chatHistory = _prepareChatHistory();

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Model': _currentModel,
        },
        body: jsonEncode({
          'message': userMessage,
          'chat_history': chatHistory,
          'model': _currentModel,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['response'] as String;

        // Extract and set suggestions
        final extracted = _extractSuggestionsFromResponse(botResponse);
        _addBotMessage(extracted['response'] as String);
        _latestSuggestions = extracted['suggestions'] as List<String>;
      } else {
        final localResponse = generateLocalResponse(userMessage);
        _addBotMessage(localResponse);
        _latestSuggestions = _generateFallbackSuggestions();
      }
    } catch (e) {
      final localResponse = generateLocalResponse(userMessage);
      _addBotMessage(localResponse);
      _latestSuggestions = _generateFallbackSuggestions();
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _prepareChatHistory() {
    return _messages.reversed
        .where((message) => message is types.TextMessage)
        .map((message) {
          final textMessage = message as types.TextMessage;
          return {
            'role': textMessage.author.id == _user.id ? 'user' : 'assistant',
            'content': textMessage.text,
          };
        })
        .take(20)
        .toList();
  }

  void _addBotMessage(String text) {
    final botMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: text,
    );

    _messages.insert(0, botMessage);
    notifyListeners();
  }

  void _addErrorMessage(String error) {
    final errorMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: 'Sorry, I encountered an error: $error. Please try again later.',
    );

    _messages.insert(0, errorMessage);
    notifyListeners();
  }

  void handleSendPressed(types.PartialText message) {
    addUserMessage(message.text);
    getBotResponse(message.text, useStreaming: _useStreaming);
  }

  String generateLocalResponse(String userMessage) {
    return "I'm currently offline. Please check your connection and try again.";
  }
}
