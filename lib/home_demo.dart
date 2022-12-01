import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:friday_chat_app/contact.dart';

class home_demo extends StatefulWidget {
  const home_demo({super.key});

  @override
  State<home_demo> createState() => _home_demoState();
}

class _home_demoState extends State<home_demo> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
            
            decoration: BoxDecoration(
                 color: Colors.cyanAccent,
                 borderRadius: BorderRadius.only(
                   topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20)
                 )
            ),
       
            height: size.height / 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                   // color: Colors.yellowAccent,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network("https://i.pinimg.com/236x/6a/c4/5e/6ac45ea5a3f5ace324b79b8f36d30f27.jpg"),
                      ),
                    ),
                  )
                ),
                Flexible(
                  flex: 4,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                  //    color: Color.fromARGB(255, 162, 162, 61),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height / 80,),
                          Padding(
                            padding: const EdgeInsets.only( left: 5),
                            child: Text("Navdip patel chothani", style: TextStyle(
                              fontSize: 20 ,overflow: TextOverflow.ellipsis,
                               fontFamily: "SansFont" , fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(height: size.height / 100,),
                            Row(
                              children: [
                                Image.asset("asset/read.png" ,scale: 30,color: Colors.black54,),
                                SizedBox(width: size.width / 50,),
                                Text("hii How are you .." ,
                                 style: TextStyle(
                                  color: Colors.black54
                                 ),overflow: TextOverflow.ellipsis,)
                              ],
                            )
                        ],
                      ),
                    ),
                  )
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                   
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("03:11"),
                          SizedBox(height: size.height / 100,),
                          Visibility(
                            visible: true,
                            child: Icon(Icons.circle , size: 10 , color: Color.fromARGB(255, 2, 146, 36),)
                          )
                        ],
                      ),
                    ),
                  )
                )
              ],

            ),

          ),
        ) 
      ),
    );





    // Scaffold(
    //   body: Center(
    //     child: Container(
    //       decoration: BoxDecoration(
    //        // borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
    //        color: Color.fromARGB(153, 213, 212, 212),
    //         border: Border(
    //           bottom: BorderSide(
    //             width: 1
    //           )
    //         )

    //       ),
    //       height: size.height / 9,
    //       width: size.width,
    //       child: Row(
    //         children: [
    //           Padding(
    //             padding: const EdgeInsets.only(left: 5),
    //             child: Container(
    //              height: size.height / 10,
    //              width: size.width / 5,
    //              child: CircleAvatar(
    //               radius: 10,
    //                child: ClipRRect(
    //                 borderRadius: BorderRadius.circular(100),
    //                 child: Image.network("https://i.pinimg.com/236x/6a/c4/5e/6ac45ea5a3f5ace324b79b8f36d30f27.jpg"),
    //                ),
    //              )
    //             ),
    //           ),
    //           Container(width: size.width / 20,),
    //           Container(
    //             child: Column(
    //              mainAxisAlignment: MainAxisAlignment.start,
    //               children: [
    //                 Padding(
    //                   padding: const EdgeInsets.only(top: 15),
    //                   child: Text("Navdip Patel" , 
    //                     style: TextStyle(fontSize: 20 , fontFamily: "SansFont" , fontWeight: FontWeight.w600),),
    //                 ),
    //                 Container(height: size.height / 55,),
    //                 Container(
    //                   width: size.width / 2,
                      
    //                   child: Row(
    //                     mainAxisAlignment: MainAxisAlignment.start,
    //                     children: [
    //                       Icon(Icons.alarm),
    //                       SizedBox(width: size.width/ 30,),
    //                       Text("data")
    //                     ],
    //                   ),
                      
    //                 )
    //               ],
                  
    //             ),
    //           ),
    //           Expanded(child: Container()),
    //           Container(
                
               
    //             height: size.height / 15,
    //             width: size.width /5,
             
    //             child: Padding(
    //               padding: const EdgeInsets.all(10.0),
    //               child: Center(child: Text("03:56")),
    //             ),
    //           )

    //         ],
    //       ),

    //     ),
    //   ),
    // );
  }
}