import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("About"),
        ),
        body: new Center(
          child: new Container(
              height: 150.0,
              child: new Center(
                child: new Card(
                  child: new Column(
                    children: <Widget>[
                      new CircleAvatar(
                        radius: 30.0,
                        backgroundImage: new AssetImage("images/avatar.jpg"),
                      ),
                      new Text(" Music PLayer"),
                      new Text("Checkout this project on GitHub"),
                      new IconButton(
                        icon: new Icon(Icons.open_in_browser),
                        onPressed: launchUrl,
                      )
                    ],
                  ),
                ),
              )),
        ));
  }

  launchUrl() async {
    const url = "https://github.com/amangautam1/flutter-musicplayer";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not open';
    }
  }
}
