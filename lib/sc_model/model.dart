import 'package:flute_music_player/flute_music_player.dart';
import 'package:scoped_model/scoped_model.dart';

class SongModel extends Model {
  Song _song;
  List<Song> albums, recents, songs;
  Song last;
  Song top;
  int mode = 2;

  Song get song => _song;

  void updateUI(Song song, db) async {
    _song = song;
    recents = await db.fetchRecentSong();
    //recents.removeAt(0);
    top = await db.fetchTopSong().then((item) => item[0]);
    notifyListeners();
  }

  void setMode(int mode) {
    this.mode = mode;
    notifyListeners();
  }

  // void updateRecents(db)async{
  //   recents=await db.fetchRecentSong();
  //   recents.removeAt(0);
  //   notifyListeners();
  // }
  init(db) async {
    recents = (await db.fetchRecentSong());
    recents.removeAt(0); // as it is showing in header
    notifyListeners();
  }
}
