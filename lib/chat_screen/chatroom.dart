import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:friday_chat_app/advance_feature/player_audio.dart';
import 'package:friday_chat_app/chat_screen/new_chatdesign.dart';
import 'package:friday_chat_app/chat_screen/type_screen.dart';
import 'package:friday_chat_app/contact.dart';
import 'package:friday_chat_app/methods.dart';
import 'package:friday_chat_app/navigation.dart';
import 'package:friday_chat_app/open_image.dart';
import 'package:friday_chat_app/popmenu_chatrom/chat_profile.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';


class chatroom extends StatefulWidget {
  String chat_id;
  Map<String, dynamic> usermap;
  chatroom({super.key, required this.chat_id, required this.usermap});

  @override
  State<chatroom> createState() => _chatroomState(chat_id, usermap);
}

class _chatroomState extends State<chatroom> {
  String? chat_id;
  Map<String, dynamic> usermap;
  _chatroomState(this.chat_id, this.usermap);
  bool ex_file = false;
  

  bool isDownloading = false;

  TextEditingController mess = new TextEditingController();
  ScrollController sc = new ScrollController();

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isloading = false;
  var download_per = 0.0;

  bool block_user = false;
  void check() async {
    await _firestore.collection("chatroom").doc(chat_id).get().then((value) {
      setState(() {
        block_user = value["blok"];
      });
    });
  }

  blok_message() async {
    bool bl = false;
    String? name;
    await _firestore.collection("chatroom").doc(chat_id).get().then((value) {
      setState(() {
        bl = value["blok"];
        name = value["user_name"];
      });
    });
    if (!bl) {
      await _firestore.collection("chatroom").doc(chat_id).set({"blok": true, "user_name": _auth.currentUser!.displayName});
      Map<String, dynamic>? messages = {"sendy": _auth.currentUser!.displayName, "message": "${_auth.currentUser!.displayName} Blocked This Account !!", "type": "notify", "time": DateTime.now()};
      await _firestore.collection("chatroom").doc(chat_id).collection("chat").add(messages).then((value) {
        Navigator.pop(context);
      });
    }
    if (bl) {
      if (name == _auth.currentUser!.displayName) {
        await _firestore.collection("chatroom").doc(chat_id).set({"blok": false, "user_name": ""});
        Map<String, dynamic>? messages = {"sendy": _auth.currentUser!.displayName, "message": "${_auth.currentUser!.displayName} Unblocked This Account ..", "type": "notify", "time": DateTime.now()};
        await _firestore.collection("chatroom").doc(chat_id).collection("chat").add(messages).then((value) {
          Navigator.pop(context);
        });
      }
    }

    print("bloak is clckes");
  }

  Future<void> delete_message() async {
    setState(() {
      isloading = true;
    });
    var coll = _firestore.collection("chatroom").doc(chat_id).collection("chat");
    var snap = await coll.get();
    for (var doc in snap.docs) {
      await doc.reference.delete().then((value) {});
    }
    Map<String, dynamic>? messages = {"sendy": _auth.currentUser!.displayName, "message": "${_auth.currentUser!.displayName} Deleted All Chat", "type": "notify", "time": FieldValue.serverTimestamp()};
    await _firestore.collection("chatroom").doc(chat_id).collection("chat").add(messages);
    await _firestore
        .collection("contacts")
        .doc(_auth.currentUser!.email)
        .collection("lastonline")
        .doc(usermap["email"])
        .set({"time": DateTime.now(), "email": usermap["email"], "uid": usermap["uid"], "name": usermap["name"], "chat_id": chat_id, "last_message": "${_auth.currentUser!.displayName} Deleted All Chat", "image": ""});
    await _firestore.collection("contacts").doc(usermap["email"]).collection("lastonline").doc(_auth.currentUser!.email).set({
      "time": DateTime.now(),
      "email": _auth.currentUser!.email,
      "uid": _auth.currentUser!.uid,
      "name": _auth.currentUser!.displayName,
      "chat_id": chat_id,
      "last_message": "${_auth.currentUser!.displayName} Deleted All Chat",
      "image": ""
    }).then((value) {
      setState(() {
        isloading = false;
      });
    });
  }

  Future last_save() async {
    var last;
  }

  chat_endtime() async {
    var _time = DateTime.now();
    var last_message = mess.text;
    var rub = 0;
    if (rub == 0) {
      await _firestore
          .collection("contacts")
          .doc(_auth.currentUser!.uid)
          .collection("lastonline")
          .doc(usermap["uid"])
          .set({"time": _time, "email": usermap["email"], "uid": usermap["uid"], "name": usermap["name"], "chat_id": chat_id, "last_message": last_message, "image": ""});
      await _firestore
          .collection("contacts")
          .doc(usermap["uid"])
          .collection("lastonline")
          .doc(_auth.currentUser!.uid)
          .set({"time": _time, "email": _auth.currentUser!.email, "uid": _auth.currentUser!.uid, "name": _auth.currentUser!.displayName, "chat_id": chat_id, "last_message": last_message, "image": ""});
      rub = 1;
    }
    await _firestore.collection("contacts").doc(_auth.currentUser!.uid).collection("lastonline").doc(usermap["uid"]).update({
      "time": _time,
    });
  }

  ImagePicker _picker = ImagePicker();
  File? pick_image;
  Future image_picker(ImageSource source) async {
    //String ft_image;
    XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        pick_image = File(image.path);
        print("image path is : " + pick_image.toString());
        var name = pick_image.toString().split("/").last;
        var size =pick_image!.lengthSync() / 1024;
        log("image size is : $size KB");

        upload_pickimage(name);
      });
    }
  }

  Future upload_pickimage(String name) async {
    int status = 1;
    var filename = Uuid().v1();
    pick_image = await FlutterNativeImage.compressImage(pick_image!.path , quality: 50);
    var size =pick_image!.lengthSync() / 1024;
    log("compressed size : $size KB");
    await _firestore.collection("chatroom").doc(chat_id).collection("chat").doc(filename).set(
      {
        "name" : name,
        "sendy": _auth.currentUser!.displayName, 
        "message": "", 
        "type": "img", 
        "time": DateTime.now()
      });
    var ref = FirebaseStorage.instance.ref().child("images").child("$filename.jpg");
    var up_image = await ref.putFile(pick_image!).catchError((error) async {
      await _firestore.collection("chatroom").doc(chat_id).collection("chat").doc(filename).delete();
      status = 0;
    });
    if (status == 1) {
      String image_url = await up_image.ref.getDownloadURL();
      await _firestore.collection("chatroom").doc(chat_id).collection("chat").doc(filename).update({"message": image_url});
      print(image_url);
    }
  }

  void send_message() async {
    if (mess.text.isNotEmpty) {
      Map<String, dynamic>? messages = {"sendy": _auth.currentUser!.displayName, "message": mess.text, "type": "text", "time": DateTime.now()};
      await _firestore.collection("chatroom").doc(chat_id).collection("chat").add(messages);
      chat_endtime();
      mess.clear();

      scrolltobottom();
    } else {
      print("please enter some text");
    }
  }

  void scrolltobottom() async {
    await sc.animateTo(
      sc.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    //canishowfab = false;
  }

  
  void init() async{
      var datenow = DateFormat("d MMMM y").format(DateTime.now());
      log("$datenow");
      await FirebaseFirestore.instance.collection("chatroom").doc(chat_id).collection("chat").where("message" , isEqualTo: datenow ).get().then((value){
        if(value.docs.isEmpty){
          FirebaseFirestore.instance.collection("chatroom").doc(chat_id).collection("chat").add({
            "message" : datenow,
            "sendy": " ",
            "time" : DateTime.now(),
            "type" : "notify"

          }).then((value) {
            log("date notify done byy add!!");
          });
        }
      });


  }

  bool available_data = false;
  late VoidCallback scrollcontrollerlistener;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
    //check();
    print(usermap);
    print(chat_id);
    //check_bloak();
  }

  @override
  Widget build(BuildContext context) {
    var rang = MediaQuery.of(context);
    

    if (rang.viewInsets.bottom > 0) {
      scrolltobottom();
    }
    
    

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox.fromSize(
        size: Size.square(40),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.arrow_downward_rounded,
              color: Color.fromARGB(255, 6, 100, 1),
            ),
            onPressed: () {
              setState(() {
                scrolltobottom();
              });
            },
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
            height: rang.size.height / 10,
            width: rang.size.width,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("asset/chat_back1.jpg"), fit: BoxFit.cover),
              //color: Colors.transparent,

              //color: Color.fromARGB(134, 215, 214, 214),
              // borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
            ),
            child: Container(
              height: rang.size.height / 12,
              width: rang.size.width / 1.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 7,
                    child: Container(
                      alignment: Alignment.center,
                      child: TextField(
                        controller: mess,
                        decoration: InputDecoration(
                            
                            fillColor: Colors.white,
                            filled: true,
                            isCollapsed: true,
                            prefixIcon: IconButton(
                              onPressed: () {
                                
                              }, 
                              icon: Icon(Icons.emoji_emotions , color: Colors.black26,)
                            ),
                            contentPadding: EdgeInsets.all(rang.size.height / 60),
                            suffixIcon: 
                                IconButton(
                                  onPressed:() {
                                    showModalBottomSheet(
                                      context: context, 
                                      builder: (context) {
                                        return show_modelsheet(rang);
                                      },
                                    );
                                  }, 
                                  icon: Icon(Icons.attach_file, color: Color.fromARGB(255, 88, 87, 87))
                                ),
                                // IconButton(
                                //   icon: Icon(Icons.camera_alt_rounded, size: rang.size.height / 30, color: Color.fromARGB(255, 88, 87, 87)),
                                //   onPressed: () {
                                //     image_picker();
                                //   },
                                // ),
                              
                            hintText: "Message",
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Color.fromARGB(221, 7, 48, 19),
                                  width: 1,
                                )),
                            border: OutlineInputBorder(borderSide: BorderSide(strokeAlign: BorderSide.strokeAlignInside), borderRadius: BorderRadius.circular(20))),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      // margin: EdgeInsets.only(left: rang.size.width / 100),
                      child: IconButton(
                          onPressed: () {
                            send_message();
                            // scrolltobottom();
                          },
                          icon: Icon(
                            Icons.send,
                            size: 30,
                            color: Color.fromARGB(255, 6, 63, 8),
                          )),
                    ),
                  )
                ],
              ),
            )),
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection("users").where("uid", isEqualTo: usermap["uid"]).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  color: Color.fromARGB(255, 255, 255, 255),
                  height: rang.size.height / 9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Container()),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  child: Row(
                                    children: [
                                      Icon(Icons.arrow_back),
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundImage: snapshot.data!.docs[0]["image"] == ""
                                            ? NetworkImage("https://images.unsplash.com/photo-1666933000035-426a98c3b514?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwxMnx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60")
                                            : NetworkImage(usermap["image"]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => chat_profile(usermap: usermap)));
                            },
                            child: Container(
                              padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                              // height: 10,
                              //color: Colors.amber,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    // width: rang.size.width / 2.35,
                                    child: Column(
                                      children: [
                                        Text(snapshot.data!.docs[0]["name"], style: TextStyle(fontFamily: "SansFont", fontSize: 18, overflow: TextOverflow.ellipsis, color: Colors.black87, fontWeight: FontWeight.w800)),
                                        Text(
                                          snapshot.data!.docs[0]["status"],
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.start,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
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
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => chat_profile(usermap: usermap)));
                                    } else if (value == "clear") {
                                      delete_message();
                                    } else if (value == "Blok") {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>new_chatdesign()));
                                      //  _firestore.collection("chatroom").doc(widget.chat_id).get().then((value) {
                                      //   print(value.data());
                                      //   var user_data = value.data();
                                      //   print(user_data!["block"]);
                                      //  });

                                      // _firestore.collection("chatroom").doc(widget.chat_id).set({
                                      //   "block" : false

                                      // });
                                      
                                      //blok_message();
                                    }
                                  }),
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                          value: "profile",
                                          child: ListTile(
                                            title: Text("Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                            leading: Icon(Icons.person, size: 30, color: Colors.black54),
                                          )),
                                      PopupMenuItem(
                                          value: "clear",
                                          child: ListTile(
                                            title: Text(
                                              "Clear Chat",
                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                                            ),
                                            leading: Icon(
                                              Icons.delete_forever_sharp,
                                              size: 30,
                                              color: Colors.black54,
                                            ),
                                          )),
                                      PopupMenuItem(
                                          value: "Blok",
                                          child: ListTile(
                                            title: Text("Block", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                            leading: Icon(Icons.block_sharp, size: 30, color: Colors.black54),
                                          )),
                                    ];
                                  }))
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return Container(
                  height: rang.size.height / 9,
                );
              }
            },
          ),
          Container(
            height: rang.size.height - (rang.viewInsets.bottom + rang.size.height / 10) - (rang.size.height / 9),
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage("asset/chat_back1.jpg"), fit: BoxFit.cover)),
            child: SingleChildScrollView(
              child: isloading
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    )
                  : Container(
                      height: rang.size.height - (rang.viewInsets.bottom + rang.size.height / 10) - (rang.size.height / 9),
                      width: rang.size.width,
                      child: StreamBuilder(
                        stream:  _firestore.collection("chatroom").doc(chat_id).collection("chat").orderBy("time", descending: false).snapshots(),
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                             Timer(Duration(milliseconds: 100), () {
                               scrolltobottom();
                             });
                            return ListView.builder(
                              controller: sc,
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                return type_cha(chat_info : snapshot.data!.docs[index] ,  chatroomid : chat_id!,chat_id :  snapshot.data!.docs[index].id );
                              },
                            );
                          }else{
                            return Container();
                          }
                        },  
                      ) 
                    ),
            ),
          ),
        ],
      ),
    );
  }

  File? doc_file;
  Future DOC_FILE_PICK() async {
    
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowCompression: true,
      allowedExtensions: ["JPG"],
      type: FileType.custom,
      dialogTitle: "Pick Audio Files",

    );
    if(result != null){
      var size;

      setState(() {
        final path = result.files.first.path;
        doc_file = File(path!);
        size =  doc_file!.readAsBytesSync().length / (1024*1000);
      });
      upload_doc_file();
      log("File Size is : $size");
      
    }
  }
  Future upload_doc_file() async {
    if(doc_file == null){
      return null;
    }
    int status = 1;
    var filename = "DOC -"+Uuid().v1();
    log(filename);
    var file_size = doc_file!.lengthSync() / (1024*1024);
    var size_custom = file_size.toStringAsFixed(2);
    
    await _firestore.collection("chatroom").doc(chat_id).collection("chat").doc(filename).set(
      {
        "id": filename, 
        "sendy": _auth.currentUser!.displayName, 
        "message": "", 
        "name" : filename+".jpg",
        "duration" : "02:05",
        "type": "doc", 
        "time": DateTime.now(),
        "size" : "$size_custom MB"
      });
    var ref = FirebaseStorage.instance.ref().child("audio_file").child("$filename.jpg");
    var up_image = await ref.putFile(doc_file!).catchError((error) async {
      await _firestore.collection("chatroom").doc(chat_id).collection("chat").doc(filename).delete();
      status = 0;
    });
    if (status == 1) {
      String doc_url = await up_image.ref.getDownloadURL();
      await _firestore.collection("chatroom").doc(chat_id).collection("chat").doc(filename).update({"message": doc_url});
      print(doc_url);
    }
  }



 
  File? audio_file;
  Future AUD_FILE_PICK() async {
    
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowCompression: true,
      allowedExtensions: ["mp3"],
      type: FileType.custom,
      dialogTitle: "Pick Audio Files",

    );
    if(result != null){
      var size;

      setState(() {
        final path = result.files.first.path;
        audio_file = File(path!);
        int sizeinBYTE = audio_file!.lengthSync();
        size =  audio_file!.readAsBytesSync().length / (1024*1000);
        });
        if(size > 20){
          show_tost("Can't send Audio messages over 20 MB");
          // show_snak(context, 
          // "Can't send Audio messages over 16 MB");
        }else{
          upload_audio_file();

        } 
    }

  }
  bool upload_audio = false;
  Future upload_audio_file() async {
    if(audio_file == null){
      return null;
    }
    // setState(() {
    //   upload_audio = true;
    // });
    int status = 1;
    var filename = "AUD-"+Uuid().v1();
    log(filename);
    var file_size = audio_file!.lengthSync() / (1024*1024);
    var size_custom = file_size.toStringAsFixed(2);
    
    await _firestore.collection("chatroom").doc(chat_id).collection("chat").doc(filename).set(
      {
        "id": filename, 
        "sendy": _auth.currentUser!.displayName, 
        "message": "", 
        "name" : filename+".mp3",
        "duration" : "02:05",
        "type": "audio", 
        "time": DateTime.now(),
        "size" : "$size_custom MB"
      });
    var ref = FirebaseStorage.instance.ref().child("audio_file").child("$filename.jpg");
    var up_image = await ref.putFile(audio_file!).catchError((error) async {
      await _firestore.collection("chatroom").doc(chat_id).collection("chat").doc(filename).delete();
      status = 0;
    });
    if (status == 1) {
      String audio_url = await up_image.ref.getDownloadURL();
      await _firestore.collection("chatroom").doc(chat_id).collection("chat").doc(filename).update({"message": audio_url});
      print(audio_url);
    }
    // setState(() {
    //   upload_audio = false;
    // });
  }
  


  Future<bool> file_exists(doc, url) async{
   
    if(await File(local_directory_path  +"/"+doc).exists()){
      log("file exists ");
      setState(() {
        ex_file = false;
      });
      if(doc == null){
        return  false;
      }
      var link = local_directory_path +"/"+doc;
       Navigator.push(context, MaterialPageRoute(builder: (context)=>
          player_audio(link: link, )
          ));
      return true;

    }else{
      
      log("file not exists!! ");
      setState(() {
        ex_file = true;
      });
      File file_name = File(local_directory_path + "/" + doc );
      await Dio().download(
         url, 
         file_name.path,
         onReceiveProgress: (count, total) {
           setState(() {
              download_per = count / total * 100;
              
           });
         },
         
      ).catchError((error){
        Dio().delete(file_name.path);
      }).then((value) {
        setState(() {
          ex_file = false;
        });
      });
  

      return false;
    }

  }
  Widget show_modelsheet(MediaQueryData rang){
    return Container(
      height: rang.size.height / 3,
      width: rang.size.width,
     
      //color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 72, 72, 72),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              AUD_FILE_PICK();
                              Navigator.pop(context);
                              
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Color.fromARGB(255, 152, 58, 0),
                              child: Image.asset("asset/headphones.png" , scale: 15, color: Colors.white,),
                            ),
                          ),
                        ),
                        AutoSizeText("Audio", style: TextStyle(
                          color: Colors.white60
                        ),)
                      ],
                    ),
                    Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              image_picker(ImageSource.camera);
                              Navigator.pop(context);
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Color.fromARGB(255, 0, 106, 152),
                              child: Icon(Icons.camera_alt_outlined, color: Colors.white,),
                            ),
                          ),
                        ),
                        AutoSizeText("Camera", style: TextStyle(
                          color: Colors.white60
                        ),)
                      ],
                    ),
                    Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              image_picker(ImageSource.gallery);
                              Navigator.pop(context);
                              
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Color.fromARGB(255, 179, 1, 149),
                              child: Icon(Icons.photo, color: Colors.white,),
                            ),
                          ),
                        ),
                        AutoSizeText("Gallery", style: TextStyle(
                          color: Colors.white60
                        ),)
                      ],
                    )

                  ],
                ),
              ),
             // Padding(padding: EdgeInsets.all(10)),
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              DOC_FILE_PICK();
                              Navigator.pop(context);
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Color.fromARGB(255, 14, 108, 0),
                              child: Icon(Icons.edit_document, color: Colors.white,),
                            ),
                          ),
                        ),
                        AutoSizeText("Document", style: TextStyle(
                          color: Colors.white60
                        ),)
                      ],
                    ),
                    Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Color.fromARGB(255, 255, 40, 40),
                              child: Icon(Icons.person, color: Colors.white,),
                            ),
                          ),
                        ),
                        AutoSizeText("Contact", style: TextStyle(
                          color: Colors.white60
                        ),)
                      ],
                    ),
                    Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Color.fromARGB(255, 152, 58, 0),
                              child: Image.asset("asset/headphones.png" , scale: 15, color: Colors.white,),
                            ),
                          ),
                        ),
                        AutoSizeText("Audio", style: TextStyle(
                          color: Colors.white60
                        ),)
                      ],
                    )

                  ],
                ),
              ),
            
            
            ],
          ),
          
          
          
        ),
      )
      

    );

  }
}
