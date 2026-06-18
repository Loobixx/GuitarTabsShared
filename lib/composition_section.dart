import 'package:flutter/material.dart';

class CompositionSection extends StatefulWidget {
  const CompositionSection({super.key});

  @override
  State<CompositionSection> createState() => _CompositionSectionState();
}

class _CompositionSectionState extends State<CompositionSection> {
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs de saisie
  final _titleController = TextEditingController();
  final _composerController = TextEditingController();
  final _addedByController = TextEditingController();
  final _bpmController = TextEditingController();
  final _rhythmController = TextEditingController();
  final _lyricsController = TextEditingController();

  String? _selectedChord; // L'accord actuellement sélectionné pour être injecté
  List<String> availableChords = ["C", "G", "Em", "D", "Am"];

  // Fonction pour simuler l'injection d'un accord au curseur actuel
  void _insertChordInLyrics() {
    if (_selectedChord == null) return;
    
    final text = _lyricsController.text;
    final selection = _lyricsController.selection;
    
    // On injecte une balise (ex: [C]) là où est le curseur pour la traiter plus tard
    final newText = text.replaceRange(selection.start, selection.end, "[$_selectedChord]");
    _lyricsController.text = newText;
    
    // Repositionne le curseur après l'accord inséré
    _lyricsController.selection = TextSelection.collapsed(offset: selection.start + _selectedChord!.length + 2);
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
            TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: "Titre de la chanson")),
            TextFormField(controller: _composerController, decoration: const InputDecoration(labelText: "Nom du compositeur")),
            TextFormField(controller: _addedByController, decoration: const InputDecoration(labelText: "Votre nom (Contributeur)")),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _bpmController, decoration: const InputDecoration(labelText: "BPM"), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(controller: _rhythmController, decoration: const InputDecoration(labelText: "Rythme"))),
              ],
            ),
            const SizedBox(height: 24),
            
            // Outil d'injection d'accords
            const Text("Éditeur de paroles avec accords", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedChord,
                  hint: const Text("Choisir un accord"),
                  items: availableChords.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _selectedChord = val),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _insertChordInLyrics,
                  child: const Text("Placer l'accord au curseur"),
                )
              ],
            ),
            const SizedBox(height: 12),
            
            // Zone de saisie des paroles
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
              onPressed: () {
                // Logique de sauvegarde (ex: envoyer à Firebase ou une API)
                if (_formKey.currentState!.validate()) {
                  print("Chanson prête à être enregistrée !");
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
              child: const Text("Enregistrer la musique"),
            )
          ],
        ),
      ),
    );
  }
}