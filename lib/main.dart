


import 'package:flutter/material.dart';
import 'package:shake_detector/shake_detector_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shake Detoctor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ShakeDeductorPage(),
    );
  }
}


