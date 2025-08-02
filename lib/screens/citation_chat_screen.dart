import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';
import 'package:blinkid_flutter/blinkid_flutter.dart';
import 'dart:io';
import '../config/config.dart';

class CitationChatScreen extends ConsumerStatefulWidget {
  const CitationChatScreen({super.key});

  @override
  ConsumerState<CitationChatScreen> createState() => _CitationChatScreenState();
}

class _CitationChatScreenState extends ConsumerState<CitationChatScreen> {
  final List<types.Message> _messages = [];
  late final types.User _assistant;
  late final types.User _officer;
  final _speechToText = SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _assistant = const types.User(
      id: 'assistant',
      firstName: 'Citation',
      lastName: 'Assistant',
    );
    _officer = const types.User(
      id: 'officer',
      firstName: 'Officer',
    );
    _initializeSpeech();
    _sendWelcomeMessage();
  }

  void _initializeSpeech() async {
    await _speechToText.initialize();
  }

  void _sendWelcomeMessage() {
    final welcomeMessage = types.TextMessage(
      author: _assistant,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text:
          'Hello Officer! I\'m here to help you complete a citation. You can:\n'
          '• Upload photos of driver\'s license or registration\n'
          '• Use voice to describe the violation\n'
          '• Type any details\n\n'
          'Let\'s start by scanning the driver\'s license.',
    );
    setState(() {
      _messages.insert(0, welcomeMessage);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _officer,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });

    // TODO: Process the message with AI
    _processMessage(message.text);
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 192,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleDriverLicenseScan();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Scan Driver License'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo Gallery'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleVoiceInput();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Voice Input'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processMessage(String text) {
    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      final response = types.TextMessage(
        author: _assistant,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: 'I understand. Processing: "$text"',
      );
      setState(() {
        _messages.insert(0, response);
      });
    });
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1440,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final imageMessage = types.ImageMessage(
        author: _officer,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
      );

      setState(() {
        _messages.insert(0, imageMessage);
      });

      // TODO: Process image with OCR
      _processImage(File(result.path));
    }
  }

  void _handleCameraCapture() async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1440,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final imageMessage = types.ImageMessage(
        author: _officer,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        name: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        size: bytes.length,
        uri: result.path,
      );

      setState(() {
        _messages.insert(0, imageMessage);
      });

      // TODO: Process image with OCR
      _processImage(File(result.path));
    }
  }

  void _processImage(File image) {
    // Simulate OCR processing
    Future.delayed(const Duration(seconds: 2), () {
      final response = types.TextMessage(
        author: _assistant,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: 'I\'m analyzing the document...\n\n'
            'Extracted information:\n'
            '• Name: [Processing...]\n'
            '• License #: [Processing...]\n'
            '• Address: [Processing...]',
      );
      setState(() {
        _messages.insert(0, response);
      });
    });
  }

  void _handleDriverLicenseScan() async {
    try {
      var licenseKey = Platform.isIOS
          ? Config.blinkIdLicenseKeyIOS
          : Config.blinkIdLicenseKeyAndroid;

      // Initialize the BlinkID plugin
      final blinkIdPlugin = BlinkidFlutter();

      // Set the BlinkID SDK settings
      final sdkSettings = BlinkIdSdkSettings(licenseKey);
      sdkSettings.downloadResources = true;

      // Create and modify the Session Settings
      final sessionSettings = BlinkIdSessionSettings();
      sessionSettings.scanningMode = ScanningMode.automatic;

      // Create and modify the scanning settings
      final scanningSettings = BlinkIdScanningSettings();
      scanningSettings.anonymizationMode = AnonymizationMode.fullResult;
      scanningSettings.glareDetectionLevel = DetectionLevel.mid;
      scanningSettings.blurDetectionLevel = DetectionLevel.mid;

      // Create and modify the Image settings
      final imageSettings = CroppedImageSettings();
      imageSettings.returnDocumentImage = true;
      imageSettings.returnSignatureImage = false;
      imageSettings.returnFaceImage = false;

      // Place the image settings in the scanning settings
      scanningSettings.croppedImageSettings = imageSettings;

      // Place the Scanning settings in the Session settings
      sessionSettings.scanningSettings = scanningSettings;

      // Create and modify the UI settings
      final uiSettings = BlinkIdUiSettings();
      uiSettings.showHelpButton = true;
      uiSettings.showOnboardingDialog = false;

      // Call the 'performScan' method and handle the results
      await blinkIdPlugin
          .performScan(
        sdkSettings,
        sessionSettings,
        uiSettings,
      )
          .then((result) {
        if (result != null) {
          _processDriverLicenseResult(result);
        }
      }).catchError((scanningError) {
        if (scanningError is PlatformException) {
          final errorMessage = scanningError.message;
          _showErrorMessage('BlinkID scanning error: $errorMessage');
        }
      });
    } catch (e) {
      _showErrorMessage('Failed to scan driver license: $e');
    }
  }

  void _processDriverLicenseResult(BlinkIdScanningResult result) {
    String extractedInfo = 'Driver License Information:\n\n';

    if (result.firstName?.value?.isNotEmpty == true) {
      extractedInfo += '• First Name: ${result.firstName!.value}\n';
    }
    if (result.lastName?.value?.isNotEmpty == true) {
      extractedInfo += '• Last Name: ${result.lastName!.value}\n';
    }
    if (result.fullName?.value?.isNotEmpty == true) {
      extractedInfo += '• Full Name: ${result.fullName!.value}\n';
    }
    if (result.address?.value?.isNotEmpty == true) {
      extractedInfo += '• Address: ${result.address!.value}\n';
    }
    if (result.documentNumber?.value?.isNotEmpty == true) {
      extractedInfo += '• License Number: ${result.documentNumber!.value}\n';
    }
    if (result.dateOfBirth?.date != null) {
      final dob = result.dateOfBirth!.date!;
      extractedInfo += '• Date of Birth: ${dob.day}/${dob.month}/${dob.year}\n';
    }
    if (result.dateOfExpiry?.date != null) {
      final expiry = result.dateOfExpiry!.date!;
      extractedInfo +=
          '• Expiry Date: ${expiry.day}/${expiry.month}/${expiry.year}\n';
    }

    final response = types.TextMessage(
      author: _assistant,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: extractedInfo,
    );

    setState(() {
      _messages.insert(0, response);
    });
  }

  void _showErrorMessage(String message) {
    final errorMessage = types.TextMessage(
      author: _assistant,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: 'Error: $message',
    );

    setState(() {
      _messages.insert(0, errorMessage);
    });
  }

  void _handleVoiceInput() async {
    if (!_isListening) {
      final available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            if (result.finalResult) {
              _handleSendPressed(
                  types.PartialText(text: result.recognizedWords));
              setState(() => _isListening = false);
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KāPix Citation'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              _sendWelcomeMessage();
            },
          ),
        ],
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _officer,
        onAttachmentPressed: _handleAttachmentPressed,
        showUserAvatars: false,
        showUserNames: false,
        theme: DefaultChatTheme(
          backgroundColor: Colors.white,
          primaryColor: const Color(0xFF2196F3),
          secondaryColor: const Color(0xFFF5F5F5),
          inputBackgroundColor: const Color(0xFFF5F5F5),
          messageBorderRadius: 12,
          messageInsetsHorizontal: 16,
          messageInsetsVertical: 12,
          inputTextColor: Colors.black,
          attachmentButtonIcon:
              const Icon(Icons.attach_file, color: Colors.black54),
          sendButtonIcon: const Icon(Icons.send, color: Colors.black54),
          inputTextStyle: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: const Color(0xFF1976D2),
      ),
    );
  }

  @override
  void dispose() {
    _speechToText.cancel();
    super.dispose();
  }
}
