import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/location_service.dart';
import '../../services/naver_api_service.dart';

class HelpCenterPage extends StatefulWidget {
  @override
  _HelpCenterPageState createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  NaverMapController? _mapController;
  List<NMarker> _markers = [];
  List<Map<String, dynamic>> _filteredCenters = [];
  int _selectedIndex = 0;


  final List<String> _tabs = [
    "내 주변 센터 찾기",
    "긴급전화",
    "자살 위험 신호",
    "자살 예방 도움 수칙"
  ];

  final List<String> _images = [
    "",
    "assets/images/HelpCenter/emergency_number.png",
    "assets/images/HelpCenter/danger_sign.png",
    "assets/images/HelpCenter/suicide_prevention.png"
  ];

  @override
  void initState() {
    _permission();
    _loadUserLocationAndMarkers();
    _markers;
    super.initState();
  }

  void _permission() async {
    var requestStatus = await Permission.location.request();
    var status = await Permission.location.status;
    if (requestStatus.isPermanentlyDenied || status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  /// 현재 위치 가져오고 상담 센터 마커 추가
  Future<void> _loadUserLocationAndMarkers() async {
    Position? position = await LocationService.getCurrentLocation();
    final cameraPosition = await _mapController?.getCameraPosition();
    if (position == null) return;

    if (_mapController != null) {
      _mapController!.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(position.latitude, position.longitude), // ✅ target 키워드 추가
          zoom: 15,
        ),
      );
    }

    try{
      String jsonString = await rootBundle.loadString('assets/map/health_centers.json');

      final decodedData = json.decode(jsonString);

      final List<dynamic> records = decodedData is Map<String, dynamic> &&
          decodedData["records"] is List
          ? decodedData["records"]
          : throw Exception("JSON 파일의 'records' 키가 올바르지 않습니다.");

      List<NMarker> markers = records.map<NMarker>((record) {
        double lat = double.tryParse(record["위도"].toString()) ?? 0.0;
        print("lat : $lat");
        double lng = double.tryParse(record["경도"].toString()) ?? 0.0;
        print("lat : $lng");
        String centerName = record["건강증진센터명"] ?? "알 수 없음";
        print("centerName : $centerName");
        String centerWork = record["건강증진업무내용"] ?? "알 수 없음";
        print("centerWork : $centerWork");
        String phoneNumber = record["운영기관전화번호"] ?? "000-0000-0000";
        print("phoneNumber : $phoneNumber");
        String startTime = record["운영시작시각"] ?? "알 수 없음";
        print("startTime : $startTime");
        String lastTime = record["운영종료시각"] ?? "알 수 없음";
        print("lastTime : $lastTime");

        String infoText = "센터명 : $centerName\n"
            "업무내용 : $centerWork\n"
            "전화번호 : $phoneNumber\n"
            "운영시간 : $startTime ~ $lastTime";

        final onMarkerInfoWindow = NInfoWindow.onMarker(
          id: centerName,
          text: infoText,
        );

        return NMarker(
          id: centerName,
          position: NLatLng(lat, lng),
          caption: NOverlayCaption(text: centerName),
        );
      }).toList();


      List<Map<String, dynamic>> filteredCenters = [];
      for (var record in records) {
        double lat = double.tryParse(record["위도"].toString()) ?? 0.0;
        double lng = double.tryParse(record["경도"].toString()) ?? 0.0;
        double distance = Geolocator.distanceBetween(
            position.latitude, position.longitude, lat, lng);
        if (distance <= 3000) {
          record["distance"] = distance; // 계산된 거리 정보를 추가
          filteredCenters.add(record);
        }
      }

      filteredCenters.sort((a, b) =>
          (a["distance"] as double).compareTo(b["distance"] as double));

      setState(() {
        _markers = markers;
        _filteredCenters = filteredCenters;
      });

      if (_mapController != null) {
        for (var marker in _markers) {
          _mapController!.addOverlay(marker);
        }
      }
    } catch (e) {
      print("JSON 데이터 로드 중 오류 발생 : $e");
    }

  }

  Widget _buildBody(int index) {
    if (index == 0) {
      return
        Column(
          children: [
            SizedBox(
              height: 300,
              width: 400,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent, width: 6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: NaverMap(
                    options: const NaverMapViewOptions(
                      zoomGesturesEnable: true,
                      locationButtonEnable: true,
                      extent: NLatLngBounds(
                        southWest: NLatLng(31.43, 122.37),
                        northEast: NLatLng(44.35, 132.0),
                      ),
                      initialCameraPosition: NCameraPosition(
                        target: NLatLng(37.5665, 126.9780), // 기본 위치 (서울)
                        zoom: 13,
                      ),
                    ),
                    onMapReady: (controller) {
                      _mapController = controller;
                      _loadUserLocationAndMarkers();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 3km 이내 센터들을 스크롤 리스트로 표시 (세로 스크롤)
            Expanded(
              child: _filteredCenters.isEmpty
                  ? const Center(child: Text("내 위치로부터 3km 이내의 센터가 없습니다."))
                  : ListView.builder(
                itemCount: _filteredCenters.length,
                itemBuilder: (context, i) {
                  var record = _filteredCenters[i];
                  double distance = record["distance"] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        border: Border.all(color: Colors.greenAccent, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(record["건강증진센터명"] ?? "알 수 없음"),
                        subtitle: Text("${(distance / 1000).toStringAsFixed(2)} km 이내"),
                        onTap: () {
                          // 리스트 항목 탭 시 해당 센터의 위치로 지도 카메라 이동
                          double lat = double.tryParse(record["위도"].toString()) ?? 0.0;
                          double lng = double.tryParse(record["경도"].toString()) ?? 0.0;
                          String centerName = record["건강증진센터명"] ?? "알 수 없음";
                          String centerWork = record["건강증진업무내용"] ?? "알 수 없음";
                          String phoneNumber = record["운영기관전화번호"] ?? "000-0000-0000";
                          String startTime = record["운영시작시각"] ?? "알 수 없음";
                          String lastTime = record["운영종료시각"] ?? "알 수 없음";

                          if (_mapController != null) {
                            _mapController!.updateCamera(
                              NCameraUpdate.scrollAndZoomTo(
                                  target: NLatLng(lat, lng), // ✅ target 키워드 추가
                                  zoom: 15
                              ),
                            );
                          }
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "센터명: $centerName",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text("업무내용: $centerWork"),
                                    const SizedBox(height: 8),
                                    Text("전화번호: $phoneNumber"),
                                    const SizedBox(height: 8),
                                    Text("운영시간: $startTime ~ $lastTime"),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_images[index].isNotEmpty)
              Image.asset(
                _images[index],
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("도움센터", style: TextStyle(fontSize: 16)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedIndex == index
                            ? const Color(0xFF6BE5A0)
                            : const Color(0xFFBDBDBD),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _tabs[index],
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 50),
          Expanded(child: _buildBody(_selectedIndex)),
        ],
      ),
    );
  }
}
