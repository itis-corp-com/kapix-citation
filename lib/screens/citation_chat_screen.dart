import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../providers/document_scanner_provider.dart';
import '../providers/citation_provider.dart';
import '../providers/pdf_provider.dart';

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
  final _textController = TextEditingController();
  bool _isListening = false;
  bool _showAttachmentMenu = false;

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

  Future<String?> _saveBase64ImageToFile(String base64String) async {
    try {
      final bytes = base64Decode(base64String);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/scanned_document_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  void _sendWelcomeMessage() {
    final welcomeMessage = types.TextMessage(
      author: _assistant,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text:
          'Hello Officer! I\'m here to help you complete a citation. You can:\n'
          '• Scan driver\'s license with BlinkID\n'
          '• Scan vehicle registration documents\n'
          '• Use voice to describe the violation\n'
          '• Type any details\n'
          '• Generate a completed citation PDF\n\n'
          'Let\'s start by scanning the driver\'s license or vehicle registration.',
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
                icon: const Icon(Icons.camera_alt),
                onPressed: () {
                  Navigator.pop(context);
                  _takePicture();
                },
                label: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Take Picture'),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.upload_file),
                onPressed: () {
                  Navigator.pop(context);
                  _uploadFile();
                },
                label: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Upload File'),
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
              TextButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () {
                  Navigator.pop(context);
                  _handlePDFGeneration();
                },
                label: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Generate Citation PDF'),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.analytics),
                onPressed: () {
                  Navigator.pop(context);
                  _handleFormAnalysis();
                },
                label: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Analyze PDF Form (Debug)'),
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

  void _addImageMessage(String imagePath) {
    final imageMessage = types.ImageMessage(
      author: _officer,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      name: 'image',
      size: 0,
      uri: imagePath,
    );
    setState(() {
      _messages.insert(0, imageMessage);
    });
  }

  void _takePicture() async {
    final result = await ImagePicker().pickImage(source: ImageSource.camera);
    if (result != null) {
      _addImageMessage(result.path);
    }
  }

  void _uploadFile() async {
    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result != null) {
      _addImageMessage(result.path);
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

  void _handlePDFGeneration() {
    // Generate the citation PDF
    ref.read(pDFGeneratorProvider.notifier).generateCitationPDF();
  }

  void _handleFormAnalysis() {
    // Analyze the PDF form structure for debugging
    ref.read(pDFGeneratorProvider.notifier).analyzeFormStructure();
  }

  Widget _buildCustomInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Microphone button
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: _handleVoiceInput,
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.red : Colors.grey.shade600,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
            
            // Input field with attachment dropdown
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    // Attachment dropdown button
                    PopupMenuButton<String>(
                      onSelected: _handleAttachmentSelection,
                      offset: const Offset(0, -200),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.grey.shade600, size: 20),
                            const SizedBox(width: 4),
                            Icon(Icons.apps, color: Colors.grey.shade600, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Tools',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'scan_license',
                          child: Row(
                            children: [
                              Icon(Icons.badge, size: 20),
                              SizedBox(width: 12),
                              Text('Scan Driver License'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'scan_registration',
                          child: Row(
                            children: [
                              Icon(Icons.directions_car, size: 20),
                              SizedBox(width: 12),
                              Text('Scan Vehicle Registration'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'photo_gallery',
                          child: Row(
                            children: [
                              Icon(Icons.photo, size: 20),
                              SizedBox(width: 12),
                              Text('Photo Gallery'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'generate_pdf',
                          child: Row(
                            children: [
                              Icon(Icons.picture_as_pdf, size: 20),
                              SizedBox(width: 12),
                              Text('Generate Citation PDF'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'analyze_form',
                          child: Row(
                            children: [
                              Icon(Icons.analytics, size: 20),
                              SizedBox(width: 12),
                              Text('Analyze PDF Form (Debug)'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Text input field
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Ask anything',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        onSubmitted: (text) {
                          if (text.trim().isNotEmpty) {
                            _handleSendPressed(types.PartialText(text: text.trim()));
                            _textController.clear();
                          }
                        },
                      ),
                    ),
                    
                    // Send button
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        onPressed: () {
                          final text = _textController.text.trim();
                          if (text.isNotEmpty) {
                            _handleSendPressed(types.PartialText(text: text));
                            _textController.clear();
                          }
                        },
                        icon: Icon(
                          Icons.send,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAttachmentSelection(String value) {
    switch (value) {
      case 'scan_license':
        ref.read(documentScannerProvider.notifier).scanDriverLicense();
        break;
      case 'scan_registration':
        _handleVehicleRegistrationScan();
        break;
      case 'photo_gallery':
        _handleImageSelection();
        break;
      case 'generate_pdf':
        _handlePDFGeneration();
        break;
      case 'analyze_form':
        _handleFormAnalysis();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to scanner state
    ref.listen<ScannerState>(documentScannerProvider, (previous, next) async {
      if (next.status == ScannerStatus.success && next.message != null) {
        // Add image message if available
        if (next.data != null && next.data!['hasImage'] == true && next.data!['documentImage'] != null) {
          // Determine document type based on data content
          String documentName = 'Document';
          if (next.data!['dlNumber'] != null) {
            documentName = 'Driver License';
          } else if (next.data!['licensePlate'] != null || next.data!['vin'] != null) {
            documentName = 'Vehicle Registration';
          }
          
          // Save base64 image to temporary file
          final imagePath = await _saveBase64ImageToFile(next.data!['documentImage']);
          
          if (imagePath != null) {
            final imageMessage = types.ImageMessage(
              author: _assistant,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: const Uuid().v4(),
              name: documentName,
              size: File(imagePath).lengthSync(),
              uri: imagePath,
            );
            setState(() {
              _messages.insert(0, imageMessage);
            });
          }
        }
        
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

    // Listen to PDF generation state
    ref.listen<PDFState>(pDFGeneratorProvider, (previous, next) {
      if (next.status == PDFStatus.success && next.generatedPDF != null) {
        // Add success message with PDF file
        final response = types.TextMessage(
          author: _assistant,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: '📄 Citation PDF generated successfully!\nFile saved to: ${next.generatedPDF!.path}',
        );
        setState(() {
          _messages.insert(0, response);
        });
      } else if (next.status == PDFStatus.success && next.formFields != null) {
        // Add form analysis results
        final fieldsList = next.formFields!.entries
            .map((e) => '• ${e.key}: ${e.value}')
            .join('\n');
        final response = types.TextMessage(
          author: _assistant,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: '📋 PDF Form Analysis Results:\n\n$fieldsList\n\nTotal fields: ${next.formFields!.length}',
        );
        setState(() {
          _messages.insert(0, response);
        });
      } else if (next.status == PDFStatus.error && next.message != null) {
        _showErrorMessage(next.message!);
      } else if (next.status == PDFStatus.generating) {
        final response = types.TextMessage(
          author: _assistant,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: '⏳ Processing PDF...',
        );
        setState(() {
          _messages.insert(0, response);
        });
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
        theme: const DefaultChatTheme(
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
