import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:friday_chat_app/navi_item/edit_profile.dart';
import 'package:friday_chat_app/open_image.dart';
import 'package:friday_chat_app/post/add_post.dart';
import 'package:friday_chat_app/post/setting_post/Allpost.dart';
import 'package:friday_chat_app/post/setting_post/show_post.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:lottie/lottie.dart';

class profile_user extends StatefulWidget {
  const profile_user({super.key});

  @override
  State<profile_user> createState() => _profile_userState();
}

class _profile_userState extends State<profile_user> {
  FirebaseFirestore _store = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () => onbackbutton(context),
      child: SafeArea(
        top: true,
        child: Scaffold(
          body: Container(
            height: size.height,
            width: size.width,
            child: Column(
              children: [
               
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      
                      child: StreamBuilder(
                        stream: _store.collection("users").doc(_auth.currentUser!.uid).snapshots(),
                        builder: (context, snaps) {
                          if(snaps.hasData){
                            return Container(
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          flex: 2,
                                          child:
                                          Container(
                                            
                                            child: InkWell(
                                              onTap: (){
                                                Navigator.push(context, MaterialPageRoute(builder: (context)=>open_image(url: snaps.data!["image"],)));
                                              },
                                              child: CircleAvatar(
                                                radius: 46,
                                                backgroundColor: Color.fromARGB(255, 0, 68, 1),
                                                child: Hero(
                                                  tag: "imageOpen",
                                                  child: CircleAvatar(
                                                    radius: 44,
                                                    backgroundColor: Colors.white,
                                                    backgroundImage: NetworkImage(snaps.data!["image"])
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: size.width / 20),
                  
                                        Flexible(
                                          flex: 3,
                                          child: Container(
                                           
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  
                                                  //width: size.width / 1.8,
                                                  child: Text(
                                                    snaps.data!["name"] == "" ? "Update Name" : snaps.data!["name"],
                                                    style: TextStyle(fontSize: 25, fontFamily: "SansFont", fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                                                  ),
                                                ),
                                                snaps.data!["nick_name"] != "" ?  Container(
                                                 // width: size.width / 1.8,
                                                  child: Text(snaps.data!["nick_name"] == "" ? "Update Nick Name" : snaps.data!["nick_name"], style: TextStyle(fontSize: 15, fontFamily: "SansFont", fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis)),
                                                ) : SizedBox(),
                                                
                                        
                                        
                                        
                                              ],
                                            ),
                                          ),
                                        ),
                                        
                                        Flexible(
                                          flex: 1,
                                          child: Container(
                                            
                                            alignment: Alignment.bottomRight,
                                            child: CircleAvatar(
                                              backgroundColor: Color.fromARGB(255, 37, 88, 38),
                                              child: IconButton(
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => edit_profile()));
                                                },
                                                icon: Icon(Icons.edit ,color: Colors.white,)
                                              ),
                                            )
                                          
                                          ),
                                        )
                                       
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        snaps.data!["phone"] != "" ? Container(
                                          padding: EdgeInsets.only(right: 10, left: 20),
                                          height: size.height / 25,
                                          child: Row(
                                            children: [
                                              Icon(Icons.phone),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Text(
                                                  snaps.data!["phone"] == "" ? "update phone" : snaps.data!["phone"],
                                                  style: TextStyle(color: Colors.black54),
                                                ),
                                              )
                                            ],
                                          ),
                                        ) : Container(),
                                        snaps.data!["email"] != "" ? Container(
                                          padding: EdgeInsets.only(right: 10, left: 20),
                                          height: size.height / 25,
                                          child: Row(
                                            children: [
                                              Icon(Icons.email),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Text(
                                                  snaps.data!["email"] == "" ? "update email" : snaps.data!["email"],
                                                  style: TextStyle(color: Colors.black54),
                                                ),
                                              )
                                            ],
                                          ),
                                        ): Container(),
                                      ],
                  
                                    ),
                                  )
                                 
                                
                                ],
                              ),
                  
                            );
                          }else{
                            return Container();
                          }
                          
                        },
                      ) ,
                     
                    ),
                  ),
                ),
                //SizedBox(height: size.height / 30,),
                Card(
                  child: Container(
                    child: StreamBuilder(
                      stream:  _store.collection("contacts").doc(_auth.currentUser!.uid).collection("lastonline").orderBy("email", descending: true).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data!.docs.length >  0 ? 
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Your Frieds",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "SansFont"),
                                  )),
                              Container(
                               height: size.height / 5.8,
                                child: Container(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      return StreamBuilder(
                                        stream: _store.collection("users").doc(snapshot.data!.docs[index]["uid"]).snapshots(),
                                        builder: (context, snap) {
                                          if (snap.hasData) {
                                            return Container(
                                              width: size.width / 4,
                                              child: Container(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 42,
                                                      backgroundColor: Color.fromARGB(255, 7, 93, 1),
                                                      child: CircleAvatar(
                                                        radius: 40,
                                                        // backgroundColor: Colors.greenAccent,
                                                        backgroundImage: snap.data!["image"] == ""
                                                            ? NetworkImage("https://images.unsplash.com/photo-1668530933925-a57e8424cda0?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=764&q=80")
                                                            : NetworkImage(snap.data!["image"]),
                                                      ),
                                                    ),
                                                    Text(snap.data!["name"])
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            
                            ],
                          ) : Container();
                        } else {
                          return Container();
                        }
                        
                      },
                    ),
                  ),
                ),
                Card(
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Text(
                          "Your Post",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "SansFont"),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => allpost(),));
                          
                          }, 
                          icon: Icon(Icons.more_horiz)
                        )
                      ],
                    )
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Container(
                      child: StreamBuilder(
                        stream: _store.collection("post").doc(FirebaseAuth.instance.currentUser!.uid).collection("story").orderBy("time", descending: true).snapshots() ,
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            return   GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => show_post(postid: snapshot.data!.docs[index]["post_id"], userid: snapshot.data!.docs[index]["user_id"]),));
                                    },
                                    child: Container( 
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
                                  )
                                );
                              
                              },
                            );
                          }else{
                            return Container(
                            );
                          }
                          
                          
                        },
                      )
                     
                    ),
                  ),
                )
            
               
    
              ],
            ),
    
          ),
          
        ),
      ),
    );
  }
}