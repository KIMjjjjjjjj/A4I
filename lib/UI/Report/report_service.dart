import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'report_model.dart';

class ReportService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<Set<DateTime>> getAvailableReportDates() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {};

    final snapshot = await _firestore
        .collection('register')
        .doc(uid)
        .collection('report')
        .get();

    final dates = snapshot.docs.map((doc) {
      final parts = doc.id.split('-'); // "yyyy-MM-dd" 형태의 문서 ID
      if (parts.length == 3) {
        final year = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final day = int.tryParse(parts[2]);
        if (year != null && month != null && day != null) {
          return DateTime(year, month, day);
        }
      }
      return null;
    }).whereType<DateTime>().toSet();

    return dates;
  }

  Future<Report?> fetchReport(DateTime date) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final docId = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final doc = await _firestore
        .collection('register')
        .doc(uid)
        .collection('report')
        .doc(docId)
        .get();

    if (!doc.exists) return null;

    return Report.fromMap(doc.data()!);
  }

  // 대화 종료 후에 보고서 저장하는 메서드를 호출하는 것이 바람직함
  // 저장된 '사건'들을 통해 감정, 토픽, 키워드 수집
  // 감정 -> 프롬프트에서 긍정적, 부정적, 분노, 불안, 기타로 분류해서 저장
  // 토픽 -> 최빈값 상위 3개 저장 "취업", "연애", "친구" 등 (보통 겹칠 확률 높음)
  // 키워드 ->
  Future<void> saveReport(DateTime date, Report report) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docId = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    await _firestore
        .collection('register')
        .doc(uid)
        .collection('report')
        .doc(docId)
        .set(report.toMap());
  }
}
