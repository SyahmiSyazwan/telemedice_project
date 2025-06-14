import 'dart:convert';
import 'package:http/http.dart' as http;

class AIChatService {
  final String apiKey;

  AIChatService(this.apiKey);

  Future<String> sendMessage(String message) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'HTTP-Referer': 'https://yourapp.example.com', // Optional
        'X-Title': 'TeleMedice AI Assistant', // Optional
      },
      body: jsonEncode({
        "model": "deepseek/deepseek-r1:free",
        "messages": [
          {"role": "user", "content": message},
        ],
        "temperature": 0.7,
        "max_tokens": 1000,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final aiReply =
          data['choices'][0]['message']['content'].toString().trim();
      return "$aiReply\n\n*This is an AI-generated medical suggestion. Please consult a licensed healthcare professional before making any decisions.*";
    } else if (response.statusCode == 429) {
      throw Exception("❗ Rate limit exceeded. Try again later.");
    } else if (response.statusCode == 401) {
      throw Exception("❗ Invalid API key.");
    } else {
      throw Exception(
        '❗ Failed to fetch AI response: ${response.statusCode}\n${response.body}',
      );
    }
  }
}
