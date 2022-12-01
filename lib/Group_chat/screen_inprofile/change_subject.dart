import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class change_subject extends StatefulWidget {
  String id;
  String name;
  change_subject({super.key, required this.id, required this.name});

  @override
  State<change_subject> createState() => _change_subjectState(id , name);
}

class _change_subjectState extends State<change_subject> {
  TextEditingController new_name = TextEditingController();
  String id;
  String name;
  _change_subjectState( this.id, this.name);
  bool isloading = false;
  @override 
  void initState() {
    // TODO: implement initState
    super.initState();
   new_name.text = name;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 17, 81, 1),
        child: Icon(Icons.save_rounded),
        onPressed: () async{
          isloading = true;
          await FirebaseFirestore.instance.collection("groups").doc(id).update({
            "name" : new_name.text
          }).then((value) {
            setState(() {
              isloading = false;
              Navigator.pop(context);
            });
          });


        },
      ),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(137, 62, 104, 62),
        title: Text("Enter new subject" , style: TextStyle( fontSize: 18, fontFamily: "SansFont", fontWeight: FontWeight.bold),),
      ),
      body: Padding(
        
        padding: const EdgeInsets.all(15.0),
        child: isloading ? Center(child: CircularProgressIndicator(),) : 
        Container(
          padding: EdgeInsets.only(right: 15 , left: 15),
          child: TextField(
            maxLength: 20,
            controller: new_name,
            
          ),
        ),
      ),
    );
  }
}