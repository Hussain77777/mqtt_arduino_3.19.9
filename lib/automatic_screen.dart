import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'home_screen.dart';
import 'mqtt.dart';

class AutomaticScreen extends StatefulWidget {
  const AutomaticScreen({super.key});

  @override
  State<AutomaticScreen> createState() => _AutomaticScreenState();
}

class _AutomaticScreenState extends State<AutomaticScreen> {
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
      appBar: AppBar(title: Text("Automatic Mode",),centerTitle: true
        ,),
      body: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ButtonWidget(onPressed: (){
            mqttClientManager.publishMessage(
                "automatic", '{"action":"A"}');
          },title: "Button A"),
          ButtonWidget(onPressed: (){
            mqttClientManager.publishMessage(
                "automatic", '{"action":"U"}');
          },title: "Button U"),       ButtonWidget(onPressed: (){
            mqttClientManager.publishMessage(
                "automatic", '{"action":"P"}');
          },title: "Button P"),       ButtonWidget(onPressed: (){
            mqttClientManager.publishMessage(
                "automatic", '{"action":"D"}');
          },title: "Button D"),       ButtonWidget(onPressed: (){
            mqttClientManager.publishMessage(
                "automatic", '{"action":"C"}');
          },title: "Button C"),

        ],
      ),
    );
  }
}
