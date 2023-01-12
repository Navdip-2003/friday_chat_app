
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:lottie/lottie.dart';

class player_audio extends StatefulWidget {
  String link;  
   player_audio({super.key, required this.link});

  @override
  State<player_audio> createState() => _player_audioState();
}

class _player_audioState extends State<player_audio> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _player = AudioPlayer();
  bool is_play = true;
  Duration? position = Duration.zero;
  Duration? duration = Duration.zero;
 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 0),
      vsync: this);
      

    _player.play(UrlSource(widget.link));
    _player.onPlayerStateChanged.listen((event) {
        setState(() {
          is_play = event == PlayerState.playing;
        });      
     });
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
    _player.onPlayerComplete.listen((event) {
       _player.dispose();
       _player.release();
       _player.stop();
      Navigator.pop(context);
      
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _player.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async{
          _player.dispose();
          _player.release();
          _player.stop();
          Navigator.pop(context);
          return true;
        },
        child: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Container(
              color: Color.fromARGB(255, 255, 255, 255),
              padding: EdgeInsets.all(5),
              child: Card(
                color: Color.fromARGB(255, 34, 79, 95),
                semanticContainer: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: size.width,
                  padding: EdgeInsets.all(5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BackButton(
                        color: Colors.white,
                        onPressed: () {
                          _player.dispose();
                          _player.release();
                          _player.stop();
                          Navigator.pop(context);              
                        },
                      ),
                      Container(
                        child: Lottie.asset("asset/music_player.json", width: size.width / 1 , height: size.height / 2.5)),
                      Container(
                        padding: EdgeInsets.all(20),
                        child: AutoSizeText(widget.link , 
                        
                          maxLines: 2, minFontSize: 15, maxFontSize: 30,overflow: TextOverflow.ellipsis, style: TextStyle(
                          fontFamily: "SansFont",  color: Colors.white),
                          textAlign: TextAlign.left, 
                        ),
                      ),
                      Container(
                        child: Slider(
                          thumbColor: Colors.white,
                          inactiveColor: Color.fromARGB(255, 255, 255, 255),
                          activeColor: Color.fromARGB(255, 8, 198, 251),
                          min: 0,
                          max: duration!.inSeconds.toDouble(),
                          value: position!.inSeconds.toDouble(), 
                          onChanged: (value) async{
                            final pos = Duration(seconds: value.toInt());
                            await _player.seek(pos); 
                            await _player.resume();
                          }
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Padding(padding: EdgeInsets.all(10)),
                            AutoSizeText(format_time(position!) , 
                              style: TextStyle(
                                color: Colors.white
                              ),
                            ),
                            Spacer(),
                            AutoSizeText(format_time(duration!) , 
                              style: TextStyle(
                                color: Colors.white
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(10)),
                
                          ],
                        ),
                      ),
                      Container(
                       
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () async{
                            if(is_play){
                               _controller.stop();
                              //_controller.forward();
                               await _player.pause();
                            }else{
                              await _player.play(UrlSource(widget.link));
                            }
                          },
                          child: Icon(is_play ? Icons.pause : Icons.play_circle , size: 50, color: Colors.white,)
                        ),
                      ),
                      
                    ],
                  ),
                ),
                
              ),
                
            ),
          ) 
        ),
      ),
    );
  }
}