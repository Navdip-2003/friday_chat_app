import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:friday_chat_app/home_demo.dart';
import 'package:friday_chat_app/post/setting_post/show_post.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';



/// Stateful widget to fetch and then display video content.
class VideoApp extends StatefulWidget {
  const VideoApp({Key? key}) : super(key: key);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3));
    _controller = VideoPlayerController .network(
        'https://firebasestorage.googleapis.com/v0/b/chat-data-f147e.appspot.com/o/Kedarnath%20%20Status%204k%20%F0%9F%A5%80%20-%204k%20%20Full%20Screen%20Kedarnath%20Status%20%F0%9F%98%8D%20-%20Kedarnath%20Temple%202022%20Special%20Status%20%F0%9F%99%8F.mp4?alt=media&token=aa1f6eb8-4b2a-4580-bbbb-44aee92fae38')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: _controller.value.isInitialized
              ? 
              AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(child: CircularProgressIndicator(),
              ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.network(
      'https://firebasestorage.googleapis.com/v0/b/chat-data-f147e.appspot.com/o/mahadev%20status%20__%20mahakal%20__%20bholenath%20status%20__%20full%20screen%20status%20__%20Insta%20story__%20whatsapp%20status.mp4?alt=media&token=256d6ea9-8ca3-4175-9bd8-426fa1db9ed4',
    );

    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Complete the code in the next step.
    return Container();
  }
}

class permission_handle extends StatefulWidget {
  const permission_handle({super.key});

  @override
  State<permission_handle> createState() => _permission_handleState();
}

class _permission_handleState extends State<permission_handle> {
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  Future<void> _askStoragePermission() async {
    debugPrint(" ---------------- Asking for permission...");
    await Permission.manageExternalStorage.request();
    if (await Permission.manageExternalStorage.request().isGranted) {
      PermissionStatus permissionStatus = await Permission.manageExternalStorage.status;
      setState(() {
        _permissionStatus = permissionStatus;
      });
    }
  }

  void permission() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    }
    log("log : $status");
    if (!status.isGranted) {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    permission();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text("Permissiom !!"),
        ),
        body: Container(
          height: size.height,
          width: size.width,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("post").doc(FirebaseAuth.instance.currentUser!.uid).collection("story").orderBy("time", descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  child: GridView.builder(
                    itemCount: snapshot.data!.docs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              var postid = snapshot.data!.docs[index]["post_id"];
                              var userid = snapshot.data!.docs[index]["user_id"];
                              Navigator.push(context, MaterialPageRoute(builder: (context) => show_post(postid: postid, userid: userid)));
                            },
                            child: Container(
                              width: 100.0,
                              height: 100.0,
                              decoration: new BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                        snapshot.data!.docs[index]["post"],
                                        errorListener: () {
                                          Icon(Icons.error);
                                        },
                                      ),
                                      fit: BoxFit.cover)),
                            ),
                          ));
                    },
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ));
  }
}
