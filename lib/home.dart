

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:friday_chat_app/chat_screen/chatroom.dart';
import 'package:friday_chat_app/contact.dart';
import 'package:friday_chat_app/log/login.dart';
import 'package:friday_chat_app/methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friday_chat_app/variables.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> with WidgetsBindingObserver{
  
  bool isloading = false;
  TextEditingController name = TextEditingController();
  String? dis_name = FirebaseAuth.instance.currentUser?.displayName;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _store = FirebaseFirestore.instance;
  

  
  String roomid(String user1, String user2)  {
   if(user1.toLowerCase().codeUnits[0] > user2.toLowerCase().codeUnits[0]){
    //  print("chat room id id the : $user1$user2");
      return "$user1$user2";
    }else{
     // print("chat room id id the  :$user2$user1");
      return "$user2$user1";
    }
  }

  String chatid(String user1 , String user2){
     if(user1.toLowerCase().codeUnits[0] > user2.toLowerCase().codeUnits[0]){
    //  print("chat room id id the : $user1$user2");
      return "$user1$user2";
    }else{
     // print("chat room id id the  :$user2$user1");
      return "$user2$user1";
    }

  }


  Map<String , dynamic>? data;
  void searchuser() async {
    setState(() {
      isloading = true;
    });
    tm();
    FirebaseFirestore store = FirebaseFirestore.instance;
    await store.collection("users").where("email" , isEqualTo: name.text).get().then((value)  {
      setState(() {
        if(value != null){
            data = value.docs[0].data();
            print("Searchable user is : " + data!["name"]);
            isloading = false;
            print("user seachable data is the$data");
        }else{
            print("user is not found");
        }
       
      });
      
    });
  }

  
  void tm(){
    Timer(Duration(seconds: 3), (){ setState(() {
      isloading = false;
      });
    });
  }
  
 @override
  void initState() {
    print(user_email);
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setstatus("Online"); 
    // print("Currenr user is : "+FirebaseAuth.instance.currentUser.toString());
  }

  void setstatus(String state) async {
    await _store.collection("users").doc(_auth.currentUser?.uid).update({
      "status" : state
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
   if(state == AppLifecycleState.resumed){
    setstatus("Online");
   }else{
    setstatus("Offline");
   }
  }
  
  @override
  Widget build(BuildContext context) {
    
    final size = MediaQuery.of(context).size;
    return Scaffold(
     drawer: Drawer(),
      appBar: AppBar(title: Text("Welcome $dis_name" , style: TextStyle(fontSize: 18 ,) , textAlign: TextAlign.left,),
        actions: [
          IconButton(onPressed: (){
            
            signout();
            Navigator.push(context, MaterialPageRoute(builder: (context)=>const login()));
            }, icon: const Icon(Icons.logout)
          ),
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> contact()));

          }, icon: Icon(Icons.home))
          
        ],
      ),
      body:isloading ? Center(child:  CircularProgressIndicator()) :
       Column(
        children: [
          Container(height: size.height / 40,),
          Center(
            child: SizedBox(
              width: size.width / 1.15,
              child: TextField(
                controller: name,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: "Name Of Email"
                ),
              ),
            ),
          ),
          Container(height: size.height /50,),
          SizedBox(
            
            width: size.width /3,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.deepOrangeAccent
              ),
              onPressed: (){
                setState(() {
                  searchuser();
                });
                

              },
               child: const Text("Search")
            ),
          ),
          data != null ? ListTile(
            onTap: (){
              // String user2 = data!["name"];
              // String? user1 = FirebaseAuth.instance.currentUser!.displayName;
              // String chatroom_id = roomid(user1.toString(),user2 );
              // print(chatroom_id);
              // Navigator.push(context, MaterialPageRoute(builder: (context)=>
              //   chatroom(chat_id : chatroom_id , usermap : data!  )));
              String chat_id = get_chatid(data!["uid"] , FirebaseAuth.instance.currentUser!.uid);
              print(chat_id);
              
              // String chat_id = chatid( data!["uid"] , FirebaseAuth.instance.currentUser!.uid);
              // print(chat_id);
            
            },

            title: Text(data!['name']),
            subtitle: Text(data!['email']),
            leading: const Icon(Icons.message),


          ): 
          Container(
            

          ),
          Container(
            
            child:  Material(
              child:  InkWell(
                
                borderRadius: BorderRadius.circular(30),
                onTap: (){
                  
                  },
                child:  Container(
                  width: size.width / 4.8,
                  child: Row(
                   
                                  children: [
                                    Icon(Icons.arrow_back),
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.pinkAccent,
                                    )
                                  ],
                                ),
                ),
              ),
              color: Color.fromARGB(0, 158, 153, 153),
            ),
            
             
          ),
          
        ],
      ),
      
    
    );
  }
}