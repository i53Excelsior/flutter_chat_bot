import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_bot/core/constant/api_constant.dart';

class AiService {
  final Dio dio = Dio();

  Future<String> askGemini(String prompt) async {
    try {
      final response = await dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${ApiConstants.apiKey}',
        data: {
          "contents": [
            {
              "parts": [
                {
                  "text": prompt,
                }
              ]
            }
          ]
        },
      );

      debugPrint("SUCCESS RESPONSE:");
      debugPrint(response.data.toString());

      return response.data['candidates'][0]['content']['parts'][0]['text']
          .toString();
    } on DioException catch (e) {
      debugPrint("STATUS CODE: ${e.response?.statusCode}");
      debugPrint("ERROR DATA: ${e.response?.data}");

      throw Exception(
        "Gemini Error: ${e.response?.statusCode}\n${e.response?.data}",
      );
    }
  }
}