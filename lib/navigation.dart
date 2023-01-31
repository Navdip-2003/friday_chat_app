import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:friday_chat_app/advance_feature/audio_player.dart';
import 'package:friday_chat_app/advance_feature/whether_city.dart';
import 'package:friday_chat_app/contact.dart';
import 'package:friday_chat_app/dispaly_homepage.dart';
import 'package:friday_chat_app/home.dart';
import 'package:friday_chat_app/image_compressed.dart';
import 'package:friday_chat_app/navi_item/profile_user.dart';
import 'package:friday_chat_app/navi_item/user_profile.dart';
import 'package:friday_chat_app/overlay_image.dart';
import 'package:friday_chat_app/pagination.dart';
import 'package:friday_chat_app/post/pagination_comment.dart';
import 'package:friday_chat_app/post/post_home.dart';
import 'package:friday_chat_app/post/setting_post/Allpost.dart';
import 'package:friday_chat_app/ratio_image.dart';
import 'package:friday_chat_app/single_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friday_chat_app/story/homest.dart';
import 'package:friday_chat_app/story/st_home.dart';
import 'package:friday_chat_app/story/storyhome.dart';
import 'package:friday_chat_app/try.dart';
import 'package:friday_chat_app/try1.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:friday_chat_app/vedio_play.dart';
import 'package:friday_chat_app/video.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class navigation extends StatefulWidget {
  int? i;
  navigation({int? this.i, super.key});

  @override
  State<navigation> createState() => _navigationState();
}

class _navigationState extends State<navigation> with WidgetsBindingObserver {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _store = FirebaseFirestore.instance;
  late StreamSubscription subscription;
  var isdeviceconnected = false;
  bool isalertset = false;

  var bottom_key = GlobalKey<State<BottomNavigationBar>>();

  int currentindex = 0;
  List pages = [
    contact(),

    //comment_pagination(),
    //file_piker(),
    //MyHomePage(),
    //comment_pagination(),
    //permission_handle(),
    //try1(),
   // chat_pagination(),
   //VideoPlayerScreen(),
   //VideoApp(),
   // story_home(),
   //allpost(),
    //MyHomePage(),
   // homest(),
  // compressed_image(),
  //overlay_image(),
 // ratio_image(),
   // whether_city(),
   audio_player(),
    post_home(),
    profile_user()
  ];
  void setstatus(String state) async {
    await _store.collection("users").doc(_auth.currentUser?.uid).update({"status": state});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var use = FirebaseAuth.instance.currentUser;
    getconnectivity();
    if (use != null) {
      suser();
      //print("current user is  : "+ ddata!["email"]);
    }

    if (widget.i != null) {
      BottomNavigationBar br = bottom_key.currentWidget as BottomNavigationBar;
      br.onTap!(1);
    }

    WidgetsBinding.instance.addObserver(this);
  }
  void getconnectivity(){
    subscription = Connectivity().onConnectivityChanged.listen((event) async {
      isdeviceconnected = await InternetConnectionChecker().hasConnection;
      if(!isdeviceconnected && isalertset == false){
        showdialogbox();
        setState(() {
          isalertset = true;
        });
      }
      
    });
  }

  

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setstatus("Online");
    } else {
      setstatus("Offline");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentindex],
      bottomNavigationBar: BottomNavigationBar(
        key: bottom_key,
//backgroundColor: Colors.amber,
        showUnselectedLabels: false,
        currentIndex: currentindex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Search ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Post ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        onTap: (index) {
          setState(() {
            currentindex = index;
            print(index);
          });
        },
      ),
    );
  }
  showdialogbox() =>
  showCupertinoDialog<String>(
    context: context, 
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text("No Connection"),
      content: Text("please check your internet connectivity "),
      actions: [
        TextButton(
          onPressed: ()async{
            Navigator.pop(context,'cancel');
            setState(() {
              isalertset = false;
            });
            isdeviceconnected = await InternetConnectionChecker().hasConnection;
            if(!isdeviceconnected){
              showdialogbox();
              setState(() {
                isalertset = true;
              });
            }
            

          }, 
          child: Text("OK")
        )
      ],
    )
    
  );
}
