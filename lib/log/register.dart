import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:friday_chat_app/log/login.dart';
import 'package:friday_chat_app/methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friday_chat_app/variables.dart';
import 'package:lottie/lottie.dart';
class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> with SingleTickerProviderStateMixin {
  var snak =1;

  TextEditingController name = new TextEditingController();

  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  var g_key = GlobalKey<FormState>();
  late AnimationController cont;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     cont = AnimationController(
      duration: Duration(milliseconds: 750),
      vsync: this);
   
    
  }
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size;
    return Scaffold(
      body: isloading ? Center( child: Lottie.asset("asset/loading.json", width: size.width / 7 , height: size.height )) : SingleChildScrollView(
        child: Form(
          key: g_key,
          child: Column(
            children: [
              Container(height: size.height / 30,),
              Stack(
                children: [
                  Container(
                      height: size.width  ,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage("asset/register.png") , fit: BoxFit.cover ),
                        //color: Colors.tealAccent
                       
                      ),
                  ),
                 
                  
                  Positioned(
                    top: size.height /20,
                    left: size.height / 50,
                    child: Text("SignUp" , 
                      style: TextStyle(fontFamily: 'sansfont' , fontSize: 25 , fontWeight: FontWeight.w500) )
                  ),
                ],
              ),
               Container(
                width: size.width / 1.06,
                child: TextField(
                  controller: name,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                     
                      borderRadius: BorderRadius.circular(15)
                    ),
                    prefixIcon: Icon(Icons.person , color: Colors.deepOrangeAccent , size: 30 ,),
                    hintText: "Enter User name",
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color.fromARGB(255, 72, 34, 1))
                    ),
                    hintStyle: TextStyle(color: Colors.black54 ),
                    labelText: "Name",
                    labelStyle: TextStyle(color: Color.fromARGB(255, 191, 89, 6) , fontSize: 20)
                  ),
              
                ),
              ),
              Container(height: size.height / 50,),
        
              Container(
                width: size.width / 1.06,
                child: TextFormField(
                  controller: email,
                  autocorrect: false,
                  validator: ((value) {
                    
                  }),
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
                onTap: (){
                  
                  if(name.text.isNotEmpty && email.text.isNotEmpty && password.text.isNotEmpty){
                    setState(() {
                      isloading = true;
                    });
                    createaccount(name.text, email.text, password.text , context).then((users)  {
                      if(users != null){
                        setState(() {
                          isloading = false;
                        });
                        print("details is " +users.toString());
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Account Created Done.. Please SignIn !!"),
                            duration: Duration(milliseconds: 2000),
                          ));
        
                        name.clear();
                        email.clear();
                        password.clear();
                      }else{
                        print("no account is created!!");
                        setState(() {
                          isloading = false;
                        });
                      }
        
                    });
                  }else{
                    var det = "All Field are Requried !!";
                    return show_snak(context, det);
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
                  child: Center(child: Text("Register" ,style: TextStyle(fontFamily: 'sansfont', fontSize: 18 , color: Colors.deepOrange , fontWeight: FontWeight.bold),)),
                ),
              ),
              Container(height: size.height /40,),
              
               Container(
                width: size.width /1.3 ,
                child: Center(
                  child: Container(
                    width: size.width ,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Do you have an account ?" , style: TextStyle(fontSize: 15),),
                        TextButton(onPressed: (){
                           Navigator.push(context, MaterialPageRoute(builder: (context)=>login()));
                
                        }, child: Text("SignIn")
                      )
                      ],
                    ),
                  ),
                ),
              )
        
            ],
          ),
        ),
      ),
    );
  }
}