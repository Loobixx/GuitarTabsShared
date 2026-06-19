import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 👈 Import Firebase
import 'firebase_options.dart'; // 👈 Le fichier généré par Firebase
import 'package:guitar_shared_tabs/composition_section.dart';
import 'package:guitar_shared_tabs/tablature_section.dart';

void main() async {
  // 🛠️ Sécurité obligatoire pour pouvoir initialiser Firebase avant de lancer l'interface
  WidgetsFlutterBinding.ensureInitialized();

  // 🛠️ Démarrage du moteur Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TablAIApp());
}

class TablAIApp extends StatelessWidget {
  const TablAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TablAI', // Nom mis à jour !
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// 🛠️ La page principale redevient un simple StatelessWidget (sans état).
// Elle n'a plus besoin de stocker la liste _globalSongs !
class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'TablAI 🎸',
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
            // 🛠️ Les deux pages sont maintenant complètement autonomes.
            // Elles n'ont plus besoin de paramètres entre les parenthèses.
            TablatureSection(),
            CompositionSection(),
          ],
        ),
      ),
    );
  }
}