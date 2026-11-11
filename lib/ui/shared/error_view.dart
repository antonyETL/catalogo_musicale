import 'package:flutter/material.dart';

/// Stato di errore con possibilità di riprovare: l'errore non è un vicolo cieco.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.messaggio, this.onRiprova});

  final String messaggio;
  final VoidCallback? onRiprova;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(messaggio, textAlign: TextAlign.center),
            if (onRiprova != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRiprova,
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
