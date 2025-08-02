import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../providers/document_scanner_provider.dart';
import '../providers/citation_provider.dart';

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
          height: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton.icon(
                icon: const Icon(Icons.badge),
                onPressed: () {
                  Navigator.pop(context);
                  ref
                      .read(documentScannerProvider.notifier)
                      .scanDriverLicense();
                },
                label: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Scan Driver License'),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.directions_car),
                onPressed: () {
                  Navigator.pop(context);
                  _handleVehicleRegistrationScan();
                },
                label: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Scan Vehicle Registration'),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.photo),
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                label: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo Gallery'),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.mic),
                onPressed: () {
                  Navigator.pop(context);
                  _handleVoiceInput();
                },
                label: const Align(
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

      // Process image with OCR
      _processImage(File(result.path));
    }
  }

  void _handleVehicleRegistrationScan() async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      maxWidth: 2048,
    );

    if (result != null) {
      ref
          .read(documentScannerProvider.notifier)
          .scanVehicleRegistration(File(result.path));
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
    // Listen to scanner state
    ref.listen<ScannerState>(documentScannerProvider, (previous, next) {
      if (next.status == ScannerStatus.success && next.message != null) {
        // Add success message to chat
        final response = types.TextMessage(
          author: _assistant,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: next.message!,
        );
        setState(() {
          _messages.insert(0, response);
        });
      } else if (next.status == ScannerStatus.error && next.message != null) {
        // Add error message to chat
        _showErrorMessage(next.message!);
      }
    });

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
              ref.read(documentScannerProvider.notifier).reset();
              ref.read(currentCitationProvider.notifier).reset();
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
      floatingActionButton: _isListening
          ? FloatingActionButton(
              onPressed: () {
                setState(() => _isListening = false);
                _speechToText.stop();
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.mic_off),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _speechToText.cancel();
    super.dispose();
  }
}
