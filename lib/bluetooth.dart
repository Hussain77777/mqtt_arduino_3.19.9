import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_arduino/app_utils.dart';
import 'package:mqtt_arduino/automatic_screen.dart';
import 'package:mqtt_arduino/logdata.dart';
import 'package:mqtt_arduino/manual_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacterstic;
  bool isScanning = false;
  List<LogDataTime> dataa = [];
  @override
  void initState() {
    super.initState();
  }

  int counter = 10;
  late Timer _timer;

  double percentValue = 1;

  bool showResendCode = false;

  void startTimer() {
    print("aaaaaaaaaaaaaaaaaa");
    counter = 5;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (counter > 0) {
        if (mounted) {
          setState(() {
            counter--;
          });

          if (counter == 0) {
            _timer.cancel();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ManualScreen(
                  device: connectedDevice,
                ),
              ),
            );
          }
        }
      } else {
        _timer.cancel();
      }
    });
  }

  bool isDeviceAvailable = false;

  void startScanning() async {
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
    if (await FlutterBluePlus.isSupported == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Bluetooth not supported by this device"),
        ),
      );

      return;
    }
    if (mounted) {
      setState(() {
        isScanning = true;
      });
    }
    await FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          if (mounted) {
            setState(() {
              if (result.device.platformName.contains("NAPL") ||
                  result.device.platformName.contains("napl")) {
                devices.add(result.device);
                isDeviceAvailable = true;
              }
            });
          }
        }
      }
    });
    if (mounted) {
      Future.delayed(Duration(seconds: 15), () {
        print("after 3 Seconds ");

        FlutterBluePlus.stopScan();
        if (mounted) {
          setState(() {
            isScanning = false;
          });
        }
        if (devices.isEmpty) {
          AppUtils.showflushBar("No Device Found", context);
        } else {
          //   AppUtils.showflushBar("Scan Completed Successfully", context);
        }
      });
    }
  }

  List<BluetoothService>? services;

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
   //     bottomNavigationBar: LogWidgetForBluetoothScreen(size: size, logData: dataa),
        appBar: AppBar(
          leading: !isScanning
              ? Container()
              : IconButton(
                  onPressed: () {
                    FlutterBluePlus.stopScan();
                    if (mounted) {
                      setState(() {
                        isScanning = false;
                        devices.clear();
                        isDeviceAvailable = false;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
          backgroundColor: Colors.blue,
          title: Text(
            "NAPL Solutions",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: (!isScanning && devices.isEmpty)
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height * 0.15,
                    ),
                    Text(
                      "Press this button to Start Scan",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    ButtonWidget(
                        color: Colors.blue,
                        onPressed: () async {
                          startScanning();
                        },
                        title: 'Scan'),
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    ButtonWidget(
                        color: Colors.blue,
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LogDataScreen()));
                        },
                        title: 'Logs'),
                  ],
                ),
              )
            : (!isDeviceAvailable)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.height * 0.15,
                      ),
                      Text(
                        "Scanning...",
                        style: TextStyle(
                            color: Colors.white, fontSize: size.width * 0.1),
                      ),
                      SizedBox(
                        height: size.height * 0.15,
                      ),
                      Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      print("device Length ${devices.length}");

                      var deviceData = devices[index];
                      if (!isDeviceAvailable) {
                        print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
                        return CircularProgressIndicator(
                          color: Colors.black,
                        );
                      }
                      return ListTile(
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            /*shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.8)),*/
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            connectedDevice = deviceData;
                            connectedDevice?.connect();
                            FlutterBluePlus.stopScan();

                            var subscription = connectedDevice?.connectionState
                                .listen((BluetoothConnectionState state) async {
                              if (state ==
                                  BluetoothConnectionState.disconnected) {
                                // 1. typically, start a periodic timer that tries to
                                //    reconnect, or just call connect() again right now
                                // 2. you must always re-discover services after disconnection!
                                //print("${connectedDevice?.disconnectReasonCode} ${connectedDevice?.disconnectReasonDescription}");
                              }
                              if (state == BluetoothConnectionState.connected) {
                                print("inside connected ");
                                logListener();
                           //     startTimer();
                                /*    Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ManualScreen(
                                      device: connectedDevice,
                                    ),
                                  ),
                                );*/
                                AppUtils.showflushBar(
                                    "Device Connected Successfully with ${connectedDevice?.platformName}",
                                    context);
                              }
                            });
                          },
                          child: Text(
                            "Connect",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        title: Text(
                          devices[index].platformName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.05,
                          ),
                        ),
                        subtitle: Text(
                          "macaddress : ${devices[index].id.toString()}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.033,
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  logListener() async {
    if (connectedDevice?.isConnected ?? false) {
      print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
      List<BluetoothService>? services =
          await connectedDevice?.discoverServices();

      services?.forEach((service) async {
        print("service ${service.characteristics}");

        if (service.uuid.toString() == "fff0") {
          service.characteristics.forEach((characteristics) {
            if (characteristics.uuid.toString() == "fff4") {
              print("bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
              targetCharacterstic = characteristics;
              targetCharacterstic?.setNotifyValue(true);
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

  List<String> usrList = [];

  Future<StreamSubscription<List<int>>?> buildLogListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return targetCharacterstic?.lastValueStream.listen((value) {
      print("stringValue  $value");

      String? stringValue = utf8.decode(value);
      print("stringValue  $stringValue");
    /*  if (mounted) {
        AppUtils.showflushBar(
            stringValue.isNotEmpty ? stringValue : "Empty", context);
      }*/
      dataa.add(LogDataTime(title: stringValue,
        //time: formattedDate
      ));
      if(mounted){
        // if (stringValue=="manual") {
        if (stringValue.contains("manual")) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ManualScreen(
                  device: connectedDevice,
                ),
              ),
                  (route) => false);
        }
        //    if (stringValue=="auto") {
        if (stringValue.contains("auto")) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => AutomaticScreen(
                    device: connectedDevice,
                  )),
                  (route) => false);
        }
        setState(() {

        });
      }

      //    AppUtils.showflushBar(stringValue??"Empty", context);
      DateTime date = DateTime.now();
      String formattedDate = DateFormat('HH:mm:ss').format(date);
    });
  }
}
