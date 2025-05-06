import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String?> callOpenAIChat({
  required String prompt,
  required List<Map<String, String>> messages,
  String model = "gpt-4-turbo",
  double temperature = 0.85,
  double topP = 0.9,
  double frequencyPenalty = 0.7,
  double presencePenalty = 0.8,
}) async {
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  try {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": model,
        "temperature": temperature,
        "top_p": topP,
        "frequency_penalty": frequencyPenalty,
        "presence_penalty": presencePenalty,
        "messages": [
          {"role": "system", "content": prompt},
          ...messages.map((m) =>
          {
            "role": m["sender"] == "user" ? "user" : "assistant",
            "content": m["text"],
          }),
        ]
      }),
    );


    if (response.statusCode == 200) {
      final utfDecoded = utf8.decode(response.bodyBytes);
      final data = jsonDecode(utfDecoded);
      return data['choices'][0]['message']['content'];
    }
  }
  catch (e) {
    return null;
  }
  return null;
}