
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:friday_chat_app/contact.dart';
import 'package:friday_chat_app/variables.dart';

class overlay_image extends StatefulWidget {
  const overlay_image({super.key});

  @override
  State<overlay_image> createState() => _overlay_imageState();
}

class _overlay_imageState extends State<overlay_image> {
  OverlayEntry? _popupdialog;
  OverlayEntry? _createPopDialog(String url, BuildContext context){
    return OverlayEntry(
      builder:(context) {
        return _createpopupcontent(url , context );
      }
    );

  }
  OverlayState? overlayState;
  OverlayEntry? overlayEntry;
  showoverlay(BuildContext cont , url, Size size) async{
     overlayState = Overlay.of(context);
     overlayEntry = OverlayEntry(
      builder: (context) {
        return Container(
          
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(url), fit: BoxFit.cover
            )
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50 , sigmaY:50),
            
            child: Container(
              
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10)
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20)
                    ),
                      // height: MediaQuery.of(context).size.height / 1.5,
                      // width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          color: Colors.blue,
                          height: size.height / 15,
                        ),
                        Image.network(url, fit: BoxFit.cover,),
                        Container(
                          color: Colors.blue,
                          height: size.height / 15,
                        ),
                      ],
                    ),
                  ),
                ),

              ),
            ),
            
          ),
         
          
        
        );
       
      },
    );
    overlayState?.insert(overlayEntry!);
    
   
  }
  show_image(BuildContext cont , url){
    return showDialog(
      context: cont, 
      builder: (context) {
        return  Container(
           
            width: MediaQuery.of(context).size.width / 2 ,
            height: MediaQuery.of(context).size.height / 2 ,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(url , fit: BoxFit.fitHeight,)

                ],
              ),
            ),
          );
        
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Container(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemCount: Online_Images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: () {
                  // _popupdialog = _createPopDialog(Online_Images[index] , context);
                  // Overlay.of(context)?.insert(_popupdialog!);
                  showoverlay(context , Online_Images[index],size);
                },
                onLongPressEnd: (details) {
                   overlayEntry!.remove();
                 // _popupdialog?.remove();

                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Image.network(Online_Images[index] , fit: BoxFit.cover,),
                  ),
                ),
              );
            },
          ),
        )
      ),
    );
  }
  
}
_createpopupcontent(String url, BuildContext context){
  return showDialog(
    context: context, 
    builder: (context) {
      return AspectRatio(
        aspectRatio: 3/2,
        child: Container(
          // width: MediaQuery.of(context).size.width ,
          // height: MediaQuery.of(context).size.height / 1.5 ,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(url , fit: BoxFit.fitHeight,)
      
              ],
            ),
          ),
        ),
      );
    },
  );

}