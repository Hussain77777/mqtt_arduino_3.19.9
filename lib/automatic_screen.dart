import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mqtt_arduino/manual_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:web_socket_client/web_socket_client.dart';

import 'app_utils.dart';
import 'home_screen.dart';
import 'mqtt.dart';

class AutomaticScreen extends StatefulWidget {
  const AutomaticScreen(
      {super.key, required this.socket, required this.logList});

  final WebSocket? socket;
  final List<String>? logList;

  @override
  State<AutomaticScreen> createState() => _AutomaticScreenState();
}

class _AutomaticScreenState extends State<AutomaticScreen> {
  AppUtils util = AppUtils();

  WebSocket? socket;

  Future websocket() async {
    final uri = Uri.parse('ws://192.168.0.103:4000/');
    const backoff = ConstantBackoff(Duration(seconds: 1));
    socket = WebSocket(uri, backoff: backoff);
    print("object1111 ${socket?.connection.state}");
    // Listen for changes in the connection state.

    socket?.connection.listen((state) {
      print(
        'state:11 "$state"',
      );

      if (state.toString() == "Instance of 'Connected'") {
        AppUtils.showflushBar("Connected", context);

        socket?.send("aaaaaaaaaaaaaaaaaaaaaaaa");
        AppUtils.showflushBar("Connected send", context);
        socket?.messages.listen((message) {
          logData.add(message.toString());
          print('message:11111122222 "$message"');
          setState(() {
            logData.add(message);
          });
        });
      }
      if (state.toString() == "Instance of 'Reconnected'") {
        AppUtils.showflushBar("Connected", context);

        socket?.send("Re aaaaaaaaaaaaaaaaaaaaaaaa");
        AppUtils.showflushBar("ReConnected send", context);
        socket?.messages.listen((message) {
          logData.add(message.toString());
          print('message:11111122222 "$message"');
          setState(() {
            logData.add(message);
          });
        });
      }
      if (state.toString() == "Instance of 'Disconnected'") {
        AppUtils.showflushBar("Disconnected", context);
      }
    });
  }

  List<String> a = [];

  @override
  void initState() {
    logData;
    websocket();

    super.initState();
  }

  List<String> logData = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      bottomNavigationBar: LogWidget(size: size, logData: logData),
      appBar: AppBar(
        backgroundColor: Color(0xFF757172),
        /*      leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),*/
        title: Text(
          "Automatic Mode",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * 0.05,
            ),
            ButtonWidget(
                color: Colors.orange,
                onPressed: () async {
                  //     await mqttClientManager.connect();
                  /*  mqttClientManager.publishMessage(
                      "automatic", '{"action":"M"}'
                  );*/
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ManualScreen(
                                logList: logData,
                                socket: widget.socket,
                              )));
                },
                title: "Return to Manual Mode"),

            //   (isLoading)?Center(child: CircularProgressIndicator()):
          ],
        ),
      ),
    );
  }
}

class LogWidget extends StatelessWidget {
  const LogWidget({
    super.key,
    required this.size,
    required this.logData,
  });

  final Size size;
  final List<String> logData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      EdgeInsets.only(top: size.height * 0.01, left: size.width * 0.03),
      color: Colors.black,
      width: size.width,
      height: size.height * 0.45,

      // margin: EdgeInsets.only(left: size.width*0.1,right: size.width*0.1,),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(logData.length, (index) {
            return Text(
              "${logData[index]} $index",
              style: TextStyle(color: Colors.white),
            );
          }),
        ),
      ),
    );
  }
}
