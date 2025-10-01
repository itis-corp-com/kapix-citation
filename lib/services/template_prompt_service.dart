import '../state/citation_state.dart';

/// Represents a chat prompt returned to the UI. The [ui] string
/// contains the assistant's message while [actions] enumerates
/// the quick reply buttons that should be offered to the user.
class NextUi {
  final String ui;
  final List<String> actions;
  const NextUi({required this.ui, required this.actions});
}

/// A simple templated prompt service used to drive the chat UI.
/// Rather than relying on an on‑device language model, this
/// service selects a canned response based on the current state
/// of the citation flow and the extracted data captured so far.
/// The returned [NextUi] includes a message and a list of
/// actions. When the user taps a quick reply button, your UI
/// should call the corresponding transition in [CitationMachine].
class TemplatePromptService {
  /// Generate the next prompt for the given [stateName]. The
  /// [citationState] is used to populate placeholders in the
  /// message and to decide which actions should be presented.
  NextUi getPrompt({required String stateName, required CitationState citationState}) {
    switch (stateName) {
      case 'start':
        return const NextUi(
          ui: 'Hello Officer! I\'m here to help you complete a citation. When you\'re ready we\'ll start with the driver\'s license.',
          actions: ['Start'],
        );
      case 'licenseFront':
        return const NextUi(
          ui: 'Please scan the front of the driver\'s license. I\'ll extract the name, DOB and license number.',
          actions: ['ScanDL'],
        );
      case 'licenseBack':
        return const NextUi(
          ui: 'I need to scan the back of the driver\'s license to read the barcode. Please flip the card and scan again.',
          actions: ['ScanDLBack'],
        );
      case 'registration':
        return const NextUi(
          ui: 'Now let\'s capture the vehicle registration. Hold it steady and scan the document.',
          actions: ['ScanRegistration'],
        );
      case 'maybeVin':
        return const NextUi(
          ui: 'The registration doesn\'t include a clear VIN. Would you like to capture the VIN from the vehicle\'s door jamb?',
          actions: ['CaptureVIN', 'SkipVIN'],
        );
      case 'vin':
        return const NextUi(
          ui: 'Please take a close photo of the VIN label (usually on the driver\'s door jamb).',
          actions: ['ScanVIN'],
        );
      case 'insurance':
        return const NextUi(
          ui: 'Next up is the insurance card. Scan the card from paper or the driver\'s phone screen.',
          actions: ['ScanInsurance'],
        );
      case 'contact':
        {
          // Prefer to use extracted contact if available; otherwise ask.
          final hasPhone = citationState.phone.isNotEmpty;
          final hasEmail = citationState.email.isNotEmpty;
          if (hasPhone || hasEmail) {
            final contact = hasPhone ? citationState.phone.value : citationState.email.value;
            return NextUi(
              ui: 'I found the contact ${contact}. Use this or provide a different one if needed.',
              actions: ['UseContact', 'VoiceInput'],
            );
          }
          return const NextUi(
            ui: 'Please provide a contact phone number or email. You can speak it aloud for voice dictation.',
            actions: ['VoiceInput', 'SkipContact'],
          );
        }
      case 'review':
        {
          // Build a summary of the captured fields for the review message.
          final buffer = StringBuffer('Here\'s what I have:\n\n');
          if (citationState.firstName.value.isNotEmpty || citationState.lastName.value.isNotEmpty) {
            buffer.writeln('• Name: ${citationState.firstName.value} ${citationState.lastName.value}');
          }
          if (citationState.dlNumber.value.isNotEmpty) {
            buffer.writeln('• DL#: ${citationState.dlNumber.value} (${citationState.dlState.value})');
          }
          if (citationState.plate.value.isNotEmpty) {
            buffer.writeln('• Plate: ${citationState.plate.value} (${citationState.plateState.value})');
          }
          final vin = citationState.registrationVin.value.isNotEmpty
              ? citationState.registrationVin.value
              : citationState.vin.value;
          if (vin.isNotEmpty) {
            buffer.writeln('• VIN: ${vin}');
          }
          if (citationState.insurer.value.isNotEmpty) {
            buffer.writeln('• Insurer: ${citationState.insurer.value}');
          }
          if (citationState.policy.value.isNotEmpty) {
            buffer.writeln('• Policy#: ${citationState.policy.value}');
          }
          if (citationState.phone.value.isNotEmpty) {
            buffer.writeln('• Phone: ${citationState.phone.value}');
          }
          if (citationState.email.value.isNotEmpty) {
            buffer.writeln('• Email: ${citationState.email.value}');
          }
          buffer.writeln('\nIf everything looks good, submit the citation or go back to fix a section.');
          return NextUi(
            ui: buffer.toString(),
            actions: ['Submit', 'FixLicense', 'FixRegistration', 'FixVIN', 'FixInsurance', 'FixContact'],
          );
        }
      case 'done':
        return const NextUi(
          ui: 'Citation completed! A PDF has been generated and stored locally.',
          actions: [],
        );
      default:
        return const NextUi(
          ui: 'Unknown state. Please restart.',
          actions: [],
        );
    }
  }
}