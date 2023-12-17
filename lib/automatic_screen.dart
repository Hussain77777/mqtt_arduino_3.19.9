import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mqtt_arduino/manual_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:web_socket_client/web_socket_client.dart';

import 'app_utils.dart';
import 'home_screen.dart';
import 'mqtt.dart';

class AutomaticScreen extends StatefulWidget {
  const AutomaticScreen({
    super.key,
    required this.device,
  });

  final BluetoothDevice? device;

  @override
  State<AutomaticScreen> createState() => _AutomaticScreenState();
}

class _AutomaticScreenState extends State<AutomaticScreen> {
  AppUtils util = AppUtils();
  BluetoothCharacteristic? targetCharacterstic;

  List<String> a = [];

  List<BluetoothService>? services;
  checkDeviceStatus() {
    var subscription = widget.device?.connectionState
        .listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        //   widget.device?.connect();
        AppUtils.showflushBar(
            "Your Device disConnected ${widget.device?.platformName}", context);
      }
      if (state == BluetoothConnectionState.connected) {}
    });
  }

  @override
  void initState() {
    checkDeviceStatus();
    super.initState();
  }

  List<String> logData = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: LogWidget(
        logData: logData,
        size: size,
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFF757172),
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        actions: [
          Icon(
            Icons.switch_right_outlined,
            color: Colors.white,
          )
        ],
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
                  services = await widget.device?.discoverServices();

                  services?.forEach((service) async {
                    print("service ${service.characteristics}");

                    if (service.uuid.toString() ==
                        "4fafc201-1fb5-459e-8fcc-c5c9c331914b") {
                      service.characteristics.forEach((characteristics) {
                        if (characteristics.uuid.toString() ==
                            "930a6b92-43f9-11ee-be56-0242ac120002") {
                          targetCharacterstic = characteristics;
                          setState(() {});
                        }
                      });
                    }
                  });
                  List<int> bytes = utf8.encode("A");
                  await targetCharacterstic?.write(bytes);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ManualScreen(
                                logList: logData,targetCharacterstic: targetCharacterstic,

                              )));
                },
                title: "Return to Manual Mode"),

            //   (isLoading)?Center(child: CircularProgressIndicator()):
          ],
        ),
      ),
    );
  }

  StreamSubscription<List<int>>? buildLogListener() {
    return targetCharacterstic?.lastValueStream.listen((value) {
      print("stringValue  $value");
      // Decode the value to string
      String stringValue = utf8.decode(value);
      print("stringValue  $stringValue");
      logData.add(stringValue);
      if (mounted) {
        setState(() {});
      }
    });
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
              "${logData[index]} ",
              style: TextStyle(color: Colors.white),
            );
          }),
        ),
      ),
    );
  }
}
