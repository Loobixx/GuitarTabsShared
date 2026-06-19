import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async'; 
import 'package:audioplayers/audioplayers.dart';
import 'package:guitar_shared_tabs/composition_section.dart';
import 'package:guitar_shared_tabs/song.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TablatureSection extends StatefulWidget {
  
  const TablatureSection({super.key});

  @override
  State<TablatureSection> createState() => _TablatureSectionState();
}
class _TablatureSectionState extends State<TablatureSection> {


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('songs').snapshots(),
      builder: (context, snapshot) {
        
        // 1. Si ça charge, on affiche un petit loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. S'il y a une erreur
        if (snapshot.hasError) {
          return Center(child: Text("Erreur : ${snapshot.error}"));
        }

        // 3. Si la base de données est vide
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Aucune tablature pour le moment.\nAllez dans Composition pour en créer une !", textAlign: TextAlign.center,));
        }

        // 4. On transforme les documents Firebase en liste d'objets Song
        final List<Song> songs = snapshot.data!.docs.map((doc) {
          return Song.fromMap(doc.data() as Map<String, dynamic>, doc.id); 
        }).toList();

        // 5. On affiche la liste exactement comme avant !
        return ListView.separated(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
          itemCount: songs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final song = songs[index];
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800), 
                child: GestureDetector(
                  onTap: () => _openSongDetails(song),
                  child: Container(
                    padding: const EdgeInsets.all(8.0), // Un peu plus d'air à l'intérieur
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16), // Plus arrondi
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), // Ombre plus douce et moderne
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: _buildCardView(song),
                  ),
                ),
              ),
            );
          },
        );
      },
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
                          "${song.bpm} BPM",
                          style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 10 : 12, fontWeight: FontWeight.w600),
                        ),
                      ],
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
        // NOUVEAU : LA COLONNE DES BOUTONS D'ACTION
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _editSong(song),
                  tooltip: "Modifier",
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
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
// NOUVEAU WIDGET : LA PAGE DÉTAILLÉE DE LA CHANSON (AVEC MÉTRONOME)
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
            
            // LE PANNEAU D'INFORMATION ET MÉTRONOME
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
  return Wrap(
    crossAxisAlignment: WrapCrossAlignment.center, 
    children: arrows
  );
}
