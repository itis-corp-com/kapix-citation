import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/citation_machine.dart';

class ProgressNotifier extends StateNotifier<String> {
  final CitationMachine _machine = CitationMachine();
  
  ProgressNotifier() : super('start') {
    _machine.startMachine();
  }

  void updateState(String newState) {
    state = newState;
  }

  String get currentState => state;
  CitationMachine get machine => _machine;
}

final progressProvider = StateNotifierProvider<ProgressNotifier, String>((ref) {
  return ProgressNotifier();
});
