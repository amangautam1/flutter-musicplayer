import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _settingState();
  }
}

class _settingState extends State<Settings> {
  var isLoading = false;
  var selected = 0;
  var db;

  @override
  void initState() {
    super.initState();
    db = DatabaseClient();
    db.create();
  }

  @override
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldState,
      appBar: new AppBar(
        title: new Text("Settings"),
      ),
      body: new Container(
        child: Column(
          children: <Widget>[
            new ListTile(
                leading:
                new Icon(Icons.style, color: Theme.of(context).accentColor),
                title: new Text(("Theme")),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return new SimpleDialog(
                          title: new Text("Select theme"),
                          children: <Widget>[
                            new ListTile(
                              title: Text("Light"),
                              onTap: () {
                                DynamicTheme.of(context).setBrightness(
                                    Brightness.light
                                );
                              
                                Navigator.of(context).pop();
                              },
                              trailing: Theme
                                  .of(context)
                                  .brightness ==
                                  Brightness.light
                                  ? Icon(Icons.check)
                                  : null,
                            ),
                            new ListTile(
                              title: Text("Dark"),
                              onTap: () {
                                DynamicTheme.of(context).setBrightness(
                                    Brightness.dark);
                          
                                Navigator.of(context).pop();
                              },
                              trailing: Theme
                                  .of(context)
                                  .brightness ==
                                  Brightness.dark
                                  ? Icon(Icons.check)
                                  : null,
                            ),
                          ],
                        );
                      });
                }),
            new Divider(),
            new ListTile(
              leading: new Icon(
                Icons.build,
                color: Theme.of(context).accentColor,
              ),
              title: new Text("Re-scan/Reset Media"),
              onTap: () async {
                setState(() {
                  isLoading = true;
                });
                var db = new DatabaseClient();
                await db.create();
                var songs;
                try {
                  songs = await MusicFinder.allSongs();
                } catch (e) {
                  print("failed to get songs");
                }
                List<Song> list = new List.from(songs);
                for (Song song in list)
                  db.updateList(song);
                setState(() {
                  isLoading = false;
                });
              },
            ),
            new Divider(),


            new Container(
                child: isLoading
                    ? new Center(
                  child: new Column(
                    children: <Widget>[
                      new CircularProgressIndicator(),
                      new Text("Loading Songs"),
                    ],
                  ),
                )
                    : new Container()),
          ],
        ),
      ),
    );
  }
}
