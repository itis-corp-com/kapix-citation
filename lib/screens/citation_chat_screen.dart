import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
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
import '../providers/progress_provider.dart';
import '../widgets/citation_progress.dart';
import '../auth/auth_provider.dart';

class CitationChatScreen extends ConsumerStatefulWidget {
  const CitationChatScreen({super.key});

  @override
  ConsumerState<CitationChatScreen> createState() => _CitationChatScreenState();
}

// Enum for document types
enum DocumentType {
  driverLicense,
  vehicleRegistration,
  insuranceCard,
  photo,
}

// Model for scanned document
class ScannedDocument {
  final DocumentType type;
  final String? imagePath;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  ScannedDocument({
    required this.type,
    this.imagePath,
    this.data,
    required this.timestamp,
  });
}

class _CitationChatScreenState extends ConsumerState<CitationChatScreen> {
  final List<types.Message> _messages = [];
  late final types.User _assistant;
  late final types.User _officer;
  final _speechToText = SpeechToText();
  final _textController = TextEditingController();
  bool _isListening = false;
  final List<ScannedDocument> _scannedDocuments = [];

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
      final file = File(
          '${tempDir.path}/scanned_document_${DateTime.now().millisecondsSinceEpoch}.jpg');
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
          'Hello Officer! I\'m here to help you complete a citation.\n\n'
          'MOCK MODE: Take any photo to advance through the citation steps:\n'
          '1. Driver License\n'
          '2. Vehicle Registration\n'
          '3. Insurance Card\n'
          '4. Contact Info\n'
          '5. Review & Submit\n\n'
          'Tap the attachment button and take a picture to start!',
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
      // Add to scanned documents as a photo
      _scannedDocuments.add(ScannedDocument(
        type: DocumentType.photo,
        imagePath: imagePath,
        timestamp: DateTime.now(),
      ));
    });
    
    // Mock: Advance the citation flow
    _advanceMockFlow();
  }

  void _advanceMockFlow() {
    final currentState = ref.read(progressProvider);
    String nextState;
    String mockResponse;
    
    switch (currentState) {
      case 'start':
        nextState = 'licenseFront';
        mockResponse = 'Great! I can see the driver\'s license. Extracting information...';
        break;
      case 'licenseFront':
        nextState = 'registration';
        mockResponse = 'License processed! Now let\'s scan the vehicle registration.';
        break;
      case 'registration':
        nextState = 'insurance';
        mockResponse = 'Registration captured! Please scan the insurance card.';
        break;
      case 'insurance':
        nextState = 'contact';
        mockResponse = 'Insurance verified! Please provide contact information.';
        break;
      case 'contact':
        nextState = 'review';
        mockResponse = 'Contact saved! Ready to review the citation details.';
        break;
      case 'review':
        nextState = 'done';
        mockResponse = 'Citation completed! PDF has been generated.';
        break;
      default:
        nextState = currentState;
        mockResponse = 'Processing...';
    }
    
    // Update progress
    ref.read(progressProvider.notifier).updateState(nextState);
    
    // Add assistant response
    Future.delayed(const Duration(milliseconds: 500), () {
      final response = types.TextMessage(
        author: _assistant,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: mockResponse,
      );
      setState(() {
        _messages.insert(0, response);
      });
    });
  }

  void _takePicture() async {
    final result = await ImagePicker().pickImage(source: ImageSource.camera);
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
    ref.read(pDFGeneratorProvider.notifier).generateCitationPDF();
  }

  void _handleFormAnalysis() {
    ref.read(pDFGeneratorProvider.notifier).analyzeFormStructure();
  }

  // Show document viewer dialog
  void _showDocumentViewer(ScannedDocument doc) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getDocumentIcon(doc.type),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getDocumentTitle(doc.type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Image
              if (doc.imagePath != null)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(doc.imagePath!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              // Data (if available)
              if (doc.data != null && doc.data!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Extracted Information:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...doc.data!.entries
                          .where((e) =>
                              e.value != null &&
                              e.key != 'documentImage' &&
                              e.key != 'hasImage')
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '${_formatKey(e.key)}: ${e.value}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatKey(String key) {
    // Convert camelCase to Title Case
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.driverLicense:
        return Icons.badge;
      case DocumentType.vehicleRegistration:
        return Icons.directions_car;
      case DocumentType.insuranceCard:
        return Icons.health_and_safety;
      case DocumentType.photo:
        return Icons.photo;
    }
  }

  String _getDocumentTitle(DocumentType type) {
    switch (type) {
      case DocumentType.driverLicense:
        return 'Driver License';
      case DocumentType.vehicleRegistration:
        return 'Vehicle Registration';
      case DocumentType.insuranceCard:
        return 'Insurance Card';
      case DocumentType.photo:
        return 'Photo';
    }
  }

  Color _getDocumentColor(DocumentType type) {
    switch (type) {
      case DocumentType.driverLicense:
        return Colors.blue.shade700;
      case DocumentType.vehicleRegistration:
        return Colors.green.shade700;
      case DocumentType.insuranceCard:
        return Colors.orange.shade700;
      case DocumentType.photo:
        return Colors.purple.shade700;
    }
  }

  // Build document tracker bar
  Widget _buildDocumentTrackerBar() {
    if (_scannedDocuments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.article,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            'Documents:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _scannedDocuments.map((doc) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => _showDocumentViewer(doc),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getDocumentColor(doc.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getDocumentColor(doc.type).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getDocumentIcon(doc.type),
                              size: 20,
                              color: _getDocumentColor(doc.type),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getDocumentTitle(doc.type),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _getDocumentColor(doc.type),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Paperclip/Attachment button
            IconButton(
              onPressed: _handleAttachmentPressed,
              icon: Icon(
                Icons.attach_file,
                color: Colors.grey.shade700,
                size: 24,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
            ),

            const SizedBox(width: 4),

            // Camera button
            IconButton(
              onPressed: _takePicture,
              icon: Icon(
                Icons.camera_alt,
                color: Colors.grey.shade700,
                size: 22,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
            ),

            const SizedBox(width: 8),

            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                        onSubmitted: (text) {
                          if (text.trim().isNotEmpty) {
                            _handleSendPressed(
                                types.PartialText(text: text.trim()));
                            _textController.clear();
                          }
                        },
                      ),
                    ),

                    // Microphone button
                    IconButton(
                      onPressed: _handleVoiceInput,
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.red : Colors.grey.shade600,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            IconButton(
              onPressed: () {
                final text = _textController.text.trim();
                if (text.isNotEmpty) {
                  _handleSendPressed(types.PartialText(text: text));
                  _textController.clear();
                }
              },
              icon: Icon(
                Icons.send,
                color: Colors.blue.shade600,
                size: 24,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to scanner state
    ref.listen<ScannerState>(documentScannerProvider, (previous, next) async {
      if (next.status == ScannerStatus.success && next.message != null) {
        if (next.data != null &&
            next.data!['hasImage'] == true &&
            next.data!['documentImage'] != null) {
          String documentName = 'Document';
          DocumentType docType = DocumentType.photo;

          if (next.data!['dlNumber'] != null) {
            documentName = 'Driver License';
            docType = DocumentType.driverLicense;
          } else if (next.data!['licensePlate'] != null ||
              next.data!['vin'] != null) {
            documentName = 'Vehicle Registration';
            docType = DocumentType.vehicleRegistration;
          }

          final imagePath =
              await _saveBase64ImageToFile(next.data!['documentImage']);

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
              // Add to scanned documents
              _scannedDocuments.add(ScannedDocument(
                type: docType,
                imagePath: imagePath,
                data: next.data,
                timestamp: DateTime.now(),
              ));
            });
          }
        }

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
        _showErrorMessage(next.message!);
      }
    });

    // Listen to PDF generation state
    ref.listen<PDFState>(pDFGeneratorProvider, (previous, next) {
      if (next.status == PDFStatus.success && next.generatedPDF != null) {
        final response = types.TextMessage(
          author: _assistant,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text:
              '📄 Citation PDF generated successfully!\nFile saved to: ${next.generatedPDF!.path}',
        );
        setState(() {
          _messages.insert(0, response);
        });
      } else if (next.status == PDFStatus.success && next.formFields != null) {
        final fieldsList = next.formFields!.entries
            .map((e) => '• ${e.key}: ${e.value}')
            .join('\n');
        final response = types.TextMessage(
          author: _assistant,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text:
              '📋 PDF Form Analysis Results:\n\n$fieldsList\n\nTotal fields: ${next.formFields!.length}',
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
                _scannedDocuments.clear();
              });
              _sendWelcomeMessage();
              ref.read(documentScannerProvider.notifier).reset();
              ref.read(currentCitationProvider.notifier).reset();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              provider.Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Document tracker bar
          _buildDocumentTrackerBar(),
          
          // Progress indicator
          Consumer(
            builder: (context, ref, child) {
              final currentState = ref.watch(progressProvider);
              return CitationProgress(currentState: currentState);
            },
          ),

          // Chat area
          Expanded(
            child: Chat(
              messages: _messages,
              onSendPressed: _handleSendPressed,
              user: _officer,
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
              ),
              customBottomWidget: _buildCustomInputArea(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _textController.dispose();
    super.dispose();
  }
}
