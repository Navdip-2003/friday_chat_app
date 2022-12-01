
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore _store = FirebaseFirestore.instance;  
var user_email = _auth.currentUser!.email; 
var user_name = _auth.currentUser!.displayName;
var _fs = FirebaseFirestore.instance;
var _au = FirebaseAuth.instance;

var blank_image = "https://raw.githubusercontent.com/Navdip-2003/OnlineFlightBooking/master/images/80-805068_my-profile-icon-blank-profile-picture-circle-clipart.png";

Map<String , dynamic>? ddata;
  void suser() async {
   
    FirebaseFirestore store = FirebaseFirestore.instance;
    await store.collection("users").doc(_auth.currentUser!.uid).get().then((value)  {
     
        ddata = value.data();
      }); 
  }
String getter_chatid(user1 , user2){
  if(user1.toLowerCase().codeUnits[0] > user2.toLowerCase().codeUnits[0]){
    //  print("chat room id id the : $user1$user2");
      return "$user1$user2";
    }else{
     // print("chat room id id the  :$user2$user1");
      return "$user2$user1";
    }
}

Future<bool> onbackbutton(BuildContext context) async{
  bool? exitapp = await showDialog(
    context: context, 
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text("Are You Sure ?"),
        content: Text("Do you want to close Chat App !!"),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(false);

            }, 
            child: Text("NO")
          ),
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(true);

            }, 
            child: Text("YES")
          ),
        ],

      );
    }
  );
  return exitapp ?? false;
}



show_snak (BuildContext context, det){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(det))
  );
}

String get_chatid(String user1 , String user2){
  if(user1.toLowerCase().codeUnits[0] > user2.toLowerCase().codeUnits[0]){
    //  print("chat room id id the : $user1$user2");
      return "$user1$user2";
    }else{
     // print("chat room id id the  :$user2$user1");
      return "$user2$user1";
    }
}
  

