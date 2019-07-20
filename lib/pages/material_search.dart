import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/now_playing.dart';
import 'package:musicplayer/util/lastplay.dart';
import 'package:musicplayer/util/utility.dart';

class SearchSong extends StatefulWidget {
  final DatabaseClient db;
  final List<Song> songs;

  SearchSong(this.db, this.songs);

  @override
  _SearchSongState createState() => _SearchSongState();
}

class _SearchSongState extends State<SearchSong> {
  List<Song> results;

  @override
  void initState() {
    super.initState();
    results = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .primaryColor,
      body: SafeArea(
        child: FloatingSearchBar.builder(
          itemCount: results.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: new Hero(
                tag: results[index].id,
                child: avatar(
                    context, getImage(results[index]), results[index].title),
              ),
              title: new Text(results[index].title,
                  maxLines: 1, style: new TextStyle(fontSize: 18.0)),
              subtitle: new Text(
                results[index].artist,
                maxLines: 1,
                style: new TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
              trailing: new Text(
                  new Duration(milliseconds: results[index].duration)
                      .toString()
                      .split('.')
                      .first,
                  style: new TextStyle(fontSize: 12.0, color: Colors.grey)),
              onTap: () {
                MyQueue.songs = results;
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (context) =>
                    new NowPlaying(widget.db, results, index, 0)));
              },
            );
          },
          trailing: Icon(Icons.search),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          onChanged: (String value) {
            if (value.trim() == "") {
              setState(() {
                results = [];
              });
            } else {
              setState(() {
                results = widget.songs
                    .where((song) =>
                song.title
                    .toLowerCase()
                    .contains(value.toLowerCase()) ||
                    song.artist
                        .toLowerCase()
                        .contains(value.toLowerCase()) ||
                    song.album.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              });
            }
            print(results.length);
          },
          onTap: () {
            print("On tap callled");
          },
          decoration: InputDecoration.collapsed(
            hintText: "Search song, artist or album",
          ),
        ),
      ),
    );
    // return new Scaffold(
    //     backgroundColor: Colors.deepPurple,
    //     body: new SafeArea(

    //       child: new MaterialSearch<String>(
    //         barBackgroundColor:Theme.of(context).accentColor,
    //         iconColor: Colors.white,
    //         placeholder: 'Search songs', //placeholder of the search bar text input
    //         results: songs
    //             .map((song) => new MaterialSearchResult<String>(
    //           value: song.title, //The value must be of type <String>
    //           text: song.title, //String that will be show in the list
    //           icon: FontAwesomeIcons.compactDisc,
    //         ))
    //             .toList(),
    //         onSelect: (dynamic selected) async {
    //           if (selected == null) {
    //             return;
    //           }

    //           results = songs.where((song) => song.title == selected).toList();

    //           Navigator.pop(context);
    //           MyQueue.songs = results;
    //           Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
    //             return new NowPlaying(db, results, 0, 0);
    //           }));
    //         },
    //         onSubmit: (String value) {

    //         },
    //       ),
    //     ));
  }
}
