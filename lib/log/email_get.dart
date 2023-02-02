import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:friday_chat_app/log/email_varified.dart';

class email_get extends StatefulWidget {
  const email_get({super.key});

  @override
  State<email_get> createState() => _email_getState();
}

class _email_getState extends State<email_get> {
  TextEditingController email = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context)  {
    var size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
    
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.height / 40,
                ),
                Container(
                  child: AutoSizeText(
                    "Sign Up",
                    minFontSize: 30,
                    maxLines: 35,
                    style: TextStyle(
                      color: Color.fromARGB(211, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontFamily: "SansFont"
                    ),
                  ),
                ),
                Container(
                  height: size.height / 2.5,
                  width: size.width ,
                  
                  child: Image.asset("asset/ddda.png" , fit: BoxFit.cover,),
                  
                ),
                Container(
                  child: AutoSizeText("YOU'RE ONE STEP AWAT",
                    minFontSize: 10,
                    maxFontSize: 15,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
        
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 70,
                ),
                Container(
                  child: AutoSizeText("Enter Your Email And Verify ..",
                    overflow: TextOverflow.clip,
                    minFontSize: 30,
                    maxFontSize: 35,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
        
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                Container(
                    width: size.width,
                    
                    child: TextFormField(
                      controller: email,
                      autocorrect: false,
                      
                      validator: ((value) {
                        if(value!.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)){
                                return "Enter Correct Email Address";
                            }else{
                               return null;
                            }
                        
                      }),
                      decoration: InputDecoration(
                        
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)
                        ),
                        prefixIcon: Icon(Icons.email , color: Color.fromARGB(253, 193, 3, 41) , size: 30 ,),
                        hintText: "Enter Email Address",
                        
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color.fromARGB(255, 72, 34, 1))
                        ),
                        hintStyle: TextStyle(color:Colors.black ),
                        labelText: "Email",
                        labelStyle: TextStyle(color: Color.fromARGB(251, 144, 3, 1) , fontSize: 20)
                      ),
                  
                    ),
                  ),
               
                  SizedBox(
                    height: size.height / 15,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: (){
                        if(formKey.currentState!.validate()){
                          log("validate");
                          FirebaseAuth.instance.currentUser!.sendEmailVerification();
                         // Navigator.push(context, MaterialPageRoute(builder: (context)=>email_varified()));
                        }else{
                          log("NOT validate");
                        }
                      },
                      child: Container(
                        height: size.height / 15,
                        width: size.width / 3,
                        
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Center(child: Text("VARIFY" , style: TextStyle(
                            fontSize: 20 , color: Colors.white , fontWeight: FontWeight.bold , fontFamily: "SansFont"
                          ),
                        )),
                                      
                      ),
                    ),
                  ),
                
                
              ],
            ),
          ),
        ),
      ),
          ),
    );
  }
}