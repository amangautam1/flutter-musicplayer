import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/list_songs.dart';
import 'package:musicplayer/sc_model/model.dart';
import 'package:scoped_model/scoped_model.dart';

class PlayList extends StatefulWidget {
  DatabaseClient db;
  PlayList(this.db);

  @override
  State<StatefulWidget> createState() {
    return new _statePlaylist();
  }
}

class _statePlaylist extends State<PlayList> with AutomaticKeepAliveClientMixin {
  var mode;
  var selected;
  Orientation orientation;
  @override
  void initState() {
    mode = 1;
    selected = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    orientation = MediaQuery.of(context).orientation;
    return new Container(
      child: /*orientation == Orientation.portrait ? */potrait() /*: landscape()*/,
    );
  }

  Widget potrait() {
    return new ListView(
      children: <Widget>[
        new ListTile(
          leading: new Icon(Icons.call_received,
              color: Theme.of(context).accentColor),
          title: new Text("Recently played"),
          subtitle: new Text("songs"),
          onTap: () {
            Navigator.of(context)
                .push(new MaterialPageRoute(builder: (context) {
              return new ListSongs(widget.db, 1, orientation);
            }));
          },
        ),
        new Divider(),
        new ListTile(
          leading:
              new Icon(Icons.show_chart, color: Theme.of(context).accentColor),
          title: new Text("Top tracks"),
          subtitle: new Text("songs"),
          onTap: () {
            Navigator.of(context)
                .push(new MaterialPageRoute(builder: (context) {
              return new ListSongs(widget.db, 2, orientation);
            }));
          },
        ),
        new Divider(),
        new ListTile(
          leading:
              new Icon(Icons.favorite, color: Theme.of(context).accentColor),
          title: new Text("Favourites"),
          subtitle: new Text("Songs"),
          onTap: () {
            Navigator.of(context)
                .push(new MaterialPageRoute(builder: (context) {
              return new ListSongs(widget.db, 3, orientation);
            }));
          },
        ),
        new Divider(),
      ],
    );
  }

  Widget landscape() {
    return new Row(
      children: <Widget>[
        new Container(
          width: MediaQuery
              .of(context)
              .size
              .width / 2.5,
          child: new ListView(
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.call_received),
                title: new Text("Recently played",
                    style: new TextStyle(
                        color: selected == 1 ? Colors.deepPurpleAccent : Colors
                            .black)),
                subtitle: new Text("songs"),
                onTap: () {
                  setState(() {
                    mode = 1;
                    selected = 1;
                  });
                },
              ),
              new Divider(),
              ScopedModelDescendant<SongModel>(
                  builder: (context, child, model) {
                    return new ListTile(
                leading: new Icon(Icons.show_chart),
                title: new Text("Top tracks",
                    style: new TextStyle(
                        color: selected == 2 ? Colors.deepPurpleAccent : Colors
                            .black)),
                subtitle: new Text("songs"),
                        onTap: () => model.setMode(2)
                    );
                  }),
              new Divider(),
              ScopedModelDescendant<SongModel>(
                  builder: (context, child, model) {
                    return
                      new ListTile(
                        leading: new Icon(Icons.favorite),
                        title: new Text("Favourites",
                            style: new TextStyle(
                                color: selected == 3
                                    ? Colors.deepPurpleAccent
                                    : Colors.black)),
                        subtitle: new Text("Songs"),
                        onTap: () {
                          model.setMode(3);
                          // setState(() {
                          //   mode = 3;
                          //   selected = 3;
                          // });
                        },
                      );
                  }),
              new Divider(),
            ],
          ),
        ),
        ScopedModelDescendant<SongModel>(
            builder: (context, child, model) {
              return new Expanded(
            child: new Container(
              child: new ListSongs(widget.db, model.mode, orientation),
            ));
            })
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
