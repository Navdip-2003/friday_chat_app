import 'package:cloud_firestore/cloud_firestore.dart';
List Datagroup = [
  {
    "message":"hii",
    "sendy": "Navdip",
    "type":"text",
    "time":  FieldValue.serverTimestamp()
  },
  {
    "message":"hii",
    "sendy": "Navdip",
    "type":"text",
    "time":  FieldValue.serverTimestamp()
  }
];

void add_group_data()async{
  FirebaseFirestore.instance.collection("groups").doc("bcf5ef30-5e67-11ed-93c7-bfeb5526065d").
    collection("chats").add(Datagroup[0]).then((value) { print("data add successfully ....");});
}