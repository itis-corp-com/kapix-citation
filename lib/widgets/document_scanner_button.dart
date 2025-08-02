import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/document_scanner_provider.dart';

class DocumentScannerButton extends ConsumerWidget {
  final DocumentType type;
  final VoidCallback? onSuccess;

  const DocumentScannerButton({
    super.key,
    required this.type,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerState = ref.watch(documentScannerProvider);

    return ElevatedButton.icon(
      icon: Icon(_getIcon()),
      label: Text(_getLabel()),
      onPressed: scannerState.status == ScannerStatus.scanning
          ? null
          : () => _handleScan(ref),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case DocumentType.driverLicense:
        return Icons.badge;
      case DocumentType.vehicleRegistration:
        return Icons.directions_car;
    }
  }

  String _getLabel() {
    switch (type) {
      case DocumentType.driverLicense:
        return 'Scan Driver License';
      case DocumentType.vehicleRegistration:
        return 'Scan Registration';
    }
  }

  Future<void> _handleScan(WidgetRef ref) async {
    final scanner = ref.read(documentScannerProvider.notifier);

    switch (type) {
      case DocumentType.driverLicense:
        await scanner.scanDriverLicense();
        break;
      case DocumentType.vehicleRegistration:
        // Handle registration scanning
        break;
    }

    if (ref.read(documentScannerProvider).status == ScannerStatus.success) {
      onSuccess?.call();
    }
  }
}

enum DocumentType {
  driverLicense,
  vehicleRegistration,
}
