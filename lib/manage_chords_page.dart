import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guitar_shared_tabs/chord_creator.dart';

class ManageChordsPage extends StatelessWidget {
  const ManageChordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 120),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'Vos Accords', 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))
            ),
          ),

          // 🛠️ 1. PREMIER STREAM : On récupère TOUTES les chansons
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('songs').snapshots(),
              builder: (context, songsSnapshot) {
                if (!songsSnapshot.hasData) return const Center(child: CircularProgressIndicator());

                // 🛠️ 2. DEUXIÈME STREAM : On récupère les accords sauvegardés
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('chords').snapshots(),
                  builder: (context, chordsSnapshot) {
                    if (!chordsSnapshot.hasData) return const Center(child: CircularProgressIndicator());

                    // --- LOGIQUE DE CROISEMENT DES DONNÉES ---
                    
                    // A. On liste tous les accords utilisés dans les chansons
                    Set<String> allUsedChords = {};
                      for (var doc in songsSnapshot.data!.docs) {
                        // On convertit les données en Map pour pouvoir vérifier l'existence des champs sans crasher
                        final data = doc.data() as Map<String, dynamic>?; 
                        
                        if (data != null) {
                          // 1. Si tu as un champ 'chords' explicite dans Firebase
                          if (data.containsKey('chords') && data['chords'] is List) {
                            for (var c in data['chords']) {
                              allUsedChords.add(c.toString());
                            }
                          }
                          
                          // 2. Si les accords sont détectés dans les paroles avec tes balises (ex: [Am])
                          if (data.containsKey('lyrics') && data['lyrics'] is List) {
                            final RegExp regExp = RegExp(r'\[(.*?)\]');
                            for (var line in data['lyrics']) {
                              final matches = regExp.allMatches(line.toString());
                              for (var match in matches) {
                                if (match.group(1) != null) {
                                  allUsedChords.add(match.group(1)!); // Ajoute "Am" sans les crochets
                                }
                              }
                            }
                          }
                        }
                      }

                    // B. On liste tous les accords qui existent en base de données
                    Map<String, DocumentSnapshot> savedChordsMap = {};
                    for (var doc in chordsSnapshot.data!.docs) {
                      savedChordsMap[doc['name']] = doc;
                    }

                    // C. On fusionne tout pour l'affichage et on trie par ordre alphabétique
                    Set<String> allChordsToDisplay = {...allUsedChords, ...savedChordsMap.keys};
                    List<String> sortedChords = allChordsToDisplay.toList()..sort();

                    if (sortedChords.isEmpty) return const Center(child: Text("Aucun accord à afficher."));

                    // --- AFFICHAGE DE LA LISTE ---
                    return ListView.separated(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100), 
                      itemCount: sortedChords.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        String chordName = sortedChords[index];
                        DocumentSnapshot? chordDoc = savedChordsMap[chordName];
                        
                        // Si le document existe, on considère qu'il est défini (complet)
                        bool isComplete = chordDoc != null;

                        // On applique ton design (Vert si complet, Rouge si manquant)
                        Color bgColor = isComplete 
                            ? const Color(0xFFE6F4EA) // Vert très clair
                            : const Color(0xFFFCE8E6); // Rouge très clair
                        
                        Icon statusIcon = isComplete
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.cancel, color: Colors.red);

                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Container(
                              decoration: BoxDecoration(
                                color: bgColor, 
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isComplete ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3))
                              ),
                              child: ListTile(
                                leading: statusIcon,
                                title: Text(
                                  chordName, 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 18,
                                    color: isComplete ? Colors.green[800] : Colors.red[800]
                                  )
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Color(0xFF0EA5E9)), 
                                      onPressed: () {
                                        // On ouvre l'éditeur. S'il n'existe pas encore, on passera juste le nom (voir étape 2)
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (_) => ChordCreator(chordToEdit: chordDoc, initialName: chordDoc == null ? chordName : null)
                                        ));
                                      }
                                    ),
                                    if (isComplete) // On ne peut supprimer que s'il existe en base
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Color(0xFFFF5A5F)), 
                                        onPressed: () => _confirmDelete(context, chordDoc)
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), 
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF1E293B),
          elevation: 4,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChordCreator())),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer l'accord ?"),
        content: Text("Veux-tu vraiment supprimer '${doc['name']}' ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await doc.reference.delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}