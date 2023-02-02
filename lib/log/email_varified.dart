import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lottie/lottie.dart';

class email_varified extends StatefulWidget {
  const email_varified({super.key});

  @override
  State<email_varified> createState() => _email_varifiedState();
}

class _email_varifiedState extends State<email_varified> with SingleTickerProviderStateMixin {
  late AnimationController cont;
  bool is_varify = false;
  var _auth = FirebaseAuth.instance;
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      cont = AnimationController(
      duration: Duration(milliseconds: 750),
      vsync: this);
    
    is_varify = _auth.currentUser!.emailVerified;


  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container(
              //   child: Text("Security ",
              //     style: TextStyle(
              //       fontFamily: "SansFont",
              //       color: Color.fromARGB(255, 0, 0, 0),
              //       fontWeight: FontWeight.bold,
              //       fontSize: 30

              //     ),
              //   ),
              // ),
              !is_varify ? Align(
                child: Container(
                  alignment: Alignment.center,
                  child: Lottie.asset("asset/email_verify.json"  , fit: BoxFit.fitWidth , width: size.width / 1.3 , height: size.height / 3),
                ),
              ) : Container(),

              Container(
                padding: EdgeInsets.all(5),
                child: text_our("YOU'RE ONE STEP AWAY" , FontWeight.bold , 17, TextOverflow.ellipsis , Color.fromARGB(255, 77, 76, 76))
              ),
              Container(
                padding: EdgeInsets.all(5),
                child: text_our("Verify Your Email Address", FontWeight.w900, 35, TextOverflow.clip , Colors.black),
              ),
              Container(
                padding: EdgeInsets.all(5),
                child: text_our("To complete your profile and start chatting your friends , " + '\n'+ " you'll need to verify your email address.", FontWeight.normal, 15, TextOverflow.clip , Colors.black),
              ),
              Container(
                
                padding: EdgeInsets.all(5),
                child: text_our("Check your email and click on the confirmation link to continue.", FontWeight.w400, 18, TextOverflow.clip , Colors.black),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dangerous , color: Color.fromARGB(200, 83, 19, 168),size: 30,),
                      SizedBox(width: 10,),
                      text_our("Please Still Do not use Press Back Button !!", FontWeight.w500, 18, TextOverflow.clip , Colors.black),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: size.height / 15,
              ),
              Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: Color.fromARGB(200, 83, 19, 168),
                ),
              ),
            ],
          ),
        ) ,
      ),
    );
  }
  Widget text_our(text, FontWeight fontWeight, double sizee, TextOverflow TextOverflow, Color color){
    return Text(text,
      style: TextStyle(
        fontWeight: fontWeight,
        fontSize: sizee,
        overflow: TextOverflow,
        color: color
      ),
    
    );
  }
}