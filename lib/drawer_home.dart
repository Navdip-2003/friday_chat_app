
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:friday_chat_app/log/login.dart';
import 'package:friday_chat_app/methods.dart';
import 'package:friday_chat_app/policies.dart';
import 'package:gallery_saver/files.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
class drawer_home extends StatefulWidget {
  const drawer_home({super.key});

  @override
  State<drawer_home> createState() => _drawer_homeState();
}

class _drawer_homeState extends State<drawer_home> {
  FirebaseFirestore _store = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String greetingMessage(){

    var timeNow = DateTime.now().hour;
    
    if (timeNow <= 12) {
      return 'Good Morning';
    } else if ((timeNow > 12) && (timeNow <= 16)) {
    return 'Good Afternoon';
    } else if ((timeNow > 16) && (timeNow < 20)) {
    return 'Good Evening';
    } else {
    return 'Good Night';
    }
  }
  var whether_data;
  var whether_current;
  bool isgetdata = false;
  var city = "amreli";
  Future get_city_whether() async{
    setState(() {
      isgetdata = true;
    });
      
      var res = await http.get(Uri.parse("https://api.weatherapi.com/v1/current.json?key=25a1ca48c9224a6aa79135604230401&q=$city&aqi=yes"));
      if(res.statusCode == 200){
        var result = jsonDecode(res.body);
        whether_data = result;
        whether_current = whether_data["current"];
        print(whether_data["current"]["temp_c"]);
        setState(() {
          isgetdata = false;
        });
      }
      setState(() {
          isgetdata = false;
        });
      
    }
  var whether = 32;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   // get_city_whether();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
                return  Drawer(
                  child: ListView(
                      padding: EdgeInsets.zero,
                      children: [

                        UserAccountsDrawerHeader(
                          
                          accountName: Text(snapshot.data!["firstname"]), 
                          accountEmail: Text(snapshot.data!["email"]),
                          currentAccountPicture: CircleAvatar(
                            
                          backgroundImage: snapshot.data!["image"] != null ? NetworkImage(snapshot.data!["image"]) :
                             NetworkImage("https://firebasestorage.googleapis.com/v0/b/chat-data-f147e.appspot.com/o/profile_image%2Fnoimage.png?alt=media&token=de45644f-9837-4c23-a306-cc583eeee05c")
                          ),
                          
                          decoration: BoxDecoration(
                            image: DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1483232539664-d89822fb5d3e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cGhvdG8lMjBiYWNrZ3JvdW5kfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60"), fit: BoxFit.cover)
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(greetingMessage() , style: TextStyle(fontSize: 20 , fontFamily: "SansFont"),),
                              Text("Navdip" , style: TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: "SansFont"),),
                            ],
                          ),
                        ),
                        Divider(
                          endIndent: 20,
                          indent: 20,
                          thickness: 3,
                        ),
                        // Align(
                        //   alignment: Alignment.center,
                        //   child: Column(
                        //     children: [
                              
                        //       Text("Currently In Surat " , style: TextStyle(fontFamily: "SansFont" , fontWeight: FontWeight.bold , fontSize: 15),),
                        //       isgetdata ? Text("Loading...") :
                        //       Row(
                                
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           Container(
                                    
                        //             height: 30,
                        //             width: 30,
                        //             child: Image.asset("asset/weather.png" , color: Colors.pinkAccent)),
                        //             SizedBox(width: 10,),
                        //           Text(
                        //             whether_data["current"]["temp_c"].toString() + "\u00B0", style: TextStyle(fontSize: 30 , color: Colors.pinkAccent),
                        //           ),
                        //         ],
                        //       )
                              
                        //     ],
                        //   ),
                        // ),
                        Divider(
                          endIndent: 20,
                          indent: 20,
                          thickness: 3,
                        ),
                        // ListTile(
                        //   leading: Icon(Icons.favorite),
                        //   title: Text("Favorites"),
                        //   onTap: (){

                        //   },
                        // ),
                        // ListTile(
                        //   leading: Icon(Icons.people),
                        //   title: Text("Friends"),
                        //   onTap: (){

                        //   },
                        // ),
                        ListTile(
                          leading: Icon(Icons.share),
                          title: Text("Share"),
                          onTap: () async{
                            print("share is clicked");
                            Share.share( " Let's chat on FriDayApp! It's a fast, simple, and secure app we can use to message and call each other for free. Get it at https://google.com/" );
                           
                            //await Share.share("this is navdip app chat app");

                          },
                        ),
                        // ListTile(
                        //   leading: Icon(Icons.notifications),
                        //   title: Text("Request"),
                        //   onTap: (){

                        //   },
                        // ),
                        // Divider(
                        //   endIndent: 10,
                        //   indent: 20,
                        //   thickness: 2,
                        // ),
                        ListTile(
                          leading: Icon(Icons.settings),
                          title: Text("Setting"),
                          onTap: (){

                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.description),
                          title: Text("Policies"),
                          onTap: (){

                            Navigator.push(context,MaterialPageRoute(builder: (context)=>policies()));
                           

                          },
                        ),
                        ListTile(
                          leading: Image.asset("asset/switch.png", scale: 20, color: Color.fromARGB(255, 218, 86, 3)),
                          title: Text("Logout" , style: TextStyle(fontSize: 20 , color: Color.fromARGB(179, 233, 18, 3)),),
                           onTap: () async {
                             await _store.collection("users").doc(_auth.currentUser!.uid).update({"status": "Offline"});

                             signout();
                             Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => login()), (route) => false);
                           }
                        ),
                           ListTile(
                          leading: Icon(Icons.restore),
                          title: Text("Reset password" , style: TextStyle(fontSize: 15 , color: Color.fromARGB(179, 60, 51, 51)),),
                           onTap: () async {
                            Navigator.pop(context);
                            var email = _auth.currentUser?.email;
                            reset_dialog();
                            
                            
                           }
                        )
                      ],
                    ),

                );
        }else{
          return Container();
        }
        
      },
    );
   
  }

  reset_dialog(){
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Reset Password !!"),
          content: Text("Press 'OK' And Check your email to reset your password "),
          actions: [
            TextButton(
              onPressed:() {
                Navigator.pop(context);
                
              }, 
              child: TextButton(
                child: Text("OK"),
                onPressed: () async {
                  var email = _auth.currentUser!.email;
                  await _auth.sendPasswordResetEmail(email: email!).then((value) {
                    Navigator.pop(context);
                  });
                  
                },
              )
            )
          ],
          actionsAlignment: MainAxisAlignment.center,
          icon: Icon(Icons.email),

        );
        
      },
    );
  }

}