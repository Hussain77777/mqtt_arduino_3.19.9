import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'automatic_screen.dart';

class LogDataScreen extends StatefulWidget {
  const LogDataScreen({super.key});

  @override
  State<LogDataScreen> createState() => _LogDataScreenState();
}

class _LogDataScreenState extends State<LogDataScreen> {
  List<LogDataTime>? localData = [];

  Future loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? listString = prefs.getStringList('list');
    localData = listString
        ?.map((item) => LogDataTime.fromMap(json.decode(item)))
        .toList();
    log("bbbbbbbbbbbbbbbbbbb ${listString?.map((item) => LogDataTime.fromMap(json.decode(item))).toList()}");
    log("ccccccccc $localData");
    setState(() {});
    localData?.forEach((element) {
      //  print("ccccccccc ${element.time}");
      print("ccccccccc ${element.title}");
    });
    //This command gets us the list stored with key name "list"
  }

  @override
  void initState() {
    loadData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
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
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  "Clear Log",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
          title: Text(
            "Logs",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Container(
          width: size.width,
          height: size.height,
          color: Colors.black,
          child: ((localData?.isEmpty ?? false || localData != null))
              ? CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(localData?.length ?? 0, (index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: size.width * 0.02, right: size.width * 0.02),
                        child: Text(
                          "${localData?[index].title}",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }),
                  ),
                ),
        ),
      ),
    );
  }
}
