import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  static const String _apiKey = "";
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> sendMessage(String message, String language, List<Map<String, String>> history) async {
    try {
      final systemPrompt = '''You are a friendly language tutor teaching $language. 
The user will write in $language or English. 
1. If there are grammar mistakes, gently correct them.
2. Reply naturally in $language.
3. Always include an English translation of your reply in brackets.
Keep responses short (2-4 sentences).''';

      final messages = [
        {"role": "system", "content": systemPrompt},
        ...history,
        {"role": "user", "content": message},
      ];

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": messages,
          "max_tokens": 300,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return "Sorry, kuch problem hui (${response.statusCode}). Try again.";
      }
    } catch (e) {
      return "Sorry, connection me issue hai. Please try again.";
    }
  }
}