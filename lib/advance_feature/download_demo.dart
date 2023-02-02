import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class download_demo extends StatefulWidget {
  const download_demo({super.key});

  @override
  State<download_demo> createState() => _download_demoState();
}

class _download_demoState extends State<download_demo> {
   List<String> courcename = [
       "Dart",
    "Flutter",
    "Java",
    "Kotlin",
    "Swift",
    "Angular",
    "React",
    "Spring",
    "JavaScript",
    "C++",
    "Python",
    "Android",
    "Iconic",
    "Xamarin"
    ];

    int downloadProgress = 0;

  bool isDownloadStarted = false;

  bool isDownloadFinish = false;
  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      body: Container(
        child: ListView.builder(
          itemCount: courcename.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(courcename[index]),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green ,
              ),
              trailing: Column(children: [
                Visibility(
                    visible: isDownloadStarted,
                    child: CircularPercentIndicator(
                      radius: 20.0,
                      lineWidth: 3.0,
                      percent: (downloadProgress / 100),
                      center: Text(
                        "$downloadProgress%",
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                      progressColor: Colors.blue,
                    )),
                Visibility(
                    visible: !isDownloadStarted,
                    child: IconButton(
                      icon: const Icon(Icons.download),
                      color: isDownloadFinish ? Colors.green : Colors.grey,
                      onPressed: downloadCourse,
                    ))
              ]));
            
          },
        ),
      ),
    );
  }
 void downloadCourse() async {
    isDownloadStarted = true;
    isDownloadFinish = false;
    downloadProgress = 0;
    setState(() {});

    //Download logic
    while (downloadProgress < 100) {
      // Get download progress
      downloadProgress += 10;
      setState(() {});
      if (downloadProgress == 100) {
        isDownloadFinish = true;
        isDownloadStarted = false;
        setState(() {});
        break;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}