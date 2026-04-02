import '../../../../data/repositories/artist/artist_repository.dart';
import '../../../../data/repositories/songs/song_repository.dart';
import '../../../../model/artist/artist.dart';
import '../../../../model/comment/comment.dart';
import '../../../../model/songs/song.dart';
import '../../../../ui/utils/async_value.dart';
import 'package:flutter/material.dart';

class ArtistDetailViewModel extends ChangeNotifier {
  final ArtistRepository artistRepository;
  final SongRepository songRepository;
  final Artist artist;

  AsyncValue<List<Song>> songsValue = AsyncValue.loading();
  AsyncValue<List<Comment>> commentsValue = AsyncValue.loading();
  bool isPostingComment = false;

  ArtistDetailViewModel({
    required this.artistRepository,
    required this.songRepository,
    required this.artist,
  }) {
    _init();
  }

  void _init() {
    fetchData();
  }

  Future<void> fetchData() async {
    // Reset both to loading
    songsValue = AsyncValue.loading();
    commentsValue = AsyncValue.loading();
    notifyListeners();

    try {
      // Fetch songs and comments in parallel
      final results = await Future.wait([
        artistRepository.fetchSongsByArtist(artist.id),
        artistRepository.fetchCommentsByArtist(artist.id),
      ]);

      songsValue = AsyncValue.success(results[0] as List<Song>);
      commentsValue = AsyncValue.success(results[1] as List<Comment>);
    } catch (e) {
      songsValue = AsyncValue.error(e);
      commentsValue = AsyncValue.error(e);
    }
    notifyListeners();
  }

  // post a comment and update local state immediately
  Future<void> addComment(String text) async {
    if (text.trim().isEmpty) return;

    isPostingComment = true;
    notifyListeners();

    try {
      final Comment newComment = await artistRepository.postComment(
        artist.id,
        text,
      );

      // Add to local list without re-fetching
      final currentComments = commentsValue.data ?? [];
      commentsValue = AsyncValue.success([...currentComments, newComment]);
    } catch (e) {
      commentsValue = AsyncValue.error(e);
    }

    isPostingComment = false;
    notifyListeners();
  }

  Future<void> likeSong(String songId, int currentLikes) async {
    try {
      await songRepository.likeSong(songId, currentLikes);

      // Update local list without re-fetching
      final currentSongs = songsValue.data ?? [];
      final updatedSongs = currentSongs.map((s) {
        if (s.id == songId) {
          return Song(
            id: s.id,
            title: s.title,
            artistId: s.artistId,
            duration: s.duration,
            imageUrl: s.imageUrl,
            likes: currentLikes + 1,
          );
        }
        return s;
      }).toList();

      songsValue = AsyncValue.success(updatedSongs);
      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
  }
}
