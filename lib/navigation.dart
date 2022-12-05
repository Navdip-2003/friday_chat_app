import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:friday_chat_app/contact.dart';
import 'package:friday_chat_app/dispaly_homepage.dart';
import 'package:friday_chat_app/home.dart';
import 'package:friday_chat_app/navi_item/user_profile.dart';
import 'package:friday_chat_app/pagination.dart';
import 'package:friday_chat_app/post/pagination_comment.dart';
import 'package:friday_chat_app/post/post_home.dart';
import 'package:friday_chat_app/single_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friday_chat_app/try.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:friday_chat_app/vedio_play.dart';

class navigation extends StatefulWidget {
  int? i;
  navigation({int? this.i, super.key});

  @override
  State<navigation> createState() => _navigationState();
}

class _navigationState extends State<navigation> with WidgetsBindingObserver {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _store = FirebaseFirestore.instance;

  var bottom_key = GlobalKey<State<BottomNavigationBar>>();

  int currentindex = 0;
  List pages = [
    contact(),

    //comment_pagination(),
    permission_handle(),

    post_home(),
    profile()
  ];
  void setstatus(String state) async {
    await _store.collection("users").doc(_auth.currentUser?.uid).update({"status": state});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var use = FirebaseAuth.instance.currentUser;
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
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
}
