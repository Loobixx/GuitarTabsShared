import 'package:flutter/material.dart';
import 'package:guitar_shared_tabs/composition_section.dart';
import 'package:guitar_shared_tabs/tablature_section.dart';

// Remplace 'ton_projet' par le nom exact de ton projet flutter (défini dans ton pubspec.yaml)
// import 'package:ton_projet/models/song.dart'; 
// import 'package:ton_projet/screens/tablature_section.dart';
// import 'package:ton_projet/screens/composition_section.dart';

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

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Le nombre d'onglets (Tablatures + Composition)
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'SharedTabs 🎸',
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
        body: const TabBarView(
          children: [
            // On affiche tes deux sections ici
            TablatureSection(),
            CompositionSection(),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// COLLE ICI TES WIDGETS PRÉCÉDENTS SI TU VEUX 
// TOUT METTRE DANS LE MÊME FICHIER POUR TESTER
// ==========================================

// class Song { ... }
// class TablatureSection extends StatefulWidget { ... }
// class CompositionSection extends StatefulWidget { ... }