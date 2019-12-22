import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/card_detail.dart';
import 'package:musicplayer/pages/list_songs.dart';
import 'package:musicplayer/pages/material_search.dart';
import 'package:musicplayer/pages/now_playing.dart';
import 'package:musicplayer/sc_model/model.dart';
import 'package:musicplayer/util/lastplay.dart';
import 'package:musicplayer/util/utility.dart';
import 'package:scoped_model/scoped_model.dart';

class Home extends StatefulWidget {
  final DatabaseClient db;
  Home(this.db);
  @override
  State<StatefulWidget> createState() {
    return new stateHome();
  }
}

class stateHome extends State<Home> with AutomaticKeepAliveClientMixin{
  List<Song> albums, recents, songs;
  bool isLoading = true;
  Song last;
  Song top;
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    albums = await widget.db.fetchRandomAlbum();
    last = await widget.db.fetchLastSong();
    songs = await widget.db.fetchSongs();
    recents = await widget.db.fetchRecentSong();
    recents.removeAt(0);
    top = await widget.db.fetchTopSong().then((item) => item[0]);
    // ScopedModel
    //     .of<SongModel>(context, rebuildOnChange: true)
    //     .recents = recents;
    ScopedModel.of<SongModel>(context, rebuildOnChange: true).init(widget.db);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return new CustomScrollView(
      slivers: <Widget>[
        new SliverAppBar(
          expandedHeight: MediaQuery
              .of(context)
              .size
              .height / 2.4,
          floating: false,
          pinned: true,
          title: new Text("Music Player"),
          actions: <Widget>[
            new IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator.of(context)
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
                ScopedModelDescendant<SongModel>(
                  builder: (context, child, model) {
                    return new Hero(
                      tag: model.song == null ? "" : model.song.id,
                      child: model.song == null
                          ? new Image.asset(
                        "images/back.jpg",
                        fit: BoxFit.cover,
                      )
                          : getImage(model.song) != null
                          ? new Image.file(
                        getImage(model.song),
                        fit: BoxFit.cover,
                      )
                          : new Image.asset(
                        "images/back.jpg",
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        new SliverList(
          delegate: !isLoading
              ? new SliverChildListDelegate(<Widget>[
                  new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      elevation: 1,
                      // onPressed: (){},
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.play_circle_outline,
                                size: 50.0,
                                color: Theme
                                    .of(context)
                                    .accentColor,
                              ),
                              ScopedModelDescendant<SongModel>(
                                  builder: (context, child, model) {
                                    return Flexible(
                                      child: RotateAnimatedTextKit(


                                          text: model.song == null
                                              ? [
                                            "One good thing about music, when it hits you, you feel no pain.",
                                            "Music is the strongest form of magic.",
                                            "Music is an outburst of the soul"
                                          ]
                                              : [
                                            model.song.title,
                                            model.song.artist,
                                            model.song.album
                                          ],
                                          textStyle: TextStyle(
                                            fontSize: 17.0,
                                          ),
                                          textAlign: TextAlign.left,
                                          alignment: AlignmentDirectional
                                              .topStart // or Alignment.topLeft
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
                            heroTag: "favourites",
                            onPressed: () {
                              Navigator.of(context).push(
                                  new MaterialPageRoute(builder: (context) {
                                    return new ListSongs(
                                        widget.db, 3, orientation);
                              }));
                            },
                            child: new Icon(Icons.favorite_border),
                          ),
                          new Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0)),
                          new Text("Favourites"),
                        ],
                      ),
                      new Column(
                        children: <Widget>[
                          new FloatingActionButton(
                            heroTag: "Top",
                            onPressed: () {
                              Navigator.of(context).push(
                                  new MaterialPageRoute(builder: (context) {
                                return new ListSongs(widget.db, 2, orientation);
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
                              MyQueue.songs.shuffle();
                              Navigator.of(context).push(
                                  new MaterialPageRoute(builder: (context) {
                                return new NowPlaying(widget.db, MyQueue.songs,
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
                      "Albums you may like!",
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  randomW(),
                  new Divider(),
                  new Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                    child: new Text(
                      "Trending!",
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  ScopedModelDescendant<SongModel>(
                      builder: (context, child, model) {
                        return new Card(
                          child: new InkResponse(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                    child: new Hero(
                                      tag: _top(model).timestamp,
                                      child: getImage(_top(model)) != null
                                          ? new Image.file(
                                        getImage(_top(model)),
                                        height: 180.0,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        fit: BoxFit.cover,
                                      )
                                          : new Image.asset(
                                        "images/back.jpg",
                                        height: 180.0,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                                SizedBox(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  child: Padding(
                                    // padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                                    padding:
                                    EdgeInsets.fromLTRB(4.0, 8.0, 0.0, 0.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        Text(
                                          _top(model).title,
                                          style: new TextStyle(fontSize: 18.0),
                                          maxLines: 1,
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          _top(model).artist,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.grey),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              List<Song> list = new List();
                              list.add(_top(model));
                              MyQueue.songs = list;
                              Navigator.of(context)
                                  .push(
                                  new MaterialPageRoute(builder: (context) {
                                    return new NowPlaying(
                                        widget.db, list, 0, 0);
                                  }));
                            },
                          ),
                        );
                      })
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
                    child: new Hero(
                      tag: albums[i].album,
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
                    )),
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
                          style: TextStyle(fontSize: 14.0, color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context)
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
      child: ScopedModelDescendant<SongModel>(builder: (context, child, model) {
        return new ListView.builder(
            itemCount: _recents(model).length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) =>
            new Card(
              child: new InkResponse(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      child: new Hero(
                        tag: _recents(model)[i],
                        child: getImage(_recents(model)[i]) != null
                            ? new Image.file(
                          getImage(_recents(model)[i]),
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
                              _recents(model)[i].title,
                              style: new TextStyle(fontSize: 18.0),
                              maxLines: 1,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              _recents(model)[i].artist,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  MyQueue.songs = model.recents;

                  Navigator.of(context)
                      .push(new MaterialPageRoute(builder: (context) {
                    return new NowPlaying(widget.db, model.recents, i, 0);
                  }));
                },
              ),
            ));
      }),
    );
  }

  List<Song> _recents(SongModel model) {
    return model.recents == null ? recents : model.recents;
  }

  Song _top(model) {
    return model.top == null ? top : model.top;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
