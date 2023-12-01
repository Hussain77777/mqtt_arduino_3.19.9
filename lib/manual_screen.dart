import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_arduino/automatic_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DataModel.dart';
import 'home_screen.dart';
import 'mqtt.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key});

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  MQTTClientManager mqttClientManager = MQTTClientManager();
  TextEditingController controller = TextEditingController();

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


  DataModel dataModel = DataModel();

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
      controller.text = pt;

     // print("dataModel ${dataModel.data} ${dataModel.hello}");
     // print("dataModel ${a.length}");
      //  int age = jsonMap['world'];
      if(mounted){
      setState(() {});}
    });
  }

  List<DataModel> a = [];
  List<String> logData = [];

  @override
  void initState() {
    getList();
    setupMqttClient();
    setupUpdatesListener();
    super.initState();
  }

  void saveLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> dataList =
        a.map((item) => item.toJson()).toList();

// Convert the list of Maps to a JSON string
    final String jsonString = jsonEncode(dataList);

// Save the JSON string in SharedPreferences
    print("save data list from local $jsonString");
    prefs.setString("Listt", jsonString);
  }

  static Future getList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON string from SharedPreferences
    final String jsonString = prefs.getString("Listt") ?? '[]';

    // Convert the JSON string to a list of Maps
    final List<dynamic> jsonList = jsonDecode(jsonString);

    // Convert the list of Maps to a list of DataModel objects
    final List<DataModel> dataList =
        jsonList.map((item) => DataModel.fromJson(item)).toList();
    print("data list from local ${dataList.length}");
    print("data list from local ${dataList.toString()}");

//    return dataList;
  }

  @override
  void dispose() {
    saveLocalData();
    print("sd fmsdf sdfsdf");
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar:
      Container(
        padding: EdgeInsets.only(top: size.height*0.01,left: size.width*0.03),
        color: Colors.black,
        width: size.width,
        height: size.height * 0.38,

        // margin: EdgeInsets.only(left: size.width*0.1,right: size.width*0.1,),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(logData.length, (index) {
              return Text(
                logData[index]?? "",
                style: TextStyle(color: Colors.white),
              );
            }),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFF757172),
        leading: InkWell(
            onTap: () {

              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>AutomaticScreen()), (route) => false);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Text(
          "Manual Mode",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: //(isLoading)?Center(child: CircularProgressIndicator()):
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: size.height * 0.05,
                  left: size.width * 0.07,
                  right: size.width * 0.07),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ButtonWidget(
                      color: Color(0xFF70ad46),
                      onPressed: () {
                        mqttClientManager.publishMessage(
                            "manual", '{"action":"A"}');
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>AutomaticScreen()), (route) => false);

                      },
                      title: 'Automatic Mode '),
                  ButtonWidget(
                      color: Color(0xFF4472c7),
                      onPressed: () {
                        mqttClientManager.publishMessage(
                            "manual", '{"action":"U"}');
                      },
                      title: 'Reel Up '),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: size.width * 0.07, right: size.width * 0.07),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ButtonWidget(
                      color: Color(0xFFfe0000),
                      onPressed: () {
                        mqttClientManager.publishMessage(
                            "manual", '{"action":"P"}');
                      },
                      title: 'Pump '),
                  ButtonWidget(
                      color: Color(0xFF4473c5),
                      onPressed: () {
                        mqttClientManager.publishMessage(
                            "manual", '{"action":"D"}');
                      },
                      title: 'Reel Down '),
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
                  ButtonWidget(
                      color: Color(0xFFee7d31),
                      onPressed: () {
                        mqttClientManager.publishMessage(
                            "manual", '{"action":"C"}');
                      },
                      title: 'Calibration '),
                ],
              ),
            ),

            /*    TextFormField(
              maxLines: 7,
              readOnly: true,
              decoration: InputDecoration(
                fillColor: Colors.black,
                filled: true,
              ),
              controller: controller,
              style: TextStyle(color: Colors.white),
            )*/
          ],
        ),
      ),
    );
  }
}
