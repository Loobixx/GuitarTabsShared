class Song {
  final String title;
  final String artist;
  final String composer;
  final String addedBy;
  final String imageUrl;
  final int bpm;
  final String rhythm; // Ex: "B B H H B H" (B = Bas, H = Haut)
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