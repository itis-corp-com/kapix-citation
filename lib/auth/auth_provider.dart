import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  DateTime? _expiryDate;
  Timer? _authTimer;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const Duration tokenExpiryDuration = Duration(hours: 1);

  bool get isAuthenticated {
    return token != null;
  }

  String? get userId {
    return _userId ?? _auth.currentUser?.uid;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _initializeUserData(userCredential.user);
    } on FirebaseAuthException catch (error) {
      _handleAuthError(error, defaultMessage: "Sign in failed");
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      _initializeUserData(userCredential.user);
    } on FirebaseAuthException catch (error) {
      _handleAuthError(error, defaultMessage: "Sign up failed");
    }
  }

  void _initializeUserData(User? user) async {
    if (user != null) {
      _userId = user.uid;
      _token = await user.getIdToken();
      _expiryDate = DateTime.now().add(tokenExpiryDuration);
      _startAutoLogoutTimer();
      _storeUserDataInPreferences();
      notifyListeners();
    } else {
      throw Exception("User data initialization failed");
    }
  }

  Future<void> _storeUserDataInPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = jsonEncode({
      "token": _token,
      "userId": _userId,
      "expiryDate": _expiryDate?.toIso8601String(),
    });
    prefs.setString("userData", userData);
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userData")) {
      return false;
    }

    final userData =
        jsonDecode(prefs.getString("userData")!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData["expiryDate"] as String);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = userData["token"];
    _userId = userData["userId"];
    _expiryDate = expiryDate;

    _startAutoLogoutTimer();
    notifyListeners();
    return true;
  }

  void logout() async {
    _clearAuthData();
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("userData");
    notifyListeners();
  }

  void _clearAuthData() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
  }

  void _startAutoLogoutTimer() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }

    final timeToExpiry = _expiryDate?.difference(DateTime.now()).inSeconds;
    if (timeToExpiry != null && timeToExpiry > 0) {
      _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
    }
  }

  void _handleAuthError(FirebaseAuthException error,
      {required String defaultMessage}) {
    var errorMessage = defaultMessage;
    if (error.code == 'user-not-found') {
      errorMessage = 'No user found with this email.';
    } else if (error.code == 'wrong-password') {
      errorMessage = 'Invalid password. Please try again.';
    } else if (error.code == 'email-already-in-use') {
      errorMessage = 'This email is already registered. Please log in instead.';
    } else if (error.code == 'weak-password') {
      errorMessage = 'The password provided is too weak.';
    }

    throw Exception(errorMessage);
  }
}
