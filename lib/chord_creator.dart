import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guitar_shared_tabs/chord_grid_selector.dart';

class ChordCreator extends StatefulWidget {
  final DocumentSnapshot? chordToEdit; 
  final String? initialName; 
  
  const ChordCreator({super.key, this.chordToEdit, this.initialName});

  @override
  State<ChordCreator> createState() => _ChordCreatorState();
}

class _ChordCreatorState extends State<ChordCreator> {
  final _nameController = TextEditingController();
  List<int> _frets = [0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    if (widget.chordToEdit != null) {
      _nameController.text = widget.chordToEdit!['name'];
      _frets = List<int>.from(widget.chordToEdit!['frets']);
    } else if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
  }

  Future<void> _saveChord() async {
    if (_nameController.text.isEmpty) return; // Sécurité

    final data = {'name': _nameController.text, 'frets': _frets};
    
    try {
      if (widget.chordToEdit == null) {
        await FirebaseFirestore.instance.collection('chords').add(data);
      } else {
        await widget.chordToEdit!.reference.update(data);
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Erreur sauvegarde : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.chordToEdit != null;

    return Scaffold(
      extendBodyBehindAppBar: true, // 🛠️ Permet au dégradé de passer sous la barre du haut
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F9FF), Color(0xFFE0E7FF)], // Ton beau dégradé !
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- TITRE MIGNON ---
                    Text(
                      isEditing ? "Modifier l'accord 🎸" : "Nouvel accord ✨",
                      style: const TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.w900, 
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // --- CHAMP DE TEXTE ---
                    TextFormField(
                      controller: _nameController, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        labelText: "Nom de l'accord (ex: Am, G...)",
                        prefixIcon: const Icon(Icons.music_note, color: Color(0xFF0EA5E9)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      )
                    ),
                    const SizedBox(height: 40), 
                    
                    // --- LE MANCHE DE GUITARE ---
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6), // Effet verre un peu transparent
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
                        ]
                      ),
                      child: Column(
                        children: [
                          // Les numéros des cordes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(6, (index) => 
                              Container(
                                width: 33, 
                                alignment: Alignment.center, 
                                child: Text(
                                  "${index + 1}", 
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)
                                )
                              )
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Ta grille cliquable
                          ChordGridSelector(
                            frets: _frets,
                            onSelect: (string, fret) {
                              setState(() {
                                _frets[string] = (_frets[string] == fret) ? 0 : fret;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40), 
                    
                    // --- BOUTON SAUVEGARDER ---
                    SizedBox(
                      width: double.infinity, // Bouton large
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline, size: 22, color: Colors.white,),
                        label: Text(
                          isEditing ? "Mettre à jour" : "Créer l'accord", 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: const Color(0xFF0EA5E9), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        onPressed: _saveChord, 
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}