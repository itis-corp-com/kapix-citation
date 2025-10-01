// Firebase Realtime Database Configuration
class FirebaseConfig {
  // Database structure paths
  static const String citationsPath = 'citations';
  static const String documentsPath = 'documents';
  static const String progressPath = 'progress';
  static const String usersPath = 'users';

  // Citation workflow states (matching FSM from summary)
  static const List<String> citationSteps = [
    'start',
    'licenseFront',
    'registration', 
    'insurance',
    'contact',
    'review',
    'done'
  ];

  // Document types
  static const Map<String, String> documentTypes = {
    'license_front': 'Driver License (Front)',
    'license_back': 'Driver License (Back)',
    'registration': 'Vehicle Registration',
    'insurance': 'Insurance Card',
    'photo': 'Scene Photo',
  };
}

// AWS S3 Configuration (from summary)
class AWSConfig {
  static const String region = 'us-west-2';
  static const String bucketName = 'itis.kapix-citation';
  
  // These should be loaded from environment or secure storage
  static const String accessKeyId = 'YOUR_ACCESS_KEY_ID';
  static const String secretAccessKey = 'YOUR_SECRET_ACCESS_KEY';
}

// Firebase Realtime Database URL (from summary)
class DatabaseConfig {
  static const String firebaseUrl = 'https://itis-kapix-citation.firebaseio.com';
}
