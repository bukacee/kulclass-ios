import 'package:flutter/material.dart';

// TEST: Minimal App to check if Native Layer is healthy
void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.green,
      body: Center(child: Text("NATIVE LAYER IS OK")),
    ),
  ));
}