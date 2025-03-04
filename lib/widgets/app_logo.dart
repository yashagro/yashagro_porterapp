import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double height;

  const AppLogo({this.width = 120, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset("assets/logo.png", width: width, height: height),
    );
  }
}
