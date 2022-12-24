import 'dart:io';
import 'package:friday_chat_app/contact.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';

class add_post extends StatefulWidget {
  const add_post({super.key});

  @override
  State<add_post> createState() => _add_postState();
}

class _add_postState extends State<add_post> with SingleTickerProviderStateMixin {
  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  var auth_id = FirebaseAuth.instance.currentUser!.uid;
  var image = "https://images.unsplash.com/photo-1669487903359-1eb4bbb86ef8?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwyM3x8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60";
  bool isload = false;
  TextEditingController des = new TextEditingController();
  TextEditingController loc = new TextEditingController();
  File? _image;
  ImagePicker _picker = ImagePicker();

  var filename;
  Future<void> imagepicker(ImageSource soc) async {
    XFile? img = await _picker.pickImage(source: soc);
    if (img != null) {
      setState(() {
        _image = File(img.path);
        filename = img.path.split('/').last;
        print(filename);
        upload_image();
      });
    }
  }

  void upload_post() async {
    setState(() {
      isload = true;
    });

    String post_id = Uuid().v1();
    print(" post  id is the : " + post_id);
    print("user id is : " + _auth.currentUser!.uid);
    List contact = [];
    var snap = await _firestore.collection("contacts").doc(_auth.currentUser!.uid).collection("lastonline").get();
    for (var doc in snap.docs) {
      contact.add(doc.data());
    }
    for (var i = 0; i < contact.length; i++) {
      await _firestore.collection("cont_post").doc(contact[i]["uid"]).collection("all_post").doc(post_id).set({"time": DateTime.now(), "uid": _auth.currentUser!.uid, "post_id": post_id});
    }
    await _firestore.collection("cont_post").doc(_auth.currentUser!.uid).collection("all_post").doc(post_id).set({"time": DateTime.now(), "uid": _auth.currentUser!.uid, "post_id": post_id});

    await _firestore.collection("post").doc(_auth.currentUser!.uid).collection("story").doc(post_id).set({
      "post_id": post_id,
      "time": DateTime.now(),
      "user_id": _auth.currentUser!.uid,
      "description": des.text,
      "location": loc.text,
      "post": image_url,
      "like_enable": true,
      "comment_enable": true,
    }).then((value) {
      print("post successfully done !!");
    });
    await _firestore.collection("post").doc(_auth.currentUser!.uid).collection("story").doc(post_id).update({'like.$auth_id': false}).then((value) {
      print("post successfully done !!");
      setState(() {
        isload = false;
      });
    });
    Navigator.pop(context);
  }

  String image_url = "";
  void upload_image() async {
    isload = true;
    var ref = FirebaseStorage.instance.ref().child("post_image").child(filename);
    var up_image = await ref.putFile(_image!);
    image_url = await up_image.ref.getDownloadURL();
    print(image_url);
    setState(() {
      isload = false;
    });
  }

  late AnimationController cont;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cont = AnimationController(duration: Duration(milliseconds: 750), vsync: this);
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
              height: size.height / 30,
            ),
            Container(
              height: size.height / 12,
              child: Row(
                children: [
                  BackButton(
                    color: Colors.black,
                  ),
                  Text("New Post", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 20)),
                  Expanded(child: Container()),
                  IconButton(
                      onPressed: () {
                        if (_image != null) {
                          upload_post();
                        } else {
                          show_snak(context, "Please Enter Image For Post !!");
                        }
                      },
                      icon: Icon(Icons.check))
                ],
              ),
            ),
            Divider(
              thickness: 2,
            ),
            Expanded(
                child: isload
                    ? //Container(height: size.height / 5, child: Lottie.asset("asset/loading.json", width: size.width / 5, height: size.height))
                    Center(
                        child: Lottie.asset("asset/loading.json", width: size.width / 7, height: size.height),
                      )
                    : SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: size.width,
                          //  color: Colors.amber,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 51,
                                            backgroundColor: Color.fromARGB(255, 23, 52, 0),
                                            child: CircleAvatar(
                                              radius: 50,
                                              backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
                                            ),
                                          ),
                                          Positioned(
                                              right: 0,
                                              bottom: 10,
                                              child: CircleAvatar(
                                                radius: 21,
                                                backgroundColor: Colors.white,
                                                child: CircleAvatar(
                                                    radius: 20,
                                                    backgroundColor: Color.fromARGB(255, 0, 109, 7),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.camera_alt_outlined,
                                                        color: Color.fromARGB(255, 243, 243, 243),
                                                      ),
                                                      onPressed: () {
                                                        imagepicker(ImageSource.gallery);
                                                      },
                                                    )),
                                              )),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                        flex: 2,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: TextField(
                                            controller: des,
                                            keyboardType: TextInputType.multiline,
                                            maxLines: null,
                                            decoration: InputDecoration(hintText: "Write a caption...", isCollapsed: true, contentPadding: EdgeInsets.all(10)),
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: size.height / 20,
                              ),
                              Container(
                                child: TextField(
                                  controller: loc,
                                  decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      isCollapsed: true,
                                      contentPadding: EdgeInsets.all(10),
                                      prefixIcon: Icon(
                                        Icons.location_on,
                                        color: Colors.green,
                                      ),
                                      hintText: "Add Location",
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                            color: Color.fromARGB(221, 7, 48, 19),
                                            width: 1,
                                          )),
                                      border: OutlineInputBorder(borderSide: BorderSide(strokeAlign: StrokeAlign.inside), borderRadius: BorderRadius.circular(15))),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
          ],
        ),
      ),
    );
  }
}
