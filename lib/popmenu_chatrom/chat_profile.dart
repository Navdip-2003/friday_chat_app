import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:friday_chat_app/main.dart';

class chat_profile extends StatefulWidget {
  Map<String, dynamic> usermap;
  chat_profile({super.key, required this.usermap});

  @override
  State<chat_profile> createState() => _chat_profileState(usermap);
}

class _chat_profileState extends State<chat_profile> {
   Map<String, dynamic> usermap;
  _chat_profileState(this.usermap);

  @override
  Widget build(BuildContext context) {
    var size= MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              Container(  
                child: Stack(

                  children: [
                    Positioned(
                      child: Container(
                        height: size.height / 3,
                        width: double.infinity,

                        decoration: BoxDecoration(

                          image: DecorationImage( 
                            image: NetworkImage(usermap["image"] != null ? usermap["image"] : "https://images.unsplash.com/photo-1666478216294-b31ef20ab804?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwyM3x8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60")
                            , fit: BoxFit.cover)
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top:30,
                      left: 10,
                        child: Hero(
                          tag: "chatroom",
                          child: IconButton(icon: Icon(Icons.arrow_back),
                            onPressed: (){
                              Navigator.pop(context);
                            },
                          ),
                        )
                      )
                  ],
                ),
              ),
              Positioned(
              
                
                child: Padding(
                  padding: const EdgeInsets.only(top: 120),
                  child: Container(
                    height: size.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white

                    ),
                    child: Container(
                      width: size.width,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 70,
                          ),
                          Container(
                            child: Text(usermap["name"] != null ? usermap["name"] : "Name"  
                              ,style: TextStyle(
                              fontFamily: "SansFont" ,fontWeight: FontWeight.w600 ,fontSize: 25 , color: Color.fromARGB(255, 6, 76, 113)
                            ),),

                          ),
                          SizedBox(
                            height: 0,
                          ),
                          Container(
                            child: Text(usermap["nick_name"] != null ? usermap["nick_name"] : "Nick Name",
                            style: TextStyle(
                              fontWeight: FontWeight.w500 ,fontSize: 15 , color: Color.fromARGB(255, 36, 75, 97)
                            ),),

                          ),
                           SizedBox(
                            height: 25,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Container(
                              width: size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [

                                  Container(
                                    child: Row(
                                      children: [
                                        Icon(Icons.email),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 20),
                                          child: Container(child: Text(usermap["email"] != null ? usermap["email"] : "Email"
                                           , overflow: TextOverflow.ellipsis,)),
                                        )
                                      ],
                                    ),
                                  ),
                                   SizedBox(
                                      height: 5,
                                    ),
                                   Container(
                                    child: Row(
                                      children: [
                                        Icon(Icons.phone),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 20),
                                          child: Container(child: Text( usermap["phone"] != null ? usermap["phone"] : "phone"
                                            , overflow: TextOverflow.ellipsis,)),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )

                        ],
                      ),

                      
                    ),
                    
                  
                  ),
                ),
              )
            
            ],
          ),
          Positioned(
            top: 60,
            child: Container(
              width: size.width,
              child: Center(
                child: CircleAvatar(
                  radius: 61,
                  backgroundColor: Colors.black54,

                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(usermap["image"] != null ? usermap["image"] : "https://images.unsplash.com/photo-1666478216294-b31ef20ab804?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwyM3x8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60"),
                  ),
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}