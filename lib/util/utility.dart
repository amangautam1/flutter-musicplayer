import 'dart:io';
import 'dart:typed_data';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';

dynamic getImage(Song song) {
  return song.albumArt == null
      ? null
      : new File.fromUri(Uri.parse(song.albumArt));
}

Widget avatar(context, File f, String title) {
  return new Material(
    borderRadius: new BorderRadius.circular(30.0),
    elevation: 2.0,
    child: f != null
        ? new CircleAvatar(
            backgroundColor: Theme.of(context).accentColor,
            backgroundImage: new FileImage(
              f,
            ),
          )
        : new CircleAvatar(
            backgroundColor: Theme.of(context).accentColor,
            child: new Text(title[0].toUpperCase()),
          ),
  );
}
