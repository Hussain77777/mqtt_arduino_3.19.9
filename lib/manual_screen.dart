import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_arduino/automatic_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_client/web_socket_client.dart';

import 'DataModel.dart';
import 'app_utils.dart';
import 'home_screen.dart';
import 'mqtt.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key, this.socket, this.logList});
  final WebSocket? socket;
  final List<String>? logList;
  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  MQTTClientManager mqttClientManager = MQTTClientManager();
  TextEditingController controller = TextEditingController();

  bool isLoading = false;

  List<DataModel> a = [];
  List<String> logData = [];

  @override
  void initState() {
    logData=widget.logList??[];
    websocket();
    super.initState();
  }
  AppUtils util=AppUtils();


  Future websocket() async {

    print("object1111 ${widget.socket?.connection.state}");
    // Listen for changes in the connection state.



    widget.socket?.connection.listen((state) {

      print('state:11 "$state"',);

      if(state.toString()=="Instance of 'Connected'"){
       // AppUtils.showflushBar("Connected",context);
        widget.socket?.messages.listen((message) {

          logData.add(message.toString());
          print('message:11111122222 "$message"');
          setState(() {

          });
        });
      }
      if(state.toString()=="Instance of 'Disconnected'"){
        AppUtils.showflushBar("Disconnected",context);
      }
    });
    //  socket.send("hello from flutter");



  }
  @override
  void dispose() {
    print("sd fmsdf sdfsdf");
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: LogWidget(size: size, logData: logData),
      appBar: AppBar(
        backgroundColor: Color(0xFF757172),
        leading: InkWell(
            onTap: () {
            /*  Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AutomaticScreen()),
                  (route) => false);*/
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
                   /*     Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AutomaticScreen()),
                            (route) => false);*/
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
