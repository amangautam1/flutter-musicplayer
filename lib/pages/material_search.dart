import 'package:flute_music_player/flute_music_player.dart';
import 'package:material_search/material_search.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/now_playing.dart';
import 'package:musicplayer/util/lastplay.dart';

class SearchSong extends StatelessWidget {
  final DatabaseClient db;
  final List<Song> songs;
  SearchSong(this.db, this.songs);
  List<Song> results;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new SafeArea(
          child: new MaterialSearch<String>(
            placeholder: 'Search songs', //placeholder of the search bar text input
            results: songs
                .map((song) => new MaterialSearchResult<String>(
              value: song.title, //The value must be of type <String>
              text: song.title, //String that will be show in the list
              icon: Icons.music_note,
            ))
                .toList(),
            onSelect: (dynamic selected) async {
              if (selected == null) {
                return;
              }
              print(selected);
              results = songs.where((song) => song.title == selected).toList();
              print(results);

              Navigator.pop(context);
              MyQueue.songs = results;
              Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                return new NowPlaying(db, results, 0, 0);
              }));
            },
            onSubmit: (String value) {
              print(value);
            },
          ),
        ));
  }
}
