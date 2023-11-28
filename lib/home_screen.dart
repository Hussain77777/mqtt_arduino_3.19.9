import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_arduino/automatic_screen.dart';
import 'package:mqtt_arduino/manual_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'mqtt.dart';

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

  void setupUpdatesListener() {
    mqttClientManager
        .getMessagesStream()!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      //jsonDecode(pt["light_on_time"]);
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
      //    print('MQTTClient::Message received on topic: <${c[0].topic}> is ${pt['light_on_time']}\n');
      print('MQTTClient::Message received on topic: <${c[0].topic}> is $pt\n');
      print(
          'MQTTClient::Message received on topic: 1233<${c[0].payload}> is $pt\n');
      Map<String, dynamic> jsonMap = jsonDecode(pt);
      /* print(
          'MQTTClient::Message received on topic: 12334 ${ReadingsModel.fromJson(jsonMap)}');
      readingsModel = ReadingsModel.fromJson(jsonMap);
*/
      //  int age = jsonMap['world'];

      setState(() {});
    });
  }

  @override
  void initState() {
    setupMqttClient();
    setupUpdatesListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Selection Mode",
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ButtonWidget(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AutomaticScreen()));
              },
              title: "Automatic"),
          ButtonWidget(
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
    Size size=MediaQuery.of(context).size;
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
                color: color??Colors.blue,
                borderRadius: BorderRadius.circular(size.width*0.1)),

            height: size.height*0.17,
            width:size.width*0.4,
            child: Center(
                child: Padding(padding: EdgeInsets.only(left: size.width*0.02,right:size.width*0.02 ),
                  child: Text(
              title ?? "",
              style: TextStyle(color: Colors.white,),textAlign: TextAlign.center,
            ),
                )),
          ),
        ),
        /* child: ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.blue,elevation: 5,
              minimumSize:Size(70, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          onPressed:onPressed,
          child: Text(title??"",style: TextStyle(color: Colors.white),),
        ),*/
      ),
    );
  }
}
