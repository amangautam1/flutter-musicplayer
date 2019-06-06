import 'dart:io';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/now_playing.dart';
import 'package:musicplayer/util/lastplay.dart';
import 'package:musicplayer/util/utility.dart';

class CardDetail extends StatefulWidget {
  int id;
  var album;
  Song song;
  int mode;
  DatabaseClient db;
  CardDetail(this.db, this.song, this.mode);
  @override
  State<StatefulWidget> createState() {
    return new stateCardDetail();
  }
}

class stateCardDetail extends State<CardDetail> {
  List<Song> songs;
  bool isLoading = true;
  var image;
  @override
  void initState() {
    super.initState();
    initAlbum();
  }

  void initAlbum() async {
    image = widget.song.albumArt == null
        ? null
        : new File.fromUri(Uri.parse(widget.song.albumArt));
    if (widget.mode == 0)
      songs = await widget.db.fetchSongsfromAlbum(widget.song.albumId);
    else
      songs = await widget.db.fetchSongsByArtist(widget.song.artist);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return new Scaffold(
      body: isLoading
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : new CustomScrollView(
              slivers: <Widget>[
                new SliverAppBar(
                  expandedHeight:
                      orientation == Orientation.portrait ? 350.0 : 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: new FlexibleSpaceBar(
                    title: widget.mode == 0
                        ? new Text(
                            widget.song.album,
                          )
                        : new Text(widget.song.artist),
                    background: new Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        new Hero(
                          tag: widget.mode == 0
                              ? widget.song.album
                              : widget.song.artist,
                          child: image != null
                              ? new Image.file(
                                  image,
                                  fit: BoxFit.cover,
                                )
                              : new Image.asset("images/back.jpg",
                                  fit: BoxFit.cover),
                        ),
                      ],
                    ),
                  ),
                ),
                new SliverList(
                  delegate: new SliverChildListDelegate(<Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: new Text(
                        widget.mode == 0
                            ? widget.song.album
                            : widget.song.artist,
                        style: new TextStyle(
                            fontSize: 30.0, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: new Text(
                        widget.mode == 0 ? widget.song.artist : "",
                        style: new TextStyle(fontSize: 14.0),
                        maxLines: 1,
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 10.0, bottom: 10.0),
                      child: new Text(songs.length.toString() + " song(s)"),
                    ),
                    new Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: new Text("Songs",
                            style: new TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ))),
                  ]),
                ),
                new SliverList(
                  delegate: new SliverChildBuilderDelegate((builder, i) {
                    return new ListTile(
                      leading: new CircleAvatar(
                        child: new Hero(
                          tag: songs[i].id,
                          child: avatar(
                              context, getImage(songs[i]), songs[i].title),
                        ),
                      ),
                      title: new Text(songs[i].title,
                          maxLines: 1, style: new TextStyle(fontSize: 18.0)),
                      subtitle: new Text(
                        songs[i].artist,
                        maxLines: 1,
                        style:
                            new TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      trailing: new Text(
                          new Duration(milliseconds: songs[i].duration)
                              .toString()
                              .split('.')
                              .first,
                          style: new TextStyle(
                              fontSize: 12.0, color: Colors.grey)),
                      onTap: () {
                        MyQueue.songs = songs;
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (context) =>
                                new NowPlaying(widget.db, songs, i, 0)));
                      },
                    );
                  }, childCount: songs.length),
                ),
              ],
            ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          MyQueue.songs = songs;
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) =>
                  new NowPlaying(widget.db, MyQueue.songs, 0, 0)));
        },
        child: new Icon(Icons.shuffle),
      ),
    );
  }
}
