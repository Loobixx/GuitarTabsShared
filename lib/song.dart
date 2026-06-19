class Song {
  final String title;
  final String artist;
  final String composer;
  final String addedBy;
  final String imageUrl;
  final int bpm;
  final String rhythm;
  final List<String> lyrics;

  Song({
    required this.title,
    required this.artist,
    required this.composer,
    required this.addedBy,
    required this.imageUrl,
    required this.bpm,
    required this.rhythm,
    required this.lyrics,
  });

  // 🛠️ 1. Pour envoyer vers Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'composer': composer,
      'addedBy': addedBy,
      'imageUrl': imageUrl,
      'bpm': bpm,
      'rhythm': rhythm,
      'lyrics': lyrics,
    };
  }

  // 🛠️ 2. Pour recevoir depuis Firebase
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      title: map['title'] ?? 'Sans Titre',
      artist: map['artist'] ?? 'Inconnu',
      composer: map['composer'] ?? '',
      addedBy: map['addedBy'] ?? '',
      imageUrl: map['imageUrl'] ?? 'https://i.scdn.co/image/ab67616d0000b273f1e3c5e4a1f2c3e4a5b6c7d8',
      bpm: map['bpm']?.toInt() ?? 100,
      rhythm: map['rhythm'] ?? '',
      lyrics: List<String>.from(map['lyrics'] ?? []),
    );
  }


  // 🛠️ Le Getter magique : Extrait automatiquement les accords uniques des paroles
  List<String> get chords {
    final RegExp regExp = RegExp(r'\[(.*?)\]');
    final Set<String> uniqueChords = {}; // Un Set empêche naturellement les doublons

    for (var line in lyrics) {
      final matches = regExp.allMatches(line);
      for (var match in matches) {
        uniqueChords.add(match.group(1)!);
      }
    }
    
    return uniqueChords.toList();
  }
}