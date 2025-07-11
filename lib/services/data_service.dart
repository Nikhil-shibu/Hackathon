import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  Future<void> recordTaskCompletion(String userId, String taskName, DateTime completionTime) async {
    final taskRecord = {
      'userId': userId,
      'taskName': taskName,
      'completionTime': completionTime.toUtc().toIso8601String(),
      'recordId': _uuid.v4(),
    };

    await _firestore.collection('task_completions').add(taskRecord);
  }

  Future<void> recordMedicationTaken(String userId, String medicationName, DateTime takenTime) async {
    final medRecord = {
      'userId': userId,
      'medicationName': medicationName,
      'takenTime': takenTime.toUtc().toIso8601String(),
      'recordId': _uuid.v4(),
    };

    await _firestore.collection('medication_taken').add(medRecord);
  }
}
