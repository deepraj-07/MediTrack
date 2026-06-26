import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meditrack/config/api_config.dart';

class OpenRouterService {
  static Map<String, String> get _headers => {
    'Authorization': 'Bearer ${ApiConfig.openRouterApiKey}',
    'Content-Type': 'application/json',
    'HTTP-Referer': 'https://meditrack.app',
  };

  static Future<Map<String, String>?> parseVitalFromSpeech(String transcript) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.openRouterBaseUrl}/chat/completions'),
      headers: _headers,
      body: jsonEncode({
        'model': ApiConfig.model,
        'messages': [
          {
            'role': 'system',
            'content': '''You are a health data extractor. Extract vital health information from the user's speech transcript.

The transcript may be in English, Hindi, or Hinglish.

Return ONLY a JSON object with these fields:
- "type": one of "bp", "sugar", "oxygen", "temperature", or "none"
- "value": the numeric value(s) found

Examples:
- "mera BP 120/80 hai" → {"type":"bp","value":"120/80"}
- "sugar 98 thi aaj subah" → {"type":"sugar","value":"98"}
- "oxygen 99 percent" → {"type":"oxygen","value":"99%"}
- "temperature 98.6 degree" → {"type":"temperature","value":"98.6°F"}
- "open medicines screen" → {"type":"none","value":""}

If no vital info is found, return {"type":"none","value":""}
Respond with ONLY the JSON, no other text.''',
          },
          {'role': 'user', 'content': transcript},
        ],
        'temperature': 0.1,
        'max_tokens': 50,
      }),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final body = jsonDecode(response.body);
    final content = body['choices']?[0]?['message']?['content'] as String?;
    if (content == null) return null;

    try {
      final parsed = jsonDecode(content.trim()) as Map<String, dynamic>;
      final type = parsed['type'] as String?;
      final value = parsed['value'] as String?;

      if (type == null || type == 'none' || value == null) return null;

      return {'type': type, 'value': value};
    } catch (_) {
      return null;
    }
  }

  static Future<String?> chat(String userMessage, {String? healthContext, String languageCode = 'hi'}) async {
    String langInstruction;
    if (languageCode == 'hi') {
      langInstruction = '- Respond in natural, warm Hinglish (Hindi written using the English/Latin alphabet, mix of simple Hindi and English words naturally, e.g., "Aapki agli dawai Metformin hai jo aapko subah 8 baje khani hai. Aaj dophar me aapka BP 120/80 mmHg tha, jo bilkul normal hai.") or simple conversational Hindi. Do not use complex pure Hindi words. Keep it friendly and easy to understand for an elderly Indian patient.';
    } else {
      langInstruction = '- Always respond in English only.';
    }

    String systemContent = '''You are MediBot, a friendly health assistant inside the MediTrack health app.

You have access to the user's current health data. Use it to answer their questions accurately.

You can:
- Answer health & wellness questions based on the user's actual data
- Explain medical terms in simple language
- Give general health tips
$langInstruction
- Be warm, supportive, and conversational

Important rules:
- NEVER claim to be a doctor. Always say "I'm an AI assistant, not a doctor" when giving medical advice
- Keep responses short and clear (max 3-4 sentences)
- If user asks about their health, check their vitals, medicines, and conditions from the data below
- Don't invent specific medical numbers or diagnosis
- Be encouraging and positive
- NEVER use markdown formatting like **bold**, *italic*, bullet points, or any special characters. Write in plain text only.''';

    if (healthContext != null && healthContext.isNotEmpty) {
      systemContent += '\n\nHere is the user\'s current health data:\n$healthContext';
    }

    systemContent += '\n\nThe user\'s message is below. Respond naturally.';

    final response = await http.post(
      Uri.parse('${ApiConfig.openRouterBaseUrl}/chat/completions'),
      headers: _headers,
      body: jsonEncode({
        'model': ApiConfig.model,
        'messages': [
          {
            'role': 'system',
            'content': systemContent,
          },
          {'role': 'user', 'content': userMessage},
        ],
        'temperature': 0.7,
        'max_tokens': 300,
      }),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final body = jsonDecode(response.body);
    final content = body['choices']?[0]?['message']?['content'] as String?;
    if (content == null || content.trim().isEmpty) return null;

    return content.trim();
  }
}
