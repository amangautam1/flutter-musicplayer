import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/list_songs.dart';

class PlayList extends StatefulWidget {
  DatabaseClient db;
  PlayList(this.db);
  @override
  State<StatefulWidget> createState() {
    return new _statePlaylist();
  }
}

class _statePlaylist extends State<PlayList> {
  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: <Widget>[
        new ListTile(
          leading: new Icon(Icons.call_received),
          title: new Text("Recently added"),
          subtitle: new Text("songs"),
          onTap: () {
            Navigator
                .of(context)
                .push(new MaterialPageRoute(builder: (context) {
              return new ListSongs(widget.db, 1);
            }));
          },
        ),
        new Divider(),
        new ListTile(
          leading: new Icon(Icons.show_chart),
          title: new Text("Top tracks"),
          subtitle: new Text("songs"),
          onTap: () {
            Navigator
                .of(context)
                .push(new MaterialPageRoute(builder: (context) {
              return new ListSongs(widget.db, 2);
            }));
          },
        ),
        new Divider(),
        new ListTile(
          leading: new Icon(Icons.favorite),
          title: new Text("Favourites"),
          subtitle: new Text("Songs"),
          onTap: () {
            Navigator
                .of(context)
                .push(new MaterialPageRoute(builder: (context) {
              return new ListSongs(widget.db, 3);
            }));
          },
        )
      ],
    );
  }
}
