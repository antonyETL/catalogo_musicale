import 'package:flutter/material.dart';

import '../../data/repo.dart';
import '../../models/traccia.dart';
import '../../validation/validators.dart';
import '../shared/feedback.dart';

class TracciaFormSheet extends StatefulWidget {
  const TracciaFormSheet({
    super.key,
    required this.idAlbum,
    this.traccia,
    this.numeroSuggerito = 1,
  });

  final int idAlbum;
  final Traccia? traccia;
  final int
  numeroSuggerito; // prossima posizione libera: meno lavoro per l'utente

  @override
  State<TracciaFormSheet> createState() => _TracciaFormSheetState();
}

class _TracciaFormSheetState extends State<TracciaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titoloCtrl;
  late final TextEditingController _numeroCtrl;
  late final TextEditingController _durataCtrl;
  bool _salvataggio = false;

  @override
  void initState() {
    super.initState();
    final t = widget.traccia;
    _titoloCtrl = TextEditingController(text: t?.titolo ?? '');
    _numeroCtrl = TextEditingController(
      text: (t?.numeroTraccia ?? widget.numeroSuggerito).toString(),
    );
    _durataCtrl = TextEditingController(
      text: t?.durataSecondi.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titoloCtrl.dispose();
    _numeroCtrl.dispose();
    _durataCtrl.dispose();
    super.dispose();
  }

  Future<void> _salva() async {
    if (!_formKey.currentState!.validate()) return;

    final traccia = Traccia(
      id: widget.traccia?.id,
      titolo: _titoloCtrl.text.trim(),
      numeroTraccia: int.parse(_numeroCtrl.text.trim()),
      durataSecondi: int.parse(_durataCtrl.text.trim()),
      idAlbum: widget.idAlbum,
    );

    setState(() => _salvataggio = true);
    try {
      if (widget.traccia == null) {
        await Repo.tracce.crea(traccia);
      } else {
        await Repo.tracce.aggiorna(traccia);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvataggio = false);
      mostraSnackBar(context, 'Salvataggio non riuscito: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tastiera = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + tastiera),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.traccia == null ? 'Nuova traccia' : 'Modifica traccia',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titoloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titolo *',
                  helperText: 'Massimo 300 caratteri',
                ),
                validator: validaTitolo,
                maxLines: 2,
                minLines: 1,
              ),
              const SizedBox(height: 12),
              // Row + Expanded: due campi affiancati che si dividono lo spazio.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _numeroCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'N. *',
                        helperText: '1 – 999',
                      ),
                      validator: validaNumeroTraccia,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex:
                        2, // questo campo prende il doppio dello spazio residuo
                    child: TextFormField(
                      controller: _durataCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Durata (secondi) *',
                        helperText: 'Es. 225 per 3:45',
                      ),
                      validator: validaDurataSecondi,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _salvataggio
                          ? null
                          : () => Navigator.pop(context, false),
                      child: const Text('Annulla'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _salvataggio ? null : _salva,
                      child: Text(
                        _salvataggio
                            ? 'Salvataggio…'
                            : (widget.traccia == null ? 'Aggiungi' : 'Salva'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
