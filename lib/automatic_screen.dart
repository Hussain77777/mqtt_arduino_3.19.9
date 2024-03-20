import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_arduino/manual_screen.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  ScrollController _scrollController1 = ScrollController();
  Future loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? listString = prefs.getStringList('list');
    localData = listString
        ?.map((item) => LogDataTime.fromMap(json.decode(item)))
        .toList();
    log("bbbbbbbbbbbbbbbbbbb ${listString?.map((item) => LogDataTime.fromMap(json.decode(item))).toList()}");
    log("ccccccccc $localData");
    localData?.forEach((element) {
      // print("ccccccccc ${element.time}");
      print("ccccccccc ${element.title}");
    });
    //This command gets us the list stored with key name "list"
  }

  checkDeviceStatus() async {
    var subscription = widget.device?.connectionState
        .listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.disconnected) {
        if(mounted){
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => BluetoothScreen()),
            (route) => false);

        AppUtils.showflushBar(
            "Your Device disconnected ${widget.device?.platformName}", context);
      }}

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
    loadData();
    //  widget.logList?.removeLast();
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
  List<LogDataTime>? localData = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        bottomNavigationBar: LogWidgetForAutomaticMode(
          logData: dataa,
          size: size,scrollController: _scrollController1,
          logDataNotifier: ValueNotifier<List<LogDataTime>>(dataa),
        ),
        appBar: AppBar(
          backgroundColor: Colors.blue,
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
          title: Text(
            "Automatic Mode",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * 0.05,
              ),
              Padding(
                padding: EdgeInsets.only(
                  //   top: size.height * 0.005,
                  left: size.width * 0.07,
                  right: size.width * 0.07,
                ),
                child: ButtonWidget(height: 0.07,
                    color: Colors.orange,
                    onPressed: () async {
                      print("vvvvvvvvvvvvvvvvvv");

                      if (widget.device?.isConnected ?? false) {
                        List<int> bytes = utf8.encode("M");
                        await targetCharacterstic?.write(bytes);
                        dataa.removeLast();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ManualScreen(
                                        logList: dataa,
                                        device: widget.device,
                                        targetCharacterstic:
                                            targetCharacterstic,
                                      ))); // Your state change code here
                        });
                      } else {
                        AppUtils.showflushBar(
                            "Your Device is not connected to any hardware",
                            context);
                      }
                    },
                    title: "Return to Manual Mode"),
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
                  //   top: size.height * 0.005,
                  left: size.width * 0.07,
                  right: size.width * 0.07,
                ),
                child: ButtonWidget(
                    color: Colors.orange,
                    onPressed: () async {
                      print("vvvvvvvvvvvvvvvvvv");

                      if (widget.device?.isConnected ?? false) {
                        List<int> bytes = utf8.encode("Q");
                        await targetCharacterstic?.write(bytes);
                      } else {
                        AppUtils.showflushBar(
                            "Your Device is not connected to any hardware",
                            context);
                      }
                    },
                    title: "Status"),
              ),
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
          //time: formattedDate
        ));
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

class LogDataTime {
  final String title;

//  final String time;

  LogDataTime({
    required this.title, //required this.time
  });

  LogDataTime.fromMap(
      Map map) // This Function helps to convert our Map into our User Object
      : this.title = map["title"];

  //      this.time = map["time"];

  Map toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "title": title,
      //  "time": this.time,
    };
  }
}
class LogWidget extends StatefulWidget {
  const LogWidget({
    Key? key,
    required this.size,
    required this.logDataNotifier, // Updated to ValueNotifier
    this.scrollController,
  }) : super(key: key);

  final ScrollController? scrollController;
  final Size size;
  final ValueNotifier<List<LogDataTime>> logDataNotifier; // Use ValueNotifier here

  @override
  _LogWidgetState createState() => _LogWidgetState();
}
class _LogWidgetState extends State<LogWidget> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: widget.size.height * 0.01,
        left: widget.size.width * 0.03,
      ),
      color: Colors.black,
      width: widget.size.width,
      height: widget.size.height * 0.18,
      child: Align(
        alignment: Alignment.topCenter,
        child: ValueListenableBuilder<List<LogDataTime>>(
          valueListenable: widget.logDataNotifier,
          builder: (context, logData, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_controller.hasClients) {
                _controller.animateTo(
                  _controller.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }
            });
            return ListView.builder(
              controller: _controller,
              shrinkWrap: true,
              itemCount: logData.length,
              itemBuilder: (context, index) {
                return Text(
                  logData[index].title,
                  style: const TextStyle(color: Colors.white),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/*
class LogWidget extends StatefulWidget {
  const LogWidget({
    Key? key,
    required this.size,
    required this.logData,
    this.scrollController,
  }) : super(key: key);

  final ScrollController? scrollController;
  final Size size;
  final List<LogDataTime> logData;

  @override
  _LogWidgetState createState() => _LogWidgetState();
}

class _LogWidgetState extends State<LogWidget> {
  late Timer _timer;
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.scrollController ?? ScrollController();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_controller.hasClients) {
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: widget.size.height * 0.01,
        left: widget.size.width * 0.03,
      ),
      color: Colors.black,
      width: widget.size.width,
      height: widget.size.height * 0.18,
      child: Align(
        alignment: Alignment.topCenter,
        child: ListView.builder(
          controller: _controller,
         // reverse: true,
          shrinkWrap: true,
          itemCount: widget.logData.length,
          itemBuilder: (context, index) {
            return Text(
              widget.logData[index].title,
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}
*/

class LogWidgetForAutomaticMode extends StatefulWidget {
  const LogWidgetForAutomaticMode({
    super.key,
    required this.size,
    required this.logData, this.scrollController, required this.logDataNotifier,
  });
  final ScrollController? scrollController;
  final Size size;
  final List<LogDataTime> logData;
  final ValueNotifier<List<LogDataTime>> logDataNotifier;
  @override
  State<LogWidgetForAutomaticMode> createState() => _LogWidgetForAutomaticModeState();
}

class _LogWidgetForAutomaticModeState extends State<LogWidgetForAutomaticMode> {

  late Timer _timer;


  @override
  void initState() {
    super.initState();
    _controller = widget.scrollController ?? ScrollController();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_controller.hasClients) {
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }
  late ScrollController _controller;
  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(top: widget.size.height * 0.01, left: widget.size.width * 0.03),
      color: Colors.black,
      width: widget.size.width,
      height: widget.size.height * 0.58,

      // margin: EdgeInsets.only(left: size.width*0.1,right: size.width*0.1,),
      child:  Align(
        alignment: Alignment.topCenter,
        child: ValueListenableBuilder<List<LogDataTime>>(
          valueListenable: widget.logDataNotifier,
          builder: (context, logData, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_controller.hasClients) {
                _controller.animateTo(
                  _controller.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              }
            });
            return ListView.builder(
              controller: _controller,
              shrinkWrap: true,
              itemCount: logData.length,
              itemBuilder: (context, index) {
                return Text(
                  logData[index].title,
                  style: const TextStyle(color: Colors.white),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

