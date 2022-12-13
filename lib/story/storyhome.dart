import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:video_player/video_player.dart';

class story_home extends StatefulWidget {
  const story_home({super.key});

  @override
  State<story_home> createState() => _story_homeState();
}

class _story_homeState extends State<story_home> {
  List dymmydata = [
    {
      "type":"image",
      "url":"https://images.unsplash.com/photo-1670786611555-5218c1407492?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw5fHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60"

    },
    {
      "type":"video",
      "url":"https://firebasestorage.googleapis.com/v0/b/chat-data-f147e.appspot.com/o/Kedarnath%20%20Status%204k%20%F0%9F%A5%80%20-%204k%20%20Full%20Screen%20Kedarnath%20Status%20%F0%9F%98%8D%20-%20Kedarnath%20Temple%202022%20Special%20Status%20%F0%9F%99%8F.mp4?alt=media&token=aa1f6eb8-4b2a-4580-bbbb-44aee92fae38"

    },
    {
      "type":"image",
      "url":"https://images.unsplash.com/photo-1670747375356-6efaa71ec623?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60"

    },
    {
      "type":"image",
      "url":"https://images.unsplash.com/photo-1670786611555-5218c1407492?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw5fHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60"

    },
    {
      "type":"image",
      "url":"https://images.unsplash.com/photo-1670786611555-5218c1407492?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw5fHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60"

    },
    {
      "type":"image",
      "url":"https://images.unsplash.com/photo-1670786611555-5218c1407492?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw5fHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60"

    },

  ];
  List pic = [
  "https://images.unsplash.com/photo-1670786611555-5218c1407492?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHw5fHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60",
  "https://images.unsplash.com/photo-1670747375356-6efaa71ec623?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzfHx8ZW58MHx8fHw%3D&auto=format&fit=crop&w=500&q=60",
  "https://images.unsplash.com/photo-1670777361177-7ea502ee059d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwxMnx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60"
  ];
  VideoPlayerController? _vd;
  PageController? _pg;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pg = PageController();
    _vd =VideoPlayerController.network(dymmydata[1]["url"])..initialize().then((value) {
      setState(() {
        
      });
      _vd?.play();
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _vd!.dispose();
    _pg!.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: dymmydata.length,
        itemBuilder: (context, index) {
          switch(dymmydata[index]["type"]){
            case "image":
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(dymmydata[index]["url"],), fit: BoxFit.cover
                  )
                ),
              ); 
            case "video":
              if(_vd != null && _vd!.value.isInitialized) {
                return GestureDetector(
                  onLongPress: () => _vd!.pause(),
                  onLongPressCancel: () => _vd!.play(),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _vd!.value.size.width,
                      height: _vd!.value.size.height,
                      child: VideoPlayer(
                        _vd!
                      ),
                    ),
                  ),
                );

              }
          }
          return SizedBox.shrink();
        
        },
      ),

    );
  }
}