import 'dart:async';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/util/lastplay.dart';
import 'package:musicplayer/util/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _stateNowPlaying extends State<NowPlaying>
    with SingleTickerProviderStateMixin {
  MusicFinder player;
  Duration duration;
  Duration position;
  bool isPlaying = false;
  Song song;
  int isfav;
  Orientation orientation;
  AnimationController _animationController;
  Animation<Color> _animateColor;
  bool isOpened = true;
  Animation<double> _animateIcon;
  @override
  void initState() {
    super.initState();
    initAnim();
    initPlayer();
  }

  initAnim() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animateColor = ColorTween(
      begin: Colors.deepPurple,
      end: Colors.purpleAccent[700],
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
  }

  animateForward() {
    _animationController.forward();
  }

  animateReverse() {
    _animationController.reverse();
  }

  void initPlayer() async {
    if (player == null) {
      player = MusicFinder();
      MyQueue.player = player;
      var pref = await SharedPreferences.getInstance();
      pref.setBool("played", true);
    }
    setState(() {
      if (widget.mode == 0) {
        player.stop();
      }
      updatePage(widget.index);
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
    MyQueue.index = index;
    song = widget.songs[index];
    widget.index = index;
    song.timestamp = new DateTime.now().millisecondsSinceEpoch;
    if (song.count == null) {
      song.count = 0;
    } else {
      song.count++;
    }
    if (widget.db != null && song.id != 9999 /*shared song id*/)
      widget.db.updateSong(song);
    isfav = song.isFav;
    player.play(song.uri);
    animateReverse();
    setState(() {
      isPlaying = true;
      isfav = song.isFav;
      // isOpened = !isOpened;
    });
  }

  void _playpause() {
    if (isPlaying) {
      player.pause();
      animateForward();
      setState(() {
        isPlaying = false;
      });
    } else {
      player.play(song.uri);
      animateReverse();
      setState(() {
        isPlaying = true;
      });
    }
  }

  Future next() async {
    player.stop();
    print(widget.index);
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

  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    orientation = MediaQuery.of(context).orientation;
    return new Scaffold(
      key: scaffoldState,
      body: Stack(children: <Widget>[
        orientation == Orientation.portrait ? potrait() : landscape(),
        new Positioned(
          //Place it at the top, and not use the entire screen
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: AppBar(
            title: Text('Now Playing'),
            backgroundColor: Colors.transparent, //No more green
            elevation: 0.0, //Shadow gone
            leading: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => {Navigator.pop(context)},
            ),
          ),
        ),
      ]),
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
                          leading: avatar(context, getImage(widget.songs[i]),
                              widget.songs[i].title),
                          title: new Text(widget.songs[i].title,
                              maxLines: 1,
                              style: new TextStyle(fontSize: 18.0)),
                          subtitle: new Text(
                            widget.songs[i].artist,
                            maxLines: 1,
                            style: new TextStyle(
                                fontSize: 12.0, color: Colors.grey),
                          ),
                          trailing: song.id == widget.songs[i].id
                              ? new Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.deepPurple,
                                )
                              : new Text(
                                  (i + 1).toString(),
                                  style: new TextStyle(
                                      fontSize: 12.0, color: Colors.grey),
                                ),
                          onTap: () {
                            player.stop();
                            updatePage(i);
                            print(i);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
              ));
        });
  }

  Widget potrait() {
    return new Container(
      // color: Colors.transparent,
      child: new Column(
        children: <Widget>[
          new AspectRatio(
            aspectRatio: 15 / 15,
            child: new Hero(
              tag: song.id,
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
          new Slider(
            min: 0.0,
            value: position?.inMilliseconds?.toDouble() ?? 0.0,
            max: song.duration.toDouble() + 1000,
            onChanged: (double value) =>
                player.seek((value / 1000).roundToDouble()),
            divisions: song.duration,
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new IconButton(
                    icon: new Icon(Icons.skip_previous, size: 40.0),
                    onPressed: prev,
                  ),
                  new FloatingActionButton(
                    backgroundColor: _animateColor.value,
                    child: new AnimatedIcon(
                        icon: AnimatedIcons.pause_play, progress: _animateIcon),
                    onPressed: _playpause,
                  ),
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
                  icon: Icon(Icons.playlist_add),
//                  isfav == 0
//                      ? new Icon(Icons.favorite_border)
//                      : new Icon(
//                          Icons.favorite,
//                          color: Colors.deepPurple,
//                        ),
                  onPressed: () {
                    setFav(song);

                    scaffoldState.currentState.showSnackBar(
                        new SnackBar(content: new Text("Song added to favourites")));
                  })
            ],
          )
        ],
      ),
    );
  }

  Widget landscape() {
    return new Row(
      children: <Widget>[
        new Container(
          width: 350.0,
          child: new AspectRatio(
              aspectRatio: 15 / 19,
              child: new Hero(
                tag: song.id,
                child: getImage(song) != null
                    ? new Image.file(
                        getImage(song),
                        fit: BoxFit.cover,
                      )
                    : new Image.asset(
                        "images/back.jpg",
                        fit: BoxFit.fitHeight,
                      ),
              )),
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
                        style:
                            new TextStyle(fontSize: 14.0, color: Colors.grey),
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new IconButton(
                        icon: new Icon(Icons.skip_previous, size: 40.0),
                        onPressed: prev,
                      ),
                      //fab,
                      new FloatingActionButton(
                        backgroundColor: _animateColor.value,
                        child: new AnimatedIcon(
                            icon: AnimatedIcons.pause_play,
                            progress: _animateIcon),
                        onPressed: _playpause,
                      ),
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
                     icon: Icon(Icons.playlist_add),
                  //isfav == 0
//                          ? new Icon(Icons.favorite_border)
//                          : new Icon(
//                              Icons.favorite,
//                              color: Colors.deepPurple,
//                            ),
                      onPressed: () {
                        setFav(song);
                        scaffoldState.currentState.showSnackBar(
                            new SnackBar(content: new Text("Song added to favourites")));

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
    var i = await widget.db.favSong(song);
    print(i);
//    setState(() {
//      if (i == "added") {
//        isfav = 1;
//        widget.songs[widget.index].isFav=1;
//      }
//      else {
//        isfav = 0;
//        widget.songs[widget.index].isFav=1;
//      }
//    });
  }
}
