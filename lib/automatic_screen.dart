import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mqtt_arduino/manual_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:web_socket_client/web_socket_client.dart';

import 'app_utils.dart';
import 'bluetooth.dart';
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
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BleScanner()),
            (route) => false);
        //   widget.device?.connect();
        AppUtils.showflushBar(
            "Your Device disconnected ${widget.device?.platformName}", context);
      }
      if (state == BluetoothConnectionState.connected) {}
    });
  }

  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    checkDeviceStatus();
    super.initState();
  }

  void dispose() {
    targetCharacterstic?.setNotifyValue(false);
    super.dispose();
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
          InkWell(
            onTap: () {
              widget.device?.disconnect();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => BleScanner()),
                  (route) => false);
              AppUtils.showflushBar(
                  "Device Disconnected SuccessFully", context);
            },
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text(
                "Disconnect",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
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
                  print("vvvvvvvvvvvvvvvvvv");
                  if (widget.device?.isConnected ?? false) {
                    services = await widget.device?.discoverServices();

                    services?.forEach((service) async {
                      print("service ${service.characteristics}");

                      if (service.uuid.toString() ==
                          // "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
                          "fff0") {
                        service.characteristics.forEach((characteristics) {
                          if (characteristics.uuid.toString() ==
                              // "beb5483e-36e1-4688-b7f5-ea07361b26a8")
                              "fff1") {
                            targetCharacterstic = characteristics;
                            targetCharacterstic?.setNotifyValue(true);
                            if (mounted) {
                              // setState(() {});
                            }
                          }
                        });
                      }
                    });
                    List<int> bytes = utf8.encode("M");
                    await targetCharacterstic?.write(bytes);

                    buildLogListener();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManualScreen(
                                    logList: logData,
                                    device: widget.device,
                                    targetCharacterstic: targetCharacterstic,
                                  ))); // Your state change code here
                    });
                  } else {
                    AppUtils.showflushBar(
                        "Your Device is not connected to any hardware",
                        context);
                  }
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
