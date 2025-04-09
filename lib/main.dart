import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'dart:math';
Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String?> notificationList = [];
  List<String?> notificationMsgs = [];
  late FirebaseMessaging messaging;
  String? notificationText;
  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic("messaging");
    messaging.getToken().then((value) {
      print(value);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
      setState(() {
        notificationList.add(event.notification!.body);
      });
      print(event.data);
      var type = (event.data)['notificationType'];
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.red, 
              title: type == "regular" ? Text("Regular Notification") : Text("URGENT MESSAGE"),
              content: Text(event.notification!.body!),
              actions: [
                TextButton(
                  child: type == "regular" ? Text("OK!") : Text("Understood.", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Print a random statement!"),
                  onPressed: () {
                    _printStatement();
                  },
                )
              ],
            );
          });
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  void _printStatement() {
    List<String> randomStatements = [
      "Notifications are great", 
      "This is an example message", 
      "01110100 01101000 01111000 00100000 00110100 00100000 01100011 01101111 01101110 01110110 01100101 01110010 01110100 01101001 01101110 01100111 00100001"
    ];
    var intValue = Random().nextInt(3);
    setState(() {
      notificationMsgs.add(randomStatements[intValue]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Column(
        children: <Widget>[
          Text("Notification History: "),
          SizedBox(
            height: 250,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: notificationList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 40,
                  child: Center(child: Text('Notification #${index + 1}: ${notificationList[index]}')),
                );
              }
            ),
          ),
          Text("Notification Messages"),
          SizedBox(
            height: 250,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: notificationMsgs.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 40,
                  child: Center(child: Text('Message #${index + 1}: ${notificationMsgs[index]}')),
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}