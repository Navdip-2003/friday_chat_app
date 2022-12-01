import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friday_chat_app/chatroom.dart';
import 'package:friday_chat_app/contact.dart';
import 'package:friday_chat_app/data_search.dart';
import 'package:friday_chat_app/open_image.dart';
import 'package:friday_chat_app/shimmer.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:intl/intl.dart';

class chats extends StatefulWidget {
  const chats({super.key});

  @override
  State<chats> createState() => _chatsState();
}

class _chatsState extends State<chats> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  var db = FirebaseFirestore.instance.collection("chatroom");
  ScrollController? sc;
  var isloading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sc = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () {
          showSearch(context: context, delegate: data_search());
        },
        child: Icon(Icons.message),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("contacts").doc(_auth.currentUser!.uid).collection("lastonline").orderBy("time", descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return shimmer_effect();
          } else {
            return ListView.builder(
                controller: sc,
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final Timestamp timestamp = snapshot.data!.docs[index]["time"] as Timestamp;
                  final DateTime dateTime = timestamp.toDate();
                  final dateString = DateFormat('kk:mm a').format(dateTime);

                  String chat_id = snapshot.data!.docs[index]["chat_id"];
                  var last_uid = snapshot.data!.docs[index]["uid"];
                  var data_last = snapshot.data!.docs[index];

                  return StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("users").doc(last_uid).snapshots(),
                    builder: (context, snap) {
                      if (snap.hasData) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Container(
                            decoration: BoxDecoration(color: Color.fromARGB(66, 188, 188, 188), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                            child: ListTile(
                              onTap: () async {
                                Map<String, dynamic>? data;
                                await FirebaseFirestore.instance.collection("users").doc(last_uid).get().then((value) {
                                  setState(() {
                                    data = value.data();
                                  });
                                });
                                Navigator.push(context, MaterialPageRoute(builder: ((context) => chatroom(chat_id: data_last["chat_id"], usermap: data!))));
                              },
                              title: Text(data_last["name"], style: TextStyle(fontSize: 20, overflow: TextOverflow.ellipsis, fontFamily: "SansFont", fontWeight: FontWeight.w600)),
                              subtitle: Text(data_last["last_message"], overflow: TextOverflow.ellipsis),
                              leading: snap.data!["image"] == ""
                                  ? CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Color.fromARGB(255, 54, 85, 41),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        var url = snap.data!["image"] == "" ? blank_image : snap.data!["image"];
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => open_image(
                                                      url: url,
                                                    )));
                                      },
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(snap.data!["image"]),
                                      ),
                                    ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(dateString),
                                  snap.data!["status"] == "Online"
                                      ? Icon(
                                          Icons.circle,
                                          size: 10,
                                          color: Color.fromARGB(255, 3, 143, 15),
                                        )
                                      : SizedBox()
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
                });
          }
        },
      ),
    );
  }
}
