import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY']!;

  Future<String> generateResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Respond in the context of Vedic philosophy: $message'}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 300
          }
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      }
    } catch (e) {
      print('Error generating response: $e');
    }
    return 'I apologize, but I could not process your request.';
  }
}