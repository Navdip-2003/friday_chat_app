import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:friday_chat_app/Group_chat/chatroom_group.dart';
import 'package:friday_chat_app/Group_chat/home_group.dart';
import 'package:friday_chat_app/navigation.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class gruop_name extends StatefulWidget {
  List<Map<String,dynamic>> member;
  
  
  gruop_name({super.key,required this.member});

  @override
  State<gruop_name> createState() => _gruop_nameState(member);
}

class _gruop_nameState extends State<gruop_name> {

var isloading = false;
var isload = false;
  List<Map<String, dynamic>> member;
  _gruop_nameState( this.member);
  TextEditingController group_name = TextEditingController();

  void creategroup()async{
    isloading = true;
    var img = image_url != "" ? image_url :
      "https://raw.githubusercontent.com/Navdip-2003/OnlineFlightBooking/master/images/80-805068_my-profile-icon-blank-profile-picture-circle-clipart.png";
    String groupid = Uuid().v1();
    if(mounted){
      setState(() {
         
      });
    }
    await FirebaseFirestore.instance.collection("groups").doc(groupid).set({
      "name" : group_name.text,
      "members": member,
      "id":groupid,
      "image" : img 
      }).then((value) {
        print("group created successsfully ......");
       // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>navigation()), (route) => false);
      
    }).catchError((error)=>print("Error is the +${error}"));

    await FirebaseFirestore.instance.collection("groups").doc(groupid).collection("chats").add({
      "message":"${FirebaseAuth.instance.currentUser!.displayName} Created groups..",
      "sendy": FirebaseAuth.instance.currentUser!.displayName,
      "type":"notify",
      "time":  FieldValue.serverTimestamp()
    }).catchError((error)=>print("error is +${error}"));
    for(int i=0 ; i < member.length ; i++){
      String uid = member[i]["uid"];
      await FirebaseFirestore.instance.collection("users").doc(uid).collection("groups").doc(groupid).set({
        "name" : group_name.text,
        "id": groupid,
        
      }).catchError((error)=>print("this error is +${error}"));
      for(int i = 0 ; i < member.length ; i++){
        FirebaseFirestore.instance.collection("last_group").doc(member[i]["uid"]).collection("group").doc(groupid).set({
          "message" : "${FirebaseAuth.instance.currentUser!.displayName} Added This Group ..",
          "time" : DateTime.now(),
          "group_id" : groupid
        });
      }
      await FirebaseFirestore.instance.collection("groups").doc(groupid).collection("chats").add({
        "message":"${FirebaseAuth.instance.currentUser!.displayName} added ${member[i]["name"]}",
        "sendy": FirebaseAuth.instance.currentUser!.displayName,
        "type":"notify",
        "time":  FieldValue.serverTimestamp()
      }).catchError((error)=>print("error is +${error}"));
      setState(() {
        isloading = false;
      });
    }
   
    Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>group_chatroom(
      group_id : groupid,
      group_name : group_name.text,
      group_image : image_url,
      i: 1,
      )) , (route) => false);

  }
  File? _image;
  ImagePicker _picker = ImagePicker();
  
  var filename;
  Future<void> imagepicker(ImageSource soc ) async{
    
     XFile? img = await _picker.pickImage(source: soc );
    if(img != null){
      setState((){
        _image =  File(img.path);
        filename = img.path.split('/').last;
        print(filename);
        upload_image();
        Navigator.pop(context);
       
      });
    }
  }
  String image_url = "";
  void upload_image() async{
    isload = true;
    var ref = FirebaseStorage.instance.ref().child("profile_image").child(filename);
    var up_image = await ref.putFile(_image!);
    image_url = await up_image.ref.getDownloadURL();
    print(image_url);
    setState(() {
      isload = false;
    });
    
  }
  
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        flexibleSpace: Container(
          color: Color.fromARGB(255, 124, 123, 123),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("New Group"),
            Text("Add subject" , style: TextStyle(fontSize: 10), textAlign: TextAlign.start,)
          ],
        ) ,
        
      ),
      body: isloading ? Center(child: CircularProgressIndicator(),) :
      Container(
        child: Column(
          children: [
            SizedBox(height: size.height / 30,),
            Container(
              //color: Colors.redAccent,
              height: size.height / 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex:1 ,
                    child: Container(
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
                                                  imagepicker(ImageSource.camera);

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
                                                  imagepicker(ImageSource.gallery);
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
                        child: Stack(
                          children: <Widget>[
                            isload ? Center(child: CircularProgressIndicator(),) :
                             CircleAvatar(
                              radius: 30,
                              backgroundImage:_image != null ? FileImage(File(_image!.path)) : null
                              
                              
                                
                            ),
                            !isload ? Positioned(
                              top: 35,
                              left: 35,
                              child: Container(
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Color.fromARGB(255, 186, 60, 1),
                                border: Border.all(
                                  width: 0
                                  )
                                ),
                               
                                child: Icon(Icons.add , color: Colors.white,),
                              )
                            ) : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20,),
                  Flexible(
                    flex: 2,
                    child: Container(
                      child: TextField(
                        maxLength: 20,
                        controller: group_name,
                        decoration: InputDecoration(
                          
                          isCollapsed: true,
                          contentPadding: EdgeInsets.all(10),
                          hintText: "Type group name ...", 
                          hintStyle: TextStyle(overflow: TextOverflow.ellipsis)
                        ),
                        
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              child: Container(
               // color: Color.fromARGB(255, 246, 159, 153),
                height: 10, 
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              width: size.width,
              child:Text("Participants : " + member.length.toString() , textAlign: TextAlign.start,),
            ),
            SizedBox(
              child: Container(
               // color: Color.fromARGB(255, 246, 159, 153),
                height: 10, 
              ),
            ),
            Container(
              height: size.height/ 7,
              //color: Colors.blueAccent,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:member.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(member[index]["image"] !=""? member[index]["image"] :
                             "https://images.unsplash.com/photo-1666934209593-25b6aa02ab4e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzMnx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60"),
                          backgroundColor: Colors.amber,
                        ),
                        Container(
                          width: size.width / 7,
                          child: Text(member[index]["name"] , textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,),
                        )
                      ],
                    ),
                  );
                
                },
              ),

            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () {
          creategroup();
          
       },
       child: Container(child: Image.asset("asset/right_tick.png", scale: 2,color: Colors.white,),)
      ),


    );
    
  }
}