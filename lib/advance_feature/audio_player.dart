

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:friday_chat_app/advance_feature/download_local_storage.dart';
import 'package:friday_chat_app/advance_feature/player_audio.dart';
import 'package:friday_chat_app/variables.dart';
class audio_player extends StatefulWidget {
  const audio_player({super.key});

  @override
  State<audio_player> createState() => _audio_playerState();
}

class _audio_playerState extends State<audio_player> {
  String url = "https://firebasestorage.googleapis.com/v0/b/chat-data-f147e.appspot.com/o/audio_file%2FMaan_Meri_Jaan_%7C_Official_Music_Video_%7C_Champagne_Talk_%7C_King(256k)?alt=media&token=86ea8cec-7ba8-49fa-a532-596b3d872f3e";


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
        log("$path");
        _player.play(UrlSource(path));
      });

     //await upload_file();
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
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text(format_time(position!)),
                      Spacer(),
                      Text(format_time(duration!)),
                      
                    ],
                  ),
                ),
                 ElevatedButton(
                  onPressed: ()  async{

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
                      is_play ? Icon(Icons.play_arrow_outlined) : Icon(Icons.pause_circle),
                      Text("PLAY AUDIO"),
                    ],
                  )
                ),
                ElevatedButton(
                  onPressed: () async {

                    Navigator.push(context, MaterialPageRoute(builder: (context)=>player_audio(link : url)));

                   
                  }, 
                  child: Text("Play Song")
                ),
                ElevatedButton(
                  onPressed: () {
                    filepicker();
                  
                  }, 
                  child: Text("PICK AUDIO FILE")
                ),
                ElevatedButton(
                  onPressed: () async {
                    var file = "/data/user/0/com.example.friday_chat_app/cache/file_picker/Gujarati_Slowed_+_Reverb_Mixtape_1_|_30_Minutes_to_Relax_and_Chill_|_Yours_Lo-fi_(_Gujarati_Lofi_)(128k).m4a";
                   if(await File(file).exists()){
                    log("file exists: " );

                   }else{
                    log("file NOT exists: " );

                   }
                  
                    _player.play(UrlSource(file));
                  
                  }, 
                  child: Text("PICK LOCAL AUDIO FILE")
                ),
                ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>download_storage()));

                }, child: Text("GEt DowNload "))

               
              ],
            ),
          ),
        ),

      ),
    );
  }
}


