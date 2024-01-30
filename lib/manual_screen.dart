import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  List<LogDataTime> buttonList = [];

  bool isPumpOn = false;
  String isStatusOn = "Stop";

  checkDeviceStatus() {
    var subscription = widget.device?.connectionState
        .listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BluetoothScreen()),
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
    // widget.logList?.removeLast();
    widget.logList?.forEach((element) {
      dataa.add(element);
    });
    //   logData = widget.logList ?? [];
    checkDeviceStatus();
    logListener();
    super.initState();
  }

  BluetoothCharacteristic? targetCharacterstic;
  BluetoothCharacteristic? targetCharactersticForButton;
  BluetoothCharacteristic? targetCharactersticForStatus;

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
            }
            if (characteristics.uuid.toString() == "fff2") {
              print("targetCharactersticForButton ");
              targetCharactersticForButton = characteristics;
              targetCharactersticForButton?.setNotifyValue(true);
            }
            if (characteristics.uuid.toString() == "fff3") {
              print("targetCharactersticForStatus ");
              targetCharactersticForStatus = characteristics;
              targetCharactersticForStatus?.setNotifyValue(true);
            }
          });
        }
      });

      buildLogListener();
      buildLogListenerForButton();
      buildLogListenerForStatus();
    } else {
      AppUtils.showflushBar(
          "Your Device is not connected to any hardware", context);
    }
  }

  AppUtils util = AppUtils();

  @override
  void dispose() {
//widget.device?.disconnect();
    print("sd fmsdf sdfsdf");

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        bottomNavigationBar: LogWidget(size: size, logData: dataa),
        appBar: AppBar(
          actions: [
            InkWell(
              onTap: () {
                widget.device?.disconnect();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => BluetoothScreen()),
                    (route) => false);
                AppUtils.showflushBar(
                    "Device Disconnected SuccessFully", context);
              },
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  "Disconnect",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
          backgroundColor: Colors.blue,
          leading: InkWell(
              onTap: () {
                //    dataa.removeLast();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AutomaticScreen(
                        logList: dataa,
                        device: widget.device,
                        //       targetCharacterstic: targetCharacterstic,
                      ),
                    ),
                  ); // Your state change code here
                });
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          title: const Text(
            "Manual Mode",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: //(isLoading)?Center(child: CircularProgressIndicator()):
              Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * 0.02,
              ),
              Padding(
                padding: EdgeInsets.only(
                  //   top: size.height * 0.005,
                  left: size.width * 0.07,
                  right: size.width * 0.07,
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ButtonWidget(
                        color: Color(0xFF70ad46),
                        onPressed: () async {
                          if (widget.device?.isConnected ?? false) {
                            print("bbbbbbbbbbbbbbbbbbbb ${dataa.length}");
                            if (dataa.length > 1) {
                              List<int> bytes = utf8.encode("A");
                              await targetCharacterstic?.write(bytes);
                              dataa.removeLast();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AutomaticScreen(
                                    logList: dataa,
                                    device: widget.device,
                                    //targetCharacterstic: targetCharacterstic,
                                  ),
                                ),
                              ); //
                              ();
                            } else {
                              AppUtils.showflushBar(
                                  "Waiting for Previous Logs", context);
                            }
                          } else {
                            AppUtils.showflushBar(
                                "Your Device is not connected to any hardware",
                                context);
                          }
                        },
                        title: 'Automatic Mode '),
                  ],
                ),
              ),
              Divider(
                height: size.height * 0.01,
                color: Colors.white,
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Padding(
                padding: EdgeInsets.only(
                    //top: size.height * 0.01,
                    left: size.width * 0.07,
                    right: size.width * 0.07),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        ButtonWidget(
                            color: Color(0xFF4472c7),
                            onPressed: () async {
                              if (widget.device?.isConnected ?? false) {
                                if (dataa.length > 1) {
                                  List<int> bytes = utf8.encode("U");
                                  await targetCharacterstic?.write(bytes);

                                  ();
                                } else {
                                  AppUtils.showflushBar(
                                      "Waiting for Previous Logs", context);
                                }
                              } else {
                                AppUtils.showflushBar(
                                    "Your Device is not connected to any hardware",
                                    context);
                              }
                            },
                            title: 'Reel Up '),
                        ButtonWidget(
                            color: Color(0xFF4473c5),
                            onPressed: () async {
                              if (widget.device?.isConnected ?? false) {
                                if (dataa.length > 1) {
                                  List<int> bytes = utf8.encode("D");
                                  await targetCharacterstic?.write(bytes);
                                } else {
                                  AppUtils.showflushBar(
                                      "Waiting for Previous Logs", context);
                                }
                              } else {
                                AppUtils.showflushBar(
                                    "Your Device is not connected to any hardware",
                                    context);
                              }
                            },
                            title: 'Reel Down '),
                      ],
                    ),
                    ButtonWidgetForStatus(
                        color: Color(0xFFee7d31),
                        onPressed: () async {},
                        title: isStatusOn),
                  ],
                ),
              ),
              Divider(
                height: size.height * 0.01,
                color: Colors.white,
              ),
              SizedBox(
                height: size.height * 0.01,
              ),

              Padding(
                padding: EdgeInsets.only(
                    left: size.width * 0.07, right: size.width * 0.07),
                child: Row(
                  //    crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonWidget(
                        color: Color(0xFFfe0000),
                        onPressed: () async {
                          if (widget.device?.isConnected ?? false) {
                            if (dataa.length > 1) {
                              List<int> bytes = utf8.encode("P");
                              await targetCharacterstic?.write(bytes);
                            } else {
                              AppUtils.showflushBar(
                                  "Waiting for Previous Logs", context);
                            }
                          } else {
                            AppUtils.showflushBar(
                                "Your Device is not connected to any hardware",
                                context);
                          }
                        },
                        title: 'Pump'),
                    ButtonWidgetForStatus(
                        color: (isPumpOn) ? Colors.green : Colors.red,
                        onPressed: () async {},
                        title: (isPumpOn) ? 'On' : 'Off'),
                    //),
                  ],
                ),
              ),
              Divider(
                height: size.height * 0.01,
                color: Colors.white,
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: size.width * 0.07, right: size.width * 0.07),
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonWidget(
                        color: Color(0xFFee7d31),
                        onPressed: () async {
                          if (widget.device?.isConnected ?? false) {
                            if (dataa.length > 1) {
                              List<int> bytes = utf8.encode("Q");
                              await targetCharacterstic?.write(bytes);
                            } else {
                              AppUtils.showflushBar(
                                  "Waiting for Previous Logs", context);
                            }
                          } else {
                            AppUtils.showflushBar(
                                "Your Device is not connected to any hardware",
                                context);
                          }
                        },
                        title: 'Status'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: size.width * 0.07, right: size.width * 0.07),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonWidget(
                        color: Color(0xFFee7d31),
                        onPressed: () async {
                          if (widget.device?.isConnected ?? false) {
                            if (dataa.length > 1) {
                              List<int> bytes = utf8.encode("C");
                              await targetCharacterstic?.write(bytes);
                            } else {
                              AppUtils.showflushBar(
                                  "Waiting for Previous Logs", context);
                            }
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
                            if (dataa.length > 1) {
                              List<int> bytes = utf8.encode("T");
                              await targetCharacterstic?.write(bytes);
                            } else {
                              AppUtils.showflushBar(
                                  "Waiting for Previous Logs", context);
                            }
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
              Divider(
                height: size.height * 0.01,
                color: Colors.white,
              ),
              //  SizedBox(height: size.height*0.02,),
            ],
          ),
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
        dataa.add(LogDataTime(
          title: stringValue,
        ));
        if (usrList.length > 100) {
          prefs.clear();
        }
        if (usrList.length < 100) {
          usrList = dataa.map((item) => jsonEncode(item.toMap())).toList();

          prefs.setStringList("list", usrList);
        }
        // SchedulerBinding.instance?.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
        //     });
      }
    });
  }

  Future<StreamSubscription<List<int>>?> buildLogListenerForButton() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return targetCharactersticForButton?.lastValueStream.listen((value) {
      print("targetCharactersticForButton stringValue  $value");
      // Decode the value to string
      String targetCharactersticForButtonStringValue = utf8.decode(value);
      print(
          "targetCharactersticForButton stringValue  $targetCharactersticForButtonStringValue");
      DateTime date = DateTime.now();
      String formattedDate = DateFormat('HH:mm:ss').format(date);

      if (targetCharactersticForButtonStringValue != null) {
        /*   buttonList.add(
          LogDataTime(
            title: targetCharactersticForButtonStringValue,
          ),
        );*/
        if (targetCharactersticForButtonStringValue == "pump_on") {
          isPumpOn = true;
        }
        if (targetCharactersticForButtonStringValue == "pump_off") {
          isPumpOn = false;
        }
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Future<StreamSubscription<List<int>>?> buildLogListenerForStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return targetCharactersticForStatus?.lastValueStream.listen((value) {
      print("targetCharactersticForStatus stringValue  $value");
      // Decode the value to string
      String targetCharactersticForStatusStringValue = utf8.decode(value);
      print(
          "targetCharactersticForStatus stringValue  $targetCharactersticForStatusStringValue");
      DateTime date = DateTime.now();
      String formattedDate = DateFormat('HH:mm:ss').format(date);

      if (targetCharactersticForStatusStringValue != null) {
        /*   buttonList.add(
          LogDataTime(
            title: targetCharactersticForButtonStringValue,
          ),
        );*/
        isStatusOn = targetCharactersticForStatusStringValue;
        /* if (targetCharactersticForStatusStringValue == "forward") {
          isStatusOn = true;
        }
        if (targetCharactersticForStatusStringValue == "reverse") {
          isStatusOn = false;
        }*/
        if (mounted) {
          setState(() {});
        }
      }
    });
  }
}
