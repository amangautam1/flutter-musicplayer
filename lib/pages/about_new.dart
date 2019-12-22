import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:clippy_flutter/diagonal.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutNew extends StatelessWidget {
  static final double containerHeight = 300.0;
  double clipHeight = containerHeight * 0.35;
  DiagonalPosition position = DiagonalPosition.BOTTOM_RIGHT;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: SingleChildScrollView(
        child: Stack(children: <Widget>[
          Image.network("http://imcmusiclessons.com/wp-content/uploads/2015/07/Music-Background-light-500.jpg",height: 500,),
          Column(
            children: <Widget>[
              Diagonal(
                position: position,
                clipHeight: clipHeight,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          "http://www.micrasolution.com/assets/images/proj1-bg.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: containerHeight,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(50, 80, 10, 70),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundImage: AssetImage("images/micra.jpg"),
                              radius: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                "Micra Solution",
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Icon(FontAwesomeIcons.facebook,
                                color: Colors.white),
                            Icon(FontAwesomeIcons.linkedinIn,
                                color: Colors.white),
                            Icon(Icons.email, color: Colors.white)
                          ],
                        ),
                        RaisedButton.icon(
                          icon: Icon(Icons.call, color: Colors.white),
                          label: Text(
                            "Contact us",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.deepPurple,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          onPressed: () => {},
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Card(
                  child: new Column(
                    children: <Widget>[
                      Text("Developed by:",
                       style: TextStyle(fontSize: 20),),
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
                                  launchUrl("mailto:amangautam208@gmail.com")),
                          IconButton(
                              icon: Icon(
                                FontAwesomeIcons.linkedinIn,
                                color: Colors.deepPurpleAccent,
                                size: 25,
                              ),
                              onPressed: () => launchUrl(
                                  "https://www.linkedin.com/in/amangautam1/")),
                          new IconButton(
                            icon: new Icon(FontAwesomeIcons.githubSquare,
                                color: Colors.deepPurpleAccent, size: 25),
                            onPressed: () => launchUrl(
                                "https://github.com/amangautam1/flutter-musicplayer"),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Column(
                  children: <Widget>[
                    Text(
                      "Open source plugins",
                      style: TextStyle(fontSize: 25),
                    ),
                    ListTile(
                      title: Text("flute_music_player"),
                      trailing: IconButton(
                        icon: new Icon(FontAwesomeIcons.github,
                            color: Colors.deepPurpleAccent, size: 25),
                        onPressed: () => launchUrl(
                            "https://github.com/iampawan/Flute-Music-Player"),
                      ),
                    ),
                    ListTile(
                      title: Text("sqflite"),
                      trailing: IconButton(
                        icon: new Icon(FontAwesomeIcons.github,
                            color: Colors.deepPurpleAccent, size: 25),
                        onPressed: () =>
                            launchUrl("https://github.com/tekartik/sqflite"),
                      ),
                    ),
                    ListTile(
                      title: Text("dynamic_theme"),
                      trailing: IconButton(
                        icon: new Icon(FontAwesomeIcons.github,
                            color: Colors.deepPurpleAccent, size: 25),
                        onPressed: () => launchUrl(
                            "https://github.com/Norbert515/dynamic_theme"),
                      ),
                    ),
                    ListTile(
                      title: Text("floating_search_bar"),
                      trailing: IconButton(
                        icon: new Icon(FontAwesomeIcons.github,
                            color: Colors.deepPurpleAccent, size: 25),
                        onPressed: () => launchUrl(
                            "https://github.com/AppleEducate/plugins/tree/master/packages/floating_search_bar"),
                      ),
                    ),
                    ListTile(
                      title: Text("scoped_model"),
                      trailing: IconButton(
                        icon: new Icon(FontAwesomeIcons.github,
                            color: Colors.deepPurpleAccent, size: 25),
                        onPressed: () => launchUrl(
                            "https://github.com/brianegan/scoped_model"),
                      ),
                    ),
                    ListTile(
                      title: Text("font_awesome_flutter"),
                      trailing: IconButton(
                        icon: new Icon(FontAwesomeIcons.github,
                            color: Colors.deepPurpleAccent, size: 25),
                        onPressed: () => launchUrl(
                            "https://github.com/brianegan/font_awesome_flutter"),
                      ),
                    )
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
            ],
          ),
          new Positioned(
            //Place it at the top, and not use the entire screen
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
              title: Text('About Us'),
              backgroundColor: Colors.transparent, //No more green
              elevation: 0.0, //Shadow gone
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => {Navigator.pop(context)},
              ),
            ),
          ),
        ]),
      ),
    );
  }

  launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not open';
    }
  }
}
