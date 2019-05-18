import 'package:flutter/material.dart';
import 'package:musicplayer/musichome.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _mainState();
  }
}

class _mainState extends State<MyApp> {
  var isLoading = true;
  ThemeData theme;
  @override
  void initState() {
    super.initState();
    getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: isLoading ? lightTheme : theme,
      title: "Music player",
      debugShowCheckedModeBanner: false,
      home: isLoading ? new Container() : new MusicHome(),
    );
  }

  getTheme() async {
    var pref = await SharedPreferences.getInstance();
    var val = pref.getInt("theme");
    print("theme=$val");
    if (val == null) {
      theme = lightTheme;
    } else if (val == 1) {
      theme = getDarkTheme(context);
    } else {
      theme = lightTheme;
    }
    setState(() {
      isLoading = false;
    });
  }
  getDarkTheme(context){
    return  new ThemeData(
      brightness: Brightness.dark,
      accentColor: Colors.grey[800],
      fontFamily: 'Raleway',
      sliderTheme:  SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.deepPurpleAccent[700],
        inactiveTrackColor: Colors.deepPurpleAccent[100],
        thumbColor: Colors.purple,
        disabledThumbColor: Colors.grey,),
      
      dialogBackgroundColor: Colors.black,
    );
  }

  ThemeData lightTheme = new ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Raleway',
    primaryColor: Colors.deepPurple,
    accentColor: Colors.deepPurpleAccent,
  );
}
