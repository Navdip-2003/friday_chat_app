import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:friday_chat_app/Group_chat/grop_name.dart';

class member_add extends StatefulWidget {
  List alredy_member;
  String groupid;
  String gropname;
  member_add({super.key, required this.alredy_member, required  this.groupid, required this.gropname});

  @override
  State<member_add> createState() => _member_addState(alredy_member, groupid, gropname);
}

class _member_addState extends State<member_add> {
   List alredy_member;
   String groupid;
   String gropname;
  _member_addState(this.alredy_member, this.groupid,  this.gropname);

  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  Map<String , dynamic>? usermap ;
  var sea = "";
  void alredy_member_add(){
    for(int i=0; i < alredy_member.length;i++){
      member_list.add(alredy_member[i]);
    }
    
  }
  TextEditingController result = TextEditingController();
  List<Map<String, dynamic>> member_list =[];
 
  void onresulttap(Map<String, dynamic> data){
    bool isalreadyexist = false;
    for( int i=0 ; i < member_list.length ;i++){
      if(member_list[i]["uid"] == data["uid"]){
        isalreadyexist = true;
      }
    }
    if(!isalreadyexist){
       setState(() {
        member_list.add({
          "name" : data["name"],
          "uid":data["uid"],
          "email" : data["email"],
          "isadmin" : false,
          "image" : data["image"]

      });
    });
    }
   
  } 
  void onremovetap(int index){
    if(member_list[index]["uid"] != _auth.currentUser!.uid){
      setState(() {
            member_list.removeAt(index);
      });
    }
    

  }
  bool isloading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    alredy_member_add();
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
        title: Text("Add member in Group ...") ,
      ),
      body: isloading == true ? Center(child: CircularProgressIndicator(),) :
       SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                
                height: size.height / 8 ,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: member_list.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(member_list[index]["image"] == "" ? 
                                "https://images.unsplash.com/photo-1666934209593-25b6aa02ab4e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzMnx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60" :
                                  member_list[index]["image"] ),
                              ),
                              Positioned(
                                top: 25,
                                left: 25,
                                child: IconButton(
                                  
                                  onPressed: (){
                                    onremovetap(index);
      
                                  },
                                  icon: Icon(Icons.close_outlined ,)
                                ) 
                              ),
                            ],
                          ),
                          Container(
                            
                            width: size.width /7,
                            child: Text(member_list[index]["name"], overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 13 
                              ),textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10, left: 10),
                child: TextField(
                  onChanged: (value){
                    setState(() {
                      sea = value;
                      
                    });
                  },
                  controller: result,
                  expands: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    isCollapsed: true,
                    contentPadding: EdgeInsets.all(10),
                    hintText: "Search ..."
                  ),
      
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(top: 10 , left: 10 , right:10),
                  child: Container(
                    height: size.height / 1.43,
                    child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("users").snapshots(),
                    builder: (context, snapshot) {
                            return (snapshot.connectionState == ConnectionState.waiting) ? 
                              Center(child: CircularProgressIndicator()) : 
                              ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var data = snapshot.data!.docs[index].data() as Map<String , dynamic>;
                                  if(sea.isEmpty){
                                    return ListTile(
                                      title: Text(data["name"]),
                                      subtitle: Text(data["email"]),
                                      leading: data["image"] == "" ? CircleAvatar(
                                        backgroundColor: Colors.greenAccent,radius: 30,
                                        ):
                                        CircleAvatar(backgroundImage: NetworkImage(data["image"]),radius: 30,),
                                      trailing: IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: (){
                                          onresulttap(data);
                                          print(member_list);

      
                                        },
                                      ),
                                    );
                                    
                                  }
                                  if(data["email"].toString().toLowerCase().startsWith(sea.toLowerCase())){
                                    return ListTile(
                                      title: Text(data["name"]),
                                      subtitle: Text(data["email"]),
                                      leading: data["image"] == "" ? CircleAvatar(
                                        backgroundColor: Colors.greenAccent,radius: 30,
                                      ):
                                      CircleAvatar(backgroundImage: NetworkImage(data["image"]),radius: 30,),
                                      trailing: IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: (){
                                           onresulttap(data);
                                            
                                        },
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              );
                          },
                    ),
                  ),
                ),
              ),
            ],
          )
        ),
      ),
      floatingActionButton: member_list.length >= 2 ? FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () async {
          isloading = true;
          for(int i=0 ; i < member_list.length ; i++){
            String uid = member_list[i]["uid"];
            await FirebaseFirestore.instance.collection("users").doc(uid).collection("groups").doc(groupid).set({
              "name" : gropname ,
              "id": groupid,
              
            }).catchError((error)=>print("this error is +${error}"));
            setState(() {
             
            });
          }
          await _firestore.collection("groups").doc(groupid).update({
            "members" : member_list
          }).then((value){
            setState(() {
              isloading =false;
              Navigator.pop(context);
              
            });
          });
        },
        child: Icon(Icons.people_sharp),
      ) : SizedBox(),

    );
  }
}