import 'package:flutter/material.dart';

/// Overlay loading dengan animasi AI "sedang menganalisis" (PRD §4.1).
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.message = 'AI sedang menganalisis…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
