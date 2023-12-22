import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_arduino/automatic_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_client/web_socket_client.dart';

import 'DataModel.dart';
import 'app_utils.dart';
import 'bluetooth.dart';
import 'home_screen.dart';
import 'mqtt.dart';

class ManualScreen extends StatefulWidget {
  ManualScreen(
      {super.key, this.logList, this.device, this.targetCharacterstic});

  final BluetoothDevice? device;
  BluetoothCharacteristic? targetCharacterstic;
  final List<LogDataTime>? logList;

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

  List<LogDataTime> dataa = [];

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
            "Your Device disConnected ${widget.device?.platformName}", context);
      }
      if (state == BluetoothConnectionState.connected) {}
    });
  }

  @override
  void initState() {
    widget.logList?.forEach((element) {
      dataa.add(element);
    });
    //   logData = widget.logList ?? [];
    checkDeviceStatus();
    logListener();
    super.initState();
  }

  BluetoothCharacteristic? targetCharacterstic;

  logListener() async {
    if (widget.device?.isConnected ?? false) {
      print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
      List<BluetoothService>? services =
          await widget.device?.discoverServices();
      /*  widget.targetCharacterstic?.setNotifyValue(true);
      widget.targetCharacterstic?.lastValueStream.listen((value) {
        print("stringValue11  $value");
        // Decode the value to string
        String stringValue = utf8.decode(value);
        print("stringValue11  $stringValue");
        logData.add(stringValue);
        if (mounted) {
          setState(() {});
        }
      });*/
      services?.forEach((service) async {
        print("service ${service.characteristics}");

        if (service.uuid.toString() == "fff0") {
          service.characteristics.forEach((characteristics) {
            if (characteristics.uuid.toString() == "fff1") {
              print("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
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
    } else {
      AppUtils.showflushBar(
          "Your Device is not connected to any hardware", context);
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
      bottomNavigationBar: LogWidget(size: size, logData: dataa),
      appBar: AppBar(
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
        backgroundColor: Color(0xFF757172),
        leading: InkWell(
            onTap: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AutomaticScreen(
                              logList: dataa,
                              device: widget.device,
                              //       targetCharacterstic: targetCharacterstic,
                            ))); // Your state change code here
              });
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
                  top: size.height * 0.02,
                  left: size.width * 0.07,
                  right: size.width * 0.07),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ButtonWidget(
                      color: Color(0xFF70ad46),
                      onPressed: () async {
                        if (widget.device?.isConnected ?? false) {
                          List<int> bytes = utf8.encode("A");
                          await targetCharacterstic?.write(bytes);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AutomaticScreen(
                                        logList: dataa,
                                        device: widget.device,
                                        //targetCharacterstic: targetCharacterstic,
                                      ))); //
                          // buildLogListener();
                        } else {
                          AppUtils.showflushBar(
                              "Your Device is not connected to any hardware",
                              context);
                        }
                      },
                      title: 'Automatic Mode '),
                  ButtonWidget(
                      color: Color(0xFF4472c7),
                      onPressed: () async {
                        if (widget.device?.isConnected ?? false) {
                          List<int> bytes = utf8.encode("U");
                          await targetCharacterstic?.write(bytes);

                          // buildLogListener();
                        } else {
                          AppUtils.showflushBar(
                              "Your Device is not connected to any hardware",
                              context);
                        }
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
                      onPressed: () async {
                        if (widget.device?.isConnected ?? false) {
                          List<int> bytes = utf8.encode("P");
                          await targetCharacterstic?.write(bytes);

                          // buildLogListener();
                        } else {
                          AppUtils.showflushBar(
                              "Your Device is not connected to any hardware",
                              context);
                        }
                      },
                      title: 'Pump '),
                  ButtonWidget(
                      color: Color(0xFF4473c5),
                      onPressed: () async {
                        if (widget.device?.isConnected ?? false) {
                          List<int> bytes = utf8.encode("D");
                          await targetCharacterstic?.write(bytes);

                          // buildLogListener();
                        } else {
                          AppUtils.showflushBar(
                              "Your Device is not connected to any hardware",
                              context);
                        }
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ButtonWidget(
                      color: Color(0xFFee7d31),
                      onPressed: () async {
                        if (widget.device?.isConnected ?? false) {
                          List<int> bytes = utf8.encode("C");
                          await targetCharacterstic?.write(bytes);

                          // buildLogListener();
                        } else {
                          AppUtils.showflushBar(
                              "Your Device is not connected to any hardware",
                              context);
                        }
                      },
                      title: 'Calibration '),
                  ButtonWidget(
                      color: Color(0xFFee7d31),
                      onPressed: () async {
                        if (widget.device?.isConnected ?? false) {
                          List<int> bytes = utf8.encode("T");
                          await targetCharacterstic?.write(bytes);

                          // buildLogListener();
                        } else {
                          AppUtils.showflushBar(
                              "Your Device is not connected to any hardware",
                              context);
                        }
                      },
                      title: 'Trouble  Shooting '),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> usrList = [];

  Future<StreamSubscription<List<int>>?> buildLogListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return targetCharacterstic?.lastValueStream.listen((value) {
      print("stringValue  $value");
      // Decode the value to string
      String stringValue = utf8.decode(value);
      print("stringValue  $stringValue");
      DateTime date = DateTime.now();
      String formattedDate = DateFormat('HH:mm:ss').format(date);

      if (stringValue != null) {
        dataa.add(
            LogDataTime(title: stringValue, time: formattedDate.toString()));
        if (usrList.length > 100) {
          prefs.clear();
        }
        if (usrList.length < 100) {
          usrList = dataa.map((item) => jsonEncode(item.toMap())).toList();

          prefs.setStringList("list", usrList);
        }

        if (mounted) {
          setState(() {});
        }
      }
    });
  }
}
