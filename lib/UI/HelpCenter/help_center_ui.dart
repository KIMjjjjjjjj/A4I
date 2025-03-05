import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../services/naver_api_service.dart';

class HelpCenterPage extends StatefulWidget {
  @override
  _HelpCenterPageState createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  NaverMapController? _mapController;
  List<NMarker> _markers = [];
  int _selectedIndex = 0;

  final List<String> _tabs = ["내 주변 센터 찾기", "긴급전화", "자살 위험 신호", "자살 예방 도움 수칙"];
  final List<String> _images = [
    "",
    "assets/images/HelpCenter/emergency_number.png",
    "assets/images/HelpCenter/danger_sign.png",
    "assets/images/HelpCenter/suicide_prevention.png"
  ];

  @override
  void initState() {
    super.initState();
    _loadUserLocationAndMarkers();
  }

  /// 현재 위치 가져오고 상담 센터 마커 추가
  Future<void> _loadUserLocationAndMarkers() async {
    Position? position = await LocationService.getCurrentLocation();
    if (position == null) return;

    List<Map<String, dynamic>> centers =
    await NaverApiService.fetchCounselingCenters(position.latitude, position.longitude);

    List<NMarker> markers = centers.map((center) {
      return NMarker(
        id: center["name"],
        position: NLatLng(center["lat"], center["lng"]),
        caption: NOverlayCaption(text: center["name"]),
      )..setOnTapListener((overlay) {
        debugPrint("${center["name"]} 클릭됨");
      });
    }).toList();

    setState(() {
      _markers = markers;
    });

    if (_mapController != null) {
      _mapController!.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(position.latitude, position.longitude), // ✅ target 키워드 추가
          zoom: 13,
        ),
      );

      for (var marker in _markers) {
        _mapController!.addOverlay(marker);
      }
    }
  }

  Widget _buildBody(int index) {
    if (index == 0) {
      return NaverMap(
        options: const NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(37.5665, 126.9780), // 기본 위치 (서울)
            zoom: 13,
          ),
        ),
        onMapReady: (controller) {
          _mapController = controller;
          _loadUserLocationAndMarkers();
        },
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
                        color: _selectedIndex == index ? const Color(0xFF6BE5A0) : const Color(0xFFBDBDBD),
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
          Expanded(
            child: _buildBody(_selectedIndex),
          ),
        ],
      ),
    );
  }
}
