import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:friday_chat_app/home_demo.dart';
import 'package:friday_chat_app/post/show_post.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';

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
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
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
