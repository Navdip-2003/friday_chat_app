

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friday_chat_app/chat_screen/chatroom.dart';
import 'package:friday_chat_app/contact.dart';
import 'package:friday_chat_app/variables.dart';

class dis_homepage extends StatefulWidget {
  const dis_homepage({super.key});

  @override
  State<dis_homepage> createState() => _dis_homepageState();
}

class _dis_homepageState extends State<dis_homepage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
 

  @override
  Widget build(BuildContext context) {
    var rang= MediaQuery.of(context);
    return Scaffold(
      
      appBar: AppBar(title: Text("Only DEMO"),
      toolbarHeight: rang.size.height / 13,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          
        ),
      ),
        leading: Icon(Icons.menu),
        actions: [
          IconButton(
             onPressed: () { 
              showSearch(context: context, delegate: datasearch());

              }, 
            icon: Icon(Icons.search , size: rang.size.height /30,),
          ),
          Container(width: rang.size.width / 25,)
        ],
      ),            
    );
  }
}


class datasearch extends SearchDelegate<String>{
  var list_city =["surat" , "amdavad", "amreli" , "bhavanager" , "rajkot"];
  var re_city =["palitana" ,"valasad"];
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [IconButton(onPressed: (){ 
    }, icon: Icon(Icons.clear))];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(onPressed: (){
      close(context, "ook");
    }, icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: transitionAnimation,
    ));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Container(child: Text("User is not found !!"),));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    String roomid(String user1, String user2)  {
    if(user1.toLowerCase().codeUnits[0] > user2.toLowerCase().codeUnits[0]){
      //  print("chat room id id the : $user1$user2");
        return "$user1$user2";
      }else{
      // print("chat room id id the  :$user2$user1");
        return "$user2$user1";
      }
    }

      return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context , snapshot){
          return (snapshot.connectionState == ConnectionState.waiting) ? 
           Center(child: CircularProgressIndicator(),) : 
           ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data  = snapshot.data!.docs[index].data() as Map<String , dynamic>;
              if(query.isEmpty){
                return Column(
                  children: [
                    ListTile(
                      leading: data["image"] == "" ? CircleAvatar(radius: 30, backgroundColor: Colors.blueAccent,) :  CircleAvatar(radius: 30, backgroundImage: NetworkImage(data["image"]),),
                      title: Text(data["name"]),
                      subtitle: Text(data["email"]),
                      
                    ),
                    Divider(color: Colors.black54,height: 2,indent: 10,endIndent: 10,)
                  ],
                );

              }
               if(data["name"].toString().toLowerCase().startsWith(query.toLowerCase())){
                return Column(
                  children: [
                    ListTile(
                      onTap: () async{
                        print(data["email"]);
                         String user2 = data["name"];
                          String? user1 = user_name;
                          String chatroom_id = roomid(user1.toString(),user2 );
                          print(chatroom_id);
                          var usermap ;
                          await FirebaseFirestore.instance.collection("users").where("email" , isEqualTo: data["email"]).get().then((value) {
                            usermap = value.docs[0].data();
                          });

                          Navigator.push(context, MaterialPageRoute(builder: (context)=>chatroom(chat_id: chatroom_id, usermap: usermap)));
                        
                       
                      },
                      leading: data["image"] == "" ? CircleAvatar(radius: 30, backgroundColor: Colors.blueAccent,) :  CircleAvatar(radius: 30, backgroundImage: NetworkImage(data["image"]),),
                      title: Text(data["name"]),
                      subtitle: Text(data["email"]),
                     
                    ),
                    Divider(color: Colors.black54,height: 2,indent: 10,endIndent: 10,)

                  ],
                );
               }

               return Container();
             
            },
           );

      });


    //var sugg_list = query.isEmpty ? re_city : list_city.where((element) => element.startsWith(query)).toList(); 
    
    
    //  return ListView.builder(
    //   itemCount: sugg_list.length ,
    //   itemBuilder: (context , index){
    //     return InkWell(
    //       onTap: (){
            
    //         print("item is clickes : "+ sugg_list[index]);
    //       },
    //       child: ListTile(
    //         leading: Icon(Icons.person),
    //         title: Text(sugg_list[index]),
    //       ),
    //     );
    //   } 
    // );
    
  }
  

}