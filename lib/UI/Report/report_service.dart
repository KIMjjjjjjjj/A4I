import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'report_model.dart';

class ReportService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;


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
  // 감정 -> '불안' -> '걱정', '좌절' -> '슬픔' 감정을 일반화 한 뒤 상위 4~5개 (감정, 비율), 나머지 (기타, 비율) 로 저장

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


