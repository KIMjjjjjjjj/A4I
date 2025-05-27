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
        .collection('diary')
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
        .collection('diary')
        .doc(uid)
        .collection('report')
        .doc(docId)
        .get();
    if (!doc.exists) return null;

    return Report.fromMap(date, doc.data()!);
  }


  Future<void> saveReport(DateTime date, Report report) async {
    print("saveReport");
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final docId = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    await _firestore
        .collection('diary')
        .doc(uid)
        .collection('report')
        .doc(docId)
        .set(report.toMap());
  }

  // 기간별 분석 데이터 조회
  Future<List<Report>?> loadReports(DateTime startDate, DateTime endDate) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final query = await _firestore
        .collection('diary')
        .doc(uid)
        .collection('report')
        .get();

    final filteredDocs = query.docs.where((doc) {
      final docDate = DateTime.tryParse(doc.id);
      if (docDate == null) return false;
      return docDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          docDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    return filteredDocs.map((doc) => Report.fromMap(DateTime.parse(doc.id), doc.data())).toList();
  }

}


