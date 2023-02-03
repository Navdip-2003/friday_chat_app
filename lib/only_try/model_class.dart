import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
class model_class extends StatefulWidget {
  const model_class({super.key});

  @override
  State<model_class> createState() => _model_classState();
}

class _model_classState extends State<model_class> {
  List data = [];
  bool isloading = false;
  void getdata(){
    isloading =true;
    setState(() {
      
    });
     FirebaseFirestore.instance.collection("users").get().then((value){

        value.docs.forEach((element) {
            
            data.addAll(element.data().values);
        });
        setState(() {
          isloading = false;
        });
     });

    print(data);


  }
   bool is_reaction = false; 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getdata();
    
  }

  @override
  Widget build(BuildContext context) {
  
    
    return Scaffold(
      body:
      Center(
        child: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text("I am navdip patel .. "),
              ),
              Padding(padding: EdgeInsets.all(10)),
              is_reaction ?
                Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color.fromARGB(255, 143, 1, 1)
                  ),
                ) : SizedBox(),
              InkWell(
                onLongPress: () {
                  setState(() {
                    is_reaction = true;
                  });
                  
                },
                
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text("hii how are you"),
                ),
              ),
            ],
          ),
        )
        )
      //  isloading ? Center(child: CircularProgressIndicator(),)  : Container(
      //   child: Column(
      //     children: [
      //       Center(
      //         child: Container(
      //           height: 500,
      //           width: double.infinity,
      //           child: ListView.builder(
      //             itemCount: data.length,
      //             itemBuilder:  (context, index) {
      //               return ListTile(
      //                 title: Text(data[index]) ,
      //               );
      //             },
      //           ),

      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

}