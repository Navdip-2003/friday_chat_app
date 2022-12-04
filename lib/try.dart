import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class tty extends StatefulWidget {
  const tty({super.key});

  @override
  State<tty> createState() => _ttyState();
}

class _ttyState extends State<tty> with SingleTickerProviderStateMixin {
  @override
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
    await _firestore.collection("chatroom").doc("FenilDarshan").collection("chat").orderBy("time", descending: false).limit(6).get().then((value) {
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
    get_pr = true;
    await Future.delayed(Duration(seconds: 1));
    await _firestore.collection("chatroom").doc("FenilDarshan").collection("chat").orderBy("time", descending: false).startAfter([last_re!["time"]]).limit(5).get().then((value) {
          kl.addAll(value.docs);
          last_re = value.docs[value.docs.length - 1];
          if (value.docs.length < 5) {
            more_pr = false;
          }

          setState(() {
            get_pr = false;
          });
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
      body: isloading
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
                          return ListTile(
                            title: Text(kl[index]["sendy"]),
                            subtitle: Text(kl[index]["message"]),
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
    );
  }
}

class demoty extends StatefulWidget {
  const demoty({super.key});

  @override
  State<demoty> createState() => _demotyState();
}

class _demotyState extends State<demoty> {
  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  bool isloading = false;
  bool more_pr = true;
  bool get_pr = false;
  ScrollController sc = ScrollController();
  DocumentSnapshot? last_re;
  List kl = [];
  void show_data() async {
    isloading = true;
    await _firestore.collection("chatroom").doc("OPElQEDKCpZsFMu9RL37O5Gswzu2Ikw2p5ry0WceDSK606Dzz6VmtR22").collection("chat").orderBy("time", descending: false).limit(6).get().then((value) {
      kl = value.docs;
      last_re = value.docs[value.docs.length - 1];
      setState(() {
        isloading = false;
      });
    });
  }

  void getmoredata() async {
    print("more data afford in database !!");
    if (!more_pr) {
      print("no product available !!");
      return;
    }
    if (get_pr) {
      return;
    }
    get_pr = true;
    // await Future.delayed(Duration(seconds: 1));
    await _firestore.collection("chatroom").doc("OPElQEDKCpZsFMu9RL37O5Gswzu2Ikw2p5ry0WceDSK606Dzz6VmtR22").collection("chat").orderBy("time", descending: false).startAfter([last_re!["time"]]).limit(5).get().then((value) {
          // kl.addAll(value.docs);
          print(value.docs[0]["message"]);
          last_re = value.docs[value.docs.length - 1];

          if (value.docs.length < 5) {
            more_pr = false;
          }

          setState(() {
            get_pr = false;
          });
        });
  }

  @override
  void initState() {
    super.initState();
    show_data();
    sc.addListener(() {
      double maxscroll = sc.position.maxScrollExtent;
      double cuscrll = sc.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxscroll - cuscrll <= delta) {
        getmoredata();
      }
    });
    // sc.addListener(() {
    //   if (sc.offset == sc.position.minScrollExtent) {
    //     print("thi is minimum scroll !!");
    //     // print(last_re!["message"]);
    //     getmoredata();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      sc.position.maxScrollExtent;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("This Is Paging !!"),
      ),
      body: Center(
        child: Container(
          height: size.height * 0.50,
          width: size.width,
          color: Colors.amber,
          child: ListView.builder(
            controller: sc,
            itemCount: kl.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(kl[index]["sendy"]),
                subtitle: Text(kl[index]["message"]),
              );
            },
          ),
        ),
      ),
    );
  }
}



class file_piker extends StatefulWidget {
  const file_piker({super.key});

  @override
  State<file_piker> createState() => _file_pikerState();
}

class _file_pikerState extends State<file_piker> {
  File? image;
  Future file_pick() async{
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false ,
      type: FileType.image ,
      allowedExtensions: ['jpg', 'jpeg', ]
    );  

      if (result != null) {
       final path = result.files.single.path;
       setState(() {
         image = File(path!);
         var ll = image!.path.split("/").last;
         log("image : $ll");
         
       });
      } 
  }
  Future file_upload() async{
    if(image == null) return;

    final filename = image!.path.split("/").last;
    final destination = 'files_upload/$filename';
    final ref = await FirebaseStorage.instance.ref(destination);
    final url = await ref.putFile(image!);
    String ll =await url.ref.getDownloadURL();
    print(ll);
   
  


  }
  @override
  Widget build(BuildContext context) {
    final text = image == null ? Text("Pick file!!") : Text(image!.path.split("/").last);
    return Scaffold(
      
      appBar: AppBar(
        title: Text("File Picker😁 "),
      ),
      body: Container(
        child: Container(
         
          child: Center(
            child: Column(
              children: [
                text,
                ElevatedButton(
                  onPressed: (){
                    file_pick();
                  },
                  child: Text("File Picker"),
                ),
                 ElevatedButton(
                  onPressed: (){
                    file_upload();
                  },
                  child: Text("File Upload"),
                ),
              ],
            ),
          ),
        ),

      ),
    );
  }
}