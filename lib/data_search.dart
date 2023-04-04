
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friday_chat_app/chat_screen/chatroom.dart';
import 'package:friday_chat_app/variables.dart';
class data_search extends SearchDelegate<String>{

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
                          // String chatroom_id = roomid(user1.toString(),user2 );
                          // print(chatroom_id);
                          // bool exist_chatroom = true;
                          // await FirebaseFirestore.instance.collection("chatroom").doc(chatroom_id).get().then((value) {
                          //   value.exists ? exist_chatroom = true : exist_chatroom = false;
                          //   print(exist_chatroom);
                          // });
                          // print(exist_chatroom);
                          var usermap ;
                          await FirebaseFirestore.instance.collection("users").doc(data["uid"]).get().then((value) {
                            usermap = value.data();
                          });
                          String ci = get_chatid(FirebaseAuth.instance.currentUser!.uid, data["uid"]);
                          print(ci);
                          print(usermap);

                          

                          Navigator.push(context, MaterialPageRoute(builder: (context)=>chatroom(chat_id: ci, usermap: usermap)));
                        
                       
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