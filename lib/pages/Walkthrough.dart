import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/musichome.dart';

class TestScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new WalkState();
  }
}

class WalkState extends State<TestScreen> {
  var db;
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.deepPurple,
        body: SafeArea(
          child: new Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.queue_music, color: Colors.white, size: 100.0),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 5),
                  child: Text(
                    "Music player",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                    ),
                  ),
                ),
                isLoading ? CircularProgressIndicator() : Container(),
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Wait...",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  loadSongs() async {
    setState(() {
      isLoading = true;
    });
    var db = new DatabaseClient();
    await db.create();
    if (await db.alreadyLoaded()) {
      Navigator.of(context).pop();
      Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
        return new MusicHome();
      }));
    } else {
      var songs;
      try {
        songs = await MusicFinder.allSongs();
        List<Song> list = new List.from(songs);
        if (list == null || list.length == 0) {
          Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Row(
            children: <Widget>[
              Text("No songs found"),
              FlatButton(
                child: Text("Ok"),
                onPressed: () => {SystemNavigator.pop()},
              )
            ],
          )));
        }
        for (Song song in list) db.upsertSOng(song);
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop(true);
        Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
          return new MusicHome();
        }));
      } catch (e) {
        print("failed to get songs");
      }
    }
  }
}
