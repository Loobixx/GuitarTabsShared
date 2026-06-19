import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:guitar_shared_tabs/composition_section.dart';
import 'package:guitar_shared_tabs/tablature_section.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'SharedTabs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0EA5E9), 
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), 
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2), 
          ),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TablatureSection(),
    const CompositionSection(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 🛠️ TRÈS IMPORTANT : Permet au fond coloré de glisser SOUS la barre de navigation
      
      // 🛠️ LE NOUVEAU FOND MODERNE (Dégradé très doux Bleu Ciel -> Bleu Lavande)
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F9FF), // Un bleu ciel extrêmement clair (quasi blanc)
              Color(0xFFE0E7FF), // Un bleu lavande très doux
            ],
          ),
        ),
        child: SafeArea(
          bottom: false, // Laisse le dégradé descendre jusqu'en bas de l'écran
          child: Column(
            children: [
              // --- HEADER RÉDUIT POUR MOBILE ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12), // 🛠️ Beaucoup moins d'espace vide
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SharedTabs 🎸',
                      style: TextStyle(
                        fontSize: 24, // 🛠️ Réduit de 32 à 24 pour ne plus écraser les cartes
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0, 
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8), // Icône de profil légèrement plus petite
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7), // Effet un peu transparent (Glassmorphism)
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ]
                      ),
                      child: const Icon(Icons.person_outline, color: Color(0xFF1E293B), size: 22),
                    )
                  ],
                ),
              ),
              
              // --- LE CONTENU ---
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _pages[_currentIndex],
                ),
              ),
            ],
          ),
        ),
      ),
      
      // --- LA BARRE DE NAVIGATION EN FORME DE PILULE ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  height: 65, // Barre légèrement plus fine
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B), 
                    borderRadius: BorderRadius.circular(35), 
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E293B).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(Icons.library_music_rounded, "Tablatures", 0),
                      _buildNavItem(Icons.add_circle_rounded, "Composer", 1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LE BOUTON DE NAVIGATION ANIMÉ
Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), 
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: isSelected ? Colors.white : Colors.white54,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}