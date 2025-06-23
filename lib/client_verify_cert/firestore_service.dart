import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> updateDocumentStatus(String docId, String newStatus) async {
    await _db.collection('truecopies').doc(docId).update({
      'status': newStatus.toLowerCase(),
    });
  }
}
