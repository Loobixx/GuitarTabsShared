import 'package:flutter/material.dart';
import 'dart:async'; // 👈 Pour le Timer du métronome
import 'package:audioplayers/audioplayers.dart'; // 👈 Pour le son
import 'package:guitar_shared_tabs/song.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TablatureSection extends StatefulWidget {
  const TablatureSection({super.key});

  @override
  State<TablatureSection> createState() => _TablatureSectionState();
}

class _TablatureSectionState extends State<TablatureSection> {
  // Liste des morceaux
  final List<Song> _songs = [
    Song(
      title: "Everywhere, Everything",
      artist: "Noah Kahan, Gracie Abrams",
      composer: "Noah Kahan",
      addedBy: "Yoann",
      imageUrl: "https://i.scdn.co/image/ab67616d0000b273f1e3c5e4a1f2c3e4a5b6c7d8",
      bpm: 1000,
      rhythm: "B B H H B H", // Mis à jour avec des espaces pour plus de clarté
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
      rhythm: "B B B B", 
      lyrics: [
        "Would we survive in a horror movie Would we survive in a horror movie Would we survive in a horror movie Would we survive in a horror movie Would we survive in a horror movie Would we survive in a [C]horror movie ",
        "I doubt it, [G]we're too [C]slow moving",
        "[C] [G] [Em]", 
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final double desiredHeight = isMobile ? 80.0 : 140.0; 
        final double columnWidth = (constraints.maxWidth - 16 - 12) / 2;
        final double dynamicAspectRatio = columnWidth / desiredHeight;

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _songs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: dynamicAspectRatio, 
          ),
          itemBuilder: (context, index) {
            final song = _songs[index];

            return GestureDetector(
              onTap: () => _openSongDetails(song),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
                ),
                child: _buildCardView(song),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCardView(Song song) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final imageSize = isMobile ? 50.0 : 120.0;
    final titleFontSize = isMobile ? 10.5 : 18.0;
    final artistFontSize = isMobile ? 9.0 : 14.0;
    final chipFontSize = isMobile ? 8.5 : 13.0;

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
                  style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, height: 1.1),
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
                
                Row(
                  children: [
                    _buildRhythmArrows(song.rhythm, isMobile: isMobile),
                    const SizedBox(width: 12), 
                    Icon(Icons.timer_outlined, size: isMobile ? 12 : 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      "${song.bpm} BPM",
                      style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 10 : 12, fontWeight: FontWeight.w600),
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
      ],
    );
  }

  // ---------------------------------------------------------
  // 🛠️ OUVERTURE DE LA PAGE DE LECTURE
  // ---------------------------------------------------------

  void _openSongDetails(Song song) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Fermer",
      barrierColor: Colors.transparent, 
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        // 👈 On appelle un vrai widget StatefulWidget pour gérer le métronome !
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
// 🎸 NOUVEAU WIDGET : LA PAGE DÉTAILLÉE DE LA CHANSON (AVEC MÉTRONOME)
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

  @override
  void dispose() {
    // IL EST VITAL DE COUPER LE TIMER ET LE SON QUAND ON FERME LA PAGE
    _metronomeTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleMetronome() async {
    if (_isPlayingMetronome) {
      _metronomeTimer?.cancel();
      setState(() => _isPlayingMetronome = false);
    } else {
      // Précharge le son pour éviter le lag au premier tic
      await _audioPlayer.setSource(AssetSource('tick.mp3')); 
      
      // Calcule le temps entre chaque battement en millisecondes
      // Formule : (60 secondes / BPM) * 1000 millisecondes
      int msPerBeat = (60000 / widget.song.bpm).round();

      setState(() => _isPlayingMetronome = true);

      // Joue le premier coup immédiatement
      _playTick();

      // Lance la boucle
      _metronomeTimer = Timer.periodic(Duration(milliseconds: msPerBeat), (timer) {
        _playTick();
      });
    }
  }

  void _playTick() async {
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.stop(); // Coupe le son précédent s'il était encore en train de résonner
    }
    await _audioPlayer.resume(); // Joue le tic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(), 
        ),
        title: Text(widget.song.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.song.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              "Compositeur : ${widget.song.composer} | Ajouté par : ${widget.song.addedBy}", 
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            
            const SizedBox(height: 24),
            
            // 🛠️ LE PANNEAU D'INFORMATION ET MÉTRONOME
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueGrey[100]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Affichage du Rythme
                        Row(
                          children: [
                            const Text("Rythme : ", style: TextStyle(fontWeight: FontWeight.bold)),
                            _buildRhythmArrows(widget.song.rhythm),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Affichage des Accords
                        Row(
                          children: [
                            const Text("Accords : ", style: TextStyle(fontWeight: FontWeight.bold)),
                            Wrap(
                              spacing: 6,
                              children: widget.song.chords.map((chord) => Text(
                                chord, 
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                              )).toList(),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Le bouton Métronome
                  Column(
                    children: [
                      Text("${widget.song.bpm} BPM", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      FloatingActionButton.small(
                        backgroundColor: _isPlayingMetronome ? Colors.redAccent : Colors.blueGrey[900],
                        onPressed: _toggleMetronome,
                        child: Icon(_isPlayingMetronome ? Icons.stop : Icons.play_arrow, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 40, thickness: 1),
            
            // Les paroles
            ...widget.song.lyrics.map((rawLine) => _buildLyricsLine(rawLine)),
          ],
        ),
      ),
    );
  }

  // J'ai ramené les méthodes de parsing ici pour qu'elles fonctionnent sur cette page
  Widget _buildLyricsLine(String rawLine) {
    final RegExp regExp = RegExp(r'\[(.*?)\]');
    final Iterable<RegExpMatch> matches = regExp.allMatches(rawLine);

    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(rawLine, style: const TextStyle(fontSize: 18)),
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
            Text(
              (i == 0 && chord != null) ? chord : "",
              style: TextStyle(
                color: (i == 0 && chord != null) ? Colors.red : Colors.transparent,
                fontWeight: FontWeight.bold, fontSize: 16, height: 1.2,
              ),
            ),
            Text(wordText, style: const TextStyle(fontSize: 18, height: 1.2)),
          ],
        )
      );
    }
    return chunks;
  }
}

// Note: J'ai laissé cette méthode en "globale" en bas car elle est utilisée à la fois par la carte et par la page détaillée
Widget _buildRhythmArrows(String rhythm, {bool isMobile = false}) {
  List<Widget> arrows = [];
  final double iconSize = isMobile ? 14.0 : 18.0;
  for (int i = 0; i < rhythm.length; i++) {
    String char = rhythm[i].toUpperCase();
    if (char == 'B' || char == 'D') { 
      arrows.add(Icon(Icons.arrow_downward, size: iconSize, color: Colors.blueGrey[800]));
    } else if (char == 'H' || char == 'U') { 
      arrows.add(Icon(Icons.arrow_upward, size: iconSize, color: Colors.blueGrey[800]));
    } else if (char == ' ') {
      arrows.add(const SizedBox(width: 4)); 
    }
  }
  return Row(mainAxisSize: MainAxisSize.min, children: arrows);
}