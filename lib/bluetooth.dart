import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mqtt_arduino/app_utils.dart';
import 'package:mqtt_arduino/automatic_screen.dart';

import 'home_screen.dart';

class BleScanner extends StatefulWidget {
  @override
  _BleScannerState createState() => _BleScannerState();
}

class _BleScannerState extends State<BleScanner> {
  // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacterstic;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
  }

  bool isDeviceAvailable = false;

  void startScanning() async {
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
    if (await FlutterBluePlus.isSupported == false) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bluetooth not supported by this device")));

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
          setState(() {
            if (result.device.platformName.contains("NAPL")) {
              devices.add(result.device);
              isDeviceAvailable = true;
            }
          });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: !isScanning?Container():IconButton(onPressed: (){
          FlutterBluePlus.stopScan();
          setState(() {
            isScanning=false;devices.clear();isDeviceAvailable=false;
          });
        }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        backgroundColor: Color(0xFF757172),

        title: Text(
          "NAPL Solutions",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: (!isScanning&&devices.isEmpty)
          ? Center(
              child: Column(     mainAxisAlignment: MainAxisAlignment.start,
                children: [ SizedBox(
                  height: size.height * 0.15,
                ),
                  Text("Press this button to Start Scan",style: TextStyle(fontSize: size.width*0.05,fontWeight: FontWeight.bold),),


                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  ButtonWidget(
                      color: Color(0xFF757172),
                      onPressed: () async {
                        startScanning();
                      },
                      title: 'Scan'),

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
                          color: Colors.black, fontSize: size.width * 0.1),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AutomaticScreen(
                                      device: connectedDevice,
                                    ),
                                  ),
                                );
                                AppUtils.showflushBar(
                                    "Device Connected Successfully with ${connectedDevice?.platformName}",
                                    context);
                              }
                            });
                          },
                          child: Text("Connect")),
                      title: Text(devices[index].platformName),
                      subtitle: Text(devices[index].id.toString()),
                    );
                  },
                ),
    );
  }
}
