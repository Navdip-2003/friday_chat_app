import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class comment_post extends StatefulWidget {
  String post_id;
  comment_post({super.key, required this.post_id});

  @override
  State<comment_post> createState() => _comment_postState(post_id);
}

class _comment_postState extends State<comment_post> {
  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  TextEditingController comment = new TextEditingController();
  ScrollController sc = new ScrollController();
  bool isload = false;
  String? image;
  image_get_user() async {
    setState(() {
      isload = true;
    });
    await _firestore.collection("users").doc(_auth.currentUser!.uid).get().then((value) {
      setState(() {});
      image = value["image"];
    });
    setState(() {
      isload = false;
    });
    return image!;
  }

  String post_id;
  _comment_postState(this.post_id);

  void scrolltobottom() async {
    await sc.animateTo(
      sc.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    //canishowfab = false;
  }

  void add_post() async {
    var coid = Uuid().v1();
    await FirebaseFirestore.instance.collection("comment").doc(post_id).collection("comment").doc(coid).set({"time": DateTime.now(), "uid": FirebaseAuth.instance.currentUser!.uid, "comment": comment.text}).then((value) {
      print("comment is done !!");
      comment.clear();
      scrolltobottom();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    image_get_user();
    print(post_id);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var rang = MediaQuery.of(context);

    if (rang.viewInsets.bottom > 0) {
      scrolltobottom();
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: false,
      body: Hero(
        tag: "comment",
        child: Container(
            height: size.height,
            width: size.width,
            //   color: Colors.amber,
            child: Column(
              children: [
                SizedBox(
                  height: size.height / 30,
                ),
                Container(
                  //  color: Colors.green,
                  height: size.height / 12,
                  child: Row(
                    children: [
                      BackButton(
                        color: Colors.black,
                      ),
                      Text("Comments", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20))
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 2,
                  color: Colors.black38,
                ),
                Expanded(
                    child: isload
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Container(
                            // height: rang.size.height - (rang.viewInsets.bottom + rang.size.height / 8),
                            child: StreamBuilder(
                              stream: _firestore.collection("comment").doc(post_id).collection("comment").orderBy("time", descending: false).snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                    controller: sc,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      final Timestamp timestamp = snapshot.data!.docs[index]["time"] as Timestamp;
                                      final DateTime dateTime = timestamp.toDate();
                                      final dateString = DateFormat('kk:mm a').format(dateTime);
                                      getTime(time) {
                                        if (DateTime.now().difference(time).inMinutes < 2) {
                                          return "Now";
                                        } else if (DateTime.now().difference(time).inMinutes < 60) {
                                          return "${DateTime.now().difference(time).inHours} min";
                                        } else if (DateTime.now().difference(time).inMinutes < 1440) {
                                          return "${DateTime.now().difference(time).inHours} hours";
                                        } else if (DateTime.now().difference(time).inMinutes > 1440) {
                                          return "${DateTime.now().difference(time).inDays} days";
                                        }
                                      }

                                      var diff_time = getTime(dateTime);

                                      return StreamBuilder(
                                        stream: _firestore.collection("users").doc(snapshot.data!.docs[index]["uid"]).snapshots(),
                                        builder: (context, snap) {
                                          if (snap.hasData) {
                                            return Container(
                                                padding: EdgeInsets.all(10),
                                                width: size.width,
                                                // color: Colors.blue,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Flexible(
                                                            flex: 1,
                                                            child: CircleAvatar(
                                                              radius: 23,
                                                              backgroundImage: NetworkImage(snap.data!["image"]),
                                                            ),
                                                          ),
                                                          Flexible(
                                                            flex: 4,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(left: 10),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Container(
                                                                        child: Text(
                                                                          snap.data!["firstname"],
                                                                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                                                        ),
                                                                      ),
                                                                      Expanded(child: Container()),
                                                                      Text(
                                                                        "$diff_time",
                                                                        style: TextStyle(fontSize: 13, color: Colors.black54),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    padding: EdgeInsets.only(top: 5),
                                                                    // width: size.width / 1.3,
                                                                    //  color: Colors.redAccent,
                                                                    child: Text(
                                                                      snapshot.data!.docs[index]["comment"],
                                                                      style: TextStyle(fontSize: 13),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Divider(
                                                      indent: 5,
                                                      thickness: 2,
                                                    ),
                                                    // Padding(padding: EdgeInsets.all(4)),
                                                  ],
                                                ));
                                          } else {
                                            return Container();
                                          }
                                        },
                                      );
                                    },
                                  );
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                          )),
                Container(
                  height: size.height / 10,
                  width: size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Container(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 1,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.cyanAccent,
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          Flexible(
                              flex: 2,
                              child: TextField(
                                controller: comment,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                    suffixIcon: TextButton(
                                      onPressed: () {
                                        if (comment.text != "") {
                                          add_post();
                                        }
                                      },
                                      child: Text("POST"),
                                    ),
                                    isCollapsed: true,
                                    contentPadding: EdgeInsets.all(10),
                                    focusColor: Colors.white,
                                    hintText: "Add Comments ..."),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
