import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friday_chat_app/contact.dart';
import 'package:friday_chat_app/navigation.dart';
import 'package:friday_chat_app/open_image.dart';
import 'package:friday_chat_app/popmenu_chatrom/chat_profile.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class chatroom extends StatefulWidget {
  String chat_id;
  Map<String, dynamic> usermap;
  chatroom({super.key, required this.chat_id, required this.usermap});

  @override
  State<chatroom> createState() => _chatroomState(chat_id, usermap);
}

class _chatroomState extends State<chatroom> {
  String chat_id;
  Map<String, dynamic> usermap;
  _chatroomState(this.chat_id, this.usermap);

  TextEditingController mess = new TextEditingController();
  ScrollController sc = new ScrollController();

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isloading = false;

  bool block_user = false;
  void check() async {
    await _firestore.collection("chatroom").doc(chat_id).get().then((value) {
      setState(() {
        block_user = value["blok"];
      });
    });
  }

  blok_message() async {
    bool bl = false;
    String? name;
    await _firestore.collection("chatroom").doc(chat_id).get().then((value) {
      setState(() {
        bl = value["blok"];
        name = value["user_name"];
      });
    });
    if (!bl) {
      await _firestore.collection("chatroom").doc(chat_id).set({"blok": true, "user_name": _auth.currentUser!.displayName});
      Map<String, dynamic>? messages = {"sendy": _auth.currentUser!.displayName, "message": "${_auth.currentUser!.displayName} Blocked This Account !!", "type": "notify", "time": DateTime.now()};
      await _firestore.collection("chatroom").doc(chat_id).collection("chat").add(messages).then((value) {
        Navigator.pop(context);
      });
    }
    if (bl) {
      if (name == _auth.currentUser!.displayName) {
        await _firestore.collection("chatroom").doc(chat_id).set({"blok": false, "user_name": ""});
        Map<String, dynamic>? messages = {"sendy": _auth.currentUser!.displayName, "message": "${_auth.currentUser!.displayName} Unblocked This Account ..", "type": "notify", "time": DateTime.now()};
        await _firestore.collection("chatroom").doc(chat_id).collection("chat").add(messages).then((value) {
          Navigator.pop(context);
        });
      }
    }

    print("bloak is clckes");
  }

  Future<void> delete_message() async {
    setState(() {
      isloading = true;
    });
    var coll = _firestore.collection("chatroom").doc(chat_id).collection("chat");
    var snap = await coll.get();
    for (var doc in snap.docs) {
      await doc.reference.delete().then((value) {});
    }
    Map<String, dynamic>? messages = {"sendy": _auth.currentUser!.displayName, "message": "${_auth.currentUser!.displayName} Deleted All Chat", "type": "notify", "time": FieldValue.serverTimestamp()};
    await _firestore.collection("chatroom").doc(chat_id).collection("chat").add(messages);
    await _firestore
        .collection("contacts")
        .doc(_auth.currentUser!.email)
        .collection("lastonline")
        .doc(usermap["email"])
        .set({"time": DateTime.now(), "email": usermap["email"], "uid": usermap["uid"], "name": usermap["name"], "chat_id": chat_id, "last_message": "${_auth.currentUser!.displayName} Deleted All Chat", "image": ""});
    await _firestore.collection("contacts").doc(usermap["email"]).collection("lastonline").doc(_auth.currentUser!.email).set({
      "time": DateTime.now(),
      "email": _auth.currentUser!.email,
      "uid": _auth.currentUser!.uid,
      "name": _auth.currentUser!.displayName,
      "chat_id": chat_id,
      "last_message": "${_auth.currentUser!.displayName} Deleted All Chat",
      "image": ""
    }).then((value) {
      setState(() {
        isloading = false;
      });
    });
  }

  Future last_save() async {
    var last;
  }

  chat_endtime() async {
    var _time = DateTime.now();
    var last_message = mess.text;
    var rub = 0;
    if (rub == 0) {
      await _firestore
          .collection("contacts")
          .doc(_auth.currentUser!.uid)
          .collection("lastonline")
          .doc(usermap["uid"])
          .set({"time": _time, "email": usermap["email"], "uid": usermap["uid"], "name": usermap["name"], "chat_id": chat_id, "last_message": last_message, "image": ""});
      await _firestore
          .collection("contacts")
          .doc(usermap["uid"])
          .collection("lastonline")
          .doc(_auth.currentUser!.uid)
          .set({"time": _time, "email": _auth.currentUser!.email, "uid": _auth.currentUser!.uid, "name": _auth.currentUser!.displayName, "chat_id": chat_id, "last_message": last_message, "image": ""});
      rub = 1;
    }
    await _firestore.collection("contacts").doc(_auth.currentUser!.uid).collection("lastonline").doc(usermap["uid"]).update({
      "time": _time,
    });
  }

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
      });
    }
  }

  Future upload_pickimage() async {
    int status = 1;
    var filename = Uuid().v1();
    await _firestore.collection("chatroom").doc(chat_id).collection("chat").doc(filename).set(
      {
        "sendy": _auth.currentUser!.displayName, 
        "message": "", 
        "type": "img", 
        "time": DateTime.now()
      });
    var ref = FirebaseStorage.instance.ref().child("images").child("$filename.jpg");
    var up_image = await ref.putFile(pick_image!).catchError((error) async {
      await _firestore.collection("chatroom").doc(chat_id).collection("chat").doc(filename).delete();
      status = 0;
    });
    if (status == 1) {
      String image_url = await up_image.ref.getDownloadURL();
      await _firestore.collection("chatroom").doc(chat_id).collection("chat").doc(filename).update({"message": image_url});
      print(image_url);
    }
  }

  void send_message() async {
    if (mess.text.isNotEmpty) {
      Map<String, dynamic>? messages = {"sendy": _auth.currentUser!.displayName, "message": mess.text, "type": "text", "time": DateTime.now()};
      await _firestore.collection("chatroom").doc(chat_id).collection("chat").add(messages);
      chat_endtime();
      mess.clear();

      scrolltobottom();
    } else {
      print("please enter some text");
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

  bool available_data = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //check();
    print(usermap);
    print(chat_id);
    //check_bloak();
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
            height: rang.size.height / 10,
            width: rang.size.width,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("asset/chat_back1.jpg"), fit: BoxFit.cover),
              //color: Colors.transparent,

              //color: Color.fromARGB(134, 215, 214, 214),
              // borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
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
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection("users").where("uid", isEqualTo: usermap["uid"]).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  color: Color.fromARGB(255, 255, 255, 255),
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
                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  child: Row(
                                    children: [
                                      Icon(Icons.arrow_back),
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundImage: snapshot.data!.docs[0]["image"] == ""
                                            ? NetworkImage("https://images.unsplash.com/photo-1666933000035-426a98c3b514?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwxMnx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60")
                                            : NetworkImage(usermap["image"]),
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => chat_profile(usermap: usermap)));
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
                                    child: Column(
                                      children: [
                                        Text(snapshot.data!.docs[0]["name"], style: TextStyle(fontFamily: "SansFont", fontSize: 18, overflow: TextOverflow.ellipsis, color: Colors.black87, fontWeight: FontWeight.w800)),
                                        Text(
                                          snapshot.data!.docs[0]["status"],
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.start,
                                        )
                                      ],
                                    ),
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
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => chat_profile(usermap: usermap)));
                                    } else if (value == "clear") {
                                      delete_message();
                                    } else if (value == "Blok") {
                                      //blok_message();
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
                                      PopupMenuItem(
                                          value: "Blok",
                                          child: ListTile(
                                            title: Text("Block", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                            leading: Icon(Icons.block_sharp, size: 30, color: Colors.black54),
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
            height: rang.size.height - (rang.viewInsets.bottom + rang.size.height / 10) - (rang.size.height / 9),
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage("asset/chat_back1.jpg"), fit: BoxFit.cover)),
            child: SingleChildScrollView(
              child: isloading
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    )
                  : Container(
                      height: rang.size.height - (rang.viewInsets.bottom + rang.size.height / 10) - (rang.size.height / 9),
                      width: rang.size.width,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection("chatroom").doc(chat_id).collection("chat").orderBy("time", descending: false).snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            available_data = true;

                            last_save();
                            Timer(Duration(milliseconds: 100), () {
                              scrolltobottom();
                            });
                            // scrolltobottom();

                            return ListView.builder(
                                physics: BouncingScrollPhysics(),
                                controller: sc,
                                scrollDirection: Axis.vertical,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  String gt = snapshot.data!.docs[index]["type"];
                                  final Timestamp timestamp = snapshot.data!.docs[index]["time"] as Timestamp;
                                  final DateTime dateTime = timestamp.toDate();
                                  final dateString = DateFormat('kk:mm a').format(dateTime);
                                  String message = snapshot.data!.docs[index]['message'];
                                  if (gt == "text") {
                                    return Slidable(
                                      endActionPane: ActionPane(
                                        extentRatio: 0.25,
                                        motion: BehindMotion(),
                                        children: [
                                          SlidableAction(
                                            foregroundColor: Colors.black,
                                            backgroundColor: Colors.transparent,
                                            autoClose: true,
                                            onPressed: (context) async {
                                              var delete_key = snapshot.data!.docs[index].id;
                                              await _firestore.collection("chatroom").doc(chat_id).collection("chat").doc(delete_key).delete();
                                            },
                                            icon: Icons.delete,
                                          )
                                        ],
                                      ),
                                      child: Column(
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
                                                borderRadius: message.length > 2
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
                                      ),
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
                                              horizontal: 5,
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
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                          height: rang.size.height / 4.4,
                                          width: rang.size.width,
                                          alignment: snapshot.data!.docs[index]["sendy"] == _auth.currentUser!.displayName ? Alignment.centerRight : Alignment.centerLeft,
                                          child: Container(
                                            height: rang.size.height / 4.3,
                                            width: rang.size.width / 2.6,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(

                                                //snapshot.data!.docs[index]['message']
                                                ),
                                            child: snapshot.data!.docs[index]['message'] != ""
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
                                                            snapshot.data!.docs[index]['message'],
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )),
                                                  )
                                                : Center(
                                                    child: CircularProgressIndicator(),
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
                                            style: TextStyle(fontSize: 10, color: Colors.black45),
                                          ),
                                        ),
                                        SizedBox(height: 5)
                                      ],
                                    );
                                  }else if (gt == "audio") {
                                    return Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                          //height: rang.size.height / 4.4,
                                          width: rang.size.width,
                                          alignment: snapshot.data!.docs[index]["sendy"] == _auth.currentUser!.displayName ? Alignment.centerRight : Alignment.centerLeft,
                                          child: Container(
                                            height: 100,
                                            width: 400,
                                            color: Colors.red,
                                          ),
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
                                        SizedBox(height: 5)
                                      ],
                                    );
                                  }

                                  return Container();
                                });
                          } else {
                            return Center(
                              child: Container(height: rang.size.height / 30, width: rang.size.width / 30, child: CircularProgressIndicator()),
                            );
                          }
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
