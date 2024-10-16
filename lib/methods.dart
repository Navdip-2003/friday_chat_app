



import 'dart:developer';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friday_chat_app/home.dart';
import 'package:friday_chat_app/log/login.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<User?> createaccount(String name, String email ,String password, BuildContext context) async{
    
    try{
      User? user = (await _auth.createUserWithEmailAndPassword( email: email, password: password)).user;
      if(user != null){
        
        print("account successfully created");
        print("users details is = " + user.toString());
        user.updateProfile(displayName: name);
        await _firestore.collection("users").doc(_auth.currentUser?.uid).set({
          "name" : name,
          "email" : email,  
          "status" : "unavailable" ,
          "uid" : _auth.currentUser?.uid,
          "phone" : "",
          "firstname":name, 
          "lastname":"",
          "image": blank_image,
          "nick_name":""
        });
        //await _firestore.collection("cont_post").doc(_auth.currentUser!.uid);
        return user;
      }else{
        print(user);
        print("user does not created");
        return user;
      }
      

    } on FirebaseAuthException catch(e){
      print(e.code);
      print(e);
      if(e.code == 'invalid-email'){
        var det = "The email address is badly formatted.";
        show_snak(context,det);
      }else if
        (e.code == 'weak-password'){
          var det = "Password should be at least 6 characters !!";
          show_snak(context,det);
      }else if
        (e.code == 'email-already-in-use'){
          var det = "The email address is already in use by another account. !!";
          show_snak(context,det);
      }else if
        (e.code == 'operation-not-allowed'){
          var det = "The email address is operation not allowed. !!";
          show_snak(context,det);
      }else if
        (e.code == 'invalid-credential'){
          var det = "The email is Invalid. !!";
          show_snak(context,det);
      }
      
    }catch(er){
      print(er);
    }

  }

  Future<User?> loginaccount(String email , String password, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    try{
      User? user = (await _auth.signInWithEmailAndPassword(email: email, password: password)).user;
      if(user != null){
      
        print("user login done");
        print("info is : "+user.toString());
        return user;
      }else{
        print("user is not login");
        return user;
      }

    } on FirebaseAuthException catch(e){
      print(e.code);
      print(e);
      if(e.code == 'user-not-found'){
        var det = "There is no user record corresponding to this identifier.";
        show_snak(context,det);
      }else if
      (e.code == 'wrong-password'){
        var det = "The password is invalid or the user does not have a password.";
        show_snak(context,det);
      }else if
      (e.code == 'too-many-requests'){
        var det = "We have blocked all requests from this device due to unusual activity. Try again later.";
        show_snak(context,det);
      }else if
      (e.code == 'user-disabled'){
        var det = "We have Disabled all requests. Try again later.";
        show_snak(context,det);     
      }else if
      (e.code == 'operation-not-allowed'){
        var det = "This request is not allowed from Server. Try again later.";
        show_snak(context,det); 
      }
    
    }catch(er){
      print(er);
    }
  }
  Future<void> signout()async{
    FirebaseAuth _auth = FirebaseAuth.instance;
    try{
      await _auth.signOut();
    
      if(_auth.currentUser == null){
        print("user is signout");
      }

    }catch(e){
      print(e);
    }
  }

  void saved_image_galary(String path, BuildContext context){
    GallerySaver.saveImage(path).then((value) {
        log("images save status : $value");
        show_snak(context, "Download image done !!");
      });

  }

  Future<bool> request_permission(Permission permissions)async{
    if(await permissions.isGranted){
      return true;
    }else{
      var result = await permissions.request();
      if(result == permissions.isGranted){
        return true;
      }else{
        return false;
      }
    } 
  }

  var local_directory_path;

  Future<void> Storage_create_folder() async{
    SharedPreferences share = await SharedPreferences.getInstance();
    Directory? directory;
    try{
      if(await request_permission(Permission.storage)){
        directory = await getExternalStorageDirectory();
        log("${directory!.path}");
        String newpath = "";
        print(directory.path.split("/"));

        var split_file = directory.path.split("/");
        ///storage/emulated/0//data/com.example.friday_chat_app/files

        for(int i = 1 ;  i < split_file.length ; i++){
          if(split_file[i] != "Android"){
            newpath += "/" + split_file[i];
          }else{
            break;
          }
        }
        newpath = newpath +"/FridayData";
        directory = Directory(newpath);
        log("new path is : ${newpath}");
        local_directory_path = newpath;
        share.setString("loc_path", newpath);

        if(!await directory.exists()){
          await directory.create(recursive: true);
        }

      }else{
        Fluttertoast.showToast(msg: "Storage permission denied !!");
      }

      
      
    }catch(e){
      print(e);

    }
  
  }
  
  
  Future<void> create_loc_directory() async{
    SharedPreferences share = await SharedPreferences.getInstance();
    String? loc_path = share.getString("loc_path");
    if(loc_path == ""){
      await Storage_create_folder();
    }else{
      await Directory(loc_path!).create(recursive: true).then((value) {
        log("folder create Done!!");
      });
    }
    
    // if(!await Directory(loc_path!).exists()){
    //   await Directory(loc_path).create(recursive: true);
    //   return true;

    // }else{
    //   log("Directory not created exists!!");
    //   return false;
      
    // }

  }

