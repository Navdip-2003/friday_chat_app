import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class open_image extends StatefulWidget {
  var url;
  open_image({super.key,  this.url});

  @override
  State<open_image> createState() => _open_imageState(url);
}

class _open_imageState extends State<open_image> {
  var url;
  _open_imageState(this.url);
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      
      body: SafeArea(
        child: InteractiveViewer(
          panAxis: PanAxis.free,
          panEnabled: true,
          
          child: Container(
            color: Colors.black,
            height: size.height,
            width: size.width,
            child: Image.file(File(url))
          ),
        ),
      ),
    );
  }
}