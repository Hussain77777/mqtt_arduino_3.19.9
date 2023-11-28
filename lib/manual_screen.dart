import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'home_screen.dart';
import 'mqtt.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key});

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF757172),

        leading: InkWell(onTap: (){
          Navigator.pop(context);
        },child: Icon(Icons.arrow_back,color: Colors.white,)),
        title: Text(
          "Manual Mode",style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: size.height*0.05,
                left: size.width * 0.07, right: size.width * 0.07),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonWidget(
                    color: Color(0xFF70ad46),
                    onPressed: () {
                      mqttClientManager.publishMessage(
                          "manual", '{"action":"M"}');
                    },
                    title: 'Automatic Mode (Accessed by "A"in the Terminal)'),
                ButtonWidget(        color: Color(0xFF4472c7),
                    onPressed: () {
                      mqttClientManager.publishMessage(
                          "manual", '{"action":"M"}');
                    },
                    title: 'Reel Up (Accessed by "U"in the Terminal)'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: size.width * 0.07, right: size.width * 0.07),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonWidget(color: Color(0xFFfe0000),
                    onPressed: () {
                      mqttClientManager.publishMessage(
                          "manual", '{"action":"M"}');
                    },
                    title: 'Pump (Accessed by "P"in the Terminal)'),
                ButtonWidget(color: Color(0xFF4473c5),
                    onPressed: () {
                      mqttClientManager.publishMessage(
                          "manual", '{"action":"M"}');
                    },
                    title: 'Reel Down (Accessed by "D"in the Terminal)'),
                    //),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: size.width * 0.07, right: size.width * 0.07),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ButtonWidget(color: Color(0xFFee7d31),
                    onPressed: () {
                      mqttClientManager.publishMessage(
                          "manual", '{"action":"M"}');
                    },
                    title: 'Calibration (Accessed by "C"in the Terminal)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
