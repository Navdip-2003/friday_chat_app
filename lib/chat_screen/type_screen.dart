import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:friday_chat_app/advance_feature/audio_player.dart';
import 'package:friday_chat_app/advance_feature/player_audio.dart';
import 'package:friday_chat_app/methods.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:friday_chat_app/open_image.dart';
  import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

  class type_screen extends StatefulWidget {
    String chatroomid;
    type_screen({super.key, required this.chatroomid});

    @override
    State<type_screen> createState() => _type_screenState();
  }

  class _type_screenState extends State<type_screen> {
    
    var _firestore = FirebaseFirestore.instance;
    var db_chatrrom = FirebaseFirestore.instance.collection("chatroom").doc("OPElQEDKCpZsFMu9RL37O5Gswzu2Ikw2p5ry0WceDSK606Dzz6VmtR22").collection("chat");
    
  
    
    
    void init() async{
      var datenow = DateFormat("d MMMM y").format(DateTime.now());
      log("$datenow");
      await db_chatrrom.where("message" , isEqualTo: datenow ).get().then((value){
        if(value.docs.isEmpty){
          db_chatrrom.add({
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
    @override
    void initState() {
      // TODO: implement initState
      super.initState();
      init();
    }
    @override
    Widget build(BuildContext context) {
       
      return StreamBuilder(
          stream:  _firestore.collection("chatroom").doc(widget.chatroomid).collection("chat").orderBy("time", descending: false).snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return
                   type_cha(chat_info : snapshot.data!.docs[index] ,  chatroomid : widget.chatroomid, chat_id: "",);
                },
              );
            }else{
              return Container();
            }
          },  
        );
      
    }
  }

  class type_cha extends StatefulWidget {
    QueryDocumentSnapshot<Map<String, dynamic>> chat_info;
    String chatroomid;
    String chat_id;
    type_cha({super.key, required this.chat_info, required this.chatroomid, required this.chat_id });

    @override
    State<type_cha> createState() => _type_chaState();
  }
  class _type_chaState extends State<type_cha> {
    bool chatbubble = false;
    var _auth = FirebaseAuth.instance;
    bool sc = true;
    double downloadProgress = 0.0;
    bool isDownloadStarted = false;
    bool isDownloadFinish = false;

    @override
    void initState() {
      // TODO: implement initState
      super.initState();
    
    }
 
    @override
    Widget build(BuildContext context) {
      var _firebase = FirebaseFirestore.instance;
    var data = widget.chat_info.data();
    var type = data["type"];
    final Timestamp timestamp = data["time"] as Timestamp;
    final DateTime dateTime = timestamp.toDate();
    final dateString = DateFormat('kk:mm a').format(dateTime);
    var check_now_date = DateFormat('d MMMM y').format(DateTime.now());
    var size = MediaQuery.of(context).size;
      
      //return type(widget.chat_info.data() , MediaQuery.of(context).size);
      if(type == "text"){
        return Column(
          children: [
            Container(
              width: size.width,
              alignment:data['sendy'] == _auth.currentUser!.displayName ? Alignment.centerRight : Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  ontapped();
                  
                },
                onDoubleTap: () {
                  _firebase.collection("chatroom").doc(widget.chatroomid).collection("chat").doc(widget.chat_id).delete().then((value) {
                    log("deleteChat done !!");
                  });
                },
                
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  margin: EdgeInsets.symmetric(
                    horizontal: 13,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: data["message"].length > 2
                        ? BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(0), topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
                        : BorderRadius.only(topRight: Radius.circular(0), bottomRight: Radius.circular(15), topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
                    gradient: data['sendy'] == _auth.currentUser!.displayName
                        ? LinearGradient(colors: [Color.fromARGB(255, 45, 83, 137), Color.fromARGB(255, 50, 114, 44)])
                        : LinearGradient(colors: [Color.fromARGB(255, 50, 114, 44), Color.fromARGB(255, 45, 83, 137)]),
                  ),
                  child: Column(
                    children: [
                     // if (data["sendy"] != _auth.currentUser!.displayName) Text("~: " + data["sendy"], style: TextStyle(fontSize: 8, color: Color.fromARGB(255, 208, 208, 208))),
                      Text(
                        data['message'],
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
             chatbubble ?  Container(
                padding: EdgeInsets.only(top: 1),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                alignment: data['sendy'] == _auth.currentUser!.displayName ? Alignment.centerRight : Alignment.centerLeft,
                //color: Colors.blueAccent,
                width: size.width,
                child: Text(
                  dateString,
                  style: TextStyle(fontSize: 9, color: Colors.black45),
                ),
              ) : SizedBox() ,
            SizedBox(height: 4)
          ],
        );
      }else if(type == "notify"){
        return Column(
         children: [
           Container(
             width: size.width,
             alignment: Alignment.center,
             child: Container(
               padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
               margin: EdgeInsets.symmetric(
                 horizontal: 5,
               ),
               decoration: BoxDecoration(
                   border: Border.all(color: Color.fromARGB(95, 198, 198, 198), width: 1.5),
                   borderRadius: BorderRadius.circular(7),
                   color: Color.fromARGB(255, 225, 224, 224)
                   ),
               child: Text(
                 data['message'] == check_now_date ? "Today" : data["message"],
                 style: TextStyle(
                     fontFamily: "SansFont.ttf",
                     //fontWeight: FontWeight.w600 ,
                     fontSize: 11,
                     color: Color.fromARGB(255, 17, 17, 17)),
               ),
             ),
           ),
           SizedBox(height: 9)
         ],
       );
      }else if(type == "img"){
        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              height:size.height / 4.4,
              width: size.width,
              alignment: data["sendy"] == _auth.currentUser!.displayName ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                height: size.height / 4.3,
                width: size.width / 2.6,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                 
                    //snapshot.data!.docs[index]['message']
                    ),
                child: data['message'] != ""
                    ? GestureDetector(
                        onTap: () {
                           file_circular(data["message"] , data["name"], data["type"] );

                          // Navigator.push(context, MaterialPageRoute(builder: (context) => open_image(url: data['message'])));
                        },
                        onDoubleTap: (){
                          _firebase.collection("chatroom").doc(widget.chatroomid).collection("chat").doc(widget.chat_id).delete().then((value) {
                            log("delete message Done ..");
                          });
                          
                        },
                        child: Container(
                          padding: EdgeInsets.all(3),
                            height: size.height,
                            width: size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: data['sendy'] == _auth.currentUser!.displayName ? 
                                LinearGradient(
                                  colors: 
                                    [Color.fromARGB(255, 45, 83, 137), Color.fromARGB(255, 50, 114, 44)]
                                ) :
                                LinearGradient(
                                  colors: 
                                    [ Color.fromARGB(255, 50, 114, 44) , Color.fromARGB(255, 45, 83, 137)]
                                )
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: isDownloadStarted ?
                                Center(child: CircularProgressIndicator(),) :  
                               Image.network(
                                 data['message'],
                                 fit: BoxFit.cover,
                               ),
                            )),
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              alignment: data['sendy'] == _auth.currentUser!.displayName ? Alignment.centerRight : Alignment.centerLeft,
              //color: Colors.blueAccent,
              width: size.width,
              child: Text(
                dateString,
                style: TextStyle(fontSize: 10, color: Colors.black45),
              ),
            ),
            SizedBox(height: 5)
          ],
        );
      }else if(type == "audio"){
        return Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Container(
               padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
               alignment: data["sendy"] == _auth.currentUser!.displayName ? Alignment.centerRight : Alignment.centerLeft,
               child: Container(
                 decoration: BoxDecoration(
                   color: Colors.grey.shade500,
                   borderRadius: BorderRadius.only(
                     topLeft: Radius.circular(20) ,
                     topRight: Radius.circular(5) ,
                     bottomLeft: Radius.circular(30) , 
                     bottomRight: Radius.circular(30)
                   )
                 ),
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Flexible(
                       flex: 3,
                       child: Container(
                         padding: EdgeInsets.only(left: 10, top: 5 , bottom: 5),
                         child: InkWell(
                           onTap: () async {
                            if( data["message"] != "" && downloadProgress == 0.0){
                              file_circular(data["message"] , data["name"], data["type"] );
                            }
                           },
                            onDoubleTap: () {
                              _firebase.collection("chatroom").doc(widget.chatroomid).collection("chat").doc(widget.chat_id).delete().then((value) {
                                log("deleteChat done !!");
                              });
                            },
                           child: CircleAvatar(
                             maxRadius: 30,
                             minRadius: 21,
                             backgroundColor: Colors.redAccent,
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Image.asset("asset/headphones.png" , scale: 20, color: Colors.white,),
                                 Container(
                                   padding: EdgeInsets.all(4),
                                   child: AutoSizeText(data['duration'] , maxFontSize: 13, minFontSize: 8,
                                     style: TextStyle(color: Colors.white),
                                   ),
                                 )
                               ],
                             ),
                           ),
                         ),
                       ),
                     ),
                     Flexible(
                       flex: 2,
                       child: Container(
                         padding: EdgeInsets.only(top: 10 , bottom: 10 , left: 10 , right: 10),
                         child: Column(
                           children: [
                             Container(
                               child: AutoSizeText(data['name'] , 
                               overflow: TextOverflow.ellipsis,maxLines: 2, 
                                 style: TextStyle(
                                   color: Colors.grey.shade200
                                 ),
                               ),
                             ),
                             Container(
                               alignment: Alignment.bottomRight,
                               child: AutoSizeText(data['size'] , 
                               maxFontSize: 10,
                               minFontSize: 4,
                               overflow: TextOverflow.ellipsis,maxLines: 1, 
                                 style: TextStyle(
                                   fontWeight: FontWeight.w300,
                                   color: Colors.grey.shade200
                                   
                                 ),
                               ),
                             ),

                             data['message'] == "" ? Container(
                               child: AutoSizeText("Sending..." , 
                               maxFontSize: 8,
                               minFontSize: 5,
                               overflow: TextOverflow.ellipsis,maxLines: 1, 
                                 style: TextStyle(
                                   color: Colors.grey.shade200
                                 ),
                               ),
                             ) : SizedBox(),
                           ],
                         ),
                       ),
                     ),
                     Visibility(
                       visible: isDownloadStarted,
                       child: Flexible(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularPercentIndicator(
                            
                            radius: 18.0,
                            lineWidth: 4.0,
                            percent: (downloadProgress/100),
                            center: Text(
                              "${downloadProgress.toStringAsFixed(0)}%",
                              style: const TextStyle(fontSize: 10, color: Color.fromARGB(255, 140, 0, 0)),
                            ),
                            progressColor: Color.fromARGB(255, 0, 104, 26),
                          ),
                        )
                                         ),
                     )
                   ],
                 ),
               ),
             ),
             Container(
               margin: EdgeInsets.symmetric(horizontal: 16),
               alignment: data['sendy'] == _auth.currentUser!.displayName ? Alignment.centerRight : Alignment.centerLeft,
               //color: Colors.blueAccent,
               width: size.width,
               child: Text(
                 dateString,
                 style: TextStyle(fontSize: 10, color: Colors.black45),
               ),
             ),
             SizedBox(height: 5)
           ],
         );
      }else if(type == "doc"){
        return Column(
          children: [
            Container(
               padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
               alignment: data["sendy"] == _auth.currentUser!.displayName ? Alignment.centerRight : Alignment.centerLeft,
               child: Container(
                 decoration: BoxDecoration(
                   color: Colors.grey.shade500,
                   borderRadius: BorderRadius.only(
                     topLeft: Radius.circular(20) ,
                     topRight: Radius.circular(20) ,
                     bottomLeft: Radius.circular(30) , 
                     bottomRight: Radius.circular(5)
                   )
                 ),
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Flexible(
                       flex: 4,
                       child: Container(
                         padding: EdgeInsets.only(left: 10, top: 5 , bottom: 5),
                         child: InkWell(
                           onTap: () async {
                            if( data["message"] != "" && downloadProgress == 0.0){
                              file_circular(data["message"] , data["name"], data["type"] );
                            }
                           },
                            onDoubleTap: () {
                              _firebase.collection("chatroom").doc(widget.chatroomid).collection("chat").doc(widget.chat_id).delete().then((value) {
                                log("deleteChat done !!");
                              });
                            },
                           child: CircleAvatar(
                             maxRadius: 30,
                             minRadius: 21,
                             backgroundColor: Color.fromARGB(182, 83, 31, 98),
                             child: Container(
                              padding: EdgeInsets.all(15),
                              child: Image.asset("asset/docs.png" , color: Colors.white,))
                           ),
                         ),
                       ),
                     ),
                     Flexible(
                       flex: 2,
                       child: Container(
                         padding: EdgeInsets.only(top: 10 , bottom: 10 , left: 10 , right: 10),
                         child: Column(
                           children: [
                             Container(
                               child: AutoSizeText("IMG_202121_302010.JPG" , 
                               overflow: TextOverflow.ellipsis,maxLines: 2, 
                                 style: TextStyle(
                                   color: Colors.grey.shade200
                                 ),
                               ),
                             ),
                             Container(
                               alignment: Alignment.bottomLeft,
                               child: AutoSizeText(data['size'] , 
                               maxFontSize: 10,
                               minFontSize: 4,
                               overflow: TextOverflow.ellipsis,maxLines: 1, 
                                 style: TextStyle(
                                   fontWeight: FontWeight.w300,
                                   color: Colors.grey.shade200
                                   
                                 ),
                               ),
                             ),

                             data['message'] == "" ? Container(
                               child: AutoSizeText("Sending..." , 
                               maxFontSize: 8,
                               minFontSize: 5,
                               overflow: TextOverflow.ellipsis,maxLines: 1, 
                                 style: TextStyle(
                                   color: Colors.grey.shade200
                                 ),
                               ),
                             ) : SizedBox(),
                           ],
                         ),
                       ),
                     ),
                     Visibility(
                       visible: isDownloadStarted,
                       child: Flexible(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularPercentIndicator(
                            
                            radius: 18.0,
                            lineWidth: 4.0,
                            percent: (downloadProgress/100),
                            center: Text(
                              " ${downloadProgress.toStringAsFixed(0)}% ",
                              style: const TextStyle(fontSize: 10, color: Color.fromARGB(255, 40, 40, 40)),
                            ),
                            progressColor: Color.fromARGB(255, 136, 87, 182),
                          ),
                        )
                                         ),
                     )
                   ],
                 ),
               ),
             ),
             Container(
               margin: EdgeInsets.symmetric(horizontal: 16),
               alignment: data['sendy'] == _auth.currentUser!.displayName ? Alignment.centerRight : Alignment.centerLeft,
               //color: Colors.blueAccent,
               width: size.width,
               child: Text(
                 dateString,
                 style: TextStyle(fontSize: 10, color: Colors.black45),
               ),
             ),
          ],

        );
      }
      else{
        return Container();
      }
    }
    void ontapped() async{
      try{
        if(chatbubble){
          chatbubble = false;
    
          setState(() {});
        }else{
          chatbubble = true;
          setState(() {});
          await Future.delayed(Duration(seconds: 5)).whenComplete(() {
            setState(() {
              chatbubble = false;
            });
          });
        }
      }catch(e){
        print(e);
        
      }
    }

    Future<void> file_circular( link, file_name, type) async{
      SharedPreferences share = await SharedPreferences.getInstance();
      String? loc_path = share.getString("loc_path");
      if(loc_path == null){
        await Storage_create_folder();
      }
      if(await Directory(loc_path!).exists()){
        if(await File(loc_path + "/" +file_name).exists()){
          if(type == "audio"){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> player_audio(link: (loc_path+"/"+file_name))));
          }else if(type == "img"){
            Navigator.push(context, MaterialPageRoute(builder: (context) => open_image(url: (loc_path+"/"+file_name))));
          }else if(type == "doc"){
            Navigator.push(context, MaterialPageRoute(builder: (context) => open_image(url: (loc_path+"/"+file_name))));
          }
        }else{
          download_file(file_name , loc_path , link );
        }
      }else{
        log("folder does not exist");
        await create_loc_directory();
      }
    }
    void download_file( file_name,  loc_path, link) async{
      File file = File(loc_path + "/" + file_name);
      isDownloadStarted = true;
      isDownloadFinish = false;
      
      setState(() {});

      await Dio().download(
         link, 
         file.path,
         onReceiveProgress: (count, total) {
           setState(() {
              downloadProgress = (count / total) * 100;
           });
         },
      ).whenComplete(() {
        setState(() {
          isDownloadFinish = true;
          isDownloadStarted = false;
          downloadProgress = 0.0;
        });
      });
    }
  }
  
 
 


