import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("About"),
        ),
        body: SingleChildScrollView(
          child: new Center(
            child: new Container(
                child: new Column(children: <Widget>[
                  new Card(
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          "images/logo.png",
                          height: 150,
                          width: 150,
                        ),
                        Text(
                          "Music player",
                          style: TextStyle(fontSize: 30),
                        )
                      ],
                    ),
                  ),
                  new Card(
                    child: new Column(
                      children: <Widget>[
                        new CircleAvatar(
                          radius: 30.0,
                          backgroundImage: new AssetImage("images/avatar.jpg"),
                        ),
                        Text(
                          "Aman gautam",
                          style: TextStyle(fontSize: 30),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                                icon: Icon(
                                  Icons.mail,
                                  color: Colors.deepPurpleAccent,
                                  size: 25,
                                ),
                                onPressed: () =>
                                    launchUrl(
                                        "mailto:amangautam208@gmail.com")),
                            IconButton(
                                icon: Icon(
                                  FontAwesomeIcons.linkedinIn,
                                  color: Colors.deepPurpleAccent,
                                  size: 25,
                                ),
                                onPressed: () =>
                                    launchUrl(
                                        "https://www.linkedin.com/in/amangautam1/")),
                            new IconButton(
                              icon: new Icon(FontAwesomeIcons.githubSquare,
                                  color: Colors.deepPurpleAccent, size: 25),
                              onPressed: () =>
                                  launchUrl(
                                      "https://github.com/amangautam1/flutter-musicplayer"),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          child: Image.asset(
                            "images/kid.png", height: 250, width: 170,
                            fit: BoxFit.fill,
                          ),
                          right: 45.0,
                          bottom: 0.0,
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              "References",
                              style: TextStyle(fontSize: 25),
                            ),
                            ListTile(
                              title: Text("flute_music_player"),
                              trailing: IconButton(
                                icon: new Icon(FontAwesomeIcons.github,
                                    color: Colors.deepPurpleAccent, size: 25),
                                onPressed: () =>
                                    launchUrl(
                                        "https://github.com/iampawan/Flute-Music-Player"),
                              ),
                            ),
                            ListTile(
                              title: Text("sqflite"),
                              trailing: IconButton(
                                icon: new Icon(FontAwesomeIcons.github,
                                    color: Colors.deepPurpleAccent, size: 25),
                                onPressed: () =>
                                    launchUrl(
                                        "https://github.com/tekartik/sqflite"),
                              ),
                            ),
                            ListTile(
                              title: Text("dynamic_theme"),
                              trailing: IconButton(
                                icon: new Icon(FontAwesomeIcons.github,
                                    color: Colors.deepPurpleAccent, size: 25),
                                onPressed: () =>
                                    launchUrl(
                                        "https://github.com/Norbert515/dynamic_theme"),
                              ),
                            ),
                            ListTile(
                              title: Text("floating_search_bar"),
                              trailing: IconButton(
                                icon: new Icon(FontAwesomeIcons.github,
                                    color: Colors.deepPurpleAccent, size: 25),
                                onPressed: () =>
                                    launchUrl(
                                        "https://github.com/AppleEducate/plugins/tree/master/packages/floating_search_bar"),
                              ),
                            ),
                            ListTile(
                              title: Text("scoped_model"),
                              trailing: IconButton(
                                icon: new Icon(FontAwesomeIcons.github,
                                    color: Colors.deepPurpleAccent, size: 25),
                                onPressed: () =>
                                    launchUrl(
                                        "https://github.com/brianegan/scoped_model"),
                              ),
                            ),
                            ListTile(
                              title: Text("font_awesome_flutter"),
                              trailing: IconButton(
                                icon: new Icon(FontAwesomeIcons.github,
                                    color: Colors.deepPurpleAccent, size: 25),
                                onPressed: () =>
                                    launchUrl(
                                        "https://github.com/brianegan/font_awesome_flutter"),
                              ),
                            )

                          ],
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Image.asset(
                          "images/logo.png",
                          height: 50,
                          width: 50,
                        ),
                        Flexible(
                          child: Text(
                            "Logo designed with www.designevo.com",
                            style: TextStyle(fontSize: 10),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  )
                ])),
          ),
        ));
  }

  launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not open';
    }
  }
}
