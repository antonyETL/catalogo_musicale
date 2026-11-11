import 'package:flutter/material.dart';

/// Stato vuoto: NON una lista bianca. Dice cosa manca e cosa fare.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icona,
    required this.messaggio,
    this.suggerimento,
    this.azioneLabel,
    this.onAzione,
  });

  final IconData icona;
  final String messaggio;
  final String? suggerimento;
  final String? azioneLabel;
  final VoidCallback? onAzione; // VoidCallback = void Function()

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icona, size: 64, color: tema.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              messaggio,
              style: tema.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (suggerimento != null) ...[
              const SizedBox(height: 8),
              Text(
                suggerimento!,
                style: tema.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (azioneLabel != null && onAzione != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAzione,
                icon: const Icon(Icons.add),
                label: Text(azioneLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
