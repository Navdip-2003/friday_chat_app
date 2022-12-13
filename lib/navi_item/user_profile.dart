import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:friday_chat_app/contact.dart';
import 'package:friday_chat_app/log/login.dart';
import 'package:friday_chat_app/methods.dart';
import 'package:friday_chat_app/navi_item/edit_profile.dart';
import 'package:friday_chat_app/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:firebase_auth/firebase_auth.dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  FirebaseFirestore _store = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  bool islaoding = false;
  var data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //islaoding = true;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        body: WillPopScope(
      onWillPop: () => onbackbutton(context),
      child: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          child: islaoding
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  child: StreamBuilder(
                  stream: _store.collection("users").doc(_auth.currentUser!.uid).snapshots(),
                  builder: (context, snaps) {
                    if (snaps.hasData) {
                      return Column(
                        children: [
                          SizedBox(
                            height: size.height / 20,
                          ),
                          //Edit and back icon
                          Container(
                            child: Row(
                              children: [
                                // IconButton(
                                //   onPressed: (){

                                //   },
                                //   icon: Icon(Icons.arrow_back ,size: 30,)
                                // ),
                                Expanded(child: Container()),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Hero(
                                    tag: "edit_profile",
                                    child: InkWell(
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => edit_profile()));
                                        },
                                        child: Image.asset(
                                          "asset/edit.png",
                                          scale: 15,
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ),
                          //name and photo
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: size.height / 8,
                                  width: size.width / 3.5,
                                  child: CircleAvatar(
                                    radius: 50,

                                    backgroundImage: NetworkImage(snaps.data!["image"] == "" ? "https://i.pinimg.com/236x/20/85/1e/20851efa9c2ac253e78584bd7f1ac55f.jpg" : snaps.data!["image"]),

                                    // child: data["image"] == "" ?  Center(child: Text("Image"),) :
                                    //  Image.network(data["image"] , fit: BoxFit.cover),
                                  ),
                                ),
                                SizedBox(width: size.width / 20),
                                Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: size.width / 1.8,
                                        child: Text(
                                          snaps.data!["name"] == "" ? "Update Name" : snaps.data!["name"],
                                          style: TextStyle(fontSize: 25, fontFamily: "SansFont", fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      Container(
                                        width: size.width / 1.8,
                                        child: Text(snaps.data!["nick_name"] == "" ? "Update Nick Name" : snaps.data!["nick_name"], style: TextStyle(fontSize: 15, fontFamily: "SansFont", fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis)),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                         
                          SizedBox(
                            height: size.height / 50,
                          ),
                          //phone no
                          Container(
                            padding: EdgeInsets.only(right: 10, left: 20),
                            height: size.height / 25,
                            child: Row(
                              children: [
                                Icon(Icons.phone),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    snaps.data!["phone"] == "" ? "update phone" : snaps.data!["phone"],
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                )
                              ],
                            ),
                          ),
                          //email
                          Container(
                            padding: EdgeInsets.only(right: 10, left: 20),
                            height: size.height / 25,
                            child: Row(
                              children: [
                                Icon(Icons.email),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    snaps.data!["email"] == "" ? "update email" : snaps.data!["email"],
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height / 20,
                          ),
                          //friend listview

                          StreamBuilder(
                            stream: _store.collection("contacts").doc(_auth.currentUser!.email).collection("lastonline").orderBy("email", descending: true).snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          "Your Frieds",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "SansFont"),
                                        )),
                                    Container(
                                      height: size.height / 5,
                                      child: Container(
                                        color: Colors.red,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            return StreamBuilder(
                                              stream: _store.collection("users").doc(snapshot.data!.docs[index]["uid"]).snapshots(),
                                              builder: (context, snap) {
                                                if (snap.hasData) {
                                                  return Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Container(
                                                      width: size.width / 3.5,
                                                      child: Container(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 52,
                                                              backgroundColor: Color.fromARGB(255, 7, 93, 1),
                                                              child: CircleAvatar(
                                                                radius: 50,
                                                                // backgroundColor: Colors.greenAccent,
                                                                backgroundImage: snap.data!["image"] == ""
                                                                    ? NetworkImage("https://images.unsplash.com/photo-1668530933925-a57e8424cda0?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=764&q=80")
                                                                    : NetworkImage(snap.data!["image"]),
                                                              ),
                                                            ),
                                                            Text(snap.data!["name"])
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),

                          //SizedBox(height: size.height / 10,),
                          //logout button
                          Expanded(child: Container()),
                          Container(
                            child: Center(
                              child: Material(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                child: InkWell(
                                  splashColor: Color.fromARGB(255, 231, 231, 231),
                                  onTap: () async {
                                    await _store.collection("users").doc(_auth.currentUser!.uid).update({"status": "Offline"});

                                    signout();
                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => login()), (route) => false);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      width: size.width / 3,
                                      height: size.height / 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset("asset/switch.png", scale: 30, color: Color.fromARGB(255, 145, 17, 17)),
                                          SizedBox(
                                            width: size.width / 40,
                                          ),
                                          Text(
                                            "Logout",
                                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Color.fromARGB(255, 163, 43, 43)),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                )),
        
        ),
      ),
    ));
  }
}
