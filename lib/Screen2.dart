import 'package:flutter/material.dart';

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  TextEditingController citynamecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('images/screen2.jpeg'),fit: BoxFit.cover),

    ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           SizedBox(height: 24,),
           IconButton(onPressed: (){
             Navigator.pop(context);
           }, icon: Icon(Icons.arrow_back,size: 40,color: Colors.black,),),
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: TextFormField(

               controller: citynamecontroller,
                decoration: InputDecoration(
                  hintText: 'Enter Cityname',
                  hintStyle: TextStyle(fontSize: 20),
                  fillColor: Colors.white,
                  filled: true,

                ),
             ),
           ),
           GestureDetector(
             child: Center(
               child: Text("Get Weather",style: TextStyle(
               fontSize: 30,
                 fontWeight: FontWeight.bold,
                 color: Colors.white
               ),
               ),
             ),
             onTap: (){
               Navigator.pop(context,citynamecontroller.text);
             },
           ),

         ],
       ),   
    ),
    );
  }
}
