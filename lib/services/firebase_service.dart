import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  // Initialize RTDB with offline persistence
  static Future<void> initialize() async {
    _database.setPersistenceEnabled(true);
    _database.setPersistenceCacheSizeBytes(10000000); // 10MB cache
  }

  // Get database reference
  static DatabaseReference get database => _database.ref();

  // Citation-specific references
  static DatabaseReference citationsRef(String userId) =>
      _database.ref().child('citations').child(userId);

  static DatabaseReference citationRef(String userId, String citationId) =>
      citationsRef(userId).child(citationId);

  static DatabaseReference documentsRef(String userId, String citationId) =>
      citationRef(userId, citationId).child('documents');

  static DatabaseReference progressRef(String userId, String citationId) =>
      citationRef(userId, citationId).child('progress');
}
