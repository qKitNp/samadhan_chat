import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final List<Content> _history = [];
  static const int _maxHistoryLength = 10;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY']!;
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,

      ),
    );
    _chat = _model.startChat(history: _history);
  }
  
  Future<String> generateResponse(String message) async {
    try {
      // Add user message to history
      final userMessage = Content('user', [TextPart(message)]);
      _history.add(userMessage);

      // Generate response
      final response = await _chat.sendMessage(userMessage);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      // Add AI response to history
      _history.add(Content('model', [TextPart(responseText)]));

      // Maintain history size
      // if (_history.length > _maxHistoryLength * 2) {
      //   _history.removeRange(0, 2); // Remove oldest Q&A pair
      // }

      return responseText;
    } on Exception catch (e) {
      print('Gemini error: $e');
      return 'I apologize, but I encountered an error processing your request.';
    }
  }

  void resetConversation() {
    _history.clear();
    _chat = _model.startChat(history: _history);
  }


  bool get hasHistory => _history.isNotEmpty;
}