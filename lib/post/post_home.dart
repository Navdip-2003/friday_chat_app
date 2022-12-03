import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:friday_chat_app/open_image.dart';
import 'package:friday_chat_app/post/add_post.dart';
import 'package:friday_chat_app/post/comment_post.dart';
import 'package:like_button/like_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:image_downloader/image_downloader.dart';

class post_home extends StatefulWidget {
  const post_home({super.key});

  @override
  State<post_home> createState() => _post_homeState();
}

class _post_homeState extends State<post_home> with SingleTickerProviderStateMixin {
  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  String cuu_id = FirebaseAuth.instance.currentUser!.uid;

  bool isload = false;
  List post_show = [];
  void get_post() async {
    isload = true;
    await _firestore.collection("cont_post").doc(_auth.currentUser!.uid).collection("all_post").orderBy("time", descending: true).get().then((value) {
      value.docs.forEach((element) {
        print(element.data());
        post_show.add(element.data());
      });
      print(post_show);
    });
    setState(() {
      isload = false;
    });
  }

  final GlobalKey<RefreshIndicatorState> ref_key = GlobalKey<RefreshIndicatorState>();
  bool isloading = false;
  bool more_pr = true;
  bool get_pr = false;
  ScrollController sc = ScrollController();
  DocumentSnapshot? last_re;
  List kl = [];
  void show_data() async {
    setState(() {
       isloading = true;
    });
   
    await _firestore.collection("cont_post").doc(_auth.currentUser!.uid).collection("all_post").orderBy("time", descending: true).limit(3).get().then((value) {
      if (value.docChanges.isNotEmpty) {
        kl = value.docs;
        last_re = value.docs[value.docs.length - 1];
      }

      // print(last_re!["time"]);

      setState(() {
        isloading = false;
      });
    });
  }

  void show() async {
    print("more data afford in database !!");
    if (!more_pr) {
      print("no product available !!");
      return;
    }
    if (get_pr) {
      return;
    }
    setState(() {
      get_pr = true;
    });

    await Future.delayed(Duration(seconds: 1));
    await _firestore.collection("cont_post").doc(_auth.currentUser!.uid).collection("all_post").orderBy("time", descending: true).startAfter([last_re!["time"]]).limit(2).get().then((value) {
          if (value.docs.isEmpty) {
            setState(() {
              more_pr = true;
              get_pr = false;
              return;
            });
          } else {
            kl.addAll(value.docs);
            last_re = value.docs[value.docs.length - 1];
            print(value.docs.length);
            if (value.docs.length < 2) {
              setState(() {
                more_pr = false;
              });
            }
            setState(() {
              get_pr = false;
            });
          }
        });
  }

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

  late AnimationController cont;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //get_post();
    image_get_user();
    show_data();
    sc = ScrollController();
    sc.addListener(() {
      double maxscroll = sc.position.maxScrollExtent;
      double cuscrll = sc.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxscroll - cuscrll <= delta) {
        show();
      }
    });
    cont = AnimationController(duration: Duration(milliseconds: 750), vsync: this);
    // getlike();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.blueGrey,
        onPressed: (() {
          Navigator.push(context, MaterialPageRoute(builder: (context) => add_post()));
        }),
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
      body: Container(
        //color: Colors.greenAccent,
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height / 25,
            ),
            Container(
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "Social Media",
                      style: TextStyle(color: Colors.black, fontFamily: "Paci", fontSize: 20),
                    ),
                  ),
                  Divider(
                    height: 3,
                    thickness: 2,
                  )
                ],
              ),
            ),
            Expanded(
                child: Container(
              child: isload
                  ? Center(
                      child: Lottie.asset("asset/loading.json", width: size.width / 7, height: size.height),
                    )
                  : RefreshIndicator(
                      key: ref_key,
                      onRefresh: () async {
                        setState(() {
                          show_data();
                          more_pr = true;
                          get_pr = false;
                        });
                      },
                      child: Container(
                       
                        color: Colors.red,
                        width: size.width,
                        child: ListView.builder(
                          controller: sc,
                          itemCount: kl.length,
                          itemBuilder: (context, index) {
                            if (kl.isNotEmpty) {
                              return StreamBuilder(
                                stream: _firestore.collection("post").doc(kl[index]["uid"]).collection("story").doc(kl[index]["post_id"]).snapshots(),
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
                                    final Timestamp timestamp = kl[index]["time"] as Timestamp;
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
                                      stream: _firestore.collection("users").doc(kl[index]["uid"]).snapshots(),
                                      builder: (context, snap) {
                                        if (snap.hasData) {
                                          return Card(
                                            //color: Color.fromARGB(255, 200, 200, 200),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                                            child: Container(
                                              child: Container(
                                                width: size.width,
                                                child: Column(
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
                                                                      width: size.width / 1.8,
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
                                                          Text("$diff_time")
                                                        ],
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onDoubleTap: () {
                                                        if (jj == false) {
                                                          setState(() {
                                                            tot_like += 1;
                                                            jj = true;
                                                            _firestore.collection("post").doc(kl[index]["uid"]).collection("story").doc(kl[index]["post_id"]).update({'like.$cuu_id': true});
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
                                                        height: size.height / 2.2,
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

                                                                  _firestore.collection("post").doc(kl[index]["uid"]).collection("story").doc(kl[index]["post_id"]).update({'like.$cuu_id': true});
                                                                });

                                                                return !kkr;
                                                              } else {
                                                                print("isnotliked!!");
                                                                setState(() {
                                                                  tot_like -= 1;
                                                                  jj = false;
                                                                  _firestore.collection("post").doc(kl[index]["uid"]).collection("story").doc(kl[index]["post_id"]).update({'like.$cuu_id': false});
                                                                });
                                                                return !kkr;
                                                              }
                                                            },
                                                          ),

                                                          // IconButton(
                                                          //   onPressed: () async{
                                                          //     if(jj == false){
                                                          //       setState(() {
                                                          //         jj = true;
                                                          //         _firestore.collection("post").doc("6aBmHJnwWXhT3AQl9fjBW0uhYd52").collection("story").
                                                          //           doc("vHe7VbbqzMWHc6eErcgw").update({
                                                          //             'like.$cuu_id' : true
                                                          //           });
                                                          //       });
                                                          //     }else{
                                                          //       setState(() {
                                                          //         jj = false;
                                                          //         _firestore.collection("post").doc("6aBmHJnwWXhT3AQl9fjBW0uhYd52").collection("story").
                                                          //           doc("vHe7VbbqzMWHc6eErcgw").update({
                                                          //             'like.$cuu_id' : false
                                                          //           });
                                                          //       });
                                                          //     }
                                                          //   },
                                                          //   icon: jj ? Icon(Icons.favorite , color: Colors.red,) : Icon(Icons.favorite_border , color: Colors.red,)

                                                          // ),
                                                          SizedBox(
                                                            width: size.width / 25,
                                                          ),
                                                          InkWell(
                                                              onTap: () {
                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => comment_post(post_id: kl[index]["post_id"])));
                                                              },
                                                              child: Image.asset(
                                                                "asset/comment.png",
                                                                scale: 23,
                                                              )),
                                                          IconButton(
                                                              onPressed: () async {
                                                                try {
                                                                  var imageId = await ImageDownloader.downloadImage(
                                                                    snapshot.data!["post"]
                                                                    //destination: AndroidDestinationType.custom(directory: 'FriDayChat')
                                                                  );
                                                                  if (imageId == null) {
                                                                    return;
                                                                  }
                                                                  var path = await ImageDownloader.findPath(imageId);
                                                                  print(path);
                                                                } on PlatformException catch (error) {
                                                                  print(error);
                                                                }
                                                              },
                                                              icon: Icon(Icons.download)
                                                            ),
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
                                                                    size: 30,
                                                                  );
                                                              },
                                                              onTap: (isliked) async {
                                                                return !isliked;
                                                                
                                                              },
                                                            ),
                                                          Expanded(
                                                            child: Container(),
                                                          ),
                                                          Icon(Icons.bookmark)
                                                          // LikeButton(
                                                          //   size: 30,
                                                          //   //likeCount: 100,
                                                          //   //countPostion: CountPostion.bottom,
                                                          //   bubblesColor: BubblesColor(dotPrimaryColor: Colors.blue, dotSecondaryColor: Colors.red),
                                                          //   circleColor: CircleColor(start: Colors.black, end: Colors.white),
                                                          //   likeBuilder: (isLiked) {
                                                          //     // if (jj == false) {
                                                          //     //   return Icon(
                                                          //     //     Icons.bookmark,
                                                          //     //     color: Colors.grey,
                                                          //     //     size: 30,
                                                          //     //   );
                                                          //     // } else {
                                                          //     //   return Icon(
                                                          //     //     Icons.bookmark,
                                                          //     //     color: Colors.blue,
                                                          //     //     size: 30,
                                                          //     //   );
                                                          //     // }
                                                          //   },
                                                          //   // onTap: (kkr) async {
                                                          //   //   if (jj == false) {
                                                          //   //     print("isliked!!");
                                                          //   //     jj = true;
                                                          //   //     return !kkr;
                                                          //   //   } else {
                                                          //   //     jj = false;
                                                          //   //     print("isnotliked!!");
                                                          //   //     return !kkr;
                                                          //   //   }
                                                          //   // },
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                    // tot_like == 0
                                                    //     ? Container()
                                                    //     : Container(
                                                    //         padding: EdgeInsets.only(right: 10, left: 10),
                                                    //         width: size.width,
                                                    //         color: Color.fromARGB(255, 109, 137, 250),
                                                    //         child: tot_like == 1
                                                    //             ? Text(
                                                    //                 "Liked are 1 others",
                                                    //                 overflow: TextOverflow.ellipsis,
                                                    //               )
                                                    //             : Text(
                                                    //                 "Total Likes are  $tot_like and  others",
                                                    //                 overflow: TextOverflow.ellipsis,
                                                    //               ),
                                                    //       ),
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
                                                          Navigator.push(context, MaterialPageRoute(builder: (context) => comment_post(post_id: kl[index]["post_id"])));
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
                                    return Container(child: Center(child: CircularProgressIndicator(),),);
                                  }
                                },
                              );
                            } else {
                              return Container(child: Center(child: CircularProgressIndicator()),);
                            }
                          },
                        ),
                      ),
                    ),
            )),
            if (get_pr)
              Container(
                child: CircularProgressIndicator(),
              )
            // Expanded(
            //     child: SingleChildScrollView(
            //   child: Column(
            //     children: [
            // StreamBuilder(
            //   stream: _firestore.collection("post").doc("OPElQEDKCpZsFMu9RL37O5Gswzu2").collection("story").doc("8df3c970-6f04-11ed-bf42-035f5c778b21").snapshots(),
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       int tyy = 0;
            //       bool jj = snapshot.data!["like"][_auth.currentUser!.uid] == null ? false : snapshot.data!["like"][_auth.currentUser!.uid];
            //       Map<String, dynamic> tot = snapshot.data!["like"];
            //       tot.forEach((key, value) {
            //         if (value == true) {
            //           tyy += 1;
            //         }
            //       });
            //       //   print(jj);
            //       return Container(
            //         color: Color.fromARGB(255, 246, 179, 159),
            //         child: Container(
            //           // height: size.height / 1.5,
            //           color: Color.fromARGB(255, 90, 246, 75),
            //           width: size.width,
            //           child: Column(
            //             children: [
            //               Container(
            //                 padding: EdgeInsets.all(5),
            //                 child: Row(
            //                   children: [
            //                     CircleAvatar(
            //                       radius: 25,
            //                       foregroundColor: Color.fromARGB(255, 13, 181, 60),
            //                       child: CircleAvatar(
            //                         radius: 24,
            //                         backgroundImage: NetworkImage(image),
            //                       ),
            //                     ),
            //                     Padding(
            //                       padding: const EdgeInsets.all(8.0),
            //                       child: Column(
            //                         crossAxisAlignment: CrossAxisAlignment.start,
            //                         children: [
            //                           Container(
            //                             width: size.width / 2,
            //                             child: Text("Navdip Chothani", style: TextStyle(fontFamily: "SansFont", fontWeight: FontWeight.w900, overflow: TextOverflow.ellipsis, fontSize: 15)),
            //                           ),
            //                           Container(
            //                             width: size.width / 1.8,
            //                             child: Text(
            //                               "The World",
            //                               style: TextStyle(fontFamily: "", fontSize: 10, overflow: TextOverflow.ellipsis),
            //                             ),
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                     Expanded(child: Icon(Icons.vertical_distribute_outlined))
            //                   ],
            //                 ),
            //               ),
            //               Container(
            //                 width: size.width,
            //                 height: size.height / 2.2,
            //                 child: Image.network(
            //                   snapshot.data!["post"],
            //                   fit: BoxFit.cover,
            //                 ),
            //               ),
            //               Container(
            //                 padding: EdgeInsets.only(right: 10, left: 10, top: 5, bottom: 5),
            //                 child: Row(
            //                   children: [
            //                     LikeButton(
            //                       // countBuilder: null,
            //                       likeBuilder: (isLiked) {
            //                         if (jj == false) {
            //                           return Icon(
            //                             Icons.favorite,
            //                             color: Colors.grey,
            //                             size: 30,
            //                           );
            //                         } else {
            //                           return Icon(
            //                             Icons.favorite,
            //                             color: Color.fromARGB(255, 198, 18, 1),
            //                             size: 30,
            //                           );
            //                         }
            //                       },
            //                       onTap: (kkr) async {
            //                         if (jj == false) {
            //                           print("isliked!!");
            //                           setState(() {
            //                             tyy += 1;
            //                             jj = true;
            //                             _firestore.collection("post").doc("OPElQEDKCpZsFMu9RL37O5Gswzu2").collection("story").doc("8df3c970-6f04-11ed-bf42-035f5c778b21").update({'like.$cuu_id': true});
            //                           });
            //                           return !kkr;
            //                         } else {
            //                           print("isnotliked!!");
            //                           setState(() {
            //                             tyy -= 1;
            //                             jj = false;
            //                             _firestore.collection("post").doc("OPElQEDKCpZsFMu9RL37O5Gswzu2").collection("story").doc("8df3c970-6f04-11ed-bf42-035f5c778b21").update({'like.$cuu_id': false});
            //                           });
            //                           return !kkr;
            //                         }
            //                       },
            //                     ),
            //                     // IconButton(
            //                     //   onPressed: () async{
            //                     //     if(jj == false){
            //                     //       setState(() {
            //                     //         jj = true;
            //                     //         _firestore.collection("post").doc("6aBmHJnwWXhT3AQl9fjBW0uhYd52").collection("story").
            //                     //           doc("vHe7VbbqzMWHc6eErcgw").update({
            //                     //             'like.$cuu_id' : true
            //                     //           });
            //                     //       });
            //                     //     }else{
            //                     //       setState(() {
            //                     //         jj = false;
            //                     //         _firestore.collection("post").doc("6aBmHJnwWXhT3AQl9fjBW0uhYd52").collection("story").
            //                     //           doc("vHe7VbbqzMWHc6eErcgw").update({
            //                     //             'like.$cuu_id' : false
            //                     //           });
            //                     //       });
            //                     //     }
            //                     //   },
            //                     //   icon: jj ? Icon(Icons.favorite , color: Colors.red,) : Icon(Icons.favorite_border , color: Colors.red,)
            //                     // ),
            //                     SizedBox(
            //                       width: size.width / 25,
            //                     ),
            //                     InkWell(
            //                         onTap: () {},
            //                         child: Image.asset(
            //                           "asset/comment.png",
            //                           scale: 23,
            //                         )),
            //                     Expanded(
            //                       child: Container(),
            //                     ),
            //                     LikeButton(
            //                       size: 30,
            //                       //likeCount: 100,
            //                       //countPostion: CountPostion.bottom,
            //                       bubblesColor: BubblesColor(dotPrimaryColor: Colors.blue, dotSecondaryColor: Colors.red),
            //                       circleColor: CircleColor(start: Colors.black, end: Colors.white),
            //                       likeBuilder: (isLiked) {
            //                         if (jj == false) {
            //                           return Icon(
            //                             Icons.bookmark,
            //                             color: Colors.grey,
            //                             size: 30,
            //                           );
            //                         } else {
            //                           return Icon(
            //                             Icons.bookmark,
            //                             color: Colors.blue,
            //                             size: 30,
            //                           );
            //                         }
            //                       },
            //                       onTap: (kkr) async {
            //                         if (jj == false) {
            //                           print("isliked!!");
            //                           jj = true;
            //                           return !kkr;
            //                         } else {
            //                           jj = false;
            //                           print("isnotliked!!");
            //                           return !kkr;
            //                         }
            //                       },
            //                     )
            //                   ],
            //                 ),
            //               ),
            //               Container(
            //                 padding: EdgeInsets.only(right: 10, left: 10),
            //                 width: size.width,
            //                 color: Color.fromARGB(255, 109, 137, 250),
            //                 child: Text(
            //                   "Liked by navdip and $tyy others",
            //                   overflow: TextOverflow.ellipsis,
            //                 ),
            //               ),
            //               Container(
            //                 padding: EdgeInsets.all(10),
            //                 width: size.width,
            //                 child: Text(
            //                   snapshot.data!["description"],
            //                   style: TextStyle(fontSize: 18, fontFamily: "SansFont"),
            //                 ),
            //               ),
            //               Container(
            //                 padding: EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 10),
            //                 width: size.width,
            //                 child: InkWell(
            //                   onTap: () {
            //                     Navigator.push(context, MaterialPageRoute(builder: (context) => comment_post()));
            //                   },
            //                   child: Row(
            //                     children: [
            //                       CircleAvatar(
            //                         radius: 15,
            //                         backgroundImage: NetworkImage(image),
            //                       ),
            //                       Padding(padding: EdgeInsets.only(right: 10)),
            //                       Text("Add a comments...")
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //               Divider(
            //                 height: 5,
            //               )
            //             ],
            //           ),
            //         ),
            //       );
            //     } else {
            //       return Container();
            //     }
            //   },
            // ),
            // Container(
            //   color: Color.fromARGB(255, 246, 179, 159),
            //   child: Container(
            //     // height: size.height / 1.5,
            //     color: Colors.yellow,
            //     width: size.width,
            //     child: Column(
            //       children: [
            //         Container(
            //           padding: EdgeInsets.all(5),
            //           child: Row(
            //             children: [
            //               CircleAvatar(
            //                 radius: 25,
            //                 foregroundColor: Color.fromARGB(255, 13, 181, 60),
            //                 child: CircleAvatar(
            //                   radius: 24,
            //                   backgroundImage: NetworkImage(image),
            //                 ),
            //               ),
            //               Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Container(
            //                       width: size.width / 2,
            //                       child: Text("Navdip Chothani", style: TextStyle(fontFamily: "SansFont", fontWeight: FontWeight.w900, overflow: TextOverflow.ellipsis, fontSize: 15)),
            //                     ),
            //                     Container(
            //                       width: size.width / 1.8,
            //                       child: Text(
            //                         "The World",
            //                         style: TextStyle(fontFamily: "", fontSize: 10, overflow: TextOverflow.ellipsis),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //               Expanded(child: Icon(Icons.vertical_distribute_outlined))
            //             ],
            //           ),
            //         ),
            //         Container(
            //           width: size.width,
            //           height: size.height / 2.2,
            //           child: Image.network(
            //             image,
            //             fit: BoxFit.cover,
            //           ),
            //         ),
            //         Container(
            //           padding: EdgeInsets.only(right: 10, left: 10),
            //           child: Row(
            //             children: [
            //               // LikeButton(
            //               //  // countBuilder: null,
            //               //   likeBuilder: (isLiked) {
            //               //     return Icon(Icons.favorite,
            //               //       color: isLiked ? Color.fromARGB(255, 201, 12, 2) : Colors.grey,size:30 ,
            //               //     );
            //               //   },
            //               //   onTap: (isLiked) async {
            //               //      this.isLiked = !isLiked;
            //               //      likecon += this.isLiked ? 1 : -1 ;
            //               //     print(isLiked);
            //               //     return !isLiked;
            //               //   },
            //               // ),
            //               IconButton(
            //                   onPressed: () async {
            //                     if (falco == false) {
            //                       setState(() {
            //                         falco = true;
            //                         _firestore.collection("post").doc("6aBmHJnwWXhT3AQl9fjBW0uhYd52").collection("story").doc("vHe7VbbqzMWHc6eErcgw").update({'like.$cuu_id': true});
            //                       });
            //                     } else {
            //                       setState(() {
            //                         falco = false;
            //                         _firestore.collection("post").doc("6aBmHJnwWXhT3AQl9fjBW0uhYd52").collection("story").doc("vHe7VbbqzMWHc6eErcgw").update({'like.$cuu_id': false});
            //                       });
            //                     }
            //                   },
            //                   icon: falco
            //                       ? Icon(
            //                           Icons.favorite,
            //                           color: Colors.red,
            //                         )
            //                       : Icon(
            //                           Icons.favorite_border,
            //                           color: Colors.red,
            //                         )
            //                   // !falco ? Icon(Icons.favorite_border , color: Colors.red,size: 25,) :
            //                   //       Icon(Icons.favorite, size: 25, color: Colors.red,)
            //                   ),
            //               SizedBox(
            //                 width: size.width / 25,
            //               ),
            //               InkWell(
            //                   onTap: () {},
            //                   child: Image.asset(
            //                     "asset/comment.png",
            //                     scale: 23,
            //                   )),
            //               Expanded(
            //                 child: Container(),
            //               ),
            //               LikeButton(
            //                 size: 30,
            //                 likeCount: 100,
            //                 countPostion: CountPostion.bottom,
            //                 bubblesColor: BubblesColor(dotPrimaryColor: Colors.blue, dotSecondaryColor: Colors.red),
            //                 circleColor: CircleColor(start: Colors.black, end: Colors.white),
            //                 likeBuilder: (isLiked) {
            //                   // print(isLiked);
            //                   if (isLiked == false) {
            //                     // print("unlike");
            //                     return Icon(
            //                       Icons.bookmark,
            //                       color: Colors.grey,
            //                     );
            //                   } else {
            //                     //  print("like");
            //                     return Icon(
            //                       Icons.bookmark,
            //                       color: Colors.blue,
            //                     );
            //                   }
            //                   // return Icon(Icons.bookmark,
            //                   //   color: isLiked ? Colors.blue : Colors.grey,size:30 ,
            //                   // );
            //                 },
            //               )
            //             ],
            //           ),
            //         ),
            //         Container(
            //           padding: EdgeInsets.only(right: 10, left: 10),
            //           width: size.width,
            //           color: Color.fromARGB(255, 109, 137, 250),
            //           child: Text(
            //             "Liked by navdip and 100 others",
            //             overflow: TextOverflow.ellipsis,
            //           ),
            //         ),
            //         Container(
            //           padding: EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 10),
            //           width: size.width,
            //           child: Row(
            //             children: [
            //               CircleAvatar(
            //                 radius: 15,
            //                 backgroundImage: NetworkImage(image),
            //               ),
            //               Padding(padding: EdgeInsets.only(right: 10)),
            //               Text("Add a comments...")
            //             ],
            //           ),
            //         ),
            //         Divider(
            //           height: 5,
            //         )
            //       ],
            //     ),
            //   ),
            // ),
            // Container(
            //   color: Color.fromARGB(255, 246, 179, 159),
            //   child: Container(
            //     // height: size.height / 1.5,
            //     color: Color.fromARGB(255, 142, 102, 2),
            //     width: size.width,
            //     child: Column(
            //       children: [
            //         Container(
            //           padding: EdgeInsets.all(5),
            //           child: Row(
            //             children: [
            //               CircleAvatar(
            //                 radius: 25,
            //                 foregroundColor: Color.fromARGB(255, 13, 181, 60),
            //                 child: CircleAvatar(
            //                   radius: 24,
            //                   backgroundImage: NetworkImage(image),
            //                 ),
            //               ),
            //               Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Container(
            //                       width: size.width / 2,
            //                       child: Text("Navdip Chothani", style: TextStyle(fontFamily: "SansFont", fontWeight: FontWeight.w900, overflow: TextOverflow.ellipsis, fontSize: 15)),
            //                     ),
            //                     Container(
            //                       width: size.width / 1.8,
            //                       child: Text(
            //                         "The World",
            //                         style: TextStyle(fontFamily: "", fontSize: 10, overflow: TextOverflow.ellipsis),
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //               Expanded(child: Icon(Icons.vertical_distribute_outlined))
            //             ],
            //           ),
            //         ),
            //         Container(
            //           width: size.width,
            //           height: size.height / 2.2,
            //           child: Image.network(
            //             image,
            //             fit: BoxFit.cover,
            //           ),
            //         ),
            //         Container(
            //           padding: EdgeInsets.only(right: 10, left: 10),
            //           child: Row(
            //             children: [
            //               LikeButton(
            //                 countBuilder: null,
            //                 likeBuilder: (isLiked) {
            //                   return Icon(
            //                     Icons.favorite,
            //                     color: isLiked ? Color.fromARGB(255, 201, 12, 2) : Colors.grey,
            //                     size: 30,
            //                   );
            //                 },
            //                 onTap: (isLiked) async {
            //                   this.isLiked = !isLiked;
            //                   likecon += this.isLiked ? 1 : -1;
            //                   print(isLiked);
            //                   return !isLiked;
            //                 },
            //               ),
            //               SizedBox(
            //                 width: size.width / 25,
            //               ),
            //               InkWell(
            //                   onTap: () {},
            //                   child: Image.asset(
            //                     "asset/comment.png",
            //                     scale: 23,
            //                   )),
            //               Expanded(
            //                 child: Container(),
            //               ),
            //               LikeButton(
            //                 size: 30,
            //                 likeCount: 100,
            //                 countPostion: CountPostion.bottom,
            //                 bubblesColor: BubblesColor(dotPrimaryColor: Colors.blue, dotSecondaryColor: Colors.red),
            //                 circleColor: CircleColor(start: Colors.black, end: Colors.white),
            //                 likeBuilder: (isLiked) {
            //                   return Icon(
            //                     Icons.bookmark,
            //                     color: isLiked ? Colors.blue : Colors.grey,
            //                     size: 30,
            //                   );
            //                 },
            //               )
            //             ],
            //           ),
            //         ),
            //         Container(
            //           padding: EdgeInsets.only(right: 10, left: 10),
            //           width: size.width,
            //           color: Color.fromARGB(255, 109, 137, 250),
            //           child: Text(
            //             "Liked by navdip and 100 others",
            //             overflow: TextOverflow.ellipsis,
            //           ),
            //         ),
            //         Container(
            //           padding: EdgeInsets.only(top: 10, right: 20, left: 20, bottom: 10),
            //           width: size.width,
            //           child: Row(
            //             children: [
            //               CircleAvatar(
            //                 radius: 15,
            //                 backgroundImage: NetworkImage(image),
            //               ),
            //               Padding(padding: EdgeInsets.only(right: 10)),
            //               Text("Add a comments...")
            //             ],
            //           ),
            //         ),
            //         Divider(
            //           height: 5,
            //         )
            //       ],
            //     ),
            //   ),
            // ),
            //  ],
            //),
//           )),
          ],
        ),
      ),
    );
  }
}
