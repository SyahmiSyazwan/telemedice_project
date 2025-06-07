import 'dart:convert';
import 'package:http/http.dart' as http;

class AIChatService {
  final String apiKey;

  AIChatService(this.apiKey);

  Future<String> sendMessage(String message) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
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
      return "$aiReply\n *This is an AI-generated medical suggestion. Please consult a licensed healthcare professional before making any decisions.*";
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
