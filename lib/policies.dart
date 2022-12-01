import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class policies extends StatefulWidget {
  const policies({super.key});

  @override
  State<policies> createState() => _policiesState();
}

class _policiesState extends State<policies> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: size.height / 15),
            Container(
             
                 child: Row(
                   children: [
                      IconButton(
                        onPressed: (){
                          Navigator.pop(context);
                        }, 
                        icon: Icon(Icons.arrow_back , color: Colors.blue,)
                      ),
                     Text("Policy Of FriDay ChatApp" ,textAlign: TextAlign.center, style: TextStyle(color: Colors.blueAccent,
                         fontWeight: FontWeight.w900, fontFamily: "SansFont" , fontSize: 20),),
                   ],
                 ),
                  
      
            ),
            SizedBox(height: size.height / 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: EdgeInsets.all(8),
              
                child: Column(
                  
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
            
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("1. Send consolidated messages" , style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500, 
                       color: Color.fromARGB(221, 31, 31, 31)),),
                    ),
                    Text("       Many people approach chat as spoken conversation in written form. This can make chat conversations feel more casual and relaxed than a formally composed email, but it can also make chats feel more disjointed and broken. A series of separate chat messages can be distracting and annoying." , style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400, 
                     color: Color.fromARGB(221, 31, 31, 31)),),
                     SizedBox(height: size.height / 30,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("2. Encourage and respect the use of ‘Do Not Disturb’ status" , style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500, 
                       color: Color.fromARGB(221, 31, 31, 31)),),
                    ),
                    Text("       When you see a closed door, you should knock; you don’t barge in and start asking questions. You should follow the same workplace etiquette for virtual doors. If someone on your team has a “do not disturb” status, treat it like a closed office door. They might be in a meeting, on a break, or not feeling well." , style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400, 
                     color: Color.fromARGB(221, 31, 31, 31)),),
                     SizedBox(height: size.height / 30,),
                     Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("3. Send chats only to relevant people" , style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500, 
                       color: Color.fromARGB(221, 31, 31, 31)),),
                    ),
                    Text("       Anyone who has regularly used company email has likely received a reply all that should have just been a reply. This mistake can have a compound effect when others pile on and start replying all to the previous reply all." , style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400, 
                     color: Color.fromARGB(221, 31, 31, 31)),),
                     SizedBox(height: size.height / 30,),
                     Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("4. Use different communication channels for what they’re intended" , style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500, 
                       color: Color.fromARGB(221, 31, 31, 31)),),
                    ),
                    Text("       Collaboration tools have many advantages over email, but there’s a reason that email is still one of the most popular forms of communication in the world.\n      Always try to factor in urgency, sensitivity, and record keeping when deciding how to deliver a message. For example, a face-to-face conversation or phone call is ideal in urgent or sensitive situations, but typically does not leave a record for reference. Email is great for non-urgent announcements that may need to be referenced later, but not so much for sensitive or urgent situations. Finally, online chat and messaging is ideal for casual, ongoing collaboration and project-related discussion, but might be missed in an urgent situation or come across as cold when discussing sensitive matters." , style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400, 
                     color: Color.fromARGB(221, 31, 31, 31)),),
                     SizedBox(height: size.height / 30,),
                     Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("5. Have fun with GIFs and emojis, but don’t overdo it" , style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500, 
                       color: Color.fromARGB(221, 31, 31, 31)),),
                    ),
                    Text("       Even in a work environment, we are still humans and entitled to having some fun. This can include using cheeky emojis and GIFs in work chat conversations. In fact, these conversational techniques can add emotional complexity and tone to a text conversation where it might otherwise be impossible." , style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400, 
                     color: Color.fromARGB(221, 31, 31, 31)),),
                     SizedBox(height: size.height / 30,),
                     Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("6. Be friendly and polite" , style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500, 
                       color: Color.fromARGB(221, 31, 31, 31)),),
                    ),
                    Text("       It is clear that with remote work success comes the need for live chat tools to make communication easier, but don't forget about your workers' mental health. Remember to be friendly and polite, especially when working remotely." , style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400, 
                     color: Color.fromARGB(221, 31, 31, 31)),),
                     SizedBox(height: size.height / 30,),
                     Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("7. Be mindful of cultural context" , style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500, 
                       color: Color.fromARGB(221, 31, 31, 31)),),
                    ),
                    Text("       If you work at a multinational company, you will eventually have the opportunity to collaborate with colleagues from different cultures. For this reason, it’s important to avoid overusing slang and making regional references when making small talk." , style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400, 
                     color: Color.fromARGB(221, 31, 31, 31)),),
                     SizedBox(height: size.height / 30,),
                     

                   
                  ],
            
            
                ),
            
              ),
            ),
          ],
        ),
      ),
    );
  }
}