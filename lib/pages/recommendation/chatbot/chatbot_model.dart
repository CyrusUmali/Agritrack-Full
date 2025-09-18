import 'package:flareline/pages/recommendation/api_uri.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:async';

class ChatbotModel extends ChangeNotifier {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user', firstName: 'User');
  final _bot = const types.User(id: 'bot', firstName: 'AgriBot');
  bool _isTyping = false;
  String _currentModel = 'Gemini';
  bool _useStreaming = true; // Add streaming toggle

  // Streaming-related properties
  StreamSubscription? _streamSubscription;
  String _currentStreamingMessageId = '';
  String _currentStreamingText = '';

  // API endpoints
  final uri = Uri.parse(ApiConstants.chatbot);
  final streamUri = Uri.parse(
      '${ApiConstants.baseUrl}/chat/stream'); // Update with your streaming endpoint

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

  ChatbotModel() {
    _addBotWelcomeMessage();
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
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _isTyping = false;
    _streamSubscription?.cancel();
    _currentStreamingMessageId = '';
    _currentStreamingText = '';

    // Add welcome message back
    _addBotWelcomeMessage();
  }

  void _addBotWelcomeMessage() {
    final welcomeMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text:
          "Hello! I'm AgriBot, your agriculture assistant. I'm currently using the $_currentModel model. How can I help you today?",
    );

    _messages.insert(0, welcomeMessage);
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
    notifyListeners();
  }

  // Main method - decides between streaming and regular response
  Future<void> getBotResponse(String userMessage,
      {bool useStreaming = true}) async {
    if (useStreaming) {
      await _getBotResponseStreaming(userMessage);
    } else {
      await _getBotResponseRegular(userMessage);
    }
  }

  // Streaming response method
  Future<void> _getBotResponseStreaming(String userMessage) async {
    try {
      // Cancel any existing stream
      await _streamSubscription?.cancel();

      // Prepare chat history
      final chatHistory = _prepareChatHistory();

      // Create initial empty bot message for streaming
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

      // Create streaming request
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

      // Send request and get stream
      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        // Process the stream
        _streamSubscription = streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
              _handleStreamData,
              onError: _handleStreamError,
              onDone: _handleStreamDone,
            );
      } else {
        throw Exception(
            'Stream request failed with status: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      print('Streaming error: $e');
      // Fallback to regular response
      await _getBotResponseRegular(userMessage);
    }
  }

  // Handle incoming stream data
  void _handleStreamData(String line) {
    if (line.startsWith('data: ')) {
      final jsonStr = line.substring(6); // Remove 'data: ' prefix

      if (jsonStr.trim().isEmpty) return;

      try {
        final data = jsonDecode(jsonStr);
        final chunk = data['chunk'] as String?;
        final isComplete = data['is_complete'] as bool? ?? false;
        // final disclaimer = data['disclaimer'] as String?;

        if (chunk != null && chunk.isNotEmpty) {
          _currentStreamingText += chunk;
          _updateStreamingMessage(_currentStreamingText);
        }

        if (isComplete) {
          // _finishStreaming(disclaimer);
        }
      } catch (e) {
        print('Error parsing stream data: $e');
      }
    }
  }

  // Update the streaming message in real-time
  void _updateStreamingMessage(String text) {
    final messageIndex = _messages.indexWhere(
      (msg) => msg.id == _currentStreamingMessageId,
    );

    if (messageIndex != -1) {
      final updatedMessage = types.TextMessage(
        author: _bot,
        createdAt: _messages[messageIndex].createdAt,
        id: _currentStreamingMessageId,
        text: text,
      );

      _messages[messageIndex] = updatedMessage;
      notifyListeners();
    }
  }

  // Handle stream completion
  void _finishStreaming(String? disclaimer) {
    _isTyping = false;

    // if (disclaimer != null && disclaimer.isNotEmpty) {
    //   _currentStreamingText += '\n\n$disclaimer';
    //   _updateStreamingMessage(_currentStreamingText);
    // }

    _currentStreamingMessageId = '';
    _currentStreamingText = '';
    notifyListeners();
  }

  // Handle stream errors
  void _handleStreamError(error) {
    print('Stream error: $error');
    _isTyping = false;
    _addErrorMessage('Failed to get streaming response. Please try again.');
    notifyListeners();
  }

  // Handle stream completion
  void _handleStreamDone() {
    if (_isTyping) {
      _finishStreaming(null);
    }
  }

  // Regular (non-streaming) response method
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
        _addBotMessage(botResponse);
      } else {
        final localResponse = generateLocalResponse(userMessage);
        _addBotMessage(localResponse);
      }
    } catch (e) {
      final localResponse = generateLocalResponse(userMessage);
      _addBotMessage(localResponse);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  // Prepare chat history for API
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
        .take(20) // Limit history to last 20 messages
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
    getBotResponse(message.text,
        useStreaming: _useStreaming); // Use current streaming setting
  }

  // Method to toggle between streaming and regular responses
  void toggleStreamingMode(bool enableStreaming) {
    _useStreaming = enableStreaming;
    notifyListeners();

    // Add notification message
    final modeMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: enableStreaming
          ? "Streaming mode enabled - responses will appear in real-time!"
          : "Streaming mode disabled - responses will appear all at once.",
    );

    _messages.insert(0, modeMessage);
    notifyListeners();
  }

  String generateLocalResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('hello') || message.contains('hi')) {
      return "Hello! What agricultural topic can I help with today? I'm currently using the $_currentModel model.";
    } else if (message.contains('soil') || message.contains('ph')) {
      return "[$_currentModel] Soil quality is crucial for crops. Most prefer pH 6.0-7.0. Test your soil regularly and consider:\n\n• Adding organic matter like compost\n• Adjusting pH with lime (for acidic soil) or sulfur (for alkaline soil)\n• Testing nutrient levels (N-P-K)\n• Checking soil drainage\n\nWhat specific soil concerns do you have?";
    } else if (message.contains('crop') && message.contains('recommend')) {
      return "[$_currentModel] For crop recommendations, I need to consider:\n\n• Your climate zone/region\n• Soil type and quality\n• Available water resources\n• Market demand\n• Your experience level\n\nCould you share your location and what you're hoping to grow? Also check our Recommendation tool for personalized suggestions!";
    } else if (message.contains('pest') || message.contains('insect')) {
      return "[$_currentModel] Organic pest control strategies:\n\n🐛 **Prevention:**\n• Crop rotation\n• Companion planting (marigolds, basil)\n• Healthy soil = stronger plants\n\n🌿 **Natural treatments:**\n• Neem oil for aphids, whiteflies\n• Diatomaceous earth for crawling insects\n• Beneficial insects (ladybugs, lacewings)\n• Soap spray for soft-bodied pests\n\nWhat specific pests are you dealing with?";
    } else if (message.contains('fertilizer') ||
        message.contains('nutrients')) {
      return "[$_currentModel] Essential plant nutrients:\n\n**Primary (N-P-K):**\n• Nitrogen (N) - Leaf growth, green color\n• Phosphorus (P) - Root development, flowering\n• Potassium (K) - Disease resistance, fruit quality\n\n**Secondary:** Calcium, Magnesium, Sulfur\n**Micronutrients:** Iron, Zinc, Boron, etc.\n\n💡 **Tips:**\n• Always soil test first\n• Organic options: compost, manure, bone meal\n• Follow application rates carefully\n• Time applications with plant growth stages";
    } else if (message.contains('water') || message.contains('irrigation')) {
      return "[$_currentModel] Smart watering practices:\n\n💧 **Timing:**\n• Early morning (6-8 AM) is ideal\n• Avoid evening watering (disease risk)\n\n🎯 **Technique:**\n• Deep, infrequent watering\n• Water soil, not leaves\n• Mulch to retain moisture\n\n📊 **Systems:**\n• Drip irrigation (90% efficiency)\n• Soaker hoses for gardens\n• Smart controllers with weather sensors\n\n**Check soil moisture:** Stick finger 2 inches deep - if dry, time to water!";
    } else if (message.contains('season') || message.contains('planting')) {
      return "[$_currentModel] Planting timing guide:\n\n🌱 **Cool Season Crops** (Spring/Fall):\n• Lettuce, spinach, peas, carrots\n• Plant 2-4 weeks before last frost\n\n☀️ **Warm Season Crops** (Summer):\n• Tomatoes, peppers, cucumbers, corn\n• Plant after soil warms to 60°F+\n\n📅 **Key dates to know:**\n• Last spring frost\n• First fall frost\n• Soil temperature\n\nWhat's your growing zone? I can give more specific timing!";
    } else if (message.contains('disease') || message.contains('fungus')) {
      return "[$_currentModel] Plant disease management:\n\n🍄 **Fungal diseases** (most common):\n• Symptoms: Spots, wilting, moldy growth\n• Prevention: Good air circulation, avoid overhead watering\n• Treatment: Fungicides, remove affected parts\n\n🦠 **Bacterial diseases:**\n• Symptoms: Water-soaked spots, oozing\n• Prevention: Clean tools, avoid working wet plants\n• Treatment: Copper-based sprays, remove infected plants\n\n🔬 **Viral diseases:**\n• Symptoms: Mosaic patterns, stunted growth\n• Prevention: Control insect vectors\n• Treatment: Remove infected plants (no cure)\n\nDescribe the symptoms you're seeing for specific advice!";
    } else if (message.contains('weather') || message.contains('climate')) {
      return "[$_currentModel] Weather impacts on agriculture:\n\n🌡️ **Temperature effects:**\n• Frost damage to tender plants\n• Heat stress reduces yields\n• Growing degree days affect timing\n\n🌧️ **Precipitation:**\n• Too little = drought stress\n• Too much = root rot, fungal diseases\n• Timing matters for planting/harvesting\n\n💨 **Wind & storms:**\n• Physical damage to crops\n• Increased evaporation\n• Disease spread\n\n**Adaptation strategies:** Season extension, variety selection, protective structures. What weather challenges are you facing?";
    } else {
      return "[$_currentModel] I'm here to help with all aspects of agriculture! I can assist with:\n\n🌱 **Crop Selection & Planning**\n🌾 **Soil Health & Testing**\n🐛 **Pest & Disease Management**\n💧 **Irrigation & Water Management**\n🌿 **Fertilizers & Nutrition**\n📅 **Seasonal Planning**\n🌤️ **Weather & Climate Adaptation**\n\nWhat specific agricultural topic would you like to explore? Feel free to use the quick topic buttons above or ask me anything!";
    }
  }
}
