
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:friday_chat_app/home.dart';
import 'package:friday_chat_app/log/register.dart';
import 'package:friday_chat_app/methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friday_chat_app/navigation.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:lottie/lottie.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> with SingleTickerProviderStateMixin {
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool isloading = false;
  late AnimationController cont;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
     var user = FirebaseAuth.instance.currentUser;
      cont = AnimationController(
      duration: Duration(milliseconds: 750),
      vsync: this);
    print("Current User is :  " + user.toString());
  }
  

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: isloading ? Center(child: Lottie.asset("asset/loading.json", width: size.width / 7 , height: size.height ),) : 
      SingleChildScrollView(
        child: Column(
          children: [
            Container(height: size.height / 30,),
            Stack(
              children: [
                Container(
                    height: size.width  ,
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage("asset/login.png") , fit: BoxFit.cover ),
                      //color: Colors.tealAccent
                     
                    ),
                ),
                Positioned(
                  
                  left: size.height / 50,
                  child: Text("Welcome" , 
                    style: TextStyle( fontSize: 35 , fontWeight: FontWeight.w500) )
                ),
                Positioned(
                  top: size.height /15,
                  left: size.height / 50,
                  child: Text("SignIn" , 
                    style: TextStyle(fontFamily: 'sansfont' , fontSize: 25 , fontWeight: FontWeight.w500) )
                ),
              ],
            ),
            Container(
              width: size.width / 1.06,
              child: TextField(
                controller: email,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                   
                    borderRadius: BorderRadius.circular(15)
                  ),
                  prefixIcon: Icon(Icons.email , color: Colors.deepOrangeAccent , size: 30 ,),
                  hintText: "Enter Email",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color.fromARGB(255, 72, 34, 1))
                  ),
                  hintStyle: TextStyle(color: Colors.black54 ),
                  labelText: "Email",
                  labelStyle: TextStyle(color: Color.fromARGB(255, 191, 89, 6) , fontSize: 20)
                ),
      
              ),
            ),
            Container(height: size.height / 50,),
            Container(
              width: size.width / 1.06,
              child: TextField(
                controller: password,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                   
                    borderRadius: BorderRadius.circular(15)
                  ),
                  prefixIcon: Icon(Icons.lock , color: Colors.deepOrangeAccent , size: 30 ,),
                  hintText: "Enter password",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color.fromARGB(255, 72, 34, 1))
                  ),
                  hintStyle: TextStyle(color: Colors.black54 ),
                  labelText: "Password",
                  labelStyle: TextStyle(color: Color.fromARGB(255, 191, 89, 6) , fontSize: 20)
                ),
      
              ),
            ), 
            Container(height: size.height / 20,),
            InkWell(
              borderRadius: BorderRadius.all(Radius.circular(10)) ,
              onTap: ()   {

                // if(email.text.isNotEmpty && password.text.isNotEmpty){
                //   try{
                //     var authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: password.text);


                //   }catch(e){
                //     print(e); 
                //   }
                //   on FirebaseAuthException catch(e){
                //     if(e.code == 'weak-password' ){
                //       print("pass word error");
                //     }

                //   }

                // }else{
                //   Container();
                // }

                if(email.text.isNotEmpty && password.text.isNotEmpty){
                  setState(() {
                    isloading = true;
                  });
                loginaccount(email.text, password.text , context).then((user)  {
                  if(user != null){
                    print("login successful");
                    setState(() {
                      isloading = false;
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> navigation()), (route) => false);
                    });
                  }else{
                    print("login is failed");
                    setState(() {
                      isloading = false;
                    });
                  }
                });
                  
                }else{
                  show_snak(context, "All Field are Requried !!");
                }
                
                
              },
              child: Container(
                width: size.width /2.3,
                height: size.height / 18,
                
                decoration: BoxDecoration(
                 
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  gradient: LinearGradient(colors: [Colors.yellow , Colors.deepOrange]),
                  color: Colors.yellow,
                  
                ),
                child: Center(child: Text("Login" ,style: TextStyle(fontFamily: 'sansfont', fontSize: 18 , color: Colors.deepOrange , fontWeight: FontWeight.bold),)),
              ),
            ),
            Container(height: size.height /40,),
            Container(
              width: size.width  ,
              child: Center(
                child: Container(
                  width: size.width ,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Does't have an account ?" , style: TextStyle(fontSize: 15),),
                      TextButton(onPressed: (){
                         Navigator.push(context, MaterialPageRoute(builder: (context)=>register()));
              
                      }, child: Text("SignUp")
                    )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}