import 'dart:convert';
import 'package:http/http.dart' as http;

class NaverApiService {
  static const String baseUrl = "https://naveropenapi.apigw.ntruss.com/map-place/v1/search";
  static const String apiKeyId = "lnluw3cz1n";
  static const String apiKey = "24MTUdfj2votPiXDY3Vqbv0uPsBem1LTffX9KC1z";

  static Future<List<Map<String, dynamic>>> fetchCounselingCenters(double lat, double lng) async {
    final response = await http.get(
      Uri.parse("$baseUrl?query=상담센터&coordinate=$lng,$lat"), // 경도, 위도 순서
      headers: {
        "X-NCP-APIGW-API-KEY-ID": apiKeyId,
        "X-NCP-APIGW-API-KEY": apiKey,
        "Content-Type": "application/json",
      },
    );

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
      print("API 요청 실패: ${response.statusCode}");
      return [];
    }
  }
}
