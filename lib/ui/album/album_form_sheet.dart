import 'package:flutter/material.dart';

import '../../data/repo.dart';
import '../../models/album.dart';
import '../../models/artista.dart';
import '../../utils/formattazioni.dart';
import '../../validation/validators.dart';
import '../shared/feedback.dart';

class AlbumFormSheet extends StatefulWidget {
  const AlbumFormSheet({super.key, this.album, required this.artisti});

  final Album? album;
  final List<Artista> artisti;

  @override
  State<AlbumFormSheet> createState() => _AlbumFormSheetState();
}

class _AlbumFormSheetState extends State<AlbumFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titoloCtrl;
  late final TextEditingController _genereCtrl;
  late final TextEditingController _dataCtrl;

  DateTime? _dataUscita; // il valore "vero" che mandiamo al backend
  int? _idArtista;
  bool _salvataggio = false;

  @override
  void initState() {
    super.initState();
    final a = widget.album;
    _titoloCtrl = TextEditingController(text: a?.titolo ?? '');
    _genereCtrl = TextEditingController(text: a?.genere ?? '');
    _dataUscita = a?.dataUscita;
    _dataCtrl = TextEditingController(
      text: _dataUscita == null ? '' : ggMmAaaa(_dataUscita!),
    );
    _idArtista = a?.idArtista;
  }

  @override
  void dispose() {
    _titoloCtrl.dispose();
    _genereCtrl.dispose();
    _dataCtrl.dispose();
    super.dispose();
  }

  /// Il campo data è di SOLA LETTURA: si compila con showDatePicker.
  /// Vantaggio: l'utente non può scrivere una data non valida.
  Future<void> _scegliData() async {
    final oggi = DateTime.now();
    final scelta = await showDatePicker(
      context: context,
      initialDate: _dataUscita ?? DateTime(oggi.year - 20),
      firstDate: DateTime(1900),
      lastDate: DateTime(oggi.year + 1), // un album può essere annunciato
      helpText: 'Data di uscita',
    );
    if (scelta == null) return; // l'utente ha annullato
    setState(() {
      _dataUscita = scelta;
      _dataCtrl.text = ggMmAaaa(scelta);
    });
  }

  Future<void> _salva() async {
    if (!_formKey.currentState!.validate()) return;

    final album = Album(
      id: widget.album?.id,
      titolo: _titoloCtrl.text.trim(),
      genere: _genereCtrl.text.trim(),
      dataUscita:
          _dataUscita!, // `!` giustificato: il validator ha già controllato
      idArtista: _idArtista!, // idem
    );

    setState(() => _salvataggio = true);
    try {
      if (widget.album == null) {
        await Repo.album.crea(album);
      } else {
        await Repo.album.aggiorna(album);
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
                widget.album == null ? 'Nuovo album' : 'Modifica album',
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
              TextFormField(
                controller: _genereCtrl,
                decoration: const InputDecoration(
                  labelText: 'Genere',
                  helperText: 'Massimo 100 caratteri',
                ),
                validator: validaGenere,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dataCtrl,
                readOnly: true, // niente tastiera
                onTap: _scegliData, // si apre il calendario
                decoration: const InputDecoration(
                  labelText: 'Data di uscita *',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: validaDataUscita,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _idArtista,
                isExpanded: true, // evita overflow con nomi di artisti lunghi
                decoration: const InputDecoration(labelText: 'Artista *'),
                items: widget.artisti
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(a.nome, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _idArtista = v),
                validator: validaArtistaSelezionato,
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
                            : (widget.album == null ? 'Aggiungi' : 'Salva'),
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
