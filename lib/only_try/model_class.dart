import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:friday_chat_app/data_search.dart';
import 'package:friday_chat_app/navigation.dart';
import 'package:http/http.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
class model_class extends StatefulWidget {
  const model_class({super.key});

  @override
  State<model_class> createState() => _model_classState();
}

class _model_classState extends State<model_class> {
  List data = [];
  bool isloading = false;
  void getdata(){
    isloading =true;
    setState(() {
      
    });
     FirebaseFirestore.instance.collection("users").get().then((value){
        value.docs.forEach((element) {
            data.addAll(element.data().values);
        });
        setState(() {
          isloading = false;
        });
     });

    print(data);


  }
   bool is_reaction = false; 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getdata();
    
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> chatdemonew()));
          
          }, 
          child: Text("new chat screen")
        ),
      ),
    );
  
  }

}
class chatdemonew extends StatefulWidget {
  const chatdemonew({super.key});

  @override
  State<chatdemonew> createState() => _chatdemonewState();
}

class _chatdemonewState extends State<chatdemonew> {
  var _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream:  _firestore.collection("chatroom").doc("OPElQEDKCpZsFMu9RL37O5Gswzu2Ikw2p5ry0WceDSK606Dzz6VmtR22").collection("chat").orderBy("time", descending: false).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            
    
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return
                ddm(data : snapshot.data!.docs[index]);
              
              },
            );
    
          }else{
            return Container();
          }
    
        
        },
      ),
    );
  }
}
class ddm extends StatefulWidget {
  QueryDocumentSnapshot<Map<String, dynamic>> data;
   ddm({super.key, required this.data});

  @override
  State<ddm> createState() => _ddmState();
}

class _ddmState extends State<ddm> {
  bool download_started = false;
  bool download_end = false;
  int download_process = 0;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return detailed(widget.data.data());
  }

  Widget detailed(Map<String, dynamic> data){
    if(data["type"] == "audio"){
       return ListTile(
          title: Text(data["message"] , overflow: TextOverflow.ellipsis),
          contentPadding: EdgeInsets.all(10),
          trailing: Column(
            children: [
              Visibility(
                visible: download_started,
                child: CircularPercentIndicator(
                  radius: 20,
                    lineWidth: 3.0,
                    percent: (download_process / 100),
                    center: Text(
                      "$download_process %",
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                    progressColor: Colors.blue,

                )
              ),
              Visibility(
                visible: !download_started,
                child: download_end ? Icon(Icons.download , color: Colors.red,)  : IconButton(
                  onPressed: () {
                    download_file();
                  
                  }, 
                  icon: Icon(Icons.download)
                ),
              )
            ],
          ),
          leading: Icon(Icons.music_note),
        );

    }else{
      return ListTile(
        title: Text(data["message"]),
      );
    }
   
    
  }
  
  void download_file() async {
    download_started = true;
    download_end = false;
    download_process = 0;
    setState(() {
    });
    while(download_process < 100){
      download_process += 10;
      setState(() {
      });
      if(download_process == 100){
        download_started = false;
        download_end = true;
        setState(() {
        });
        break;
      }
      await Future.delayed(Duration(milliseconds: 500));
    }

  }
}