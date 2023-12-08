import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_arduino/automatic_screen.dart';
import 'package:mqtt_arduino/home_screen.dart';
import 'package:mqtt_arduino/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_client/web_socket_client.dart';

import 'app_utils.dart';

WebSocket? socket;

Future websocket() async {
  final uri = Uri.parse('ws://192.168.0.106:4000/');
  const backoff = ConstantBackoff(Duration(seconds: 1));
  socket = WebSocket(uri, backoff: backoff);
  print("object1111 ${socket?.connection.state}");
  // Listen for changes in the connection state.

  socket?.connection.listen((state) {
    print(
      'state:11 "$state"',
    );

    if (state.toString() == "Instance of 'Connected'") {
      //AppUtils.showflushBar("Connected",context);
      socket?.messages.listen((message) {
        //logData.add(message.toString());
        print('message:11111122222 "$message"');
        /*   setState(() {

        });*/
      });
    }
    if (state.toString() == "Instance of 'Disconnected'") {
      //    AppUtils.showflushBar("Disconnected",context);
    }
  });
  //  socket.send("hello from flutter");
}

void main() {
  runApp(const MyApp());
  websocket();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  WebSocket? socket;

  Future websocket() async {
    final uri = Uri.parse('ws://192.168.0.106:4000/');
    const backoff = ConstantBackoff(Duration(seconds: 1));
    socket = WebSocket(uri, backoff: backoff);
    print("object1111 ${socket?.connection.state}");
    // Listen for changes in the connection state.

    socket?.connection.listen((state) {
      print(
        'state:11 "$state"',
      );

      if (state.toString() == "Instance of 'Connected'") {
        AppUtils.showflushBar("Connected",context);
socket?.send("aaaaaaaaaaaaaaaaaaaaaa");
        AppUtils.showflushBar("Connected send",context);
        socket?.messages.listen((message) {
          logData.add(message.toString());
          print('message:11111122222 "$message"');
          /*   setState(() {

        });*/
        });
      }
      if (state.toString() == "Instance of 'Disconnected'") {
            AppUtils.showflushBar("Disconnected",context);
      }
    });
  }
List<String>logData=[];
  void initState(){
 //   websocket();
    super.initState();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AutomaticScreen(socket:socket ,logList: logData),
      //home: HomeScreen(),
    );
  }
}

