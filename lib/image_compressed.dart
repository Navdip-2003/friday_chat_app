import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:uuid/uuid.dart';


class compressed_image extends StatefulWidget {
  const compressed_image({super.key});

  @override
  State<compressed_image> createState() => _compressed_imageState();
}

class _compressed_imageState extends State<compressed_image> {
  File? _image;
  File? _comimage;
  
  Future<void> pick_image() async{
    
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(image != null) {
      setState(() {
        _image = File(image.path);
       
        var size = _image!.lengthSync() / 1024;
        log("Original size: $size kb");
      });
      var size_img = _image!.lengthSync() / 1024;
      
      await crop_image();
      if(size_img > 1000) {
        print("image size is greater than 2");
        await compressed_images();
      }else{
        print("image is less than 2");
        _comimage = File(_image!.path);
      }
    }
  }
  String path = "/storage/emulated/0/DCIM/img1.jpg";
  Future<void> compressed_images() async{

    final comp_image = await FlutterNativeImage.compressImage(_image!.path , quality: 50);
    if(comp_image != null){
      setState(() {
        _comimage = File(comp_image.path);
        var size =_comimage!.lengthSync() / 1024;
        log("compressed size : $size KB");
        
      });
    }
  }
  String image_url = "";
  void upload_image() async {
    var filename = Uuid().v1();
   
    var ref = FirebaseStorage.instance.ref().child("compress_images").child("$filename.jpg");
    var up_image = await ref.putFile(_comimage!);
    image_url = await up_image.ref.getDownloadURL();
    print(image_url);
    
  }
  Future crop_image() async{
    CroppedFile? crop_img = await ImageCropper().cropImage(sourcePath: _image!.path);
    setState(() {
      _image = File(crop_img!.path);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: (){
                pick_image();

              }, 
              child: Text("pick image")
            ),
            TextButton(
              onPressed: (){
                compressed_images();
              }, 
              child: Text("compressed image")
            ),
            TextButton(
              onPressed: (){
                upload_image();
              }, 
              child: Text("upload image")
            )
          ],
        ),
      ),
    );
  }
}
