import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:friday_chat_app/Group_chat/chatroom_group.dart';
import 'package:friday_chat_app/Group_chat/group_add_search.dart';
import 'package:friday_chat_app/open_image.dart';
import 'package:friday_chat_app/shimmer.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';


class home_group extends StatefulWidget {
  const home_group({super.key});

  @override
  State<home_group> createState() => _home_groupState();
}

class _home_groupState extends State<home_group> {
  TextEditingController name = TextEditingController();
  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  bool isloading = true;
  ScrollController? sc;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sc = ScrollController();
    
  
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>group_add_search()));
           
        },
        child: Icon(Icons.add),
      ),
      body:
      Container(
        child: 
        StreamBuilder(
          stream: _firestore.collection("last_group").doc(_auth.currentUser!.uid).
            collection("group").orderBy("time" , descending: true).snapshots() ,
          //_firestore.collection("users").doc(_auth.currentUser!.uid).collection("groups").snapshots(),
          builder: (context, snapshot) {
           
           
            if(snapshot.hasData){
             
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {

                  final Timestamp timestamp =  snapshot.data!.docs[index]["time"] as Timestamp;
                  final DateTime dateTime =  timestamp.toDate();
                  final dateString = DateFormat('kk:mm a').format(dateTime);
                 
                
                  return StreamBuilder(
                    stream: _firestore.collection("groups").doc(snapshot.data!.docs[index]["group_id"]).snapshots(),
                    builder: (context, snap) {
                      
                      if(snap.hasData){
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Container(
                            
                            decoration: BoxDecoration(
                              color:Color.fromARGB(66, 188, 188, 188),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20))
                            ),
                              child: ListTile(
                                onTap: () async{
                                   Map<String , dynamic>? data ;
                                 
                                    Navigator.push(context, MaterialPageRoute(
                                    builder: ((context) => group_chatroom(
                                      group_id : snap.data!["id"],
                                      group_name : snap.data!["name"],
                                      group_image :snap.data!["image"]  
                                      ))));
                          
                                },
                                title: Text(snap.data!["name"] , style: TextStyle(
                                  fontSize: 15 ,overflow: TextOverflow.ellipsis,
                                    fontFamily: "SansFont" , fontWeight: FontWeight.w600)),
                                    subtitle: Text(snapshot.data!.docs[index]["message"] , overflow: TextOverflow.ellipsis),
                                leading: snap.data!["image"] == "" ? CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blueAccent,
                                    ) :
                                  InkWell(
                                    onTap: (){
                                      var url = snap.data!["image"] == "" ? blank_image : snap.data!["image"];
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>open_image(url: url,)));
                                    },
                                    child: CircleAvatar(
                                      radius: 30,
                                    
                                      backgroundImage: 
                                        NetworkImage(snap.data!["image"]),
                                    ),
                                  ),
                                 trailing: Text(dateString)
                              ),
                          ),
                        );

                      }else{
                        return Container();
                      }
                    
                    },
                  );
                
                },
              );
              

            }else{
              return shimmer_effect();
            }
           
            
          },
        )
      )
    );
  }
}