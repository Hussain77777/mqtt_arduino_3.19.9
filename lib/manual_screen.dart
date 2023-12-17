import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mqtt_arduino/automatic_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_client/web_socket_client.dart';

import 'DataModel.dart';
import 'app_utils.dart';
import 'home_screen.dart';
import 'mqtt.dart';

class ManualScreen extends StatefulWidget {
   ManualScreen({super.key, this.logList, this.device, this.targetCharacterstic});

  final List<String>? logList;
  final BluetoothDevice? device;
   BluetoothCharacteristic? targetCharacterstic;
  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  MQTTClientManager mqttClientManager = MQTTClientManager();
  TextEditingController controller = TextEditingController();
  BluetoothCharacteristic? targetCharacterstic11;
  bool isLoading = false;

  List<DataModel> a = [];
  List<String> logData = [];
  checkDeviceStatus(){
    var subscription = widget.device?.connectionState
        .listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        //   widget.device?.connect();
        AppUtils.showflushBar(
            "Your Device disConnected ${widget.device?.platformName}",
            context);
      }
      if (state == BluetoothConnectionState.connected) {

      }
    });
  }
  @override
  void initState() {
    logData = widget.logList ?? [];
    checkDeviceStatus();
    logListener();
    super.initState();
  }
  logListener() async {
    if(widget.device?.isConnected??false){
      List<BluetoothService>? services =
          await widget.device?.discoverServices();
    widget.targetCharacterstic?.setNotifyValue(false);
      widget.targetCharacterstic?.lastValueStream.listen((value) {
        print("stringValue11  $value");
        // Decode the value to string
        String stringValue = utf8.decode(value);
        print("stringValue11  $stringValue");
        logData.add(stringValue);
        if (mounted) {
          setState(() {});
        }
      });
    }
    else{
      AppUtils.showflushBar(
          "Your Device is not connected to any hardware",
          context);
    }
  }
  AppUtils util = AppUtils();


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
  StreamSubscription<List<int>>? buildLogListener() {
    return widget.targetCharacterstic?.lastValueStream.listen((value) {
      print("stringValue  $value");
      // Decode the value to string
      String stringValue = utf8.decode(value);
      print("stringValue  $stringValue");
      logData.add(stringValue);
      if(mounted){
       setState(() {});
      }
    });
  }
}
