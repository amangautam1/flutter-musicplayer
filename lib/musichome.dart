import 'dart:async';
import 'dart:io';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musicplayer/database/database_client.dart';
import 'package:musicplayer/pages/about.dart';
import 'package:musicplayer/pages/material_search.dart';
import 'package:musicplayer/pages/now_playing.dart';
import 'package:musicplayer/pages/settings.dart';
import 'package:musicplayer/util/lastplay.dart';
import 'package:musicplayer/views/album.dart';
import 'package:musicplayer/views/artists.dart';
import 'package:musicplayer/views/home.dart';
import 'package:musicplayer/views/playlists.dart';
import 'package:musicplayer/views/songs.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
class MusicHome extends StatefulWidget {
  List<Song> songs;
  MusicHome();
  final bottomItems = [
    new BottomItem("Home", Icons.home),
    new BottomItem("Albums", Icons.album),
    new BottomItem("Songs", Icons.music_note),
    new BottomItem("Artists", Icons.person),
    new BottomItem("PlayList", Icons.playlist_add_check),
  ];
  @override
  State<StatefulWidget> createState() {
    return new _musicState();
  }
}

class _musicState extends State<MusicHome>with SingleTickerProviderStateMixin<MusicHome> {
  int _selectedDrawerIndex = 0;
  List<Song> songs;
  String title = "Music player";
  DatabaseClient db;
  bool isLoading = true;
  Song last;
  Color color = Colors.deepPurple;
 int currentIndex = 0;
 final pageController = PageController();
var pages;
 
  _onSelectItem(int index) {
    setState(() => currentIndex = index);
  //  getDrawerItemWidget(_selectedDrawerIndex);
 
    
  }

  @override
  void initState() {
    super.initState();
    getLast();
    pages=[Home(db),Artists(db),Songs(db), Album(db),PlayList(db)];

  }


  @override
  void dispose() async {
    super.dispose();
  }
  // getSharedData() async {
  //   const platform = const MethodChannel('app.channel.shared.data');
  //   Map sharedData = await platform.invokeMethod("getSharedData");
  //   if (sharedData != null) {
  //     if (sharedData["albumArt"] == "null") {
  //       sharedData["albumArt"] = null;
  //     }
  //     Song song = new Song(
  //         9999 /*random*/,
  //         sharedData["artist"],
  //         sharedData["title"],
  //         sharedData["album"],
  //         null,
  //         int.parse(sharedData["duration"]),
  //         sharedData["uri"],
  //         sharedData["albumArt"]);
  //     List<Song> list = new List();
  //     list.add((song));
  //     MyQueue.songs = list;
  //     Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
  //       return new NowPlaying(null, list, 0, 0);
  //     }));
  //   }
  // }

  void getLast() async {
    db = new DatabaseClient();
    await db.create();
    last = await db.fetchLastSong();
    songs = await db.fetchSongs();
    setState(() {
      songs = songs;
      isLoading = false;
    });

  }
   void onTap(int index) {
 pageController.jumpToPage(index);
 title = widget.bottomItems[index].title;
   }
    void onPageChanged(int index) {
 setState(() {
  currentIndex = index;
 });
 title = widget.bottomItems[index].title;
 }


  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    var bottomOptions = <BottomNavigationBarItem>[];
    for (var i = 0; i < widget.bottomItems.length; i++) {
      var d = widget.bottomItems[i];
      bottomOptions.add(
        new BottomNavigationBarItem(
          icon: new Icon(
            d.icon,
          ),
          title: new Text(d.title),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }
    return new WillPopScope(
      child: new Scaffold(
        key: scaffoldState,
        appBar: currentIndex == 0
            ? null
            : new AppBar(
                title: new Text(title),
                actions: <Widget>[
                  new IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        Navigator.of(context)
                            .push(new MaterialPageRoute(builder: (context) {
                          return new SearchSong(db, songs);
                        }));
                      })
                ],
              ),
        floatingActionButton: new FloatingActionButton(
            child: new Icon(Icons.play_circle_filled),
            onPressed: () async {
              Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (context) {
                if (MyQueue.songs == null) {
                  List<Song> list = new List();
                  list.add(last);
                  MyQueue.songs = list;
                  return new NowPlaying(db, list, 0, 0);
                } else
                  return new NowPlaying(db, MyQueue.songs, MyQueue.index, 1);
              }));
              //}
            }),
        drawer: new Drawer(
          child: SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                new UserAccountsDrawerHeader(
                  accountName: new Text("Music player"),
                  accountEmail: null,
                  currentAccountPicture: CircleAvatar(
                    child: Image.asset("images/logo.png"),
                    backgroundColor: Colors.white,
                  ),
                ),
                new Column(
                  children: <Widget>[
                    new ListTile(
                        leading: new Icon(Icons.settings,
                            color: Theme
                                .of(context)
                                .accentColor),
                        title: new Text("Settings"),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .push(new MaterialPageRoute(builder: (context) {
                            return new Settings();
                          }));
                        }),
                    new ListTile(
                      leading: new Icon(Icons.info,
                          color: Theme
                              .of(context)
                              .accentColor),
                      title: new Text("About"),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(context,
                            new MaterialPageRoute(builder: (context) {
                              return new About();
                            }));
                      },
                    ),
                    Divider(),
                    new ListTile(
                      leading: Icon(Icons.share,
                          color: Theme
                              .of(context)
                              .accentColor),
                      title: Text("Share"),
                      onTap: () {
                        Share.share(
                            "Hey, checkout this cool music player at https://play.google.com/store/apps/details?id=com.onedreamers.musicplayer");
                        Navigator.of(context).pop();
                      },
                    ),
                    new ListTile(
                      leading: Icon(Icons.star,
                          color: Theme
                              .of(context)
                              .accentColor),
                      title: Text("Rate the app"),
                      onTap: () {
                        Navigator.of(context).pop();

                        launchUrl(
                            "https://play.google.com/store/apps/details?id=com.onedreamers.musicplayer");
                      },
                    ),
                    new ListTile(
                      leading: Icon(FontAwesomeIcons.donate,
                          color: Theme
                              .of(context)
                              .accentColor),
                      title: Text("Donate"),
                      onTap: () {
                        Navigator.of(context).pop();
                        launchUrl("http://paypal.me/amangautam1");
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        body: isLoading
            ? new Center(
                child: new CircularProgressIndicator(),
              )
            : Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: PageView(
   controller: pageController,
   children: pages,
   onPageChanged: onPageChanged, //
    physics: NeverScrollableScrollPhysics (), // 
  )),
      
        bottomNavigationBar: BottomNavigationBar(
          items: bottomOptions,
          onTap: onTap,
          currentIndex: currentIndex,
        ),


      ),
      onWillPop: _onWillPop,
    );
  }

  Future<bool> _onWillPop() {
    if (currentIndex != 0) {
            onTap(0);
    } else {
         if (Platform.isAndroid) {
          if (Navigator.of(context).canPop()) {
            return Future.value(true);
          } else {
              const platform = const MethodChannel('android_app_retain');
            platform.invokeMethod("sendToBackground");
            return Future.value(false);
          }
        } else {
          return Future.value(true);
        }
    }

     
  }


  launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not open';
    }
  }
}

class BottomItem {
  String title;
  IconData icon;
  BottomItem(this.title, this.icon);
}
