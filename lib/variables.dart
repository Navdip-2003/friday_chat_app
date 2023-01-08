
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

List Online_Images = [
  "https://images.unsplash.com/photo-1661956600684-97d3a4320e45?ixlib=rb-4.0.3&ixid=MnwxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwxfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60",
  "https://images.unsplash.com/photo-1670934166570-1831b0b9a4ca?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwyfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60",
  "https://images.unsplash.com/photo-1671713682273-9a18d748d6a8?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwxMHx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60",
  "https://images.unsplash.com/photo-1664574654700-75f1c1fad74e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwxNnx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60",
  "https://images.unsplash.com/photo-1664575600850-c4b712e6e2bf?ixlib=rb-4.0.3&ixid=MnwxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwzMnx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60",
  "https://images.unsplash.com/photo-1664575196644-808978af9b1f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwzN3x8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60",
  "https://images.unsplash.com/photo-1664574654529-b60630f33fdb?ixlib=rb-4.0.3&ixid=MnwxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHw0Mnx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60",
  "https://images.unsplash.com/photo-1671733049649-9e4d534c9796?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw1MHx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60"
  "https://images.unsplash.com/photo-1661956600684-97d3a4320e45?ixlib=rb-4.0.3&ixid=MnwxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwxfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60",
];


String format_time(Duration duration){
  String twodigit(int n) => n.toString().padLeft(2,'0');
  final hours = twodigit(duration.inHours);
  final minutes = twodigit(duration.inMinutes.remainder(60));
  final seconds = twodigit(duration.inSeconds.remainder(60));

  return [
    if(duration.inHours > 0 ) hours,
    minutes , seconds ,

  ].join(':');
}
  

