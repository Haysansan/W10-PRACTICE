class Comment {
  final String id;
  final String text;
  final String artistId;

  Comment({required this.id, required this.text, required this.artistId});

  @override
  String toString() {
    return 'Comment(id: $id, artistId: $artistId, text: $text)';
  }
}
