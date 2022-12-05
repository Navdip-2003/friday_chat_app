import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friday_chat_app/post/settingInAppPost/show_post.dart';

class manage_post extends StatefulWidget {
  const manage_post({super.key});

  @override
  State<manage_post> createState() => _manage_postState();
}

class _manage_postState extends State<manage_post> {
  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  List post_data = [];
  void get_post() async {
    await _firestore.collection("post").doc(_auth.currentUser!.uid).collection("story").get().then((value) {
      setState(() {
        post_data.addAll(value.docs);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_post();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            SizedBox(
              height: size.height / 10,
            ),
            Expanded(
              child: Container(
                  color: Colors.white24,
                  width: size.width,
                  child: GridView.builder(
                    itemCount: post_data.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => show_post(postid: post_data[index]["post_id"], uid: post_data[index]["user_id"])));
                          },
                          child: Container(
                            color: Colors.red,
                            height: 100,
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Icon(Icons.error),
                              imageUrl: post_data[index]["post"],
                              placeholder: (context, url) {
                                return Center(
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            )
          ],
        ),
      ),
    );
  }
}
