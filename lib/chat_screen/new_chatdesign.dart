import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class new_chatdesign extends StatefulWidget {
  const new_chatdesign({super.key});

  @override
  State<new_chatdesign> createState() => _new_chatdesignState();
}

class _new_chatdesignState extends State<new_chatdesign> {
  ScrollController sc = new ScrollController();
  TextEditingController mess = new TextEditingController();
  void scroll_bottom() async{
    await sc.animateTo(
      sc.position.maxScrollExtent,
      duration: const Duration(milliseconds: 600),
      curve: Curves.decelerate,
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData=MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    double screenHight = mediaQueryData.size.height;
    var toppadding=mediaQueryData.padding.top;
    var bottompadding=mediaQueryData.padding.bottom;
    if(mediaQueryData.viewInsets.bottom > 0){
      scroll_bottom();
    }


    return Padding(
      padding: EdgeInsets.only(top: toppadding , bottom: bottompadding),
      child: Scaffold(
        body: Container(
          
          height: screenHight,
         // color: Colors.amber,
          child: Column(
            children: [
              Container(
                height: screenHight / 12,
               // color: Colors.red,
                child: profile_chat_user(),
              ),
              Expanded(
                child: Container(
                  //height: screenHight - screenHight/12 - screenHight/20 - screenHight/20,
                  color: Colors.green,
                  child: ListView.builder(
                    controller: sc,
                    itemCount: 100,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: Colors.teal,
                          child: ListTile(
                            title: Text(index.toString()),
                            leading: CircleAvatar(),
                          ),
                        ),
                      );
                
                    },
                  ),
                )
              ),
              Container(
                //color: Colors.deepOrange,
               height: screenHight / 12,
                child: text_filed(),
              )
            ],
          ),
        ),
      ), 
    );
  }
 
 
 
  Widget profile_chat_user(){
    return Row(
      children: [
        Container(
         // color: Color.fromARGB(255, 255, 110, 66),
          child: back_Avatar_button(),
        ),
        Expanded(
          child: Container(
            // color: Color.fromARGB(255, 133, 31, 0),
             child: name_and_status_button(),
             
          ),
        ),
        Container(
           
           //color: Color.fromARGB(255, 48, 11, 0),
           child: popup_icon(),
        ),
      ],
    );
    

  }
  Widget back_Avatar_button(){
    return Container(
      padding: EdgeInsets.all(5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            child: Row(
              children: [
                Icon(Icons.arrow_back),
                CircleAvatar(
                  radius: 25, 
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget name_and_status_button(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AutoSizeText(
          "Navdip Chothani " ,
          maxFontSize: 18 ,
          minFontSize: 15,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold ,),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: AutoSizeText(
            "Online" ,
            maxFontSize: 8 ,
            minFontSize: 6,
            maxLines: 1,
            style: TextStyle(color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  Widget popup_icon(){
    return IconButton(
      onPressed: () {
      
      }, 
      icon: Icon(Icons.more_vert)
    );
  }
  
  Widget chat_screen(){
    return Container();

  }

  Widget text_filed(){
    return Container(
      color: Colors.red,
      alignment: Alignment.center,
     // margin: const EdgeInsets.symmetric( horizontal: 10 ),
     // height: 60,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5 , horizontal: 5 ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35.0),
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 7,
                      color: Colors.grey)
                ],
              ),
              child: Row(
                children: [
                  emoji(),
                  const Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          hintText: "Message",
                          hintStyle: TextStyle(color: Color(0xFF00BFA5)),
                          border: InputBorder.none),
                    ),
                  ),
                  Row(
                   children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: attach_file(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6, right: 8),
                        child: camera(),
                      ),
                    ],
                  )
                  
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: send_button()),
        
         
        ],
      ),
    );
        
  }
  Widget emoji(){
    return IconButton(
      onPressed: () {
        
      },  
      icon: Icon(Icons.mood)
    );
  }
  Widget attach_file(){
    return GestureDetector(
      onTap: () {
        
      },
      child: Icon(Icons.attach_file)
    );
    
  }
  Widget camera(){
    return  GestureDetector(
      onTap: () {
        
      },
      child: Icon(Icons.photo_camera)
    );
    
  }
  Widget send_button(){
    return CircleAvatar(
      backgroundColor: Colors.amber,
      child: IconButton(
        onPressed: () {
          
        },  
        icon: Icon(Icons.send)
      ),
    );
  }
   

}