import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:share_plus/share_plus.dart';

class chat_pagination extends StatefulWidget {
  const chat_pagination({super.key});

  @override
  State<chat_pagination> createState() => _chat_paginationState();
}

class _chat_paginationState extends State<chat_pagination> {
  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  String cuu_id = FirebaseAuth.instance.currentUser!.uid;
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

    await _firestore.collection("chatroom").doc("OPElQEDKCpZsFMu9RL37O5Gswzu2Ikw2p5ry0WceDSK606Dzz6VmtR22").collection("chat").orderBy("time", descending: true).limit(5).get().then((value) {
      setState(() {
        kl.addAll(value.docs);
      });
      last_re = value.docs[value.docs.length - 1];
      setState(() {
        isloading = false;
      });
    });
  }

  void show() async {
    print("No more chat !!");
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

    // await Future.delayed(Duration(seconds: 1));
    await _firestore.collection("chatroom").doc("OPElQEDKCpZsFMu9RL37O5Gswzu2Ikw2p5ry0WceDSK606Dzz6VmtR22").collection("chat").orderBy("time", descending: true).startAfter([last_re!["time"]]).limit(2).get().then((value) {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    show_data();
    sc = ScrollController();
    sc.addListener(() {
      if (sc.offset >= sc.position.maxScrollExtent) {
        print("minimum scroll is dine !!");
        show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        body: Center(
      child: Container(
        height: size.height / 2,
        child: Center(
          child: isloading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    if (get_pr)
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                    Expanded(
                      child: Container(
                        color: Colors.amber,
                        child: ListView.builder(
                          reverse: true,
                          controller: sc,
                          itemCount: kl.length,
                          itemBuilder: (context, index) {
                            return Container(
                              alignment: Alignment.center,
                              height: 100,
                              child: Text(kl[index]["message"]),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ));
  }
}
