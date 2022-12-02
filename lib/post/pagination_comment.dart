import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class comment_pagination extends StatefulWidget {
  const comment_pagination({super.key});

  @override
  State<comment_pagination> createState() => _comment_paginationState();
}

class _comment_paginationState extends State<comment_pagination> {
  bool isloading = false;
  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  bool more_pr = true;
  bool get_pr = false;
  ScrollController sc = ScrollController();
  DocumentSnapshot? last_re;
  List kl = [];
  void show_data() async {
    isloading = true;
    await _firestore.collection("cont_post").doc(_auth.currentUser!.uid).collection("all_post").orderBy("time", descending: true).limit(3).get().then((value) {
      kl = value.docs;
      last_re = value.docs[value.docs.length - 1];
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
              more_pr = false;
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

  void initState() {
    // TODO: implement initState
    super.initState();
    show_data();
    //show();
    sc.addListener(() {
      double maxscroll = sc.position.maxScrollExtent;
      double cuscrll = sc.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxscroll - cuscrll <= delta) {
        show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: kl.isEmpty
          ? Container()
          : Container(
              child: isloading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Center(
                      child: Container(
                        color: Color.fromARGB(60, 255, 121, 121),
                        height: size.height / 2,
                        width: size.width,
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: sc,
                                itemCount: kl.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: size.height / 5,
                                    child: ListTile(
                                      title: Text(kl[index]["post_id"]),
                                      subtitle: Text(kl[index]["uid"]),
                                      trailing: Text(index.toString()),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (get_pr)
                              Padding(
                                padding: EdgeInsets.all(2),
                                child: CircularProgressIndicator(),
                              )
                          ],
                        ),
                      ),
                    ),
            ),
    );
  }
}
