import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shimmer/shimmer.dart';

class shimmer_effect extends StatefulWidget {
  const shimmer_effect({super.key});

  @override
  State<shimmer_effect> createState() => _shimmer_effectState();
}

class _shimmer_effectState extends State<shimmer_effect> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return  Shimmer.fromColors( 
          baseColor: Colors.grey.shade300, 
          highlightColor: Colors.grey.shade500,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Container(
              
              decoration: BoxDecoration(
                color:Color.fromARGB(66, 188, 188, 188),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))
              ),
                child: ListTile(
                 
                  
                  leading: Shimmer.fromColors(
                    baseColor: Colors.grey.shade400, 
                    highlightColor: Colors.grey.shade500,
                    child:  Container(
                      child: CircleAvatar(
                        radius: 30,
                      ),
                    ),
                  ),
                 
                  //trailing: 
          
                ),
            ),
          ),
        );

        
      },

    );
  }
}