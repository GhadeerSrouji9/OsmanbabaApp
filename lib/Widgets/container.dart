
import 'package:flutter/material.dart';

class continer extends StatelessWidget {
  String continer_name;
  bool isTrue ;
  continer(this.continer_name,this.isTrue);
  @override
  Widget build(BuildContext context) {
      return Container(
        decoration: BoxDecoration(
            color:isTrue == true ? Colors.orange :Colors.grey,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                topRight: Radius.circular(25)

            )
        ),

        width: (MediaQuery.of(context).size.width - 40),
        height : 50,
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Center(
          child:  Text(continer_name,
            style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),
          ),
        ),
      );



  }
}
