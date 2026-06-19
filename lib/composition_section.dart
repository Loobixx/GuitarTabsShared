import 'package:flutter/material.dart';
import 'package:guitar_shared_tabs/song.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompositionSection extends StatefulWidget {
  final Song? songToEdit;
  
const CompositionSection({super.key, this.songToEdit});

  @override
  State<CompositionSection> createState() => _CompositionSectionState();
}

class _CompositionSectionState extends State<CompositionSection> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _artistController = TextEditingController(); 
  final _composerController = TextEditingController();
  final _addedByController = TextEditingController();
  final _bpmController = TextEditingController();
  final _rhythmController = TextEditingController();
  final _lyricsController = TextEditingController();

  String? _selectedChord; 
  List<String> availableChords = ["C", "G", "Em", "D", "Am", "F", "Bm"];

  @override
  void initState() {
    super.initState();
    if (widget.songToEdit != null) {
      final s = widget.songToEdit!;
      _titleController.text = s.title;
      _artistController.text = s.artist;
      _composerController.text = s.composer;
      _addedByController.text = s.addedBy;
      _bpmController.text = s.bpm.toString();
      _rhythmController.text = s.rhythm;
      _lyricsController.text = s.lyrics.join('\n');
    }
  }

  void _insertChordInLyrics() {
    if (_selectedChord == null) return;
    
    final text = _lyricsController.text;
    final selection = _lyricsController.selection;
    
    final int insertPosition = selection.isValid ? selection.start : text.length;
    
    final newText = text.replaceRange(
      insertPosition, 
      selection.isValid ? selection.end : text.length, 
      "[$_selectedChord]"
    );
    _lyricsController.text = newText;
    
    _lyricsController.selection = TextSelection.collapsed(offset: insertPosition + _selectedChord!.length + 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 👈 AJOUTE CETTE LIGNE ICI !
      appBar: widget.songToEdit != null 
        ? AppBar(
            title: const Text("Modifier la tablature", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blueGrey[900],
            iconTheme: const IconThemeData(color: Colors.white),
          ) 
        : null,
      body: Center( // 🛠️ On centre le tout
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // 🛠️ Largeur max bloquée comme pour les cartes !
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 100),
              children: [
                Text(
                  widget.songToEdit == null ? "Créer une nouvelle Tablature" : "Modifier les détails", 
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])
                ),
                const SizedBox(height: 24),
                
                // --- BLOC INFOS ---
                TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: "Titre de la chanson *", prefixIcon: Icon(Icons.music_note))),
                const SizedBox(height: 16),
                TextFormField(controller: _artistController, decoration: const InputDecoration(labelText: "Artiste / Groupe original *", prefixIcon: Icon(Icons.person))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _composerController, decoration: const InputDecoration(labelText: "Compositeur (optionnel)"))),
                    const SizedBox(width: 16),
                    Expanded(child: TextFormField(controller: _addedByController, decoration: const InputDecoration(labelText: "Votre nom *"))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _bpmController, decoration: const InputDecoration(labelText: "BPM", prefixIcon: Icon(Icons.timer)), keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: TextFormField(controller: _rhythmController, decoration: const InputDecoration(labelText: "Rythme (ex: B B H H B H) *"))),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(),
                ),
                
                // --- BLOC PAROLES ---
                const Text("Éditeur de paroles avec accords", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Wrap(
                    spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, 
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedChord,
                          hint: const Text("Choisir un accord"),
                          items: availableChords.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                          onChanged: (val) => setState(() => _selectedChord = val),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text("Insérer au curseur"),
                        style: ElevatedButton.styleFrom(foregroundColor: Colors.deepOrange, backgroundColor: Colors.orange[50], elevation: 0),
                        onPressed: _insertChordInLyrics,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _lyricsController,
                  maxLines: 12,
                  decoration: const InputDecoration(hintText: "Écrivez les paroles ici..."),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                ),
                const SizedBox(height: 32),
                
                // --- BOUTON FINAL ---
                ElevatedButton.icon(
                  icon: Icon(widget.songToEdit == null ? Icons.save : Icons.check),
                  label: Text(widget.songToEdit == null ? "Enregistrer la tablature" : "Mettre à jour la tablature", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.deepOrange, // Couleur qui pète !
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    // ... GARDE TON CODE LOGIQUE EXACTEMENT COMME AVANT ICI ...
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}