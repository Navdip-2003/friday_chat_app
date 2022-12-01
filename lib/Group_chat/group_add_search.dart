import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friday_chat_app/Group_chat/grop_name.dart';
import 'package:firebase_auth/firebase_auth.dart';
class group_add_search extends StatefulWidget {
  const group_add_search({super.key});

  @override
  State<group_add_search> createState() => _group_add_searchState();
}

class _group_add_searchState extends State<group_add_search> {
  var _firestore = FirebaseFirestore.instance;
  var _auth = FirebaseAuth.instance;
  Map<String , dynamic>? usermap ;

  List<Map<String, dynamic>> member_list =[];
  var sea = "";
  TextEditingController result = TextEditingController();
  void getcurrentuserdata() async{
    await _firestore.collection("users").doc(_auth.currentUser!.uid).get().then((value) {
      setState(() {
        member_list.add({
        "name" : value["name"],
        "uid":value["uid"],
        "email" : value["email"],
        "isadmin" : true,
        "image" : value["image"]
      });
      });
      
    });
  }
  void onresulttap(Map<String, dynamic> data){
    bool isalreadyexist = false;
    for( int i=0 ; i < member_list.length ;i++){
      if(member_list[i]["uid"] == data["uid"]){
        isalreadyexist = true;
      }
    }
    if(!isalreadyexist){
       setState(() {
        member_list.add({
          "name" : data["name"],
          "uid":data["uid"],
          "email" : data["email"],
          "isadmin" : false,
          "image" : data["image"]

      });
    });
    }
   
  } 
  void onremovetap(int index){
    if(member_list[index]["uid"] != _auth.currentUser!.uid){
      setState(() {
            member_list.removeAt(index);
      });
    }
    

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getcurrentuserdata();
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        flexibleSpace: Container(
          color: Color.fromARGB(255, 124, 123, 123),
        ),
        title: Text("New Group ...") ,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                
                height: size.height / 8 ,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: member_list.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(member_list[index]["image"] == "" ? 
                                "https://images.unsplash.com/photo-1666934209593-25b6aa02ab4e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzMnx8fGVufDB8fHx8&auto=format&fit=crop&w=500&q=60" :
                                  member_list[index]["image"] ),
                              ),
                              Positioned(
                                top: 25,
                                left: 25,
                                child: IconButton(
                                  
                                  onPressed: (){
                                    onremovetap(index);
      
                                  },
                                  icon: Icon(Icons.close_outlined ,)
                                ) 
                              ),
                            ],
                          ),
                          Container(
                            
                            width: size.width /7,
                            child: Text(member_list[index]["name"], overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 13 
                              ),textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10, left: 10),
                child: TextField(
                  onChanged: (value){
                    setState(() {
                      sea = value;
                      
                    });
                  },
                  controller: result,
                  expands: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    isCollapsed: true,
                    contentPadding: EdgeInsets.all(10),
                    hintText: "Search ..."
                  ),
      
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(top: 10 , left: 10 , right:10),
                  child: Container(
                    height: size.height / 1.43,
                    child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("users").snapshots(),
                    builder: (context, snapshot) {
                            return (snapshot.connectionState == ConnectionState.waiting) ? 
                              Center(child: CircularProgressIndicator()) : 
                              ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var data = snapshot.data!.docs[index].data() as Map<String , dynamic>;
                                  if(sea.isEmpty){
                                    return ListTile(
                                      title: Text(data["name"]),
                                      subtitle: Text(data["email"]),
                                      leading: data["image"] == "" ? CircleAvatar(
                                        backgroundColor: Colors.greenAccent,radius: 30,
                                        ):
                                        CircleAvatar(backgroundImage: NetworkImage(data["image"]),radius: 30,),
                                      trailing: IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: (){
                                          onresulttap(data);
                                          print(member_list);

      
                                        },
                                      ),
                                    );
                                    
                                  }
                                  if(data["email"].toString().toLowerCase().startsWith(sea.toLowerCase())){
                                    return ListTile(
                                      title: Text(data["name"]),
                                      subtitle: Text(data["email"]),
                                      leading: data["image"] == "" ? CircleAvatar(
                                        backgroundColor: Colors.greenAccent,radius: 30,
                                      ):
                                      CircleAvatar(backgroundImage: NetworkImage(data["image"]),radius: 30,),
                                      trailing: IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: (){
                                           onresulttap(data);
                                            
                                        },
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              );
                          },
                    ),
                  ),
                ),
              ),
            ],
          )
        ),
      ),
      floatingActionButton: member_list.length >= 2 ? FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> gruop_name(member : member_list)));
        },
        child: Icon(Icons.forward),
      ) : SizedBox(),

    );
  }
}