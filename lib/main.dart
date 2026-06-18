import 'package:flutter/material.dart';
import 'package:guitar_shared_tabs/composition_section.dart';
import 'package:guitar_shared_tabs/tablature_section.dart';
import 'package:guitar_shared_tabs/song.dart'; // 👈 On a besoin du modèle Song ici

void main() {
  runApp(const TablAIApp());
}

class TablAIApp extends StatelessWidget {
  const TablAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SharedTabs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// 🛠️ Transformation en StatefulWidget pour qu'il puisse gérer l'état (la liste de chansons)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // 1. 🛠️ ON PLACE LA LISTE ICI ! C'est le boss qui distribue aux onglets.
  final List<Song> _globalSongs = [
    Song(
      title: "Everywhere, Everything",
      artist: "Noah Kahan, Gracie Abrams",
      composer: "Noah Kahan",
      addedBy: "Yoann",
      imageUrl: "https://i.scdn.co/image/ab67616d0000b273f1e3c5e4a1f2c3e4a5b6c7d8",
      bpm: 76,
      rhythm: "B B H H B H",
      lyrics: [
        "[C]Would we survive in a horror movie",
        "I doubt it, we're too [G]slow mov[C]ing",
      ],
    ),
    Song(
      title: "TEST: Balises & Longueur",
      artist: "Robot de Test",
      composer: "Yoann Lab",
      addedBy: "Debug Mode",
      imageUrl: "https://i.scdn.co/image/ab67616d0000b273f1e3c5e4a1f2c3e4a5b6c7d8",
      bpm: 120,
      rhythm: "Test de charge",
      lyrics: [
        "Would we survive in a horror movie Would we survive in a horror movie Would we survive in a horror movie Would we survive in a horror movie Would we survive in a horror movie Would we survive in a [C]horror movie ",
        "I doubt it, [G]we're too [C]slow moving",
        "[C] [G] [Em]", 
      ],
    ),
  ];

  // 2. 🛠️ La méthode que l'onglet Composition va appeler pour rajouter une chanson
  void _addNewSong(Song newSong) {
    setState(() {
      _globalSongs.add(newSong); // On l'ajoute à la liste
    });
    
    // Petite notification visuelle
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nouvelle tablature enregistrée ! Allez voir dans l\'onglet Tablatures.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'TabShared 🎸',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey[900],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.music_note), text: 'Tablatures'),
              Tab(icon: Icon(Icons.border_color), text: 'Composition'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 3. 🛠️ On donne la liste à l'onglet Tablature
            TablatureSection(songs: _globalSongs),
            
            // 4. 🛠️ On donne la fonction d'ajout à l'onglet Composition
            CompositionSection(onSongAdded: _addNewSong),
          ],
        ),
      ),
    );
  }
}