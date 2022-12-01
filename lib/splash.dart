import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:friday_chat_app/log/login.dart';
import 'package:friday_chat_app/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friday_chat_app/variables.dart';

class splash extends StatefulWidget {
  const splash({super.key});

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     var use = FirebaseAuth.instance.currentUser;
    if(use != null){
      suser();
      //print("current user is  : "+ ddata!["email"]);
    }
     Timer(Duration(seconds: 3),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
       use == null ? login() : navigation()
     
     ));
     } ,
     );
    
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        child: Center(
          child: Container(
           height: size.height / 2,
           width: size.width / 1,
           child: Column(
            children: [
              Container(
                
                child: Image.asset("asset/logo.png" , fit: BoxFit.cover,height: size.height /7,)),

                Container(
              
                child: Text("FriDay Chat App" , style: TextStyle( fontSize: 20 , fontFamily: "SansFont" ,
                   fontWeight: FontWeight.bold , color: Color.fromARGB(255, 21, 114, 0)),)               ),
                SizedBox(height: size.height / 10,),
                Container(
                  child: CircularProgressIndicator(color: Color.fromARGB(255, 2, 90, 1) ),
                )

            ],
           ),
          ),
        ),
       

      ),
    );
  }
}