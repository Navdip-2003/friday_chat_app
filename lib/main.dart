import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:friday_chat_app/Group_chat/data.dart';

import 'package:friday_chat_app/Group_chat/chatroom_group.dart';
import 'package:friday_chat_app/Group_chat/home_group.dart';
import 'package:friday_chat_app/chatroom.dart';
import 'package:friday_chat_app/contact.dart';
import 'package:friday_chat_app/demo2.dart';
import 'package:friday_chat_app/dispaly_homepage.dart';
import 'package:friday_chat_app/home.dart';
import 'package:friday_chat_app/home_demo.dart';
import 'package:friday_chat_app/log/login.dart';
import 'package:friday_chat_app/navigation.dart';
import 'package:friday_chat_app/open_image.dart';
import 'package:friday_chat_app/popmenu_chatrom/chat_profile.dart';
import 'package:friday_chat_app/post/post_home.dart';
import 'package:friday_chat_app/shimmer.dart';
import 'package:friday_chat_app/single_chat.dart';
import 'package:friday_chat_app/splash.dart';
import 'package:friday_chat_app/tab/chats.dart';
import 'package:friday_chat_app/try.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friday_chat_app/log/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // if(kIsWeb){
  //   await Firebase.initializeApp(
  //     options: const FirebaseOptions(
  //         apiKey: "AIzaSyB1pKNjmmaeaD9-OqvTCs1bgWLSKUZ6nWQ",
  //         authDomain: "chat-data-f147e.firebaseapp.com",
  //         databaseURL: "https://chat-data-f147e-default-rtdb.firebaseio.com",
  //         projectId: "chat-data-f147e",
  //         storageBucket: "chat-data-f147e.appspot.com",
  //         messagingSenderId: "738987421889",
  //         appId: "1:738987421889:web:442ffd7499d12310096440"
  //     )
  //   );
  // }else{
  //   await Firebase.initializeApp();
  // }

  //var use = FirebaseAuth.instance.currentUser;

  // if(use != null){
  //   suser();
  //   //print("current user is  : "+ ddata!["email"]);
  // }
  runApp(MaterialApp(
      title: "FriDay_Chat",
      home:
          //demoty()
          //demo2()
          splash()
      // use == null ? login() : navigation()

      ));
}
