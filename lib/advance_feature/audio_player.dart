

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
class audio_player extends StatefulWidget {
  const audio_player({super.key});

  @override
  State<audio_player> createState() => _audio_playerState();
}

class _audio_playerState extends State<audio_player> {

  final _player = AudioPlayer();
  bool is_play = false;
  Duration? position = Duration.zero;
  Duration? duration = Duration.zero;



  File? audio_file;
  Future filepicker() async{
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowCompression: true,
      allowedExtensions: ["mp3"],
      type: FileType.custom
    );
    if(result != null){
      setState(() {
        final path = result.files.first.path;
        audio_file = File(path!);
        var name = audio_file!.path.split("/").last;
        var size = audio_file!.readAsBytesSync().length;
       
      });

      await upload_file();
    }
  }

  Future upload_file() async{
    if(audio_file == null){
      return null;
    }

    final filename = audio_file!.path.split("/").last;
    final path = "audio_file/$filename";
    final ref = await FirebaseStorage.instance.ref(path);
    final url = await ref.putFile(audio_file!);
    String image_url = await url.ref.getDownloadURL();
    log("$image_url");
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _player.onPlayerStateChanged.listen((event) {
    //   setState(() {
    //     is_play = event == PlayerState.playing;
    //   });
    // });
    _player.onDurationChanged.listen((newduration) {
        setState(() {
          duration = newduration;
        });
    });
    
    _player.onPositionChanged.listen((newposition) {
      setState(() {
        position = newposition;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Slider(
                  value: position!.inSeconds.toDouble(), 
                  max: duration!.inSeconds.toDouble(),
                  onChanged: (value)  async{
                    final pos = Duration(seconds: value.toInt());
                    await _player.seek(pos); 
                  },
                ),
                ElevatedButton(
                  onPressed: ()  async{
                    String url = "https://firebasestorage.googleapis.com/v0/b/chat-data-f147e.appspot.com/o/audio_file%2Fhare-krishna-whatsapp-status-by-dainik-status-youtube-46975-58901.mp3?alt=media&token=f2b41d76-7704-4a02-b444-7a6c6e268567";

                    if(is_play){
                      setState(() {
                        is_play = false;
                      });
                      await _player.play(UrlSource(url));
                      
                    }else{
                      setState(() {
                        is_play = true;
                      });
                      await _player.pause();
                    }
                    
                   
                  
                  }, 
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      is_play ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                      Text("PLAY AUDIO"),
                    ],
                  )
                ),
                ElevatedButton(
                  onPressed: () {
                    filepicker();
                  
                  }, 
                  child: Text("PICK AUDIO FILE")
                ),
              ],
            ),
          ),
        ),

      ),
    );
  }
}