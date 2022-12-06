import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:friday_chat_app/open_image.dart';
import 'package:friday_chat_app/post/comment_post.dart';
import 'package:friday_chat_app/post/post_home.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:lottie/lottie.dart';

class show_post extends StatefulWidget {
  String postid;
  String userid;
  show_post({super.key, required this.postid, required this.userid});

  @override
  State<show_post> createState() => _show_postState();
}

class _show_postState extends State<show_post> {
  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  var user_id = FirebaseAuth.instance.currentUser!.uid;
  bool imgLoad = false;
  String? image;
  void image_get_user() async {
    setState(() {
      imgLoad = true;
    });
    await _firestore.collection("users").doc(_auth.currentUser!.uid).get().then((value) {
      setState(() {});
      image = value["image"];
    });
    setState(() {
      imgLoad = false;
    });
  }

  void deletepost() async {
    //await _firestore.collection("")
  }
  List ppdata = [];
  List postdata = [];
  void get_userdata() async {
    await _firestore.collection("contacts").doc(_auth.currentUser!.uid).collection("lastonline").get().then((value) {
      postdata.addAll(value.docs);
    }).then((value) {
      print("postdata list of successfully!!!");
    });
    for (var i = 0; i < postdata.length; i++) {
      await _firestore.collection("post").doc(postdata[i]["uid"]).collection("story").get().then((value) {
        ppdata.addAll(value.docs);
      }).then((value) {
        print(ppdata.length);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    image_get_user();
    get_userdata();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("post").doc(FirebaseAuth.instance.currentUser!.uid).collection("story").doc(widget.postid).snapshots(),
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
                  return "${DateTime.now().difference(time).inHours} min";
                } else if (DateTime.now().difference(time).inMinutes < 1440) {
                  return "${DateTime.now().difference(time).inHours} hours";
                } else if (DateTime.now().difference(time).inMinutes > 1440) {
                  return "${DateTime.now().difference(time).inDays} days";
                }
              }

              var diff_time = getTime(dateTime);
              return StreamBuilder(
                stream: FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
                builder: (context, snap) {
                  if (snap.hasData) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: size.height / 15,
                          ),
                          Card(
                            //color: Color.fromARGB(255, 200, 200, 200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Container(
                              child: Container(
                                width: size.width,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(5),
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
                                                      width: size.width / 2.3,
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
                                          Expanded(child: Container()),
                                          Text("$diff_time"),
                                          // Container(
                                          //     child: PopupMenuButton(
                                          //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                          //         icon: Icon(
                                          //           Icons.more_vert,
                                          //           color: Colors.black54,
                                          //         ),
                                          //         onSelected: ((value) {
                                          //           if (value == "share") {
                                          //           } else if (value == "setprofile") {
                                          //           } else if (value == "delete") {
                                          //             //blok_message();
                                          //           }
                                          //         }),
                                          //         itemBuilder: (context) {
                                          //           return [
                                          //             PopupMenuItem(
                                          //                 value: "share",
                                          //                 child: ListTile(
                                          //                   title: Text("Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                          //                   leading: Icon(Icons.person, size: 30, color: Colors.black54),
                                          //                 )),
                                          //             PopupMenuItem(
                                          //                 value: "clear",
                                          //                 child: ListTile(
                                          //                   title: Text(
                                          //                     "Clear Chat",
                                          //                     style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                                          //                   ),
                                          //                   leading: Icon(
                                          //                     Icons.delete_forever_sharp,
                                          //                     size: 30,
                                          //                     color: Colors.black54,
                                          //                   ),
                                          //                 )),
                                          //             PopupMenuItem(
                                          //                 value: "Blok",
                                          //                 child: ListTile(
                                          //                   title: Text("Block", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                          //                   leading: Icon(Icons.block_sharp, size: 30, color: Colors.black54),
                                          //                 )),
                                          //           ];
                                          //         })),

                                          IconButton(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  backgroundColor: Color.fromARGB(255, 225, 225, 225),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
                                                  context: context,
                                                  builder: (context) {
                                                    return Container(
                                                      height: size.height / 2.5,
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            Icons.horizontal_rule_sharp,
                                                            size: 30,
                                                          ),
                                                          Padding(padding: EdgeInsets.all(10)),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  CircleAvatar(
                                                                    radius: 26.3,
                                                                    backgroundColor: Colors.black,
                                                                    child: CircleAvatar(
                                                                        backgroundColor: Color.fromARGB(255, 225, 225, 225),
                                                                        radius: 25,
                                                                        child: IconButton(
                                                                          onPressed: () {},
                                                                          icon: Icon(
                                                                            Icons.share_outlined,
                                                                            color: Colors.black,
                                                                            size: 30,
                                                                          ),
                                                                        )),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(3.0),
                                                                    child: Text("Share"),
                                                                  )
                                                                ],
                                                              ),
                                                              Padding(padding: EdgeInsets.all(10)),
                                                              Column(
                                                                children: [
                                                                  CircleAvatar(
                                                                    radius: 26.3,
                                                                    backgroundColor: Colors.black,
                                                                    child: CircleAvatar(
                                                                        backgroundColor: Color.fromARGB(255, 225, 225, 225),
                                                                        radius: 25,
                                                                        child: IconButton(
                                                                          onPressed: () {},
                                                                          icon: Icon(
                                                                            Icons.link_rounded,
                                                                            color: Colors.black,
                                                                            size: 30,
                                                                          ),
                                                                        )),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(3.0),
                                                                    child: Text("Link"),
                                                                  )
                                                                ],
                                                              ),
                                                              Padding(padding: EdgeInsets.all(10)),
                                                              Column(
                                                                children: [
                                                                  CircleAvatar(
                                                                    radius: 26.3,
                                                                    backgroundColor: Colors.black,
                                                                    child: CircleAvatar(
                                                                        backgroundColor: Color.fromARGB(255, 225, 225, 225),
                                                                        radius: 25,
                                                                        child: IconButton(
                                                                          onPressed: () {},
                                                                          icon: Icon(
                                                                            Icons.qr_code_scanner_rounded,
                                                                            color: Colors.black,
                                                                            size: 25,
                                                                          ),
                                                                        )),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(3.0),
                                                                    child: Text("QR code"),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.all(5.0),
                                                            child: Divider(
                                                              thickness: 2,
                                                              color: Color.fromARGB(255, 110, 110, 110),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: size.width,
                                                            child: ListTile(
                                                              onTap: () {
                                                                deletepost();
                                                              },
                                                              leading: Icon(
                                                                Icons.delete_forever_rounded,
                                                                size: 35,
                                                                color: Color.fromARGB(255, 206, 33, 33),
                                                              ),
                                                              title: Text(
                                                                "Deleted Post ",
                                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: size.width,
                                                            child: ListTile(
                                                              onTap: () {},
                                                              leading: Icon(
                                                                Icons.person_pin_circle_outlined,
                                                                size: 30,
                                                                color: Color.fromARGB(255, 2, 2, 2),
                                                              ),
                                                              title: Text(
                                                                "Set Profile Picture",
                                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              icon: Icon(Icons.more_vert))
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onDoubleTap: () {
                                        if (jj == false) {
                                          setState(() {
                                            tot_like += 1;
                                            jj = true;
                                            _firestore.collection("post").doc().collection("story").doc(snapshot.data!["post_id"]).update({'like.$user_id': true});
                                          });
                                        }
                                      },
                                      onTap: () {
                                        var url = snapshot.data!["post"];
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => open_image(
                                                      url: url,
                                                    )));
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
                                      padding: EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 5),
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

                                                  _firestore.collection("post").doc(widget.userid).collection("story").doc(widget.postid).update({'like.$user_id': true});
                                                });

                                                return !kkr;
                                              } else {
                                                print("isnotliked!!");
                                                setState(() {
                                                  tot_like -= 1;
                                                  jj = false;
                                                  _firestore.collection("post").doc(widget.userid).collection("story").doc(widget.postid).update({'like.$user_id': false});
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
                                          Padding(padding: EdgeInsets.all(8)),
                                          LikeButton(
                                            size: 30,
                                            //likeCount: 100,
                                            //countPostion: CountPostion.bottom,
                                            bubblesColor: BubblesColor(dotPrimaryColor: Color.fromARGB(255, 2, 112, 203), dotSecondaryColor: Color.fromARGB(255, 255, 105, 137)),
                                            circleColor: CircleColor(start: Colors.black, end: Colors.white),
                                            likeBuilder: (isLiked) {
                                              return Icon(
                                                Icons.download,
                                                color: Color.fromARGB(255, 2, 97, 249),
                                                size: 25,
                                              );
                                            },
                                            onTap: (isliked) async {
                                              if (await Directory("FriDayChat").exists()) {
                                                print("exist!!");
                                                // try {
                                                //   var imageId = await ImageDownloader.downloadImage(snapshot.data!["post"], destination: AndroidDestinationType.custom(directory: '/FriDayChat/'));
                                                //   if (imageId == null) {
                                                //     return !isliked;
                                                //   }
                                                //   var path = await ImageDownloader.findPath(imageId);
                                                //   return !isliked;
                                                // } on PlatformException catch (error) {
                                                //   print(error);
                                                // }
                                                return !isliked;
                                              } else {
                                                await Directory("/FriDayChat").create();
                                                print("not exist");
                                                return !isliked;
                                              }
                                            },
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
                                              backgroundImage: imgLoad ? null : NetworkImage(image!),
                                            ),
                                            Padding(padding: EdgeInsets.only(right: 10)),
                                            Text("Add a comments...")
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(5))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.height / 15,
                          )
                        ],
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
      ),
    );
  }
}
