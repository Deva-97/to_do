import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Task>> taskStream() {
    return _db.collection('tasks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromJson({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  Future<void> addTask(Task task) async {
    await _db.collection('tasks').add(task.toJson());
  }

  Future<void> updateTask(Task task) async {
    await _db.collection('tasks').doc(task.id).update(task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    final taskDoc = _db.collection('tasks').doc(taskId);

    // 1) Load all shares for this task
    final sharesSnap = await taskDoc.collection('shares').get();

    // 2) Batch-delete shares + the task itself
    final batch = _db.batch();
    for (final doc in sharesSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(taskDoc);

    // 3) Commit once
    await batch.commit();
  }


  Future<void> addShareRecord(String taskId, String platform, String to) async {
    await _db.collection('tasks').doc(taskId).collection('shares').add({
      'platform': platform,
      'to': to,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}