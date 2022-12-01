import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friday_chat_app/Group_chat/home_group.dart';
import 'package:friday_chat_app/chatroom.dart';
import 'package:friday_chat_app/con_search.dart';
import 'package:friday_chat_app/data_search.dart';
import 'package:friday_chat_app/dispaly_homepage.dart';
import 'package:friday_chat_app/drawer_home.dart';
import 'package:friday_chat_app/navigation.dart';
import 'package:friday_chat_app/tab/chats.dart';
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
    // return DefaultTabController(

    //   initialIndex: 0,
    //   length: 3,
    //   child: Scaffold(
    //     key: _globalKey,
    //     drawer: drawer_home(),

    //     appBar: AppBar(
    //       elevation: 0,
    //       backgroundColor: Colors.transparent,
    //       flexibleSpace: Container(
    //         color: Colors.white,

    //       ),
    //       toolbarHeight: size.height / 15,
    //        actions: [

    //         IconButton(
    //           onPressed: (){
    //             showSearch(context: context, delegate: con_search(tab_index));
    //           },
    //           icon: Icon(Icons.search,color: Colors.black)
    //         )

    //       ],
    //       leading: IconButton(
    //         onPressed: (){
    //           _globalKey.currentState?.openDrawer();

    //         },
    //         icon: Icon(Icons.menu , color: Colors.black54,)
    //       ),
    //       title: Text('Messages' , style: TextStyle(
    //                 fontSize:  25,fontWeight: FontWeight.w500,color: Colors.black
    //                   )),

    //       bottom: TabBar(
    //         onTap: (value) {
    //           tab_index = value;
    //           print(tab_index);
    //         },
    //         indicatorColor: Colors.black26,
    //         indicatorSize: TabBarIndicatorSize.label,
    //         controller: tabcon,
    //         labelColor: Colors.black,
    //         unselectedLabelColor: Colors.black45,
    //         tabs: [
    //           Tab(child: Container(child: Row(
    //            mainAxisAlignment: MainAxisAlignment.center,
    //            children: [
    //              Icon(Icons.person, size: 17),
    //              SizedBox(width: size.width / 50,),
    //              Text("Chats" ,style: TextStyle(fontSize: 15),)
    //            ],
    //            ),),
    //         ),
    //          Tab(child: Container(child: Row(
    //              mainAxisAlignment: MainAxisAlignment.center,
    //              children: [
    //                Icon(Icons.people, size: 17),
    //                SizedBox(width: size.width / 50,),
    //                Text("Groups" ,style: TextStyle(fontSize: 15),)
    //              ],
    //              ),),
    //           ),
    //           Tab(
    //             icon: Icon(Icons.brightness_5_sharp),
    //           ),
    //         ],
    //       ),
    //     ),
    //     body: Padding(
    //       padding: const EdgeInsets.only(right: 5 ,left: 5 , top: 10),
    //       child: TabBarView(
    //         controller: tabcon,
    //         children: [
    //           chats(),
    //           home_group(),

    //           Center(
    //             child: Text("It's sunny here"),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );

    return Scaffold(
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
                padding: EdgeInsets.only(top: size.height / 25),
                // height: size.height / 5.5,
                child: Column(
                  children: [
                    Row(
                      //crossAxisAlignment: CrossAxisAlignment.start,
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

                        // Padding(
                        //   padding: const EdgeInsets.only(right: 7),
                        //   child: IconButton(
                        //     onPressed: (){
                        //       tabcon.animateTo(2);

                        //     },
                        //      icon: Icon(Icons.more_vert,color: Colors.black)
                        //   ),
                        // )
                      ],
                    ),
                    SizedBox(
                      height: size.height / 60,
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    color: Colors.red,
                    child: TabBarView(
                      controller: tbcon,
                      children: [chats(), home_group()],
                    ),
                  ),
                ),
              )
              // Container(
              //   padding: EdgeInsets.only(right: 5, left: 5),
              //   width: size.width,
              //   height: size.height - (size.height / 4.2),
              //   child: TabBarView(controller: tbcon, children: [
              //     chats(),
              //     home_group(),
              //   ]),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
