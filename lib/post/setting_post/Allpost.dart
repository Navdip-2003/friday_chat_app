import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:friday_chat_app/post/setting_post/show_post.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class allpost extends StatefulWidget {
  const allpost({super.key});

  @override
  State<allpost> createState() => _allpostState();
}

class _allpostState extends State<allpost> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(

        top: true,
        child:Column(
          children: [
            Container(
              color: Colors.black26,
              padding: EdgeInsets.only(left: 10 , bottom: 5),
              alignment: Alignment.centerLeft,
              child: Text("Your Post" , style: TextStyle(
                fontFamily: "Paci", fontSize: 20
              ),),
            ),
            Expanded(
              child: Container(
                
                
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("post").doc(FirebaseAuth.instance.currentUser!.uid).collection("story").orderBy("time", descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Container(
                            padding: EdgeInsets.all(5),
                            child: GridView.builder(
                              
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data!.docs.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), 
                              itemBuilder: (context, index) {
                                final Timestamp timestamp = snapshot.data!.docs[index]["time"] as Timestamp;
                                final DateTime dateTime = timestamp.toDate();
                                final dateString = DateFormat('kk:mm a').format(dateTime);
                                getTime(time) {
                                  if (DateTime.now().difference(time).inMinutes < 2) {
                                    return "Now";
                                  } else if (DateTime.now().difference(time).inMinutes < 60) {
                                    return "${DateTime.now().difference(time).inHours} Min ago";
                                  } else if (DateTime.now().difference(time).inMinutes < 1440) {
                                    return "${DateTime.now().difference(time).inHours} Hours ago";
                                  } else if (DateTime.now().difference(time).inMinutes > 1440) {
                                    return "${DateTime.now().difference(time).inDays} Day ago";
                                  }
                                }
                                  
                                var diff_time = getTime(dateTime);
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: InkWell(
                                    onTap: (){
                                      Navigator.push(context,MaterialPageRoute(builder: (context) =>show_post(postid: snapshot.data!.docs[index]["post_id"], userid: snapshot.data!.docs[index]["user_id"]),));
                                    },
                                    child: Stack(
                                      children: [
                                        Container( 
                                          child: CachedNetworkImage(
                                            height: size.height / 3,
                                            imageBuilder: (context, imageProvider) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  image: DecorationImage(image: imageProvider , fit: BoxFit.cover) , 
                                                ),
                                              );
                                            },
                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                            placeholder: (context, url) => Center(child: Lottie.asset("asset/image_loading.json", width: size.width / 7, height: size.height)),
                                            fit: BoxFit.cover,
                                            imageUrl: snapshot.data!.docs[index]["post"],
                                          ),
                                                  
                                        ),
                                        Positioned(
                                          top: 3,
                                          right: 5,
                                          child: Text(diff_time!, style: TextStyle(fontWeight: FontWeight.bold ,color: Color.fromARGB(255, 122, 134, 131)),))
                                    
                                      ],
                                    )
                                
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }else{
                      return Container();
                    }
                    
                  },
                )
            
              ),
            ),
          ],
        ) 
      ),
    );
  }
}