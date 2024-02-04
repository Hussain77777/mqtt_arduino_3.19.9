import 'package:flutter/material.dart';
import 'package:mqtt_arduino/movies_listview.dart';

class ScrollScreen extends StatefulWidget {
  const ScrollScreen({super.key});

  @override
  State<ScrollScreen> createState() => _ScrollScreenState();
}

class _ScrollScreenState extends State<ScrollScreen> {
  List movies1 = [
    'dja.jpg',
    'drive.jpg',
    'firsy.jpg',
    'quite.jpg',
    'seven.jpg',
    'ter.jpg',
  ];
  final ScrollController _scrollController1 = ScrollController();
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      double minScrollExtent1 = _scrollController1.position.minScrollExtent;
      double maxScrollExtent1 = _scrollController1.position.maxScrollExtent;

      //
      animateToMaxMin(maxScrollExtent1, minScrollExtent1, maxScrollExtent1, 25,
          _scrollController1);

    });
    super.initState();
  }

  animateToMaxMin(double max, double min, double direction, int seconds,
      ScrollController scrollController) {
    scrollController
        .animateTo(direction,
        duration: Duration(seconds: seconds), curve: Curves.linear)
        .then((value) {
      direction = direction == max ? min : max;
      animateToMaxMin(max, min, direction, seconds, scrollController);
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(body: Column(children: [
      Column(
        children: [
          MoviesListView(
            scrollController: _scrollController1,
            images: movies1,
          ),

        ],
      ),
    ],),);
  }
}
