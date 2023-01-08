import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';

class ratio_image extends StatefulWidget {
  const ratio_image({super.key});

  @override
  State<ratio_image> createState() => _ratio_imageState();
}

class _ratio_imageState extends State<ratio_image> {
  File? _image;
  int? hh;
  int? ww;
  var hight;
  var width;
  var ratio ;
  bool isstart = false;
  Future<void> pick_image() async{
    
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(image != null) {
      setState(() {
        _image = File(image.path);
      });
      await crop_image();
      var decode_image = await decodeImageFromList(_image!.readAsBytesSync());
      
      setState(() {
        hight = decode_image.height;
        width = decode_image.width;
        if(hight > 1000){
         
          log("images size : true");
        }
        ratio = "$hight/$width";
        isstart = true;
      });
      log("imageHW : $hight/$width");
    }
  }
  Future crop_image() async{
    CroppedFile? crop_img = await ImageCropper().cropImage(sourcePath: _image!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'ImageCropper',
            toolbarColor: Color.fromARGB(255, 10, 100, 0),
            toolbarWidgetColor: Color.fromARGB(255, 255, 255, 255),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            activeControlsWidgetColor: Color.fromARGB(255, 10, 100, 0),
          ),
        
      ]
    );
    if(crop_img !=  null){
      setState(() {
        _image = File(crop_img.path);
      });
    }
    
  }
 
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    pick_image();
                  
                  }, 
                  child: Text("PICK IMAGE")
                ),
                isstart ? AspectRatio(
                  aspectRatio:width/hight,
                  child: Container(
                    padding: EdgeInsets.all(3),
                    child: Image.file(_image!),
          
                    color: Colors.red,
                  ),
                   
                ):Container(),
                ElevatedButton(
                  onPressed: () {
                  
                  
                  }, 
                  child: Text("gallery saver images....")
                ),
                ElevatedButton(
                  onPressed: () {
                   
                  
                  }, 
                  child: Text("saved images othe method....")
                )


                
              ],
            ),
          ),
        ),
    
      ),
    );
  }
}