import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_scroll/auto_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_arduino/manual_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:web_socket_client/web_socket_client.dart';

import 'app_utils.dart';
import 'bluetooth.dart';
import 'home_screen.dart';
import 'mqtt.dart';

class AutomaticScreen extends StatefulWidget {
  AutomaticScreen({
    super.key,
    required this.device,
    this.logList,
  });

  final BluetoothDevice? device;
  BluetoothCharacteristic? targetCharacterstic;
  final List<LogDataTime>? logList;

  @override
  State<AutomaticScreen> createState() => _AutomaticScreenState();
}

class _AutomaticScreenState extends State<AutomaticScreen> {
  AppUtils util = AppUtils();
  BluetoothCharacteristic? targetCharacterstic;

  List<String> a = [];

  List<BluetoothService>? services;

  checkDeviceStatus() async {
    var subscription = widget.device?.connectionState
        .listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BleScanner()),
            (route) => false);

        AppUtils.showflushBar(
            "Your Device disconnected ${widget.device?.platformName}", context);
      }

      if (state == BluetoothConnectionState.connected) {}
    });
    if (widget.device?.isConnected ?? false) {
      services = await widget.device?.discoverServices();

      services?.forEach((service) async {
        print("service ${service.characteristics}");

        if (service.uuid.toString() == "fff0") {
          service.characteristics.forEach((characteristics) {
            if (characteristics.uuid.toString() == "fff1") {
              targetCharacterstic = characteristics;
              targetCharacterstic?.setNotifyValue(true);
              if (mounted) {
                // setState(() {});
              }
            }
          });
        }
      });

      buildLogListener();
    }
  }

  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    widget.logList?.forEach((element) {
      dataa.add(element);
    });
    //  logData=widget.logList??[];
    checkDeviceStatus();
    super.initState();
  }

  void dispose() {
    //targetCharacterstic?.setNotifyValue(false);
    super.dispose();
  }

  List<String> logData = [];
  List<LogDataTime> dataa = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: LogWidget(
        logData: dataa,
        size: size,
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFF757172),
        leading: InkWell(
            onTap: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManualScreen(
                              logList: dataa,
                              device: widget.device,
                              targetCharacterstic: targetCharacterstic,
                            ))); // Your state change code here
              });
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
                    List<int> bytes = utf8.encode("M");
                    await targetCharacterstic?.write(bytes);

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManualScreen(
                                    logList: dataa,
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
      DateTime date = DateTime.now();
      String formattedDate = DateFormat('HH:mm:ss').format(date);
      if (stringValue != null) {
        dataa.add(LogDataTime(title: stringValue, time: formattedDate));
        if (mounted) {
          setState(() {});
        }
      }
    });
  }
}

class LogDataTime {
  final String title;
  final String time;

  LogDataTime({required this.title, required this.time});
}

class LogWidget extends StatefulWidget {
  const LogWidget({
    super.key,
    required this.size,
    required this.logData,
  });
  final Size size;
  final List<LogDataTime> logData;

  @override
  State<LogWidget> createState() => _LogWidgetState();
}

class _LogWidgetState extends State<LogWidget> {
  final items = [1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    return AutoScroller(
      lengthIdentifier: items.length,
      anchorThreshold: 24,
      startAnchored: false,
      builder: (context, controller) {
        return ListView.builder(
          controller: controller,
          itemCount: items.length,
          itemBuilder: (context, index) =>
              ListTile(title: Text('Item ${items[index]}')),
        );
      },
    );
    /*   return Container(
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
              "${logData[index].time} -> ${logData[index].title}",
              style: TextStyle(color: Colors.white),
            );
          }),
        ),
      ),
    );*/
  }
}
