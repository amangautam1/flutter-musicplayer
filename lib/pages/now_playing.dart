import 'dart:async';
import 'dart:io';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/util/lastplay.dart';
import 'package:local_notifications/local_notifications.dart';

class NowPlaying extends StatefulWidget {
  int mode;
  List<Song> songs;
  int index;
  DatabaseClient db;
  NowPlaying(this.db, this.songs, this.index, this.mode);
  @override
  State<StatefulWidget> createState() {
    return new _stateNowPlaying();
  }
}

class _stateNowPlaying extends State<NowPlaying> {
  MusicFinder player;
  Duration duration;
  Duration position;
  bool isPlaying = false;
  Song song;
  int isfav = 1;
  Orientation orientation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  //  SystemChrome.setPreferredOrientations(
    //    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    initPlayer();
  }

  void initPlayer() async {
    if (player == null) {
      player = MusicFinder();
      LastPlay.player=player;
    }
    //  int i= await widget.db.isfav(song);
    setState(() {
      if (widget.mode == 0) {
        player.stop();
      }
      updatePage(widget.index);
      print("song count=${song.count}"); // song = widget.song;
      isPlaying = true;
    });
    player.setDurationHandler((d) => setState(() {
          duration = d;
        }));
    player.setPositionHandler((p) => setState(() {
          position = p;
        }));
    player.setCompletionHandler(() {
      onComplete();
      setState(() {
        position = duration;
        int i = ++widget.index;
        song = widget.songs[i];
      });
    });
    player.setErrorHandler((msg) {
      setState(() {
        player.stop();
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }


  void updatePage(int index) {
    LastPlay.index = index;
    song = widget.songs[index];
    song.timestamp = new DateTime.now().millisecondsSinceEpoch;
    if (song.count == null) {
      song.count = 0;
    } else {
      song.count++;
    }
    widget.db.updateSong(song);
    isfav = song.isFav;
    player.play(song.uri);
    isPlaying = true;

  }

  void _playpause() {
    if (isPlaying) {
      player.pause();
      setState(() {
        isPlaying = false;
        //  song = widget.songs[widget.index];
      });
    } else {
      player.play(song.uri);
      setState(() {
        //song = widget.songs[widget.index];
        isPlaying = true;
      });
    }
  }

  Future next() async {
    player.stop();
    // int i=await widget.db.isfav(song);
    setState(() {
      int i = ++widget.index;
      if (i >= widget.songs.length) {
        i = widget.index = 0;
      }
      updatePage(i);
    });
  }

  Future prev() async {
    player.stop();
    //   int i=await  widget.db.isfav(song);
    setState(() {
      int i = --widget.index;
      if (i < 0) {
        widget.index = 0;
        i = widget.index;
      }
      updatePage(i);
    });
  }

  void onComplete() {
    next();
  }

  dynamic getImage(Song song) {
    return song.albumArt == null
        ? null
        : new File.fromUri(Uri.parse(song.albumArt));
  }

  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    orientation=MediaQuery.of(context).orientation;
    return new Scaffold(
      key: scaffoldState,
      body: orientation==Orientation.portrait?potrait():landscape()
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return new Container(
              height: 450.0,
              child: new ListView.builder(
                itemCount: widget.songs.length,
                itemBuilder: (context, i) => new Column(
                      children: <Widget>[
                        new Divider(
                          height: 8.0,
                        ),
                        new ListTile(
                          leading: new CircleAvatar(
                            child: widget.songs[i].id ==
                                    LastPlay.songs[LastPlay.index].id
                                ? new Icon(Icons.insert_chart)
                                : getImage(widget.songs[i]) != null
                                    ? new Image.file(
                                        getImage(widget.songs[i]),
                                        height: 120.0,
                                        fit: BoxFit.cover,
                                      )
                                    : new Text(
                                        widget.songs[i].title[0].toUpperCase()),
                          ),
                          title: new Text(widget.songs[i].title,
                              maxLines: 1,
                              style: new TextStyle(fontSize: 18.0)),
                          subtitle: new Text(
                            widget.songs[i].artist,
                            maxLines: 1,
                            style: new TextStyle(
                                fontSize: 12.0, color: Colors.grey),
                          ),
                          trailing: new Text(
                            (i + 1).toString(),
                            style: new TextStyle(
                                fontSize: 12.0, color: Colors.grey),
                          ),
                          onTap: () {
                            setState(() {
                              LastPlay.index = i;
                              player.stop();
                              updatePage(LastPlay.index);
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ],
                    ),
              ));
        });
  }

  Widget potrait(){
    return new Container(
      // color: Colors.transparent,
      child: new Column(
        children: <Widget>[
          new AspectRatio(
            aspectRatio: 15 / 15,
            child: getImage(song) != null
                ? new Image.file(
              getImage(song),
              fit: BoxFit.cover,
            )
                : new Image.asset(
              "images/back.jpg",
              fit: BoxFit.fitHeight,
            ),
          ),
          new Slider(
            min: 0.0,
            value: position?.inMilliseconds?.toDouble() ?? 0.0,
            onChanged: (double value) =>
                player.seek((value / 1000).roundToDouble()),
            max: song.duration.toDouble() + 1000,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: new Text(position.toString().split('.').first),
              ),
              new Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: new Text(
                  new Duration(milliseconds: song.duration)
                      .toString()
                      .split('.')
                      .first,
                ),
              ),
            ],
          ),
          new Expanded(
            child: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(
                    song.title,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  new Text(
                    song.artist,
                    maxLines: 1,
                    style: new TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          new Expanded(
            child: new Center(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new IconButton(
                    icon: new Icon(Icons.skip_previous, size: 40.0),
                    onPressed: prev,
                  ),
                  new Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0)),
                  new FloatingActionButton(
                      child: !isPlaying
                          ? new Icon(Icons.play_arrow)
                          : new Icon(Icons.pause),
                      onPressed: _playpause),
                  new Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0)),
                  new IconButton(
                    icon: new Icon(Icons.skip_next, size: 40.0),
                    onPressed: next,
                  ),
                ],
              ),
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new IconButton(
                  icon: new Icon(Icons.shuffle),
                  onPressed: () {
                    widget.songs.shuffle();
                    scaffoldState.currentState.showSnackBar(
                        new SnackBar(content: new Text("List Suffled")));
                  }),
              new IconButton(
                  icon: new Icon(Icons.queue_music),
                  onPressed: _showBottomSheet),
              new IconButton(
                  icon: isfav == 0
                      ? new Icon(Icons.favorite_border)
                      : new Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setFav(song);
                  })
            ],
          )
        ],
      ),
    );
  }

  Widget landscape(){
    return new Row(
      children: <Widget>[
        new Container(
          width:350.0,
            child:  new AspectRatio(
          aspectRatio: 15 / 19,
          child: getImage(song) != null
              ? new Image.file(
            getImage(song),
            fit: BoxFit.cover,
          )
              : new Image.asset(
            "images/back.jpg",
            fit: BoxFit.fitHeight,
          ),
        ),
        ),
        new Expanded(
          child: new Column(
            children: <Widget>[

              new Expanded(
                child: new Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text(
                        song.title,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      new Text(
                        song.artist,
                        maxLines: 1,
                        style: new TextStyle(fontSize: 14.0, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              new Slider(
                min: 0.0,
                value: position?.inMilliseconds?.toDouble() ?? 0.0,
                onChanged: (double value) =>
                    player.seek((value / 1000).roundToDouble()),
                max: song.duration.toDouble() + 1000,
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: new Text(position.toString().split('.').first),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: new Text(
                      new Duration(milliseconds: song.duration)
                          .toString()
                          .split('.')
                          .first,
                    ),
                  ),
                ],
              ),
              new Expanded(
                child: new Center(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new IconButton(
                        icon: new Icon(Icons.skip_previous, size: 40.0),
                        onPressed: prev,
                      ),
                      new Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0)),
                      new FloatingActionButton(
                          child: !isPlaying
                              ? new Icon(Icons.play_arrow)
                              : new Icon(Icons.pause),
                          onPressed: _playpause),
                      new Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0)),
                      new IconButton(
                        icon: new Icon(Icons.skip_next, size: 40.0),
                        onPressed: next,
                      ),
                    ],
                  ),
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new IconButton(
                      icon: new Icon(Icons.shuffle),
                      onPressed: () {
                        widget.songs.shuffle();
                        scaffoldState.currentState.showSnackBar(
                            new SnackBar(content: new Text("List Suffled")));
                      }),
                  new IconButton(
                      icon: new Icon(Icons.queue_music),
                      onPressed: _showBottomSheet),
                  new IconButton(
                      icon: isfav == 0
                          ? new Icon(Icons.favorite_border)
                          : new Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setFav(song);
                      })
                ],
              )
            ],
          ),
        )
      ],
    );
  }
  Future<void> setFav(song) async {
    int i = await widget.db.favSong(song);
    setState(() {
      if (isfav == 1)
        isfav = 0;
      else
        isfav = 1;
    });
  }
}
