
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friday_chat_app/policies.dart';
import 'package:share_plus/share_plus.dart';
class drawer_home extends StatefulWidget {
  const drawer_home({super.key});

  @override
  State<drawer_home> createState() => _drawer_homeState();
}

class _drawer_homeState extends State<drawer_home> {
  String greetingMessage(){

    var timeNow = DateTime.now().hour;
    
    if (timeNow <= 12) {
      return 'Good Morning';
    } else if ((timeNow > 12) && (timeNow <= 16)) {
    return 'Good Afternoon';
    } else if ((timeNow > 16) && (timeNow < 20)) {
    return 'Good Evening';
    } else {
    return 'Good Night';
    }
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
                return  Drawer(
                  child: ListView(
                      padding: EdgeInsets.zero,
                      children: [

                        UserAccountsDrawerHeader(
                          
                          accountName: Text(snapshot.data!["firstname"]), 
                          accountEmail: Text(snapshot.data!["email"]),
                          currentAccountPicture: CircleAvatar(
                            
                          backgroundImage: snapshot.data!["image"] != null ? NetworkImage(snapshot.data!["image"]) :
                             NetworkImage("https://firebasestorage.googleapis.com/v0/b/chat-data-f147e.appspot.com/o/profile_image%2Fnoimage.png?alt=media&token=de45644f-9837-4c23-a306-cc583eeee05c")
                          ),
                          
                          decoration: BoxDecoration(
                            image: DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1483232539664-d89822fb5d3e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cGhvdG8lMjBiYWNrZ3JvdW5kfGVufDB8fDB8fA%3D%3D&auto=format&fit=crop&w=500&q=60"), fit: BoxFit.cover)
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(greetingMessage() , style: TextStyle(fontSize: 20 , fontFamily: "SansFont"),),
                              Text("Navdip" , style: TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold, fontFamily: "SansFont"),),
                            ],
                          ),
                        ),
                        Divider(
                          endIndent: 20,
                          indent: 20,
                          thickness: 3,
                        ),
                        // ListTile(
                        //   leading: Icon(Icons.favorite),
                        //   title: Text("Favorites"),
                        //   onTap: (){

                        //   },
                        // ),
                        // ListTile(
                        //   leading: Icon(Icons.people),
                        //   title: Text("Friends"),
                        //   onTap: (){

                        //   },
                        // ),
                        ListTile(
                          leading: Icon(Icons.share),
                          title: Text("Share"),
                          onTap: () async{
                            print("share is clicked");
                            Share.share( " Let's chat on FriDayApp! It's a fast, simple, and secure app we can use to message and call each other for free. Get it at https://google.com/" );
                           
                            //await Share.share("this is navdip app chat app");

                          },
                        ),
                        // ListTile(
                        //   leading: Icon(Icons.notifications),
                        //   title: Text("Request"),
                        //   onTap: (){

                        //   },
                        // ),
                        // Divider(
                        //   endIndent: 10,
                        //   indent: 20,
                        //   thickness: 2,
                        // ),
                        ListTile(
                          leading: Icon(Icons.settings),
                          title: Text("Setting"),
                          onTap: (){

                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.description),
                          title: Text("Policies"),
                          onTap: (){

                            Navigator.push(context,MaterialPageRoute(builder: (context)=>policies()));
                           

                          },
                        )
                      ],
                    ),

                );
        }else{
          return Container();
        }
        
      },
    );
   
  }
}