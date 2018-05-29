import 'dart:io';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/now_playing.dart';
import 'package:musicplayer/util/lastplay.dart';

class ListSongs extends StatefulWidget {
  DatabaseClient db;
  int mode;
  // mode ==1//recent 2//top 3//fav
  ListSongs(this.db, this.mode);
  @override
  State<StatefulWidget> createState() {
    return new _listSong();
  }
}

class _listSong extends State<ListSongs> {
  List<Song> songs;
  bool isLoading = true;
  dynamic getImage(Song song) {
    return song.albumArt == null
        ? null
        : new File.fromUri(Uri.parse(song.albumArt));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSongs();
  }

  void initSongs() async {
    switch (widget.mode) {
      case 1:
        songs = await widget.db.fetchRecentSong();
        break;
      case 2:
        songs = await widget.db.fetchTopSong();
        break;
      case 3:
        songs = await widget.db.fetchFavSong();
        break;
      default:
        break;
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget getTitle(int mode) {
    switch (mode) {
      case 1:
        return new Text("Recently played");
        break;
      case 2:
        return new Text("Top tracks");
        break;
      case 3:
        return new Text("Favourites");
        break;
      default:
        return;
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: getTitle(widget.mode),
        ),
        body: new Container(
          child: isLoading
              ? new Center(
                  child: new CircularProgressIndicator(),
                )
              : new ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, i) => new Column(
                        children: <Widget>[
                          new Divider(
                            height: 8.0,
                          ),
                          new ListTile(
                            leading: new CircleAvatar(
                              child: getImage(songs[i]) != null
                                  ? new Image.file(
                                      getImage(songs[i]),
                                      height: 120.0,
                                      fit: BoxFit.cover,
                                    )
                                  : new Text(songs[i].title[0].toUpperCase()),
                            ),
                            title: new Text(songs[i].title,
                                maxLines: 1,
                                style: new TextStyle(fontSize: 18.0)),
                            subtitle: new Text(
                              songs[i].artist,
                              maxLines: 1,
                              style: new TextStyle(
                                  fontSize: 12.0, color: Colors.grey),
                            ),
                            trailing: widget.mode == 2
                                ? new Text(
                                    (i + 1).toString(),
                                    style: new TextStyle(
                                        fontSize: 12.0, color: Colors.grey),
                                  )
                                : new Text(
                                    new Duration(
                                            milliseconds: songs[i].duration)
                                        .toString()
                                        .split('.')
                                        .first,
                                    style: new TextStyle(
                                        fontSize: 12.0, color: Colors.grey)),
                            onTap: () {
                              LastPlay.songs = songs;
                              Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (context) => new NowPlaying(
                                      widget.db, LastPlay.songs, i, 0)));
                            },
                          ),
                        ],
                      ),
                ),
        ));
  }
}
