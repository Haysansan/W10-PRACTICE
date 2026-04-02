import '../../../screens/artist_details/view_model/artist_details_view_model.dart';
import '../../../widgets/comment/comment_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../model/songs/song.dart';
import '../../../../model/comment/comment.dart';
import '../../../theme/theme.dart';
import '../../../utils/async_value.dart';
import '../../../screens/library/widgets/library_item_tile.dart';
import '../../../screens/library/view_model/library_item_data.dart';

class ArtistDetailContent extends StatefulWidget {
  const ArtistDetailContent({super.key});

  @override
  State<ArtistDetailContent> createState() => _ArtistDetailContentState();
}

class _ArtistDetailContentState extends State<ArtistDetailContent> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment(ArtistDetailViewModel mv) async {
    final text = _commentController.text.trim();

    // Validate empty comment
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Comment cannot be empty')));
      return;
    }

    await mv.addComment(text);

    // Clear input after submitting
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ArtistDetailViewModel mv = context.watch<ArtistDetailViewModel>();
    final artist = mv.artist;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),

            // Artist header
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(artist.imageUrl.toString()),
            ),
            SizedBox(height: 12),
            Text(artist.name, style: AppTextStyles.heading),
            Text(
              artist.genre,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 24),

            // Songs section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Songs",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            _buildSongsSection(mv),

            SizedBox(height: 24),

            // Comments section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Comments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            _buildCommentsSection(mv),
          ],
        ),
      ),

      // Comment input at bottom
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            mv.isPostingComment
                ? CircularProgressIndicator()
                : IconButton(
                    icon: Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: () => _submitComment(mv),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsSection(ArtistDetailViewModel mv) {
    final AsyncValue<List<Song>> songsValue = mv.songsValue;

    switch (songsValue.state) {
      case AsyncValueState.loading:
        return Center(child: CircularProgressIndicator());
      case AsyncValueState.error:
        return Text(
          'Failed to load songs',
          style: TextStyle(color: Colors.red),
        );
      case AsyncValueState.success:
        final songs = songsValue.data!;
        if (songs.isEmpty) {
          return Text(
            'No songs available',
            style: TextStyle(color: Colors.grey),
          );
        }
        return Column(
          children: songs
              .map(
                (song) => LibraryItemTile(
                  data: LibraryItemData(song: song, artist: mv.artist),
                  isPlaying: false,
                  onTap: () {},
                  onLike: () {
                    mv.likeSong(song.id, song.likes);
                  },
                ),
              )
              .toList(),
        );
    }
  }

  Widget _buildCommentsSection(ArtistDetailViewModel mv) {
    final AsyncValue<List<Comment>> commentsValue = mv.commentsValue;

    switch (commentsValue.state) {
      case AsyncValueState.loading:
        return Center(child: CircularProgressIndicator());
      case AsyncValueState.error:
        return Text(
          'Failed to load comments',
          style: TextStyle(color: Colors.red),
        );
      case AsyncValueState.success:
        final comments = commentsValue.data!;
        if (comments.isEmpty) {
          return Text(
            'No comments yet. Be the first!',
            style: TextStyle(color: Colors.grey),
          );
        }
        return Column(
          children: comments.map((c) => CommentTile(comment: c)).toList(),
        );
    }
  }
}
