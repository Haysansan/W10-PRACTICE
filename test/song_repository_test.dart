import 'package:w10_firebase/data/repositories/songs/song_repository.dart';
import 'package:w10_firebase/data/repositories/songs/song_repository_firebase.dart';
import 'package:w10_firebase/model/songs/song.dart';

void main() async {
  //   Instantiate the  song_repository_mock
  SongRepository songRepository = SongRepositoryFirebase();

  List<Song> songs = await songRepository.fetchSongs();

  for (var song in songs) {
    print(song);
  }
}
