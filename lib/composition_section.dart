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
  final _capoController = TextEditingController();

  String? _selectedChord; 
  List<String> availableChords = ["C", "G", "Em", "D", "Am", "F", "Bm"];

  @override
  void initState() {
    super.initState();
    // 🛠️ Si on est en mode édition, on pré-remplit les champs
    if (widget.songToEdit != null) {
      final s = widget.songToEdit!;
      _titleController.text = s.title;
      _artistController.text = s.artist;
      _composerController.text = s.composer;
      _addedByController.text = s.addedBy;
      _bpmController.text = s.bpm > 0 ? s.bpm.toString() : '';
      _rhythmController.text = s.rhythm;
      _lyricsController.text = s.lyrics.join('\n');
      _capoController.text = s.capo > 0 ? s.capo.toString() : ''; 
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
    // Petite variable pratique pour savoir si on est sur la page Modifier
    final isEditing = widget.songToEdit != null;

    return Scaffold(
      backgroundColor: isEditing ? Colors.white : Colors.transparent,
      
      // 🛠️ 1. LIGNE MAGIQUE : Autorise le texte à scroller TOUT en haut de l'écran, derrière la flèche
      extendBodyBehindAppBar: true, 
      
      appBar: isEditing 
        ? AppBar(
            backgroundColor: Colors.transparent, // 🛠️ 2. Totalement invisible
            elevation: 0, 
            scrolledUnderElevation: 0, // 🛠️ 3. Interdit à Flutter de griser la barre au scroll !
            iconTheme: const IconThemeData(color: Color(0xFF1E293B)), 
          ) 
        : null,
        
      body: Container(
        decoration: isEditing 
          ? const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF0F9FF), Color(0xFFE0E7FF)],
              ),
            )
          : null,
        child: Center( 
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800), 
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 130, bottom: 100),
                children: [
                  Text(
                    isEditing ? "Modifier les détails" : "Créer une nouvelle Tablature", 
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))
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
                      Expanded(
                        flex: 2, 
                        child: TextFormField(
                          controller: _bpmController, 
                          decoration: const InputDecoration(
                            labelText: "BPM", 
                            // Si tu veux garder l'icône, enlève le labelText ou utilise un hintText à la place.
                            // Pour une lecture propre, je suggère de ne mettre l'icône QUE si l'écran est large :
                          ), 
                          keyboardType: TextInputType.number,
                        )
                      ),                      const SizedBox(width: 16),
                      // 🛠️ NOUVEAU CHAMP CAPO
                      Expanded(flex: 2, child: TextFormField(controller: _capoController, decoration: const InputDecoration(labelText: "Capo (0-12)"), keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: TextFormField(controller: _rhythmController, decoration: const InputDecoration(labelText: "Rythme (ex: B B H H B H) *"))),
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
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color(0xFF0EA5E9), // Texte Bleu ciel
                            backgroundColor: const Color(0xFFE0F2FE), // Fond Bleu très clair
                            elevation: 0
                          ),
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
                    icon: Icon(isEditing ? Icons.check : Icons.save),
                    label: Text(isEditing ? "Mettre à jour la tablature" : "Enregistrer la tablature", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: const Color(0xFF0EA5E9), // Bleu moderne !
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        
                        // 1. On fabrique l'objet Song
                        final newSong = Song(
                          title: _titleController.text,
                          artist: _artistController.text,
                          composer: _composerController.text,
                          addedBy: _addedByController.text,
                          imageUrl: "https://i.scdn.co/image/ab67616d0000b273f1e3c5e4a1f2c3e4a5b6c7d8", 
                          bpm: int.tryParse(_bpmController.text) ?? 0, 
                          capo: int.tryParse(_capoController.text) ?? 0, 
                          rhythm: _rhythmController.text,
                          lyrics: _lyricsController.text.split('\n'), 
                        );
                        
                        // 2. Logique d'envoi vers Firebase
                        try {
                          if (isEditing) {
                            // 🛠️ MODIFICATION
                            await FirebaseFirestore.instance.collection('songs').doc(widget.songToEdit!.id).update(newSong.toMap());
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Musique mise à jour ! ✨'), backgroundColor: Colors.green),
                              );
                              // On ferme la page de modification
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            }
                          } else {
                            // 🛠️ CRÉATION
                            await FirebaseFirestore.instance.collection('songs').add(newSong.toMap());
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Musique enregistrée avec succès dans le Cloud ! ☁️'), backgroundColor: Colors.green),
                              );
                            }
                            
                            // On vide les champs (uniquement en création)
                            _titleController.clear();
                            _artistController.clear();
                            _composerController.clear();
                            _addedByController.clear();
                            _bpmController.clear();
                            _capoController.clear();
                            _rhythmController.clear();
                            _lyricsController.clear();
                            setState(() {
                              _selectedChord = null;
                            });
                          }
                        } catch (erreur) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur de sauvegarde : $erreur'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}