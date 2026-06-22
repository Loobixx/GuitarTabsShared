import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async'; 
import 'package:audioplayers/audioplayers.dart';
import 'package:guitar_shared_tabs/chord_visualizer.dart';
import 'package:guitar_shared_tabs/composition_section.dart';
import 'package:guitar_shared_tabs/song.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TablatureSection extends StatefulWidget {
  const TablatureSection({super.key});

  @override
  State<TablatureSection> createState() => _TablatureSectionState();
}

class _TablatureSectionState extends State<TablatureSection> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. LA BARRE DE RECHERCHE EST HORS DU STREAMBUILDER
        // Elle ne sera JAMAIS reconstruite quand Firebase envoie de nouvelles données.
        // On met un padding top: 140 pour tenir compte de ton Header dans le main.dart
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 140, 16, 16),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: "Rechercher...",
              prefixIcon: const Icon(Icons.search, color: Color(0xFF0EA5E9)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
        ),
        
        // 2. LE STREAMBUILDER NE GÈRE QUE LA LISTE
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('songs').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) return Center(child: Text("Erreur : ${snapshot.error}"));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Aucune tablature pour le moment."));
              }

              // Récupération et filtrage
              final List<Song> allSongs = snapshot.data!.docs.map((doc) {
                return Song.fromMap(doc.data() as Map<String, dynamic>, doc.id); 
              }).toList();

              final filteredSongs = allSongs.where((song) {
                final query = _searchQuery.toLowerCase();
                return song.title.toLowerCase().contains(query) || 
                       song.artist.toLowerCase().contains(query);
              }).toList();

              // Affichage de la liste seule
              return ListView.separated(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                itemCount: filteredSongs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final song = filteredSongs[index];
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800), 
                      child: GestureDetector(
                        onTap: () => _openSongDetails(song),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: _buildCardView(song),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // FONCTION POUR OUVRIR LA MODIFICATION
  void _editSong(Song song) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CompositionSection(songToEdit: song)),
    );
  }

  // FONCTION POUR SUPPRIMER AVEC CONFIRMATION
  void _deleteSong(Song song) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer la tablature ?"),
        content: Text("Veux-tu vraiment supprimer définitivement '${song.title}' de la base de données ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Annuler")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx); // Ferme la popup
              // Lance la suppression sur Firebase via l'ID de la chanson
              await FirebaseFirestore.instance.collection('songs').doc(song.id).delete();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tablature supprimée !"), backgroundColor: Colors.grey));
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );
  }

  Widget _buildCardView(Song song) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final imageSize = isMobile ? 75.0 : 120.0;
    final titleFontSize = isMobile ? 15.0 : 18.0;
    final artistFontSize = isMobile ? 13.0 : 14.0;
    final chipFontSize = isMobile ? 11.0 : 13.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: song.imageUrl,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              placeholder: (context, url) => SizedBox(
                width: imageSize,
                height: imageSize,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 1)),
              ),
              errorWidget: (context, url, error) => Container(
                width: imageSize,
                height: imageSize,
                color: Colors.grey[200],
                child: Icon(Icons.music_note, color: Colors.grey, size: isMobile ? 16 : 40),
              ),
            ),
          ),
        ),

        const SizedBox(width: 4),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0, top: 4.0, bottom: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  song.title, 
                  style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, height: 1.1, color: const Color(0xFF1E293B)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Par ${song.artist}", 
                  style: TextStyle(color: Colors.grey[600], fontSize: artistFontSize, height: 1.1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8, // Espace horizontal
                  runSpacing: 4, // Espace vertical si ça passe à la ligne
                  children: [
                    _buildRhythmArrows(song.rhythm, isMobile: isMobile),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined, size: isMobile ? 14 : 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          song.bpm > 0 ? "${song.bpm} BPM" : "?? BPM",
                          style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 10 : 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    
                    // 🛠️ NOUVEAU : LE BADGE DU CAPO SUR LA CARTE
                    if (song.capo > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5A5F).withOpacity(0.1), // Un fond rouge très léger
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Capo ${song.capo}",
                          style: TextStyle(
                            color: const Color(0xFFFF5A5F), 
                            fontSize: isMobile ? 10 : 12, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 4),
                Wrap(
                  spacing: 3,
                  runSpacing: 2,
                  children: song.chords.map((chord) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(chord, style: TextStyle(fontSize: chipFontSize, fontWeight: FontWeight.bold)),
                  )).toList(),
                )
              ],
            ),
          ),
        ),
        // LA COLONNE DES BOUTONS D'ACTION
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF0EA5E9), size: 20),
                  onPressed: () => _editSong(song),
                  tooltip: "Modifier",
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: const Color(0xFFFFE4E6), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFFF5A5F), size: 20),
                  onPressed: () => _deleteSong(song),
                  tooltip: "Supprimer",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // OUVERTURE DE LA PAGE DE LECTURE
  // ---------------------------------------------------------

  void _openSongDetails(Song song) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Fermer",
      barrierColor: Colors.transparent, 
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SongDetailView(song: song);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.1), 
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}

// =========================================================================
// WIDGET : LA PAGE DÉTAILLÉE DE LA CHANSON (AVEC MÉTRONOME & NOUVEAU DESIGN)
// =========================================================================

class SongDetailView extends StatefulWidget {
  final Song song;
  const SongDetailView({super.key, required this.song});

  @override
  State<SongDetailView> createState() => _SongDetailViewState();
}

class _SongDetailViewState extends State<SongDetailView> {
  bool _isPlayingMetronome = false;
  Timer? _metronomeTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // 1. Remplace ta fonction actuelle par celle-ci
  // 🛠️ 1. NOUVELLE FONCTION QUI RÉCUPÈRE TOUT L'ACCORD
  Future<Map<String, dynamic>?> _getChordData(String chordName) async {
    final query = await FirebaseFirestore.instance
        .collection('chords')
        .where('name', isEqualTo: chordName)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data() as Map<String, dynamic>;
    }
    return null; 
  }

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // L'écran reste allumé
  }

  @override
  void dispose() {
    WakelockPlus.disable(); // L'écran peut s'éteindre normalement
    _metronomeTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleMetronome() async {
    if (_isPlayingMetronome) {
      _metronomeTimer?.cancel();
      setState(() => _isPlayingMetronome = false);
    } else {
      await _audioPlayer.setSource(AssetSource('tick.mp3')); 
      int msPerBeat = (60000 / widget.song.bpm).round();

      setState(() => _isPlayingMetronome = true);
      _playTick();

      _metronomeTimer = Timer.periodic(Duration(milliseconds: msPerBeat), (timer) {
        _playTick();
      });
    }
  }

  void _playTick() async {
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.stop(); 
    }
    await _audioPlayer.resume(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 🛠️ 1. Fond transparent
      
      extendBodyBehindAppBar: true, // 🛠️ 2. Le texte passe sous la barre
      
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 🛠️ 3. Barre invisible
        elevation: 0,
        scrolledUnderElevation: 0, // Interdit le grisage au scroll
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B)), // Flèche moderne
          onPressed: () => Navigator.of(context).pop(), 
        ),
      ),
      
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F9FF), Color(0xFFE0E7FF)], // 🛠️ 4. Le même dégradé bleu !
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 100.0, bottom: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.song.title, 
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -1.0)
              ),
              const SizedBox(height: 6),
              Text(
                "Compositeur : ${widget.song.composer}  •  Ajouté par : ${widget.song.addedBy}", 
                style: TextStyle(color: Colors.blueGrey[600], fontSize: 14, fontWeight: FontWeight.w500),
              ),

              if (widget.song.capo > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5A5F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "🎸 Capo : Frette ${widget.song.capo}", 
                    style: const TextStyle(color: Color(0xFFFF5A5F), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              
              // LE PANNEAU D'INFORMATION ET MÉTRONOME
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6), // Effet un peu transparent (Glassmorphism)
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text("Rythme : ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              _buildRhythmArrows(widget.song.rhythm),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Text("Accords : ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              ),
                              Expanded(
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: widget.song.chords.map((chord) => GestureDetector(
                                    // 🛠️ ON REND L'ACCORD CLIQUABLE
                                    onTap: () async { 
                                      // 1. Récupère les données depuis Firebase
                                      final data = await _getChordData(chord); 
                                      
                                      // 2. Affiche la popup si on a trouvé les données
                                      if (mounted && data != null) {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (ctx) => ChordVisualizer(
                                            name: chord, 
                                            frets: List<int>.from(data['frets'] ?? [0, 0, 0, 0, 0, 0]), // Récupère la liste
                                            startingFret: data['startingFret'] ?? 1, // 🛠️ NOUVEAU : Récupère le décalage !
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6)
                                      ),
                                      child: Text(
                                        chord, 
                                        style: const TextStyle(
                                          color: Color(0xFF0EA5E9), 
                                          fontWeight: FontWeight.bold, 
                                          fontSize: 14
                                        ),
                                      ),
                                    ),
                                  )).toList(),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Le bouton Métronome
                    // Le bouton Métronome
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: Colors.blueGrey.withOpacity(0.2)))
                      ),
                      child: Column(
                        children: [
                          Text(
                            // 🛠️ 2. Affiche ?? si c'est 0
                            widget.song.bpm > 0 ? "${widget.song.bpm} BPM" : "?? BPM", 
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))
                          ),
                          const SizedBox(height: 8),
                          
                          // 🛠️ 3. On affiche le bouton de lecture UNIQUEMENT si on a un vrai BPM
                          if (widget.song.bpm > 0)
                            FloatingActionButton.small(
                              elevation: 0,
                              backgroundColor: _isPlayingMetronome ? const Color(0xFFFF5A5F) : const Color(0xFF0EA5E9),
                              onPressed: _toggleMetronome,
                              child: Icon(_isPlayingMetronome ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white),
                            )
                          else
                            // Sinon on met un petit chrono barré mignon pour dire qu'il n'y a pas de métronome
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Icon(Icons.timer_off_outlined, color: Colors.grey, size: 28),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              // Les paroles
              ...widget.song.lyrics.map((rawLine) => _buildLyricsLine(rawLine)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLyricsLine(String rawLine) {
    final RegExp regExp = RegExp(r'\[(.*?)\]');
    final Iterable<RegExpMatch> matches = regExp.allMatches(rawLine);

    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(rawLine, style: const TextStyle(fontSize: 18, color: Color(0xFF1E293B))),
      );
    }

    List<Widget> chunks = [];
    final matchesList = matches.toList();

    for (int i = 0; i < matchesList.length; i++) {
      final match = matchesList[i];
      if (i == 0 && match.start > 0) {
        chunks.addAll(_createWordChunks(null, rawLine.substring(0, match.start)));
      }
      final String chord = match.group(1)!;
      final int textStart = match.end;
      final int textEnd = (i + 1 < matchesList.length) ? matchesList[i + 1].start : rawLine.length;
      chunks.addAll(_createWordChunks(chord, rawLine.substring(textStart, textEnd)));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(crossAxisAlignment: WrapCrossAlignment.end, children: chunks),
    );
  }

  List<Widget> _createWordChunks(String? chord, String text) {
    List<Widget> chunks = [];
    List<String> words = text.split(' '); 
    for (int i = 0; i < words.length; i++) {
      String wordText = words[i] + (i < words.length - 1 ? ' ' : '');
      if (wordText.isEmpty && chord == null) continue;

      chunks.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: (i == 0 && chord != null) 
                ? () async { 
                    // 1. Attend le résultat de Firebase
                    final data = await _getChordData(chord!); 
                    
                    // 2. Ouvre la popup en envoyant les frettes ET le startingFret
                    if (mounted && data != null) {
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => ChordVisualizer(
                          name: chord, 
                          frets: List<int>.from(data['frets'] ?? [0, 0, 0, 0, 0, 0]),
                          startingFret: data['startingFret'] ?? 1, // 🛠️ NOUVEAU
                        ),
                      );
                    }
                  }
                : null,
              child: Text(
                (i == 0 && chord != null) ? chord : "",
                style: TextStyle(
                  color: (i == 0 && chord != null) ? const Color(0xFFFF5A5F) : Colors.transparent,
                  fontWeight: FontWeight.bold, fontSize: 16, height: 1.2,
                ),
              ),
            ),
            Text(wordText, style: const TextStyle(fontSize: 18, height: 1.2, color: Color(0xFF1E293B))),
          ],
        )
      );
    }
    return chunks;
  }
}

Widget _buildRhythmArrows(String rhythm, {bool isMobile = false}) {
  List<Widget> arrows = [];
  final double iconSize = isMobile ? 14.0 : 18.0;
  for (int i = 0; i < rhythm.length; i++) {
    String char = rhythm[i].toUpperCase();
    if (char == 'B' || char == 'D') { 
      arrows.add(Icon(Icons.arrow_downward, size: iconSize, color: const Color(0xFF1E293B)));
    } else if (char == 'H' || char == 'U') { 
      arrows.add(Icon(Icons.arrow_upward, size: iconSize, color: const Color(0xFF1E293B)));
    } else if (char == ' ') {
      arrows.add(const SizedBox(width: 4)); 
    }
  }
  return Wrap(
    crossAxisAlignment: WrapCrossAlignment.center, 
    children: arrows
  );
}