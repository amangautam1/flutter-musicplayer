import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/now_playing.dart';
import 'package:musicplayer/util/lastplay.dart';
import 'package:musicplayer/util/utility.dart';

class ListSongs extends StatefulWidget {
  DatabaseClient db;
  int mode;
  Orientation orientation;
  // mode =1=>recent, 2=>top, 3=>fav
  ListSongs(this.db, this.mode, this.orientation);
  @override
  State<StatefulWidget> createState() {
    return new _listSong();
  }
}

class _listSong extends State<ListSongs> {
  List<Song> songs;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initSongs();
  }

  void initSongs() async {
    switch (widget.mode) {
      case 1:
        songs = await widget.db.fetchRecentSong();
        break;
      case 2:
        {
          songs = await widget.db.fetchTopSong();
          break;
        }
      case 3:
        {
          songs = await widget.db.fetchFavSong();
          break;
        }
      default:
        break;
    }
    print(songs.length);

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
        return null;
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Add songs"),
          content: new Text(
              "To add songs to favourite, long press any song from All songs tab."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Got it"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // appBar: widget.orientation == Orientation.portrait
      //     ? new AppBar(
      //         title: getTitle(widget.mode),
      //       )
      //     : null,
        appBar: new AppBar(
                title: getTitle(widget.mode),
          actions: <Widget>[
            widget.mode == 3 ? IconButton(
              icon: Icon(Icons.add,), onPressed: () {
              _showDialog();
            },) : Container()
          ],
        ),

        body: new Container(
          child: isLoading
              ? new Center(
                  child: new CircularProgressIndicator(),
                )
              : new ListView.builder(
            itemCount: songs.length == null ? 0 : songs.length,
            itemBuilder: (context, i) =>
                Column(
                        children: <Widget>[
                          new Divider(
                            height: 8.0,
                          ),
                          new ListTile(
                            leading: new Hero(
                              tag: songs[i].id,
                              child: avatar(
                                  context, getImage(songs[i]), songs[i].title),
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
                              MyQueue.songs = songs;
                              Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (context) => new NowPlaying(
                                      widget.db, MyQueue.songs, i, 0)));
                            },
                            onLongPress: () {
                              if (widget.mode == 3) {
                                showDialog(
                                  context: context,
                                  child: new AlertDialog(
                                    title: new Text(
                                        'Are you sure want remove this from favourites?'),
                                    content: new Text(songs[i].title),
                                    actions: <Widget>[
                                      new FlatButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: new Text(
                                          'No',
                                        ),
                                      ),
                                      new FlatButton(
                                        onPressed: () {
                                          widget.db.removeFavSong(songs[i]);

                                          setState(() {
                                            songs.removeAt(i);
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: new Text('Yes'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                ),
        ));
  }
}
