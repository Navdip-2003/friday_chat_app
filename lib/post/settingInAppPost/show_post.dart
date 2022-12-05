import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friday_chat_app/post/comment_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:like_button/like_button.dart';

class show_post extends StatefulWidget {
  String postid;
  String uid;
  show_post({super.key, required this.postid, required this.uid});

  @override
  State<show_post> createState() => _show_postState();
}

class _show_postState extends State<show_post> {
  bool imgLoad = false;
  bool isload = false;
  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  var cuu_id = FirebaseAuth.instance.currentUser!.uid;
  void deleted_post() async {
    isload = false;
    await _firestore.collection("cont_post").doc(cuu_id).collection("all_post").doc(widget.postid).delete().then((value) {
      print("deleted done !!");
    }).catchError((error) => print(error));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        body: Center(
      child: isload
          ? Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance.collection("post").doc(widget.uid).collection("story").doc(widget.postid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  int tot_like = 0;
                  bool jj = snapshot.data!["like"][_auth.currentUser!.uid] == null ? false : snapshot.data!["like"][_auth.currentUser!.uid];
                  Map<String, dynamic> tot = snapshot.data!["like"];
                  print(tot.keys.first);
                  tot.forEach((key, value) {
                    if (value == true) {
                      tot_like += 1;
                    }
                  });
                  int total_like_cout = tot_like - 1;
                  final Timestamp timestamp = snapshot.data!["time"] as Timestamp;
                  final DateTime dateTime = timestamp.toDate();
                  final dateString = DateFormat('kk:mm a').format(dateTime);
                  getTime(time) {
                    if (DateTime.now().difference(time).inMinutes < 2) {
                      return "Now";
                    } else if (DateTime.now().difference(time).inMinutes < 60) {
                      return "${DateTime.now().difference(time).inHours} min ago";
                    } else if (DateTime.now().difference(time).inMinutes < 1440) {
                      return "${DateTime.now().difference(time).inHours} hours ago";
                    } else if (DateTime.now().difference(time).inMinutes > 1440) {
                      return "${DateTime.now().difference(time).inDays} days ago";
                    }
                  }

                  var diff_time = getTime(dateTime);
                  return StreamBuilder(
                    stream: _firestore.collection("users").doc(widget.uid).snapshots(),
                    builder: (context, snap) {
                      if (snap.hasData) {
                        return Card(
                          borderOnForeground: true,
                          elevation: 10,
                          //color: Color.fromARGB(255, 200, 200, 200),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20), topRight: Radius.circular(20))),
                          child: SingleChildScrollView(
                            child: Container(
                              width: size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 26,
                                          foregroundColor: Color.fromARGB(255, 244, 119, 2),
                                          child: CircleAvatar(
                                            radius: 24,
                                            backgroundImage: NetworkImage(snap.data!["image"]),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: size.width / 2,
                                                child: Text(snap.data!["firstname"], style: TextStyle(fontFamily: "SansFont", fontWeight: FontWeight.w900, overflow: TextOverflow.ellipsis, fontSize: 15)),
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 15,
                                                  ),
                                                  Padding(padding: EdgeInsets.only(right: 3)),
                                                  Container(
                                                    width: size.width / 2.4,
                                                    child: Text(
                                                      snapshot.data!["location"],
                                                      style: TextStyle(fontFamily: "SansFont", fontSize: 10, overflow: TextOverflow.ellipsis),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(child: Text("$diff_time")),
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
                                                  } else if (value == "clear") {
                                                    deleted_post();
                                                  } else if (value == "share") {
                                                  } else if (value == "set") {}
                                                }),
                                                itemBuilder: (context) {
                                                  return [
                                                    PopupMenuItem(
                                                        value: "profile",
                                                        child: ListTile(
                                                          title: Text("Details Post", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                                          leading: Icon(Icons.info, size: 30, color: Colors.black54),
                                                        )),
                                                    PopupMenuItem(
                                                        value: "share",
                                                        child: ListTile(
                                                          title: Text("Share", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                                          leading: Icon(Icons.share, size: 30, color: Colors.black54),
                                                        )),
                                                    PopupMenuItem(
                                                        value: "set",
                                                        child: ListTile(
                                                          title: Text("Set Your Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                                          leading: Icon(Icons.person, size: 30, color: Colors.black54),
                                                        )),
                                                    PopupMenuItem(
                                                        value: "clear",
                                                        child: ListTile(
                                                          title: Text(
                                                            "Delete Post",
                                                            style: TextStyle(color: Color.fromARGB(255, 182, 1, 1), fontWeight: FontWeight.w600),
                                                          ),
                                                          leading: Icon(
                                                            Icons.delete_forever_sharp,
                                                            size: 30,
                                                            color: Color.fromARGB(221, 249, 6, 6),
                                                          ),
                                                        )),
                                                  ];
                                                }))
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onDoubleTap: () {
                                      if (jj == false) {
                                        setState(() {
                                          tot_like += 1;
                                          jj = true;
                                          _firestore.collection("post").doc(snapshot.data!["uid"]).collection("story").doc(snapshot.data!["post_id"]).update({'like.$cuu_id': true});
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: size.width,
                                      height: size.height / 1.8,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl: snapshot.data!["post"],
                                        placeholder: (context, url) => Center(child: Lottie.asset("asset/image_loading.json", width: size.width / 7, height: size.height)),
                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 10, left: 10, top: 5, bottom: 5),
                                    child: Row(
                                      children: [
                                        LikeButton(
                                          likeCount: tot_like,
                                          countBuilder: (likeCount, isLiked, text) {},
                                          likeBuilder: (isLiked) {
                                            if (jj == false) {
                                              return Icon(
                                                Icons.favorite,
                                                color: Colors.grey,
                                                size: 30,
                                              );
                                            } else {
                                              return Icon(
                                                Icons.favorite,
                                                color: Color.fromARGB(255, 198, 18, 1),
                                                size: 30,
                                              );
                                            }
                                          },
                                          onTap: (kkr) async {
                                            if (jj == false) {
                                              setState(() {
                                                tot_like += 1;
                                                jj = true;

                                                _firestore.collection("post").doc(widget.uid).collection("story").doc(widget.postid).update({'like.$cuu_id': true});
                                              });

                                              return !kkr;
                                            } else {
                                              print("isnotliked!!");
                                              setState(() {
                                                tot_like -= 1;
                                                jj = false;
                                                _firestore.collection("post").doc(widget.uid).collection("story").doc(widget.postid).update({'like.$cuu_id': false});
                                              });
                                              return !kkr;
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          width: size.width / 25,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => comment_post(post_id: widget.postid)));
                                            },
                                            child: Image.asset(
                                              "asset/comment.png",
                                              scale: 23,
                                            )),
                                        Padding(padding: EdgeInsets.all(10)),
                                        Expanded(
                                          child: Container(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    width: size.width,
                                    child: Text(
                                      snapshot.data!["description"],
                                      style: TextStyle(fontSize: 18, fontFamily: "SansFont"),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 10),
                                    width: size.width,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => comment_post(post_id: widget.postid)));
                                      },
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 15,
                                            backgroundImage: imgLoad ? null : NetworkImage(snap.data!["image"]),
                                          ),
                                          Padding(padding: EdgeInsets.only(right: 10)),
                                          Text("Add a comments...")
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    height: 5,
                                  ),
                                  Padding(padding: EdgeInsets.all(5))
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
                } else {
                  return Container();
                }
              },
            ),
    ));
  }
}
