import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> updateCertificateStatus(String docId, String status) async {
    await _db.collection('truecopies').doc(docId).update({
      'status': status.toLowerCase(),
    });
  }
}
