import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListPost(),
    );
  }
}

class ListPost extends StatefulWidget {
  @override
  _ListPostState createState() => _ListPostState();
}

class _ListPostState extends State<ListPost> {
  List<Widget> posts = new List<Widget>();
  var currentLocation;
  var location = new Location();
  var _settings = new ConnectionSettings(
      host: 'hostname',
      port: 3306,
      user: 'root',
      password: 'password'
      db: 'posts');



  Widget refreshButton() {
    return IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () async {
        var _conn = await MySqlConnection.connect(_settings);
        var results = await _conn.query('select content, clock from all_posts');
        setState(() {
          posts.clear();
          for (var row in results) {
            print(row[0]);
            posts.add(new ListTile(
              title: Text(row[0]),
              trailing: Text(timeago.format(DateTime.parse(row[1].toString()),
                  locale: 'en_short')),
            ));
          }
        });
        _conn.close();
        print('posts = ${posts.length}');
      },
    );
  }


  textDialog() async {
    TextEditingController controller = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "Enter a post..."),
            ),
            actions: <Widget>[

              new FlatButton(
                  child: new Text('ENTER'),
                  onPressed: () async {
                    currentLocation = await location.getLocation();
                    var _conn = await MySqlConnection.connect(_settings);
                    var results = await _conn.query(
                      'insert into all_posts (content, longitude, latitude, clock) values (?, ?, ?, ?)', [controller.text, currentLocation.longitude, currentLocation.latitude, DateTime.now().toUtc()]);
                    print(currentLocation.latitude);
                    controller.dispose();
                    super.dispose();
                    Navigator.of(context).pop();
                  }),

              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Widget addPost() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      backgroundColor: Colors.blue,
      onPressed: () {
        textDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pinit'),
        actions: <Widget>[refreshButton()],
      ),
      body: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return posts[index];
          }),
      floatingActionButton: addPost(),
    );
  }
}
