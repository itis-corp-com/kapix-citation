// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_scanner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$blinkIdServiceHash() => r'dd391d894ab2f8ea83b5d67aa027a7bf0bd68136';

/// See also [blinkIdService].
@ProviderFor(blinkIdService)
final blinkIdServiceProvider = AutoDisposeProvider<BlinkIdService>.internal(
  blinkIdService,
  name: r'blinkIdServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$blinkIdServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BlinkIdServiceRef = AutoDisposeProviderRef<BlinkIdService>;
String _$documentScannerHash() => r'a9935b152a24666f8ef31d013ccaff28ff8f810e';

/// See also [DocumentScanner].
@ProviderFor(DocumentScanner)
final documentScannerProvider =
    AutoDisposeNotifierProvider<DocumentScanner, ScannerState>.internal(
  DocumentScanner.new,
  name: r'documentScannerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$documentScannerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DocumentScanner = AutoDisposeNotifier<ScannerState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
