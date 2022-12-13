import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:friday_chat_app/contact.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friday_chat_app/log/login.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

class edit_profile extends StatefulWidget {
  const edit_profile({super.key});

  @override
  State<edit_profile> createState() => _edit_profileState();
}

class _edit_profileState extends State<edit_profile> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _store = FirebaseFirestore.instance;

  TextEditingController name = TextEditingController();
  TextEditingController nick_name= TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController first_name = TextEditingController();
  TextEditingController Last_name = TextEditingController();
  TextEditingController email = TextEditingController();

  ImagePicker _picker = ImagePicker();
  File? pick_image;
  Future image_picker(ImageSource soc) async{
    XFile? image = await _picker.pickImage(source: soc );
    if(image != null){
      setState(() {
        pick_image = File(image.path);
        upload_image();
      });
    }
  }
  
Future upload_image() async {
  int status = 1;
  var filename = Uuid().v1();
  var ref = FirebaseStorage.instance.ref().child("profile_image").child("$filename.jpg");
  var up_image = await ref.putFile(pick_image!).catchError((error) async{
      print("image is not updated");
      status = 0;
  });
  if(status == 1){
    String image_url = await up_image.ref.getDownloadURL();
    print(image_url);
    
    
    await _store.collection("users").doc(ddata!["uid"]).update({
      "image" : image_url
    });  

  }
}
  

  
void update_data() async{ 
  
    var nam =name.text;
    var emai = email.text;
    var phon = phone.text;
    var last = Last_name.text;
    var first = first_name.text;
    var nick = nick_name.text;
    await _store.collection("users").doc(ddata!["uid"]).update({
      "name" :nam,
      "phone" : phon,
      "firstname" : first,
      "lastname" : last,
      "nick_name" : nick
    }).then((value) => print("user data updated !!")).catchError((error)=>print("Failed update data ! error is : $error"));
   
  }

  var data;
  Future getdata() async{
    await _store.collection("users").where("email", isEqualTo: _auth.currentUser!.email).get().then((value) {
      data = value.docs[0].data();
    });
    print(data["name"]);
  }
 
  @override
  void initState() {
    // TODO: implement initState
   
  
    void fetchdata() async{
        await getdata();
        print(data["image"]);
        name.text = data["name"];
        email.text = data["email"];
        first_name.text=data["firstname"];
        Last_name.text=data["lastname"];
        nick_name.text=data["nick_name"];
        phone.text=data["phone"];
        
        
    }
    fetchdata();
   
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: 
         Container(
          child: Column(
            children: [
              SizedBox(height: size.height / 20,),
              //update and close icon
              Container(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: (){
                         Navigator.pop(context);

                      }, 
                      icon: Icon(Icons.close ,size: 30,)
                    ),
                    Expanded(child: Container()),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: (){
                         update_data();
                         Navigator.pop(context);

                        },
                        child: Image.asset("asset/right_tick.png" , scale: 2.5,)
                      ),
                    )
                    
                  ],
                ),
              ),
              //profile picture
              Container(  child: Center(
                  child: Stack(
                    children: [
                      Positioned(
                        child: pick_image == null ? 
                        Container(
                           width: size.width / 2.2 ,
                           height: size.height / 5,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(ddata!["image"] == "" ? "https://i.pinimg.com/236x/20/85/1e/20851efa9c2ac253e78584bd7f1ac55f.jpg" :
                              ddata!["image"]) ,   
                            )
                        ) :
                        Container(
                        width: size.width / 2.2 ,
                          height: size.height / 5,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: FileImage(File(pick_image!.path)) ,   
                              )
                        )

                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,

                        child: CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 0, 95, 3),
                          child: IconButton(onPressed: (){
                            showModalBottomSheet(
                              context: context,
                              builder: (Builder){
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    
                                  ),
                                  
                                  height: size.height / 5,
                                  child: Container(
                                    child: Column(
                                      
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Choose Profile Photo" , style: (TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.w500
                                          
                                        )),),
                                        Padding(
                                          padding: const EdgeInsets.all(30),
                                          child: Container(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                InkWell(
                                                  onTap: (){
                                                    image_picker(ImageSource.camera);
                                                    Navigator.pop(context);
                        
                                                  },
                                                  child: Container(
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.camera),
                                                        SizedBox(width: size.width / 55,),
                                                        Text("Camera")
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: size.width / 20,),
                                                InkWell(
                                                  onTap: (){
                                                    image_picker(ImageSource.gallery);
                                                    Navigator.pop(context);
                        
                                                  },
                                                  child: Container(
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.image),
                                                        SizedBox(width: size.width / 55,),
                                                        Text("Gallery")
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                        
                                          ),
                                        )
                        
                                      ],
                                    ),
                                  ),
                                );
                              }
                            );
                        
                        
                          }, 
                            icon: Icon(Icons.image ) ,),
                        )
                        
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height /25),
              //edit name
              Container( 
                child: Padding(
                  padding: const EdgeInsets.only(right: 15 , left: 15),
                  child: TextField(
                    enabled: false,
                   keyboardType: TextInputType.emailAddress,
                    controller: name,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.all(15),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black87 , width: 1 ,)
                      ),
                      labelStyle: TextStyle(color: Colors.black),
                      hintText: "Name",
                      suffixIcon: Icon(Icons.person , color: Colors.black54,),
                      labelText: "Name"
                    ),

                  ),
                ),
              ),
              SizedBox(height: size.height /40),
              //Email update
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(right: 15 , left: 15),
                  child: TextField(
                     enabled: false,
                    controller: email,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.all(15),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black87 , width: 1 ,)
                      ),
                      labelStyle: TextStyle(color: Colors.black),
                      hintText: "Email",
                      suffixIcon: Icon(Icons.email , color: Colors.black54,),
                      labelText: "Email"
                    ),

                  ),
                ), 
              ),
              SizedBox(height: size.height /40),
              //phone update
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(right: 15 , left: 15),
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    controller: phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.all(15),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black87 , width: 1 ,)
                      ),
                      labelStyle: TextStyle(color: Colors.black),
                      hintText: "Phone",
                      suffixIcon: Icon(Icons.phone , color: Colors.black54,),
                      labelText: "Phone"
                    ),

                  ),
                ),
                
              ),
              SizedBox(height: size.height /40),
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(right: 15 , left: 15),
                  child: TextField(
                    
                    controller: nick_name,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.all(15),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black87 , width: 1 ,)
                      ),
                      labelStyle: TextStyle(color: Colors.black),
                      hintText: "Nick Name",
                      suffixIcon: Icon(Icons.phone , color: Colors.black54,),
                      labelText: "Nick Name"
                    ),

                  ),
                ),
                
              ),
              SizedBox(height: size.height /35), 
              //firstname and lastname
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15 , left: 15),
                        child: TextField(
                          controller: first_name,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            isCollapsed: true,
                            contentPadding: EdgeInsets.all(15),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black87 , width: 1 ,)
                            ),
                            labelStyle: TextStyle(color: Colors.black),
                            hintText: "First Name",
                            //suffixIcon: Icon(Icons.phone , color: Colors.black54,),
                            labelText: "First Name"
                          ),

                          ),

                        ),
                    
                      ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15 , left: 15),
                        child: TextField(
                          controller: Last_name,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            isCollapsed: true,
                            contentPadding: EdgeInsets.all(15),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black87 , width: 1 ,)
                            ),
                            labelStyle: TextStyle(color: Colors.black),
                            hintText: "Surname",
                          //  suffixIcon: Icon(Icons.phone , color: Colors.black54,),
                            labelText: "Lastname"
                          ),

                          ),
                          
                        ),
                    
                      ),
                  ),
                ],
              ),
             
            ],
      
      
      
          ),
        ),
      ),
    );
  }
}