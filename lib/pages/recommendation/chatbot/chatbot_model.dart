import 'package:flareline/pages/recommendation/api_uri.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class ChatbotModel extends ChangeNotifier {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user', firstName: 'User');
  final _bot = const types.User(id: 'bot', firstName: 'AgriBot');
  bool _isTyping = false;
  String _currentModel = 'Gemini'; // Default model
  final uri = Uri.parse(ApiConstants.chatbot);

  // Available AI models
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

  ChatbotModel() {
    _addBotWelcomeMessage();
  }

  void setModel(String model) {
    if (availableModels.contains(model)) {
      _currentModel = model;
      notifyListeners();

      // Add a system message about the model change
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

  Future<void> getBotResponse(String userMessage) async {
    try {
      // Prepare chat history for context
      final chatHistory = _messages.reversed
          .where((message) => message is types.TextMessage)
          .map((message) {
            final textMessage = message as types.TextMessage;
            return {
              'user':
                  textMessage.author.id == _user.id ? textMessage.text : null,
              'bot': textMessage.author.id == _bot.id ? textMessage.text : null,
            };
          })
          .where((entry) => entry['user'] != null || entry['bot'] != null)
          .toList();

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Model': _currentModel, // Send the selected model to the API
        },
        body: jsonEncode({
          'message': userMessage,
          'chat_history': chatHistory,
          'model': _currentModel, // Also include in body if needed
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['response'] as String;
        _addBotMessage(botResponse);
      } else {
        // Fallback to local response if API fails
        final localResponse = generateLocalResponse(userMessage);
        _addBotMessage(localResponse);
      }
    } catch (e) {
      // Fallback to local response on any error
      final localResponse = generateLocalResponse(userMessage);
      _addBotMessage(localResponse);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
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
    getBotResponse(message.text);
  }

  String generateLocalResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('hello') || message.contains('hi')) {
      return "Hello! What agricultural topic can I help with today? I'm currently using the $_currentModel model.";
    } else if (message.contains('soil') || message.contains('ph')) {
      return "[$_currentModel] Soil quality is crucial for crops. Most prefer pH 6.0-7.0. Need specific soil advice?";
    } else if (message.contains('crop') && message.contains('recommend')) {
      return "[$_currentModel] For crop recommendations, consider:\n- Your region\n- Soil type\n- Current season\n\nTry our Recommendation tool for precise suggestions!";
    } else if (message.contains('pest') || message.contains('insect')) {
      return "[$_currentModel] Common organic pest control methods:\n- Neem oil\n- Companion planting\n- Beneficial insects";
    } else if (message.contains('fertilizer') ||
        message.contains('nutrients')) {
      return "[$_currentModel] Essential nutrients for plants:\n- Nitrogen (N) - leaf growth\n- Phosphorus (P) - root development\n- Potassium (K) - disease resistance\n\nAlways test soil before applying fertilizers!";
    } else if (message.contains('water') || message.contains('irrigation')) {
      return "[$_currentModel] Proper watering tips:\n- Water deeply but less frequently\n- Morning watering is best\n- Check soil moisture before watering\n- Consider drip irrigation for efficiency";
    } else if (message.contains('season') || message.contains('planting')) {
      return "[$_currentModel] Planting seasons vary by region and crop. Generally:\n- Spring: warm-season crops\n- Fall: cool-season crops\n- Consider your local frost dates!";
    } else if (message.contains('disease') || message.contains('fungus')) {
      return "[$_currentModel] Common plant diseases:\n- Fungal infections (treat with fungicides)\n- Bacterial diseases (improve air circulation)\n- Viral diseases (remove affected plants)\n\nPrevention is key - ensure good plant spacing and hygiene!";
    } else {
      return "[$_currentModel] I can help with crop selection, soil health, pest management, fertilizers, irrigation, and plant diseases. Could you clarify your question?";
    }
  }
}
