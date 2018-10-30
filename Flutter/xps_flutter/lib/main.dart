import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

const String DEFAULT_CONODE_TEXT = 'You have no conode stored. Feel free to add one!';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'XPS - Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _conodeJSON = "";
  bool errorScanning = false;


  @override
  void initState() {
    super.initState();
    _loadJSON();
  }

  //Loads the conode JSON info saved in memory
  _loadJSON() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _conodeJSON = (prefs.getString('conodeJSON') ?? "");
      this.errorScanning = false;
    });
  }

  //Saves the conode JSON to memory
  _saveJSON() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('conodeJSON', _conodeJSON);
    });
  }

  //Delete the conode JSON stored in memory
  _deleteJSON() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.remove('conodeJSON');
      this._conodeJSON = "";
      this.errorScanning = false;
    });
  }
  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        this._conodeJSON = barcode;
        this.errorScanning = false;
      });
      _saveJSON();

    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this._conodeJSON = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() {
          this._conodeJSON = 'Unknown error: $e';
        });
      }
      setState(() => this.errorScanning = true);
    } on FormatException{
      setState(() {
        this._conodeJSON = 'null (User returned using the "back"-button before scanning anything. Result)';
        this.errorScanning = true;
      });
    } catch (e) {
      setState(() {
        this._conodeJSON = 'Unknown error: $e';
        this.errorScanning = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _conodeJSON == "" || errorScanning ?
            new Text(
              DEFAULT_CONODE_TEXT
            ) :
            new Text(
              _conodeJSON,
            ),
          ],
        ),
      ),
      floatingActionButton:
      _conodeJSON == "" || errorScanning ?
      new FloatingActionButton(
        onPressed: scan,
        tooltip: 'Add',
        child: new Icon(Icons.add),
      ) :
      new FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 255, 0, 0),
        onPressed: _deleteJSON,
        tooltip: 'Delete',
        child: new Icon(Icons.delete),
      ) , // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}