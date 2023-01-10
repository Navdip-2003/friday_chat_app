import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class download_storage extends StatefulWidget {
  const download_storage({super.key});

  @override
  State<download_storage> createState() => _download_storageState();
}

class _download_storageState extends State<download_storage> {
  var ddr = 0.0 ;
  var download_per = 0.0;
  var url = "https://firebasestorage.googleapis.com/v0/b/chat-data-f147e.appspot.com/o/audio_file%2FMaan_Meri_Jaan_%7C_Official_Music_Video_%7C_Champagne_Talk_%7C_King(256k)?alt=media&token=86ea8cec-7ba8-49fa-a532-596b3d872f3e";
  bool isloading = false;

  Future<bool> savefile() async{
    Directory? directory;
    try{
      if(await _request_permissions(Permission.storage)){
        directory = await getExternalStorageDirectory();
        log("${directory!.path}");
        String newpath = "";
        print(directory.path.split("/"));

        var split_file = directory.path.split("/");
        ///storage/emulated/0//data/com.example.friday_chat_app/files

        for(int i = 1 ;  i < split_file.length ; i++){
          if(split_file[i] != "Android"){
            newpath += "/" + split_file[i];
          }else{
            break;
          }
        }
        newpath = newpath +"/FridayData";
        directory = Directory(newpath);
        log("${newpath}");


      }else{
        return false;
      }

      if(!await directory.exists()){
        await directory.create(recursive: true);
      }
      if(await directory.exists()){
        var nameOFFile = Uuid().v1();
        var filename = "AUD-$nameOFFile";
        File saveFile = File(directory.path+"/$filename");
        await Dio().download(
          url, 
          saveFile.path, 
          onReceiveProgress: (count, total) {
            setState(() {
              download_per = count / total * 100 ;
              var ddr = download_per / 100;
             
              
            });
          });
        return true;
      }
    }catch(e){
      print(e);

    }
    return false;
  }
  Future<bool> _request_permissions(Permission permissions)async{
    if(await permissions.isGranted){
      return true;
    }else{
      var result = await permissions.request();
      if(result == permissions.isGranted){
        return true;
      }else{
        return false;
      }
    } 
  }

  download_file() async{
    setState(() {
      isloading = true;
    });
    bool downloaded = await savefile();
    if(downloaded){
      print("downloaded done");
    }else{
      print("download failed");
    }
    setState(() {
      isloading = false;
    });

  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Center(
          
          child: Column(
            
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${download_per.toStringAsFixed(2)} %"),
              CircularPercentIndicator(
                animateFromLastPercent: true,
                radius: 100,
                animation: true,
                lineWidth: 30,
                percent: (download_per / 100),
                progressColor: Colors.deepPurple,
                backgroundColor: Colors.deepPurple.shade200,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text("${download_per.toStringAsFixed(0)} %" , style: TextStyle(color: Colors.deepPurple , fontSize: 30),),
                
              ),

              InkWell(
                onTap: () {
                  download_file();
                },
                child: Container(
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.center,
                  height: 70,
                  width: 200,
                  color: Color.fromARGB(255, 173, 229, 251),
                  child: Text("Download", textAlign: TextAlign.center,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}