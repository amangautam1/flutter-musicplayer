import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/pages/Walkthrough.dart';
import 'package:musicplayer/sc_model/model.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) =>
        new ThemeData(
          primarySwatch: Colors.deepPurple,
          accentColor: Colors.deepPurpleAccent,
          fontFamily: 'Raleway',
          brightness: brightness,
        ),
        themedWidgetBuilder: (context, theme) {
          return ScopedModel<SongModel>(
            model: new SongModel(),
            child: new MaterialApp(

              title: 'Music Player',
              theme: theme,
              debugShowCheckedModeBanner: false,
              home: new SplashScreen(),
            ),
          );
        });
  }
}
