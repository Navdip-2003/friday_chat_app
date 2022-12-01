import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class comment_post extends StatefulWidget {
  const comment_post({super.key});

  @override
  State<comment_post> createState() => _comment_postState();
}

class _comment_postState extends State<comment_post> {
  var image = "https://images.unsplash.com/photo-1669172459261-d52881af17ab?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60";
  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  TextEditingController comment = new TextEditingController();
  ScrollController sc = new ScrollController();
  void scrolltobottom() async {
    await sc.animateTo(
      sc.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    //canishowfab = false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      // appBar: AppBar(
      //   leading: BackButton(color: Colors.black,),
      //   title: Text("Comments" , style: TextStyle(color: Colors.black , fontWeight: FontWeight.w600),),
      //   elevation: 1,
      //   backgroundColor: Color.fromARGB(0, 157, 157, 157),
      //   //brightness: Brightness.dark,
      // ),
      // floatingActionButton: _buildCommentBox(size, comment),
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
                    child: Container(
                  height: rang.size.height - (rang.viewInsets.bottom + rang.size.height / 8),
                  child: StreamBuilder(
                    stream: _firestore.collection("comment").doc("df3c970-6f04-11ed-bf42-035f5c778b21").collection("comment").snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          controller: sc,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
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
                                              backgroundImage: NetworkImage(image),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 4,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      snapshot.data!.docs[index]["uid"],
                                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                                    ),
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
                                          )
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      indent: 5,
                                      thickness: 2,
                                    ),
                                    Padding(padding: EdgeInsets.all(4)),
                                  ],
                                ));
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
                  color: Colors.orange,
                  width: size.width,
                  child: Container(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 1,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.redAccent,
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10)),
                          Flexible(
                              flex: 2,
                              child: TextField(
                                decoration: InputDecoration(isCollapsed: true, contentPadding: EdgeInsets.all(10), focusColor: Colors.white, hintText: "Add Comments ..."),
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

Widget _buildCommentBox(Size size, TextEditingController comment) {
  return Container(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(30.0),
      child: Container(
        height: size.height / 10,
        // margin: EdgeInsets.only(bottom: 20),
        width: size.width,
        //color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.amber,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 10)),
            Flexible(
                flex: 6,
                child: Container(
                  child: TextField(
                    controller: comment,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.all(10),
                        hintText: "Add Comments...",
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Color.fromARGB(221, 7, 48, 19),
                              width: 1,
                            )),
                        border: OutlineInputBorder(borderSide: BorderSide(strokeAlign: StrokeAlign.inside), borderRadius: BorderRadius.circular(20)),
                        suffixIcon: TextButton(
                          onPressed: () async {
                            var coid = Uuid().v1();
                            await FirebaseFirestore.instance.collection("comment").doc("df3c970-6f04-11ed-bf42-035f5c778b21").collection("comment").doc(coid).set({
                              "time": DateTime.now(),
                              "uid": FirebaseAuth.instance.currentUser!.uid,
                              "comment": comment.text,
                            }).then((value) {
                              print("comment is done !!");
                              comment.clear();
                            });
                          },
                          child: Text(
                            "POST",
                            style: TextStyle(color: Colors.blue),
                          ),
                        )),
                  ),
                ))
          ],
        ),
      ),
    ),
  );
}
