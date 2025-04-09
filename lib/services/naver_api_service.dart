import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NaverApiService {
  static const String baseUrl = "https://naveropenapi.apigw.ntruss.com/map-place/v1/search";
  static final String apiKeyId = dotenv.env['NAVER_MAPS_API_KEY_ID'] ?? '';
  static final String apiKey = dotenv.env['NAVER_MAPS_API_KEY'] ?? '';

  static Future<List<Map<String, dynamic>>> fetchCounselingCenters(double lat, double lng) async {
    final String requestUrl = "$baseUrl?query=상담센터&coordinate=$lng,$lat"; // 경도, 위도 순서
    print("[디버깅] 요청 URL: $requestUrl");  // ✅ 요청 URL 확인

    try {
      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          "X-NCP-APIGW-API-KEY-ID": apiKeyId,
          "X-NCP-APIGW-API-KEY": apiKey,
          "Content-Type": "application/json",
        },
      );

      print("[디버깅] 응답 코드: ${response.statusCode}"); // ✅ 응답 상태 코드 확인
      print("[디버깅] 응답 본문: ${response.body}"); // ✅ 응답 본문 출력

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> results = data["places"];

        return results.map((place) {
          return {
            "name": place["name"],
            "lat": double.parse(place["y"]),
            "lng": double.parse(place["x"]),
          };
        }).toList();
      } else {
        print("[에러] API 요청 실패: HTTP ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("[예외 발생] $e");
      return [];
    }
  }
}
