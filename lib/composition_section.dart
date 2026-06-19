import 'package:flutter/material.dart';
import 'package:guitar_shared_tabs/song.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompositionSection extends StatefulWidget {
  
  const CompositionSection({super.key});

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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text("Créer une nouvelle Tablature", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // 🛠️ Titre (Obligatoire)
            TextFormField(
              controller: _titleController, 
              decoration: const InputDecoration(labelText: "Titre de la chanson *"),
              validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer un titre' : null,
            ),
            
            // 🛠️ Artiste (Obligatoire)
            TextFormField(
              controller: _artistController, 
              decoration: const InputDecoration(labelText: "Artiste / Groupe original *"),
              validator: (value) => value == null || value.isEmpty ? 'Veuillez renseigner l\'artiste' : null,
            ),
            
            // 🛠️ Compositeur (Optionnel)
            TextFormField(
              controller: _composerController, 
              decoration: const InputDecoration(labelText: "Nom du compositeur (optionnel)")
            ),
            
            // 🛠️ Contributeur (Obligatoire)
            TextFormField(
              controller: _addedByController, 
              decoration: const InputDecoration(labelText: "Votre nom (Contributeur) *"),
              validator: (value) => value == null || value.isEmpty ? 'Veuillez renseigner votre nom' : null,
            ),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bpmController, 
                    decoration: const InputDecoration(labelText: "BPM (ex: 120)"), 
                    keyboardType: TextInputType.number,
                  )
                ),
                const SizedBox(width: 16),
                
                // 🛠️ Rythme (Obligatoire)
                Expanded(
                  child: TextFormField(
                    controller: _rhythmController, 
                    decoration: const InputDecoration(labelText: "Rythme (ex: B B H H B H) *"),
                    validator: (value) => value == null || value.isEmpty ? 'Veuillez indiquer le rythme' : null,
                  )
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            const Text("Éditeur de paroles avec accords", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 12, // Espace horizontal entre le dropdown et le bouton
              runSpacing: 12, // Espace vertical s'ils finissent sur deux lignes différentes
              crossAxisAlignment: WrapCrossAlignment.center, // Aligne verticalement au centre
              children: [
                DropdownButton<String>(
                  value: _selectedChord,
                  hint: const Text("Choisir un accord"),
                  items: availableChords.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _selectedChord = val),
                ),
                ElevatedButton(
                  onPressed: _insertChordInLyrics,
                  child: const Text("Placer l'accord au curseur"),
                )
              ],
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _lyricsController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: "Écrivez les paroles ici. Utilisez le bouton ci-dessus pour insérer l'accord au bon endroit de la phrase !",
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newSong = Song(
                    title: _titleController.text,
                    artist: _artistController.text,
                    composer: _composerController.text,
                    addedBy: _addedByController.text,
                    imageUrl: "https://i.scdn.co/image/ab67616d0000b273f1e3c5e4a1f2c3e4a5b6c7d8", 
                    bpm: int.tryParse(_bpmController.text) ?? 100, 
                    rhythm: _rhythmController.text,
                    lyrics: _lyricsController.text.split('\n'), 
                  );
                  
                  // 🛠️ ON ENVOIE DIRECTEMENT SUR FIREBASE
                  await FirebaseFirestore.instance.collection('songs').add(newSong.toMap());

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tablature sauvegardée dans le Cloud ! ☁️'), backgroundColor: Colors.green),
                  );                  
                  _titleController.clear();
                  _artistController.clear();
                  _composerController.clear();
                  _addedByController.clear();
                  _bpmController.clear();
                  _rhythmController.clear();
                  _lyricsController.clear();
                  setState(() {
                    _selectedChord = null;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.blueGrey[900], 
                foregroundColor: Colors.white,
              ),
              child: const Text("Enregistrer la musique"),
            )
          ],
        ),
      ),
    );
  }
}