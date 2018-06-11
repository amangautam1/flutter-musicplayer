import 'dart:io';
import 'dart:math';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/card_detail.dart';
import 'package:musicplayer/pages/list_songs.dart';
import 'package:musicplayer/pages/material_search.dart';
import 'package:musicplayer/pages/now_playing.dart';
import 'package:musicplayer/util/lastplay.dart';

class Home extends StatefulWidget {
  DatabaseClient db;
  Home(this.db);
  @override
  State<StatefulWidget> createState() {
    return new stateHome();
  }
}

class stateHome extends State<Home> {
  List<Song> albums, recents, songs;
  bool isLoading = true;
  Song last;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  dynamic getImage(Song song) {
    return song.albumArt == null
        ? null
        : new File.fromUri(Uri.parse(song.albumArt));
  }

  void init() async {
    albums = await widget.db.fetchRandomAlbum();
    recents = await widget.db.fetchRecentSong();
    recents.removeAt(0); // as it is showing in header
    last = await widget.db.fetchLastSong();
    songs = await widget.db.fetchSongs();
    print(last.title);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation=MediaQuery.of(context).orientation;
    return new CustomScrollView(
      slivers: <Widget>[
        new SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          title: new Text("Music Player"),
          actions: <Widget>[
            new IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator
                      .of(context)
                      .push(new MaterialPageRoute(builder: (context) {
                    return new SearchSong(widget.db, songs);
                  }));
                })
          ],
          flexibleSpace: new FlexibleSpaceBar(
            // title:new Text("home"),
            background: new Stack(
              fit: StackFit.expand,
              children: <Widget>[
                isLoading
                    ? new Image.asset(
                        "images/back.jpg",
                        fit: BoxFit.fitWidth,
                      )
                    : getImage(last) != null
                        ? new Image.file(
                            getImage(last),
                            fit: BoxFit.cover,
                          )
                        : new Image.asset(
                            "images/back.jpg",
                            fit: BoxFit.fitWidth,
                          ),
              ],
            ),
          ),
        ),

        new SliverList(
          delegate: !isLoading
              ? new SliverChildListDelegate(<Widget>[
                  new Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                    child: new Text(
                      "Quick actions",
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new FloatingActionButton(
                            heroTag: "history",
                            onPressed: () {
                              Navigator.of(context).push(
                                  new MaterialPageRoute(builder: (context) {
                                return new ListSongs(widget.db, 1,orientation);
                              }));
                            },
                            child: new Icon(Icons.history),
                          ),
                          new Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0)),
                          new Text("Recents"),
                        ],
                      ),
                      new Column(
                        children: <Widget>[
                          new FloatingActionButton(
                            heroTag: "Top",
                            onPressed: () {
                              Navigator.of(context).push(
                                  new MaterialPageRoute(builder: (context) {
                                return new ListSongs(widget.db, 2,orientation);
                              }));
                            },
                            child: new Icon(Icons.show_chart),
                          ),
                          new Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0)),
                          new Text("Top songs"),
                        ],
                      ),
                      new Column(
                        children: <Widget>[
                          new FloatingActionButton(
                            heroTag: "shuffle",
                            onPressed: () {
                              MyQueue.songs = songs;
                              Navigator.of(context).push(
                                  new MaterialPageRoute(builder: (context) {
                                return new NowPlaying(widget.db, songs,
                                    new Random().nextInt(songs.length), 0);
                              }));
                            },
                            child: new Icon(Icons.shuffle),
                          ),
                          new Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0)),
                          new Text("Random"),
                        ],
                      ),
                    ],
                  ),
                  new Divider(),
                  new Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                    child: new Text(
                      "Your recents!",
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  recentW(),
                  new Divider(),
                  new Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                    child: new Text(
                      "You may like!",
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  randomW(),
                ])
              : new SliverChildListDelegate(<Widget>[
                  new Center(
                    child: new CircularProgressIndicator(),
                  )
                ]),
        ),
      ],
    );

  }

  Widget randomW() {
    return new Container(
      //aspectRatio: 16/15,
      height: 200.0,
      child: new ListView.builder(
        itemCount: albums.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) => new Card(
              child: new InkResponse(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      child: getImage(albums[i]) != null
                          ? new Image.file(
                              getImage(albums[i]),
                              height: 120.0,
                              width: 200.0,
                              fit: BoxFit.cover,
                            )
                          : new Image.asset(
                              "images/back.jpg",
                              height: 120.0,
                              width: 200.0,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(
                      width: 200.0,
                      child: Padding(
                        // padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                        padding: EdgeInsets.fromLTRB(4.0, 8.0, 0.0, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              albums[i].album,
                              style: new TextStyle(fontSize: 18.0),
                              maxLines: 1,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              albums[i].artist,
                              maxLines: 1,
                              style:
                                  TextStyle(fontSize: 14.0, color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator
                      .of(context)
                      .push(new MaterialPageRoute(builder: (context) {
                    return new CardDetail(widget.db, albums[i], 0);
                  }));
                },
              ),
            ),
      ),
    );
  }

  Widget recentW() {
    return new Container(
      //aspectRatio: 16/15,
      height: 200.0,
      child: new ListView.builder(
        itemCount: recents.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) => new Card(
              child: new InkResponse(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      child: getImage(recents[i]) != null
                          ? new Image.file(
                              getImage(recents[i]),
                              height: 120.0,
                              width: 200.0,
                              fit: BoxFit.cover,
                            )
                          : new Image.asset(
                              "images/back.jpg",
                              height: 120.0,
                              width: 200.0,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(
                      width: 200.0,
                      child: Padding(
                        // padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                        padding: EdgeInsets.fromLTRB(4.0, 8.0, 0.0, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              recents[i].title,
                              style: new TextStyle(fontSize: 18.0),
                              maxLines: 1,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              recents[i].artist,
                              maxLines: 1,
                              style:
                                  TextStyle(fontSize: 14.0, color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  MyQueue.songs = recents;
                  Navigator
                      .of(context)
                      .push(new MaterialPageRoute(builder: (context) {
                    return new NowPlaying(widget.db, recents, i, 0);
                  }));
                },
              ),
            ),
      ),
    );
  }
}
