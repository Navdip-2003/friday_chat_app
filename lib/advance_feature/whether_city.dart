import 'dart:convert';

import 'package:flutter/material.dart' ;
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gallery_saver/files.dart';
import 'package:http/http.dart' as http;

class whether_city extends StatefulWidget {
  const whether_city({super.key});

  @override
  State<whether_city> createState() => _whether_cityState();
}

class _whether_cityState extends State<whether_city> {
  @override
  Widget build(BuildContext context) {
    Future get_city_whether() async{
      
      var res = await http.get(Uri.parse("https://api.weatherapi.com/v1/current.json?key=25a1ca48c9224a6aa79135604230401&q=surat&aqi=yes"));
      var result = jsonDecode(res.body);
      print(result);
    }
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            children: [
              TextField(),
              ElevatedButton(
                onPressed: (){
                  get_city_whether();

                }, 
                child: Text("Get wether the city")
              )
            ],
          ),
        )
      ),
    );
  }
}