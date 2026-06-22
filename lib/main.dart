import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:guitar_shared_tabs/manage_chords_page.dart';
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
    const ManageChordsPage(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, 
      
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F9FF), Color(0xFFE0E7FF)],
          ),
        ),
        child: SafeArea(
          bottom: false, 
          child: Stack(
            children: [
              // --- 1. LE CONTENU (En dessous) ---
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _pages[_currentIndex],
              ),
              
              // --- 2. LE MASQUE EN DÉGRADÉ (Doux et plus grand) ---
              Positioned(
                top: 0, left: 0, right: 0,
                child: IgnorePointer( // 🛠️ Rend le dégradé "fantôme" pour les clics
                  child: Container(
                    height: 140, // 🛠️ Plus haut pour un fondu très progressif
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFF0F9FF), 
                          const Color(0xFFF0F9FF).withOpacity(0.9), 
                          const Color(0xFFF0F9FF).withOpacity(0.0), 
                        ],
                        stops: const [0.4, 0.75, 1.0], 
                      ),
                    ),
                  ),
                ),
              ),

              // --- 3. LE HEADER "SHAREDTABS" (Par dessus le masque) ---
              Positioned(
                top: 0, left: 0, right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SharedTabs 🎸',
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0, 
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8), 
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7), 
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
              ),
            ],
          ),
        ),
      ),
      
      // --- LA BARRE DE NAVIGATION (Correction du débordement) ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible( // 🛠️ CORRECTION 1 : Permet à la boîte globale de rétrécir
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    height: 65, 
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
                        // 🛠️ CORRECTION 2 : Flexible sur les boutons
                        Flexible(child: _buildNavItem(Icons.library_music_rounded, "Tablatures", 0)),
                        Flexible(child: _buildNavItem(Icons.queue_music_rounded, "Composer", 1)),
                        Flexible(child: _buildNavItem(Icons.grid_4x4_rounded, "Accords", 2)),
                      ],
                    ),
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
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 🛠️ C'est tout ce qu'il faut ! On change juste d'onglet naturellement.
        setState(() => _currentIndex = index); 
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isSelected ? Colors.white : Colors.white54, 
              size: 24
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 14
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}