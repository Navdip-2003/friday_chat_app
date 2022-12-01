import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class demo2 extends StatelessWidget {
  const demo2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 100,
        width: 100,
        color: Colors.red,
      ),
    );
  }
}
