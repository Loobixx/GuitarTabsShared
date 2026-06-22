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
  int _startingFret = 1; 
  
  // 🛠️ NOUVEAU : Variables d'état du barré
  int _barreFret = 0;
  int _barreStartString = 0;
  int _barreEndString = 5;

  @override
  void initState() {
    super.initState();
    if (widget.chordToEdit != null) {
      final data = widget.chordToEdit!.data() as Map<String, dynamic>;
      _nameController.text = data['name'] ?? '';
      _frets = List<int>.from(data['frets'] ?? [0, 0, 0, 0, 0, 0]);
      _startingFret = data['startingFret'] ?? 1; 
      
      // 🛠️ NOUVEAU : Récupération des données du barré
      _barreFret = data['barreFret'] ?? 0;
      _barreStartString = data['barreStartString'] ?? 0;
      _barreEndString = data['barreEndString'] ?? 5;
    } else if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
  }

  Future<void> _saveChord() async {
    if (_nameController.text.isEmpty) return; 

    // 🛠️ NOUVEAU : On inclut les variables du barré dans la sauvegarde
    final data = {
      'name': _nameController.text, 
      'frets': _frets,
      'startingFret': _startingFret, 
      'barreFret': _barreFret,
      'barreStartString': _barreStartString,
      'barreEndString': _barreEndString,
    };
    
    try {
      if (widget.chordToEdit == null) {
        await FirebaseFirestore.instance.collection('chords').add(data);
      } else {
        await widget.chordToEdit!.reference.update(data);
      }
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Erreur sauvegarde : $e");
    }
  }

  void _increaseStartingFret() {
    if (_startingFret < 12) {
      setState(() {
        _startingFret++;
        if (_barreFret > 0) _barreFret++; // 🛠️ Le barré avance en même temps !
      });
    }
  }

  void _decreaseStartingFret() {
    if (_startingFret > 1) {
      setState(() {
        _startingFret--;
        if (_barreFret > 0) _barreFret--; // 🛠️ Le barré recule en même temps !
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.chordToEdit != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
            colors: [Color(0xFFF0F9FF), Color(0xFFE0E7FF)],
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
                    Text(
                      isEditing ? "Modifier l'accord 🎸" : "Nouvel accord ✨",
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 40),
                    
                    TextFormField(
                      controller: _nameController, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        labelText: "Nom de l'accord (ex: Bm, F#...)",
                        prefixIcon: const Icon(Icons.music_note, color: Color(0xFF0EA5E9)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      )
                    ),
                    const SizedBox(height: 20), 

                    // --- BLOC BARRÉ ---
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text("Accord avec barré", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            activeColor: const Color(0xFFFF5A5F),
                            value: _barreFret > 0,
                            onChanged: (val) {
                              setState(() {
                                if (val) {
                                  _barreFret = _startingFret; // On active le barré sur la case 1 par défaut
                                } else {
                                  _barreFret = 0; // On le désactive
                                }
                              });
                            },
                          ),
                          if (_barreFret > 0) ...[
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Corde de départ :", style: TextStyle(fontWeight: FontWeight.w500)),
                                  DropdownButton<int>(
                                    value: _barreStartString,
                                    // La corde 0 c'est le Mi grave (tout à gauche), 1 c'est le La, etc.
                                    items: [0, 1, 2, 3, 4].map((e) => DropdownMenuItem(value: e, child: Text("Corde ${e + 1}"))).toList(),
                                    onChanged: (val) => setState(() => _barreStartString = val!),
                                    underline: const SizedBox(),
                                  ),
                                ],
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(onPressed: _decreaseStartingFret, icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF1E293B), size: 30)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Text("Frette $_startingFret", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9))),
                        ),
                        IconButton(onPressed: _increaseStartingFret, icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1E293B), size: 30)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(6, (index) => Container(width: 33, alignment: Alignment.center, child: Text("${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)))),
                          ),
                          const SizedBox(height: 8),
                          
                          ChordGridSelector(
                            frets: _frets,
                            startingFret: _startingFret, 
                            barreFret: _barreFret, 
                            barreStartString: _barreStartString,
                            barreEndString: _barreEndString,
                            onSelect: (string, fret) {
                              setState(() {
                                // 🛠️ CORRECTION 2 : On vérifie simplement si la frette cliquée (ex: 5) 
                                // est exactement la même que celle du barré (ex: 5).
                                if (_barreFret > 0 && fret == _barreFret) {
                                  // On ne fait rien, on ne superpose pas de point sur le barré
                                } else {
                                  // Sinon, on place ou on retire le doigt normalement
                                  _frets[string] = (_frets[string] == fret) ? 0 : fret;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40), 
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline, size: 22, color: Colors.white,),
                        label: Text(isEditing ? "Mettre à jour" : "Créer l'accord", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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