import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_arduino/automatic_screen.dart';
import 'package:mqtt_arduino/manual_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_client/web_socket_client.dart';

import 'mqtt.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MQTTClientManager mqttClientManager = MQTTClientManager();

  Future<void> setupMqttClient() async {
    await mqttClientManager.connect();
    mqttClientManager.subscribe("pubTopic");
    //  mqttClientManager.subscribe();
  }

  Future websocket() async {
    final uri = Uri.parse('ws://192.168.0.107:4000/');
    const backoff = ConstantBackoff(Duration(seconds: 1));
    final socket = WebSocket(uri, backoff: backoff);
    print("object1111 ${socket.connection.state}");
    // Listen for changes in the connection state.
    socket.connection.state;


    socket.connection.listen((state) => print('state:11 "${state.toString()}"'));
    socket.send("hello from flutter");

    print("object222222222 ${socket.connection.state.toString()}");
    socket.messages.listen((message) {
      print('message:111111 "$message"');
    });
  }

  void setupUpdatesListener() {
    mqttClientManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
      print(
          'MQTTClient::Message received on topic: 1233<${c[0].payload}> is $pt\n');
      Map<String, dynamic> jsonMap = jsonDecode(pt);

      setState(() {});
    });
  }

  @override
  void initState() {
    websocket();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF757172),
        /*   leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),*/
        title: Text(
          "Selection Mode",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: size.height * 0.05,
          ),
          Text(
            "NAPL Solutions",
            style: TextStyle(
                color: Colors.black,
                fontSize: size.width * 0.08,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: size.height * 0.05,
          ),
          ButtonWidget(
              color: Color(0xFF757172),
              onPressed: () {
                //socket.send("sfsdfsdfsdfsdfsdf");
                /*  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AutomaticScreen()));*/
              },
              title: "Automatic"),

          ButtonWidget(
              color: Color(0xFF757172),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ManualScreen()));
              },
              title: "Manual"),
        ],
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    required this.onPressed,
    this.title,
    this.color,
  });

  final VoidCallback onPressed;
  final String? title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
                color: color ?? Colors.blue,
                borderRadius: BorderRadius.circular(size.width * 0.1)),
            height: size.height * 0.12,
            width: size.width * 0.4,
            child: Center(
                child: Padding(
              padding: EdgeInsets.only(
                  left: size.width * 0.02, right: size.width * 0.02),
              child: Text(
                title ?? "",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.045,
                ),
                textAlign: TextAlign.center,
              ),
            )),
          ),
        ),
      ),
    );
  }
}
