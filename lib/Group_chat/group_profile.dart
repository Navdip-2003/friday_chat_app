

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friday_chat_app/Group_chat/screen_inprofile/change_subject.dart';
import 'package:friday_chat_app/Group_chat/screen_inprofile/member_add.dart';
import 'package:friday_chat_app/chatroom.dart';
import 'package:friday_chat_app/contact.dart';
import 'package:friday_chat_app/data_search.dart';
import 'package:friday_chat_app/home_demo.dart';
import 'package:friday_chat_app/navigation.dart';
import 'package:friday_chat_app/popmenu_chatrom/chat_profile.dart';
import 'package:friday_chat_app/single_chat.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
class group_profile extends StatefulWidget {
  String groupid;
  String groupname;
  String groupimage;
  group_profile({super.key, required this.groupid, required this.groupname, required this.groupimage});

  @override
  State<group_profile> createState() => _group_profileState(groupid , groupimage , groupname);
}

class _group_profileState extends State<group_profile> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String groupid;
  String groupname;
  String groupimage;
  _group_profileState(this.groupid, this.groupimage, this.groupname);
  var snak = SnackBar(
    duration: Duration(seconds: 2),
    content: Text('Do not add members because You are Not Admin !!'));

  

  void tap_view(member)  async{
      var usermap;
      await _firestore.collection("users").doc(member).get().then((value) {
        usermap = value.data();
      });
      Navigator.push(context, MaterialPageRoute(builder: (context)=>
        chat_profile(usermap: usermap)));
  }


  void tap_chat(uid,memberid)async{
    isloading = true;
    String chatid = get_chatid(uid, memberid);
    print(chatid);
    var usermap;
    
    await _firestore.collection("users").doc(memberid).get().then((value) {
        usermap = value.data();
      }).then((value) {
        setState(() {
          isloading = false;
          Navigator.push(context, MaterialPageRoute(builder: 
            (context)=>chatroom(chat_id: chatid, usermap: usermap)));
        });
       
      });
    

  }
  ImagePicker _picker = ImagePicker();
  File? pick_image;
  Future image_picker(ImageSource soc) async{
    XFile? image = await _picker.pickImage(source: soc );
    if(image != null){
      setState(() {
        pick_image = File(image.path);
        Navigator.pop(context);
        upload_image();
      });
    }
  }
  
  Future upload_image() async {
    upload_image_loading = true;
    int status = 1;
    var filename = Uuid().v1();
    var ref = FirebaseStorage.instance.ref().child("profile_image").child("$filename.jpg");
    var up_image = await ref.putFile(pick_image!).catchError((error) async{
        print("image is not updated");
        status = 0;
    });
    if(status == 1){
      String image_url = await up_image.ref.getDownloadURL();
      print(image_url);
      
      
      await _firestore.collection("groups").doc(groupid).update({
        "image" : image_url
      }).then((value) {
        setState(() {
          upload_image_loading = false;
          
        });
      });  

    }
  }
    

  bool upload_image_loading = false;
  bool isloading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      
      body: isloading ? Center(child: CircularProgressIndicator(),) : 
      SingleChildScrollView(
        child: StreamBuilder(
          stream: _firestore.collection("groups").doc(groupid).snapshots(),
          builder: (context,AsyncSnapshot snapshot) {
            if(snapshot.hasData){
              List member = snapshot.data!["members"];
              int adminlength = 0;
              int member_index(){
                var val;
                for(int i = 0;i < member.length; i++){
                  if(member[i]["uid"] == _auth.currentUser!.uid){
                    setState(() {
                      val = i;
                    });
                  }
                }
                return val;
              }
              int count_admin(){
                 for(int i = 0; i < member.length ; i++){
                    if(member[i]["isadmin"] == true){
                      setState(() {
                        adminlength ++;
                      });
                    }
                  }
                  return adminlength;
              }
              bool checkadmin() {
                bool admin = false;
                member.forEach((element) {
                  if(element["uid"] == _auth.currentUser!.uid){
                    setState(() {
                      admin = element["isadmin"];
                    });
                  }
                });
                return admin;
              }
              
              return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(height: size.height / 30,),
                  Padding(
                    padding: const EdgeInsets.only(),
                    child: Container(
                      child: Row(
                        children: [
                          IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back , color: Colors.black,),
                        ),
                        Expanded(child: Container()),
                        PopupMenuButton(
            
                          icon: Icon(Icons.more_vert , color:Colors.black54,),
                          onSelected: ((value) {
                        
                              if(value == "change"){
                                
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>change_subject(name : snapshot.data!["name"]  , id : snapshot.data!["id"] )));
                              }else if(value == "add"){
                                if(checkadmin()){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>member_add(
                                    alredy_member : member , groupid: groupid , gropname : groupname)));
                                }else{
                                  ScaffoldMessenger.of(context).showSnackBar(snak);
                                }
                              }
                            }),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                value: "change",
                                child: Text("Change subject"),
                              ),
                              PopupMenuItem(
                                value: "add",
                                child: Text("Add participants"),
                              )
                            ];
                          },
                        )
      
                        ],
                      ),
                    ),
                  ),
                 
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10, left: 10),
                      child: Container(
                        
                        height: size.height / 8,
                        //color: Colors.yellowAccent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 1,
                              child: upload_image_loading == true ? Center(child: CircularProgressIndicator(),) :
                               Container(
                                //color: Colors.redAccent,
                                child: InkWell(
                                  onTap: (){
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (Builder){
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            
                                          ),
                                          
                                          height: size.height / 5,
                                          child: Container(
                                            child: Column(
                                              
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text("Choose Profile Photo" , style: (TextStyle(
                                                  fontSize: 18, fontWeight: FontWeight.w500
                                                  
                                                )),),
                                                Padding(
                                                  padding: const EdgeInsets.all(30),
                                                  child: Container(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        InkWell(
                                                          onTap: (){
                                                            image_picker(ImageSource.camera);
                        
                                                          },
                                                          child: Container(
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.camera),
                                                                SizedBox(width: size.width / 55,),
                                                                Text("Camera")
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: size.width / 20,),
                                                        InkWell(
                                                          onTap: (){
                                                            image_picker(ImageSource.gallery);
                                                          },
                                                          child: Container(
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.image),
                                                                SizedBox(width: size.width / 55,),
                                                                Text("Gallery")
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                        
                                                  ),
                                                )
                        
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 46,
                                    backgroundColor: Color.fromARGB(255, 16, 96, 0),
                                    child: CircleAvatar(
                                      radius: 45,
                                      backgroundImage: 
                                      groupimage == "" ? 
                                        NetworkImage("https://images.unsplash.com/photo-1667480185404-42b2d11af650?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwyMHx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60"):
                                        NetworkImage(snapshot.data!["image"]),
                                      //backgroundColor: Colors.pinkAccent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.only(left: 15),
                                //color: Colors.greenAccent,
                                
                                alignment: Alignment.centerLeft,
                                child: Text(snapshot.data["name"] , overflow: TextOverflow.ellipsis,style: 
                                  TextStyle(fontFamily: "SansFont" , fontSize: 20, fontWeight: FontWeight.w600
                                  ),
                                ),
                              ),
                            ),
                          ],
                        
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height / 70,),
                 // Divider(color: Color.fromARGB(255, 221, 221, 221), thickness: 2),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      height: size.height / 9,
                      //color: Colors.pinkAccent,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                           
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: (){
                  
                                    if(checkadmin()){
                                       Navigator.push(context, MaterialPageRoute(builder: (context)=>member_add(
                                      alredy_member : member , groupid: groupid , gropname : groupname)));
                                    }else{
                                      ScaffoldMessenger.of(context).showSnackBar(snak);
                                    }
                                    
                                   
                                  },
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor:  Colors.blueGrey,
                                    child: Icon(Icons.person_add , color: Colors.white,),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text("Add", textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),
                                )
                              ],
                            ),
                            SizedBox(width: size.width / 20,),
                            Column(
                              
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor:  Colors.blueGrey,
                                    child: Icon(Icons.message , color: Colors.white,),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text("Chat", textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),
                                )
                              ],
                            ),
                          ],
                        ),
                        
                      ),
                    ),
                  ),
                 // Divider(color: Color.fromARGB(255, 221, 221, 221), thickness: 2),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      padding: EdgeInsets.only(left: 10 , top: 5),
                      alignment: Alignment.centerLeft,
                      //color: Colors.deepOrange,
                                  
                      child: Text("${member.length}  participants" ,style: TextStyle(
                        fontSize: 15
                      ),),
                    ),
                  ),
                
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      //color: Colors.lightBlue,
                      height: 
                        //member.length > 4 ?  
                          size.height / 2.1
                          //1.8
                          ,
                        // : 
                        // size.height / 2.3,
                        child: ListView.builder(
                      itemCount: member.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: (){
                            if(checkadmin()){
                                  if(member[index]["uid"] != _auth.currentUser!.uid){
                                      showDialog(
                                      context: context,
                                      builder: (context) => Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Center(
                                          
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              color: Colors.white,
                                            ),
                                            width: size.width / 1.3 ,
                                            height: size.height / 4,
                                            child: Column(
                                              children: [
                                                TextButton(
                                                  onPressed: (){
                                                    tap_chat(_auth.currentUser!.uid ,
                                                      member[index]["uid"]);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Meassage  ${member[index]["name"]}", style: TextStyle(),)
                                                ),
                                                TextButton(
                                                  onPressed: () async{
                                                    tap_view(member[index]["uid"]);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("View  ${member[index]["name"]}")
                                                ),
                                                //remove group
                                                TextButton(
                                                  child: Text("Remove Group"),
                                                  onPressed: (){
                                                     
                                                    Navigator.pop(context);
                                                    showDialog(
                                                      context: context, 
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          content: Text("Remove  from \"$groupname\" group"),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: (){
                                                                Navigator.pop(context);
                                                              },
                                                              child: Text("Cancel")
                                                            ),
                                                            TextButton(
                                                              onPressed: () async{
                                                                Navigator.pop(context);
                                                                isloading = true;
                                                                await _firestore.collection("last_group").doc(member[index]["uid"]).
                                                                  collection("group").doc(groupid).delete();
                                                                member.removeAt(index);
                                                                await _firestore.collection("groups").doc(groupid).update({
                                                                  "members" : member
                                                                });
                                                                await _firestore.collection("users").doc(member[index]["uid"]).collection("groups").doc(groupid).delete().then((value) {
                                                                  print("user remove done !");
                                                                  isloading = false;
                        
                                                                });
                                                                
                                                                
                                                                
                        
                                                              },
                                                              child: Text("Ok")
                                                            ),
                                                            
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  
                                                ),
                                                
                                                //Make admin and Remove admin
                                                member[index]["isadmin"] == false ? 
                                                TextButton(
                                                  onPressed: () async{
                                                    isloading = true;
                                                    member[index]["isadmin"] = true;
                                                    await _firestore.collection("groups").doc(groupid).update({
                                                      "members" : member
                                                    }).then((value) {
                                                      setState(() {
                                                        isloading = false;
                                                        Navigator.pop(context);
                                                      });
                                                    });
                                                  },
                                                  child: Text("Make Group Admin")
                                                ) : 
                                                TextButton(
                                                  onPressed: () async{
                                                    isloading = true;
                                                    member[index]["isadmin"] = false;
                                                    await _firestore.collection("groups").doc(groupid).update({
                                                      "members" : member
                                                    }).then((value) {
                                                      setState(() {
                                                        isloading = false;
                                                        Navigator.pop(context);
                                                      });
                                                    });
                                                  },
                                                  child: Text("Remove Group Admin")
                                                ),
                                              
                        
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                        
                                  }
                            }
                            if(!checkadmin()){
                              if(member[index]["uid"] != _auth.currentUser!.uid){
                                      showDialog(
                                      context: context,
                                      builder: (context) => Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Center(
                                          
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              color: Colors.white,
                                            ),
                                            width: size.width / 1.3 ,
                                            height: size.height / 8,
                                            child: Column(
                                              children: [
                                                TextButton(
                                                  onPressed: (){
                                                    tap_chat(_auth.currentUser!.uid ,
                                                      member[index]["uid"]);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Meassage ${member[index]["name"]}")
                                                ),
                                                TextButton(
                                                  onPressed: (){
                                                    tap_view(member[index]["uid"]);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("View ${member[index]["name"]}")
                                                ),
                                              
                        
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                        
                                  }
                        
                            } 
                          },
                          trailing: member[index]["isadmin"] == true ? Text("Admin") : null,
                          title: Text(member[index]["name"]),
                          subtitle: Text(member[index]["email"]),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage:member[index]["image"] == "" ? NetworkImage("https://images.unsplash.com/photo-1667480185404-42b2d11af650?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwyMHx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60") : 
                              NetworkImage(member[index]["image"]),
                          ),
                        );
                      },
                      ),
                        
                    ),
                  ),
                      
                 // Divider(color: Color.fromARGB(255, 221, 221, 221), thickness: 2),
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: ListTile(
                      onTap: () async{
                        
                      //  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>navigation()), (route) => false);
                        if(member[member_index()]["isadmin"] == true){
                          if(count_admin() >= 2){
                            showDialog(
                              context: context, 
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Center(
                                    child: AlertDialog(
                                      actions: [
                                        TextButton(
                                          onPressed: () async{
                                           
                                            isloading = true;
                                             
                                              await FirebaseFirestore.instance.collection("groups").doc(groupid).collection("chats").add({
                                                "message":"${FirebaseAuth.instance.currentUser!.displayName} is left ..",
                                                "sendy": FirebaseAuth.instance.currentUser!.displayName,
                                                "type":"notify",
                                                "time": DateTime.now()
                                              }).catchError((error)=>print("error is +${error}"));
                                              member.removeAt(member_index());
                                              await _firestore.collection("groups").doc(groupid).update({
                                                "members" : member,
                                              }).then((value) {print("member remove done");}).catchError((error)=>print(error));

                                              await _firestore.collection("last_group").doc(_auth.currentUser!.uid)
                                                .collection("group").doc(groupid).delete();

                                              await _firestore.collection("users").doc(_auth.currentUser!.uid).collection("groups").
                                                doc(groupid).delete().then((value) {
                                                  setState(() {
                                                    print("delete done group");
                                                    //isloading = false;
                                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>navigation()), (route) => false);
                                                    
                                                  });
                                                 
                                                }).catchError((error)=>print(error));
                                          },
                                          child: Text("EXIT")
                                        ),
                                        TextButton(
                                          onPressed: () async{
                                            Navigator.pop(context);
                                          },
                                          child: Text("CANCEL")
                                        ),
                                      ],
                                      content: Text("Do You Want to Exit ${snapshot.data!["name"]} group?"),
                                    ),
                                  ),
                                );
                              },
                            
                            );
                        
                            
                            // print("admin is changes is valid.....");
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please choose Your Nominal ...."))
                            );
                          }
                        }

                        if(member[member_index()]["isadmin"] == false){
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text("Do You Want to Exit \"${snapshot.data!["name"]}\" group?"),
                                actions: [
                                        TextButton(
                                          onPressed: () async {
                                            isloading = true;
                                            await _firestore.collection("last_group").doc(_auth.currentUser!.uid)
                                              .collection("group").doc(groupid).delete();

                                            await FirebaseFirestore.instance.collection("groups").doc(groupid).collection("chats").add({
                                               "message":"${FirebaseAuth.instance.currentUser!.displayName} is left ..",
                                               "sendy": FirebaseAuth.instance.currentUser!.displayName,
                                               "type":"notify",
                                               "time":  DateTime.now()
                                             }).catchError((error)=>print("error is +${error}"));

                                            member.removeAt(member_index());
                                            await _firestore.collection("groups").doc(groupid).update({
                                              "members" : member
                                            });
                                            await _firestore.collection("users").doc(_auth.currentUser!.uid).
                                              collection("groups").doc(groupid).delete().then((value) {
    
                                            });
                                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>navigation()), (route) => false);

                                            
                                            
                                          },
                                          child: Text("EXIT")
                                        ),
                                        TextButton(
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                          child: Text("CANCEL")
                                        ),
                                      ],
                              );
                            },
                          );
                        }  
                      },
                      leading: Icon(Icons.exit_to_app,size: 30,color: Colors.red,),
                      title: Text("Exit Groups" ,style: 
                        TextStyle(color: Colors.red,fontWeight: FontWeight.w600 ),),
                    ),
                  ),
                  
                ]
              ),
            );
            }else{
              return Container();
            } 
          },
        ),
      ),
    );
  }
}
show_dialog(BuildContext context, double height, double width, member, String groupname, int index, String groupid, List memberlist, uid){


  return showDialog(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          width: width / 1.3 ,
          height: height / 4,
          child: Column(
            children: [
              TextButton(
                onPressed: (){
                },
                child: Text("Meassage", style: TextStyle(),)
              ),
              TextButton(
                onPressed: (){
                },
                child: Text("View")
              ),
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                  showDialog(
                    context: context, 
                    builder: (context) {
                      return AlertDialog(
                        content: Text("Remove $member from \"$groupname\" group"),
                        actions: [
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            child: Text("Cancel")
                          ),
                          TextButton(
                            onPressed: () async{
                              memberlist.removeAt(index);
                              await FirebaseFirestore.instance.collection("groups").doc(groupid).update({
                                "members" : memberlist
                              });
                              await FirebaseFirestore.instance.collection("users").doc(uid).collection("groups").doc(groupid).delete().then((value) {
                                print("user remove done !");
                              });
                              
                              

                            },
                            child: Text("Ok")
                          ),
                          
                        ],
                      );
                    },
                  );
                },
                child: Text("Remove Group")
              ),
              TextButton(
                onPressed: (){
                },
                child: Text("Make Group Admin")
              ),
             

            ],
          ),
        ),
      ),
    ),
  );
}