import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friday_chat_app/Group_chat/home_group.dart';
import 'package:friday_chat_app/chat_screen/chatroom.dart';
import 'package:friday_chat_app/con_search.dart';
import 'package:friday_chat_app/data_search.dart';
import 'package:friday_chat_app/dispaly_homepage.dart';
import 'package:friday_chat_app/drawer_home.dart';
import 'package:friday_chat_app/navigation.dart';
import 'package:friday_chat_app/chat_screen/chats.dart';
import 'package:friday_chat_app/variables.dart';

class contact extends StatefulWidget {
  int? i;
  contact({int? this.i, super.key});
  @override
  State<contact> createState() => _contactState();
}

class _contactState extends State<contact> with TickerProviderStateMixin, WidgetsBindingObserver {
  FirebaseAuth _auth = FirebaseAuth.instance;
  var isloading = false;

  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  TabController? tbcon;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tbcon = TabController(length: 2, vsync: this);
    if (widget.i != null) {
      tbcon?.animateTo(widget.i!);
    }
    WidgetsBinding.instance.addObserver(this);
    setstatus("Online");
  }

  void setstatus(String state) async {
    await FirebaseFirestore.instance.collection("users").doc(_auth.currentUser?.uid).update({"status": state});
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
    var size = MediaQuery.of(context).size;

    return SafeArea(
      top: true,
      child: Scaffold(
        key: _globalKey,  
        drawer: drawer_home(),
        body: WillPopScope(
          onWillPop: () => onbackbutton(context),
          child: Container(
            height: size.height,
            width: size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: Column(
                    children: [
                      Row(
                     
                        children: [
                          IconButton(
                              onPressed: () {
                                _globalKey.currentState?.openDrawer();
                              },
                              icon: Icon(Icons.menu)),
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Container(
                              child: Text(
                                "Messages",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: Container()),
                          IconButton(
                              onPressed: () {
                                showSearch(context: context, delegate: con_search(1));
                              },
                              icon: Icon(Icons.search, color: Colors.black)),
    
                        ],
                      ),
                
                      Container(
                        child: TabBar(
                            onTap: (index) {
                              print(index);
                            },
                            indicatorColor: Colors.black26,
                            indicatorSize: TabBarIndicatorSize.label,
                            controller: tbcon,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.black45,
                            tabs: [
                              Tab(
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person, size: 17),
                                      SizedBox(
                                        width: size.width / 50,
                                      ),
                                      Text(
                                        "Chats",
                                        style: TextStyle(fontSize: 15),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Tab(
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.people, size: 17),
                                      SizedBox(
                                        width: size.width / 50,
                                      ),
                                      Text(
                                        "Groups",
                                        style: TextStyle(fontSize: 15),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                      )
                    ],
                  ),
                ),
                Expanded(child: Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.white24,
                  child: TabBarView(
                    controller: tbcon,
                    children: [
                      chats(),
                      home_group()
    
                    ],
                  ) ,
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
