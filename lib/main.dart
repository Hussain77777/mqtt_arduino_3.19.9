import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_arduino/automatic_screen.dart';
import 'package:mqtt_arduino/home_screen.dart';
import 'package:mqtt_arduino/mqtt.dart';
import 'package:mqtt_client/mqtt_client.dart';

void main() {
  //setupMqttClient();
  //setupUpdatesListener();
  runApp(const MyApp());
}

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

    //setState(() {});
  });
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AutomaticScreen(),
    );
  }
}

