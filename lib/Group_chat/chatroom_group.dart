import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friday_chat_app/Group_chat/group_profile.dart';
import 'package:friday_chat_app/contact.dart';
import 'package:friday_chat_app/navigation.dart';
import 'package:friday_chat_app/open_image.dart';
import 'package:friday_chat_app/popmenu_chatrom/chat_profile.dart';
import 'package:friday_chat_app/single_chat.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class group_chatroom extends StatefulWidget {
  String group_id;
  String group_name;
  String group_image;

  int? i;
  group_chatroom({int? this.i, super.key, required this.group_id, required this.group_name, required this.group_image});

  @override
  State<group_chatroom> createState() => _group_chatroomState(group_id, group_image, group_name);
}

class _group_chatroomState extends State<group_chatroom> {
  String group_id;
  String group_name;
  String group_image;
  _group_chatroomState(this.group_id, this.group_image, this.group_name);

  List<Map<String, dynamic>> data = [
    {"message": "hii", "sendy": "Navdip", "type": "text", "time": "03:23 PM"},
    {"message": "i am sanjay", "sendy": "sanjay", "type": "text", "time": "03:23 PM"},
    {"message": "okk why are you saying ??", "sendy": "Navdip", "type": "text", "time": "03:23 PM"},
    {"message": "Navdip added pradip", "sendy": "Navdip", "type": "notify", "time": "03:23 PM"},
    {"message": "https://images.unsplash.com/photo-1666933000035-426a98c3b514?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwxMnx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60", "sendy": "omsai", "type": "img", "time": "03:23 PM"},
    {"message": "how are you ??", "sendy": "pradip ", "type": "text", "time": "01:09 PM"},
    {"message": "i am fine ..", "sendy": "Navdip", "type": "text", "time": "12:13 PM"},
    {"message": "whar about you ?", "sendy": "Navdip", "type": "text", "time": "04:30 PM"},
    {"message": "i am also fine .....", "sendy": "pradip", "type": "text", "time": "03:10 PM"}
  ];
  TextEditingController mess = new TextEditingController();
  ScrollController sc = new ScrollController();
  bool isloading = false;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  ImagePicker _picker = ImagePicker();
  File? pick_image;
  Future image_picker() async {
    //String ft_image;
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        pick_image = File(image.path);
        print("image path is : " + pick_image.toString());
        upload_pickimage();
        // ft_image = image.path.split("/").last;
        // print(ft_image);
      });
    }
  }

  Future upload_pickimage() async {
    int status = 1;
    var filename = Uuid().v1();
    await _firestore.collection("groups").doc(group_id).collection("chats").doc(filename).set({"sendy": _auth.currentUser!.displayName, "message": "", "type": "img", "time": DateTime.now()});
    var ref = FirebaseStorage.instance.ref().child("images").child("$filename.jpg");
    var up_image = await ref.putFile(pick_image!).catchError((error) async {
      await _firestore.collection("groups").doc(group_id).collection("chats").doc(filename).delete();
      status = 0;
    });
    if (status == 1) {
      String image_url = await up_image.ref.getDownloadURL();
      await _firestore.collection("groups").doc(group_id).collection("chats").doc(filename).update({"message": image_url});
      print(image_url);
    }
  }

  Future delete_message() async {
    isloading = true;
    var snap = await _firestore.collection("groups").doc(group_id).collection("chats").get();
    for (var doc in snap.docs) {
      await doc.reference.delete().then((value) {});
    }
    List mn = [];
    await _firestore.collection("groups").doc(group_id).get().then((value) {
      mn = value["members"];
    });
    print(mn);
    for (int i = 0; i < mn.length; i++) {
      FirebaseFirestore.instance.collection("last_group").doc(mn[i]["uid"]).collection("group").doc(group_id).set({"message": "${FirebaseAuth.instance.currentUser!.displayName} Deleted All Chat ..", "time": DateTime.now(), "group_id": group_id});
    }
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(group_id)
        .collection("chats")
        .add({"message": "${FirebaseAuth.instance.currentUser!.displayName} Deleted All Chat ..", "sendy": FirebaseAuth.instance.currentUser!.displayName, "type": "notify", "time": DateTime.now()}).then((value) {
      setState(() {
        isloading = false;
      });
    });
  }

  void send_message() async {
    var me = mess.text;
    if (mess.text.isNotEmpty) {
      Map<String, dynamic>? messages = {"sendy": _auth.currentUser!.displayName, "message": mess.text, "type": "text", "time": DateTime.now()};
      await _firestore.collection("groups").doc(group_id).collection("chats").add(messages);
      last_message_save(me);
      scrolltobottom();
      mess.clear();
    } else {
      print("please enter some text");
    }
  }

  last_message_save(String me) async {
    List mem_list = [];
    await _firestore.collection("groups").doc(group_id).get().then((value) {
      mem_list = value["members"];
    });
    for (int i = 0; i < mem_list.length; i++) {
      _firestore.collection("last_group").doc(mem_list[i]["uid"]).collection("group").doc(group_id).set({"message": me, "time": DateTime.now(), "group_id": group_id});
    }
  }

  void scrolltobottom() async {
    await sc.animateTo(
      sc.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    //canishowfab = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    sc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var rang = MediaQuery.of(context);
    if (rang.viewInsets.bottom > 0) {
      scrolltobottom();
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: false,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
            height: rang.size.height / 10,
            width: rang.size.width,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("asset/chat_back1.jpg"), fit: BoxFit.cover),
            ),
            child: Container(
              height: rang.size.height / 12,
              width: rang.size.width / 1.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 7,
                    child: Container(
                      alignment: Alignment.center,
                      child: TextField(
                        controller: mess,
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.all(rang.size.height / 60),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.camera_alt_rounded, size: rang.size.height / 30, color: Color.fromARGB(255, 88, 87, 87)),
                              onPressed: () {
                                image_picker();
                              },
                            ),
                            hintText: "Message",
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Color.fromARGB(221, 7, 48, 19),
                                  width: 1,
                                )),
                            border: OutlineInputBorder(borderSide: BorderSide(strokeAlign: StrokeAlign.inside), borderRadius: BorderRadius.circular(20))),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      // margin: EdgeInsets.only(left: rang.size.width / 100),
                      child: IconButton(
                          onPressed: () {
                            send_message();
                            // scrolltobottom();
                          },
                          icon: Icon(
                            Icons.send,
                            size: 30,
                            color: Color.fromARGB(255, 6, 63, 8),
                          )),
                    ),
                  )
                ],
              ),
            )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox.fromSize(
        size: Size.square(40),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.arrow_downward_rounded,
              color: Color.fromARGB(255, 6, 100, 1),
            ),
            onPressed: () {
              setState(() {
                scrolltobottom();
              });
            },
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          // Navigator.push(context, MaterialPageRoute(builder: (context)=>contact(i: 1,)));
          widget.i == null ? Navigator.pop(context) : Navigator.push(context, MaterialPageRoute(builder: (context) => navigation()));
          return false;
        },
        child: Column(
          children: [
            //Appbar chatroom
            StreamBuilder(
              stream: _firestore.collection("groups").doc(group_id).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List member = snapshot.data!["members"];
                  int member_index() {
                    var val;
                    for (int i = 0; i < member.length; i++) {
                      if (member[i]["uid"] == _auth.currentUser!.uid) {
                        setState(() {
                          val = i;
                        });
                      }
                    }
                    return val;
                  }

                  return Container(
                    height: rang.size.height / 9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(child: Container()),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    widget.i == null ? Navigator.pop(context) : Navigator.push(context, MaterialPageRoute(builder: (context) => navigation()));
                                    //  Navigator.push(context,MaterialPageRoute(builder: (context)=> contact(i: 1,) ));
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Icon(Icons.arrow_back),
                                        CircleAvatar(
                                          radius: 25,
                                          backgroundImage: group_image == ""
                                              ? NetworkImage("https://images.unsplash.com/photo-1666933000035-426a98c3b514?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwxMnx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60")
                                              : NetworkImage(group_image),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                child: InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => group_profile(groupid: group_id, groupname: group_name, groupimage: group_image)));
                              },
                              child: Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                                // height: 10,
                                //color: Colors.amber,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      // width: rang.size.width / 2.35,
                                      child: Text(group_name, style: TextStyle(fontFamily: "SansFont", fontSize: 18, overflow: TextOverflow.ellipsis, color: Colors.black87, fontWeight: FontWeight.w800)),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                            Container(
                                //  color: Colors.pinkAccent,
                                child: PopupMenuButton(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Colors.black54,
                                    ),
                                    onSelected: ((value) {
                                      if (value == "profile") {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => group_profile(groupid: group_id, groupname: group_name, groupimage: group_image)));
                                      } else if (value == "clear") {
                                        //Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              content: Text("You can Delete all Chat from \"${group_name}\" Group"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Cancel")),
                                                TextButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);

                                                      if (member[member_index()]["isadmin"] == true) {
                                                        delete_message();
                                                      } else {
                                                        return showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                content: Text("You are not admin so you can't Delete Chat !!"),
                                                                actions: [
                                                                  TextButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: Text("OK"))
                                                                ],
                                                              );
                                                            });
                                                      }

                                                      //
                                                    },
                                                    child: Text("Ok")),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    }),
                                    itemBuilder: (context) {
                                      return [
                                        PopupMenuItem(
                                            value: "profile",
                                            child: ListTile(
                                              title: Text("Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                              leading: Icon(Icons.person, size: 30, color: Colors.black54),
                                            )),
                                        PopupMenuItem(
                                            value: "clear",
                                            child: ListTile(
                                              title: Text(
                                                "Clear Chat",
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                                              ),
                                              leading: Icon(
                                                Icons.delete_forever_sharp,
                                                size: 30,
                                                color: Colors.black54,
                                              ),
                                            )),
                                      ];
                                    }))
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(
                    height: rang.size.height / 9,
                  );
                }
              },
            ),

            Container(
              decoration: BoxDecoration(image: DecorationImage(image: AssetImage("asset/chat_back1.jpg"), fit: BoxFit.cover)),
              child: SingleChildScrollView(
                  child: isloading
                      ? Container(
                          height: rang.size.height,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Container(
                          height: rang.size.height - (rang.viewInsets.bottom + rang.size.height / 10) - (rang.size.height / 9),
                          width: rang.size.width,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection("groups").doc(group_id).collection("chats").orderBy("time", descending: false).snapshots(),
                            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                Timer(Duration(milliseconds: 100), () {
                                  scrolltobottom();
                                });

                                return ListView.builder(
                                  controller: sc,
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    String gt = snapshot.data!.docs[index]["type"];
                                    final Timestamp timestamp = snapshot.data!.docs[index]["time"] as Timestamp;
                                    final DateTime dateTime = timestamp.toDate();
                                    final dateString = DateFormat('kk:mm a').format(dateTime);
                                    String mess = snapshot.data!.docs[index]['message'];
                                    if (gt == "text") {
                                      return Column(
                                        children: [
                                          Container(
                                            width: rang.size.width,
                                            alignment: snapshot.data!.docs[index]['sendy'] == _auth.currentUser!.displayName ? Alignment.centerRight : Alignment.centerLeft,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 13,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: mess.length > 2
                                                    ? BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(0), topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
                                                    : BorderRadius.only(topRight: Radius.circular(0), bottomRight: Radius.circular(15), topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
                                                gradient: snapshot.data!.docs[index]['sendy'] == _auth.currentUser!.displayName
                                                    ? LinearGradient(colors: [Color.fromARGB(255, 45, 83, 137), Color.fromARGB(255, 50, 114, 44)])
                                                    : LinearGradient(colors: [Color.fromARGB(255, 50, 114, 44), Color.fromARGB(255, 45, 83, 137)]),
                                              ),
                                              child: Column(
                                                children: [
                                                  if (snapshot.data!.docs[index]["sendy"] != _auth.currentUser!.displayName) Text("~: " + snapshot.data!.docs[index]["sendy"], style: TextStyle(fontSize: 8, color: Color.fromARGB(255, 208, 208, 208))),
                                                  Text(
                                                    snapshot.data!.docs[index]['message'],
                                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: 16),
                                            alignment: snapshot.data!.docs[index]['sendy'] == _auth.currentUser!.displayName ? Alignment.centerRight : Alignment.centerLeft,
                                            //color: Colors.blueAccent,
                                            width: rang.size.width,
                                            child: Text(
                                              dateString,
                                              style: TextStyle(fontSize: 9, color: Colors.black45),
                                            ),
                                          ),
                                          SizedBox(height: 4)
                                        ],
                                      );
                                    } else if (gt == "notify") {
                                      return Column(
                                        children: [
                                          Container(
                                            width: rang.size.width,
                                            alignment: Alignment.center,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                  //color: Color.fromARGB(26, 210, 210, 210),
                                                  border: Border.all(color: Color.fromARGB(95, 198, 198, 198), width: 1.5),
                                                  //borderRadius: BorderRadius.circular(10),
                                                  borderRadius: BorderRadius.circular(7),
                                                  color: Color.fromARGB(255, 225, 224, 224)
                                                  //BorderRadius.vertical(bottom: Radius.circular(15)),
                                                  // gradient:
                                                  //   LinearGradient(
                                                  //     colors: [ Color.fromARGB(255, 219, 219, 219)  ,
                                                  //             Color.fromARGB(255, 188, 188, 188) ]),
                                                  ),
                                              child: Text(
                                                snapshot.data!.docs[index]['message'],
                                                style: TextStyle(
                                                    fontFamily: "SansFont.ttf",
                                                    //fontWeight: FontWeight.w600 ,
                                                    fontSize: 11,
                                                    color: Color.fromARGB(255, 17, 17, 17)),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 9)
                                        ],
                                      );
                                    } else if (gt == "img") {
                                      return Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 5,
                                            ),
                                            height: rang.size.height / 3.8,
                                            width: rang.size.width,
                                            alignment: snapshot.data!.docs[index]["sendy"] == _auth.currentUser!.displayName ? Alignment.centerRight : Alignment.centerLeft,
                                            child: Container(
                                                height: rang.size.height / 3.8,
                                                width: rang.size.width / 2.3,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                  gradient: snapshot.data!.docs[index]['sendy'] == _auth.currentUser!.displayName
                                                      ? LinearGradient(colors: [Color.fromARGB(255, 45, 83, 137), Color.fromARGB(255, 50, 114, 44)])
                                                      : LinearGradient(colors: [Color.fromARGB(255, 50, 114, 44), Color.fromARGB(255, 45, 83, 137)]),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    if (snapshot.data!.docs[index]["sendy"] != _auth.currentUser!.displayName)
                                                      Text("~: " + snapshot.data!.docs[index]["sendy"], style: TextStyle(fontSize: 10, color: Color.fromARGB(255, 208, 208, 208))),
                                                    Container(
                                                        height: rang.size.height / 4.2,
                                                        width: rang.size.width / 2.5,
                                                        alignment: Alignment.center,
                                                        decoration: BoxDecoration(),
                                                        child: snapshot.data!.docs[index]["message"] != ""
                                                            ? InkWell(
                                                                onTap: () {
                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => open_image(url: snapshot.data!.docs[index]['message'])));
                                                                },
                                                                child: Container(
                                                                    height: rang.size.height,
                                                                    width: rang.size.width,
                                                                    child: ClipRRect(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      child: Image.network(
                                                                        snapshot.data!.docs[index]["message"],
                                                                        fit: BoxFit.cover,
                                                                      ),
                                                                    )),
                                                              )
                                                            : Center(
                                                                child: CircularProgressIndicator(),
                                                              )),
                                                  ],
                                                )),
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: 16),
                                            alignment: snapshot.data!.docs[index]['sendy'] == _auth.currentUser!.displayName ? Alignment.centerRight : Alignment.centerLeft,
                                            //color: Colors.blueAccent,
                                            width: rang.size.width,
                                            child: Text(
                                              dateString,
                                              style: TextStyle(fontSize: 10, color: Colors.black45),
                                            ),
                                          ),
                                          SizedBox(height: 3)
                                        ],
                                      );
                                    }

                                    return Container();
                                  },
                                );
                              } else {
                                Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return Container();
                            },
                          ))),
            ),
          ],
        ),
      ),
    );
  }
}
