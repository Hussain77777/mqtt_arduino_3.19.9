import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_arduino/manual_screen.dart';
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

  bool isLoading=false;

  Future<void> setupMqttClient() async {
    setState(() {
      isLoading=true;
    });
    await mqttClientManager.connect();
    mqttClientManager.subscribe("log");
    setState(() {
      isLoading=false;
    });

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
      // Map<String, dynamic> jsonMap = jsonDecode(pt);
      //  dataModel = DataModel.fromJson(jsonMap);
      logData.add(pt);
      // controller.text = pt;

      // print("dataModel ${dataModel.data} ${dataModel.hello}");
      // print("dataModel ${a.length}");
      //  int age = jsonMap['world'];
//if(mounted)
      if(mounted){
      setState(() {});}
    });
  }

  @override
  void initState() {
    print("dfnksjdnfnskdnfsndkfnksdnfk ${mqttClientManager.client.connectionStatus}");
    setupMqttClient();
    setupUpdatesListener();
    super.initState();
  }

  List<String> logData = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(top: size.height*0.01,left: size.width*0.03),
        color: Colors.black,
        width: size.width,
        height: size.height * 0.45,

        // margin: EdgeInsets.only(left: size.width*0.1,right: size.width*0.1,),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(logData.length, (index) {
              return Text(
                logData[index] ?? "",
                style: TextStyle(color: Colors.white),
              );
            }),
          ),
        ),
      ),
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
        physics: NeverScrollableScrollPhysics(),
        child: Column(
         crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: size.height*0.05,),
             ButtonWidget(color: Colors.orange,
                onPressed: () async{


      //     await mqttClientManager.connect();
                  mqttClientManager.publishMessage(
                      "automatic", '{"action":"M"}');
               Navigator.push(context,MaterialPageRoute(builder: (context)=>ManualScreen()));
                },
                title: "Return to Manual Mode"),
         //   (isLoading)?Center(child: CircularProgressIndicator()):
          ],
        ),
      ),
    );
  }
}
