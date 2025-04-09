import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportDateService {
  // 보고서가 존재하는 날짜만 선택할 수 있도록
  Future<Set<DateTime>> fetchAvailableReportDates() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return {};

      final snapshot = await FirebaseFirestore.instance
          .collection("register")
          .doc(user.uid)
          .collection("report")
          .get();

      return snapshot.docs.map((doc) {
        final dateParts = doc.id.split("-");
        return DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );
      }).toSet();
    } catch (e) {
      print("보고서 날짜 불러오기 실패: $e");
      return {};
    }
  }
}
