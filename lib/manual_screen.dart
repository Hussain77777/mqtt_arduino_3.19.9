import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  //final ValueNotifier<List<LogDataTime>>? logList; // Updated to ValueNotifier
  final List<LogDataTime>? logList;
  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  ScrollController _scrollController1 = ScrollController();
  MQTTClientManager mqttClientManager = MQTTClientManager();
  TextEditingController controller = TextEditingController();
  BluetoothCharacteristic? targetCharacterstic11;
  bool isLoading = false;
  List<String> usrList = [];
  ValueNotifier<List<LogDataTime>> logDataListNotifier = ValueNotifier<List<LogDataTime>>([]);

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
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BluetoothScreen()),
            (route) => false,
          );

          //   widget.device?.connect();
          AppUtils.showflushBar(
              "Your Device disConnected ${widget.device?.platformName}",
              context);
        }
      }
      if (state == BluetoothConnectionState.connected) {}
    });
  }

  @override
  void initState() {
    print("widget.logList?.length ${widget.logList?.length}");
   // _controller = widget.scrollController ?? ScrollController();
    // widget.logList?.removeLast();
    widget.logList?.forEach((element) {
     dataa.add(element);
      logDataListNotifier.value.add(element);
    });
    logDataListNotifier.notifyListeners();
  /*  logDataListNotifier.value.add(widget.logList);*/
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

      services?.forEach((service) async {
        if (kDebugMode) {
          print("service ${service.characteristics}");
        }

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
        bottomNavigationBar:LogWidget(
          size: size,
          logDataNotifier: ValueNotifier<List<LogDataTime>>(dataa), // Wrap with ValueNotifier
          scrollController: _scrollController1,
        ),
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
              child: const Padding(
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * 0.02,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: size.width * 0.07,
                right: size.width * 0.07,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ButtonWidget(
                      color: Color(0xFF70ad46),
                      onPressed: () async {
                        if (widget.device?.isConnected ?? false) {
                          if (kDebugMode) {
                            print("bbbbbbbbbbbbbbbbbbbb ${dataa.length}");
                          }
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
                      title: 'Automatic Mode ',
                      height: 0.07),
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
                right: size.width * 0.07,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      ButtonWidget(
                          color: const Color(0xFF4472c7),
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
                          color: const Color(0xFF4473c5),
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
                  Column(
                    children: [
                      ButtonWidgetForStatus(
                          color: Color(0xFFee7d31),
                          onPressed: () async {},
                          title: isStatusOn),
                      Image.asset(
                        "assets/updown.jpeg",
                        width: size.width * 0.20,
                      )
                    ],
                  )
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ButtonWidget(
                      color: const Color(0xFFfe0000),
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
                  Column(
                    children: [
                      ButtonWidgetForStatus(
                        color: (isPumpOn) ? Colors.green : Colors.red,
                        title: (isPumpOn) ? 'On' : 'Off',
                        onPressed: () async {},
                      ),
                      Image.asset(
                        "assets/motor.jpeg",
                        width: size.width * 0.20,
                      )
                    ],
                  ),

                  //),
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
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
                      color: const Color(0xFFee7d31),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ButtonWidget(
                          color: const Color(0xFFee7d31),
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
                          height: 0.07,
                          color: const Color(0xFFee7d31),
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
                  Image.asset(
                    "assets/setting.jpeg",
                    width: size.width * 0.3,
                  )
                ],
              ),
            ),
            Divider(
              height: size.height * 0.01,
              color: Colors.white,
            ),
            /* Container(
              padding: EdgeInsets.only(
                  top: size.height * 0.01, left: size.width * 0.03),
              color: Colors.black,
              width: size.width,
              height: size.height * 0.18,

              // margin: EdgeInsets.only(left: size.width*0.1,right: size.width*0.1,),
              child: Align(
                alignment: Alignment.topCenter,
                child: ListView.builder(
                    controller: _scrollController1,
                  //  reverse: true,
                    shrinkWrap: true,
                    itemCount: logData.length,
                    itemBuilder: (context, index) {
                      return Text(
                        // "${logData[index].time} -> ${logData[index].title}",
                        dataa[index].title,
                        style: const TextStyle(color: Colors.white),
                      );
                    }),
              ),
              */ /* child: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(logData.length, (index) {
          return Text(
            // "${logData[index].time} -> ${logData[index].title}",
            logData[index].title,
            style: const TextStyle(color: Colors.white),
          );
        }),
        ),
      ),*/ /*
            )*/
            //  SizedBox(height: size.height*0.02,),
          ],
        ),
      ),
    );
  }

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
        logDataListNotifier.value.add(LogDataTime(
          title: stringValue,
        ));
        logDataListNotifier.notifyListeners();
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
      print("targetCharacteristicForButton stringValue  $value");
      // Decode the value to string
      String targetCharactersticForButtonStringValue = utf8.decode(value);
      print(
          "targetCharacteristicForButton stringValue  $targetCharactersticForButtonStringValue");
      DateTime date = DateTime.now();
      String formattedDate = DateFormat('HH:mm:ss').format(date);

      if (targetCharactersticForButtonStringValue != null) {
        /*   buttonList.add(
          LogDataTime(
            title: targetCharacteristicForButtonStringValue,
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
      print("targetCharacteristicForStatus stringValue  $value");
      // Decode the value to string
      String targetCharactersticForStatusStringValue = utf8.decode(value);
      print(
          "targetCharacteristicForStatus stringValue  $targetCharactersticForStatusStringValue");
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
