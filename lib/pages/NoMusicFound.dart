import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class NoMusicFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
          appBar: AppBar(
            title: Text("Music player"),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          backgroundColor: Colors.deepPurple,
          body: new Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      "images/sad.png",
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Sorry ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                      ),
                    ),
                  ),
                  Text(
                    " No music found!!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: RaisedButton.icon(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      elevation: 6.0,
                      label: Text("Exit"),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }

  Future<bool> _onWillPop() {
    SystemNavigator.pop();
  }
}
