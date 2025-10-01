import 'package:flutter/material.dart';

class CitationProgress extends StatelessWidget {
  final String currentState;
  
  const CitationProgress({super.key, required this.currentState});

  static const _steps = [
    'start',
    'licenseFront', 
    'registration',
    'insurance',
    'contact',
    'review',
    'done'
  ];

  static const _stepLabels = {
    'start': 'Getting Started',
    'licenseFront': 'Driver License',
    'licenseBack': 'License Back',
    'registration': 'Registration',
    'maybeVin': 'VIN Check',
    'vin': 'VIN Capture',
    'insurance': 'Insurance',
    'contact': 'Contact Info',
    'review': 'Review',
    'done': 'Complete'
  };

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getProgressIndex(currentState);
    final progress = currentIndex >= 0 ? currentIndex / (_steps.length - 1) : 0.0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_stepLabels[currentState] ?? currentState} (${currentIndex + 1}/${_steps.length})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  int _getProgressIndex(String state) {
    // Map all states to main progress steps
    switch (state) {
      case 'start': return 0;
      case 'licenseFront':
      case 'licenseBack': return 1;
      case 'registration':
      case 'maybeVin':
      case 'vin': return 2;
      case 'insurance': return 3;
      case 'contact': return 4;
      case 'review': return 5;
      case 'done': return 6;
      default: return 0;
    }
  }
}
