
import 'dart:developer';

import 'package:advstory/advstory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:story/story_page_view/story_page_view.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:text_editor/text_editor.dart';

class homest extends StatefulWidget {
  const homest({super.key});

  @override
  State<homest> createState() => _homestState();
}

class _homestState extends State<homest> {
  
  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  List contact_id =[];
  List story_data =[];
  bool isloading = false;
  void get_story() async{
    setState(() {
      isloading = true;
    });
    
    await _firestore.collection("contacts").doc(_auth.currentUser!.uid).collection("lastonline").get().then((value) {
      value.docs.forEach((element) {
       
        contact_id.add(element["uid"]);
      });
    });
    for(int i =0; i <contact_id.length; i++) {
      _firestore.collection("cont_story").doc(contact_id[i]).collection("details").orderBy("time" , descending: true).get().then((value) {
        value.docs.forEach((element) {
          story_data.add(element.data());
          
         });

      });
    }
    setState(() {
      isloading = false;
    });
    
  }
  List getUser = [];
  List getSory = [];
  void getter() async {
    await _firestore.collection("new_story").doc(_auth.currentUser!.uid).collection("sort_story").orderBy("time" , descending: true). get().then((value) {
      value.docs.forEach((element) {
        getUser.add(element.data());
        
      });
    });
    for(int i =0 ; i < getUser.length ; i++){
      await _firestore.collection("cont_story").doc(getUser[i]["user_id"]).collection("details").get().then((value) =>{
        getSory.addAll(value.docs),
        // value.docs.forEach((element) {
        //   var hh = element.data();
        //   log("asss : $hh ");
        // })
      });
    }
    print(getSory.length);
   
   

  }
  TextStyle _textStyle = TextStyle(
    fontSize: 50,
    color: Colors.white,
    fontFamily: 'Billabong',
  );
  String _text = 'Sample Text';
  TextAlign _textAlign = TextAlign.center;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //get_story();
    getter();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading ? Center(child: CircularProgressIndicator(),):
      Container(
        // child: 
        // StreamBuilder(
        //   stream: _firestore.collection("story").doc(story_data[0]).,
        //   builder: (context, snapshot) {
        //     return Container();            
        //   },
        // ),
      )

     
     
      //  Center(child: TextButton(
      //   child: Text("Show story"),
      //   onPressed: () {
      //     print(story_data);
      //   // Navigator.push(context, MaterialPageRoute(builder: (context) => baby(),));
      //   },
    //  ),
    // ),
    );
  }
}
class baby extends StatefulWidget {
  const baby({super.key});

  @override
  State<baby> createState() => _babyState();
}

class _babyState extends State<baby> {
  List story = [
    "https://images.unsplash.com/photo-1671036174693-cae0d87e568c?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1664575196044-195f135295df?ixlib=rb-4.0.3&ixid=MnwxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwxfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60",
    "https://images.unsplash.com/photo-1664575599736-c5197c684128?ixlib=rb-4.0.3&ixid=MnwxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwxMXx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60"
  ];
  
   @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        body: 
        Container(
          alignment: Alignment.center,
          child: Center(

            child: 
            AdvStory(
              
              
              storyCount: 5,
              storyBuilder: (storyIndex) => Story(
                
                header:const StoryHeader(
                  url: "https://firebasestorage.googleapis.com/v0/b/chat-data-f147e.appspot.com/o/images%2F0f056860-764f-11ed-ac83-4f9d3ef41dbe.jpg?alt=media&token=bd8a11bc-c94d-4978-9028-687f93e692e8", 
                  text: "navdip patel"
                ),
                contentCount: story.length,
            
                contentBuilder: (contentIndex){
                  return ImageContent(url: story[contentIndex]);
                }
              ),
              trayBuilder: (index) => AdvStoryTray(url: "https://images.unsplash.com/photo-1670786611555-5218c1407492?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw5fHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60"),
            ),
          
          ),
        )
    
      ),
    );
  }
}




