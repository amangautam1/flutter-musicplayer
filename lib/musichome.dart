import 'dart:async';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/about.dart';
import 'package:musicplayer/pages/material_search.dart';
import 'package:musicplayer/pages/now_playing.dart';
import 'package:musicplayer/util/lastplay.dart';
import 'package:musicplayer/views/album.dart';
import 'package:musicplayer/views/artists.dart';
import 'package:musicplayer/views/home.dart';
import 'package:musicplayer/views/playlists.dart';
import 'package:musicplayer/views/songs.dart';

class MusicHome extends StatefulWidget {
  List<Song> songs;
  MusicHome();
  final bottomItems = [
    new BottomItem("Home", Icons.home),
    new BottomItem("Albums", Icons.album),
    new BottomItem("Songs", Icons.music_note),
    new BottomItem("Artists", Icons.person),
    new BottomItem("PlayList", Icons.playlist_add_check),
  ];
  @override
  State<StatefulWidget> createState() {
    return new _musicState();
  }
}

class _musicState extends State<MusicHome> {
  int _selectedDrawerIndex = 0;
  List<Song> songs;
  String title = "Music player";
  DatabaseClient db;
  bool isLoading = true;
  Song last;

  getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new Home(db);
      case 2:
        return new Songs(db);
      case 3:
        return new Artists(db);
      case 1:
        return new Album(db);
      case 4:
        return new PlayList(db);
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    getDrawerItemWidget(_selectedDrawerIndex);
    title = widget.bottomItems[index].title;
    // Navigator.of(context).pop(); // close the drawer
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlayer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getLast() async {
    last = await db.fetchLastSong();
    songs = await db.fetchSongs();
    setState(() {
      songs = songs;
    });
  }

  void initPlayer() async {
    db = new DatabaseClient();
    await db.create();
    if (await db.alreadyLoaded()) {
      setState(() {
        isLoading = false;
        getLast();
      });
    } else {
      var songs;
      try {
        songs = await MusicFinder.allSongs();
      } catch (e) {
        print("failed to get songs");
      }
      List<Song> list = new List.from(songs);
      for (Song song in list) db.upsertSOng(song);
      if (!mounted) {
        return;
      }
      setState(() {
        isLoading = false;
        getLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var bottomOptions = <BottomNavigationBarItem>[];
    for (var i = 0; i < widget.bottomItems.length; i++) {
      var d = widget.bottomItems[i];
      bottomOptions.add(
        new BottomNavigationBarItem(
            icon: new Icon(d.icon),
            title: new Text(d.title),
            backgroundColor: Theme.of(context).primaryColor),
      );
    }
    return new Scaffold(
      appBar: _selectedDrawerIndex == 0
          ? null
          : new AppBar(
              title: new Text(title),
              actions: <Widget>[
                new IconButton(icon: Icon(Icons.search), onPressed: null)
              ],
            ),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.play_circle_filled),
          onPressed: () {
            Navigator
                .of(context)
                .push(new MaterialPageRoute(builder: (context) {
              if (LastPlay.songs == null) {
                List<Song> list = new List();
                list.add(last);
                LastPlay.songs = list;
                return new NowPlaying(db, list, 0, 0);
              } else
                return new NowPlaying(db, LastPlay.songs, LastPlay.index, 1);
            }));
          }),
      drawer: new Drawer(
        child: new Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
                accountName: new Text("Music player"), accountEmail: null),
            new Column(
              children: <Widget>[
                new ListTile(
                  leading: new Icon(Icons.info),
                  title: new Text("About"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        new MaterialPageRoute(builder: (context) {
                      return new About();
                    }));
                  },
                )
              ],
            )
          ],
        ),
      ),
      body: isLoading
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : getDrawerItemWidget(_selectedDrawerIndex),
      bottomNavigationBar: new BottomNavigationBar(
        items: bottomOptions,
        onTap: (index) => _onSelectItem(index),
        currentIndex: _selectedDrawerIndex,
      ),
    );
  }
}

class BottomItem {
  String title;
  IconData icon;
  BottomItem(this.title, this.icon);
}
