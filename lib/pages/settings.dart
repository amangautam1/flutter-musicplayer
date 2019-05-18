import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/about.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _settingState();
  }
}

class _settingState extends State<Settings> {
  var isLoading = false;
  var selected = 0;
  void getheme() async {
    var pref = await SharedPreferences.getInstance();
    setState(() {
      selected = pref.getInt("theme") == null ? 0 : pref.getInt("theme");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getheme();
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
                onTap: () async {
                 var result= showDialog(
                      context: context,
                      builder: (context) {
                        return new SimpleDialog(
                          title: new Text("Select theme"),
                          children: <Widget>[
                            new RadioListTile(
                              value: 0,
                              groupValue: selected,
                              onChanged: (value) {
                                Navigator.pop(context,value);
                              },
                              title: new Text("Light"),
                            ),
                            new RadioListTile(
                              value: 1,
                              groupValue: selected,
                              onChanged: (value) {
                                Navigator.pop(context,value);
                              },
                              title: new Text("Dark"),
                            )
                          ],
                        );
                      });
                  var pref = await SharedPreferences.getInstance();

                  if (await result == null) {
                    return;
                  } else
                    switch (await result) {
                      case 1:
                        {
                          pref.setInt("theme", 1);
                          scaffoldState.currentState.showSnackBar(new SnackBar(
                              content: new Text(
                                  "Changes will affect on next restart.")));
                          break;
                        }
                      case 0:
                        {
                          pref.setInt("theme", 0);
                          scaffoldState.currentState.showSnackBar(new SnackBar(
                              content: new Text(
                                  "Changes will affect on next restart.")));
                          break;
                        }
                    }
                }),
            new Divider(),
            new ListTile(
              leading: new Icon(
                Icons.build,
                color: Theme.of(context).accentColor,
              ),
              title: new Text("Rebuild database"),
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
                for (Song song in list) db.upsertSOng(song);
                setState(() {
                  isLoading = false;
                });
              },
            ),
            new Divider(),
            new ListTile(
              leading:
                  new Icon(Icons.info, color: Theme.of(context).accentColor),
              title: new Text("About"),
              onTap: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) {
                  return new About();
                }));
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
