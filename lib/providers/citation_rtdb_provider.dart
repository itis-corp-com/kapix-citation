import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/firebase_service.dart';

class CitationRtdbProvider with ChangeNotifier {
  final String userId;
  final String token;

  final Map<String, Map<String, dynamic>> _citations = {};
  StreamSubscription<DatabaseEvent>? _citationSubscription;

  CitationRtdbProvider(this.userId, this.token) {
    if (userId.isNotEmpty) {
      _startListeningForChanges();
    }
  }

  Map<String, Map<String, dynamic>> get citations => _citations;

  void _startListeningForChanges() {
    _citationSubscription?.cancel();
    
    _citationSubscription = FirebaseService.citationsRef(userId)
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      
      if (data is Map) {
        _citations.clear();
        data.forEach((key, value) {
          if (value is Map) {
            _citations[key.toString()] = Map<String, dynamic>.from(value);
          }
        });
      } else {
        _citations.clear();
      }
      
      notifyListeners();
    });
  }

  Future<String> createCitation({
    required String type,
    required Map<String, dynamic> initialData,
  }) async {
    if (userId.isEmpty) throw Exception('User ID is empty');

    final citationRef = FirebaseService.citationsRef(userId).push();
    final citationId = citationRef.key!;

    final citationData = {
      'id': citationId,
      'type': type,
      'status': 'start',
      'createdAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
      'userId': userId,
      ...initialData,
    };

    await citationRef.set(citationData);
    return citationId;
  }

  Future<void> updateCitationStatus(String citationId, String status) async {
    await FirebaseService.citationRef(userId, citationId).update({
      'status': status,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> addDocument(
    String citationId,
    String documentType,
    Map<String, dynamic> documentData,
  ) async {
    final docRef = FirebaseService.documentsRef(userId, citationId).push();
    
    await docRef.set({
      'type': documentType,
      'data': documentData,
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> updateProgress(
    String citationId,
    String currentStep,
    Map<String, dynamic> progressData,
  ) async {
    await FirebaseService.progressRef(userId, citationId).set({
      'currentStep': currentStep,
      'steps': progressData,
      'updatedAt': ServerValue.timestamp,
    });
  }

  @override
  void dispose() {
    _citationSubscription?.cancel();
    super.dispose();
  }
}
