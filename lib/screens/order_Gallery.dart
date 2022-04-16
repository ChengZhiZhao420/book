import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

class OrderGallery extends StatefulWidget {
  final sellID;

  const OrderGallery({Key? key, required this.sellID}) : super(key: key);

  @override
  State<OrderGallery> createState() => _OrderGalleryState();
}

class _OrderGalleryState extends State<OrderGallery> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.sellID}"),
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref("MarketPlace/${widget.sellID}").onValue,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          var sellItemInformations;

          if(snapshot.hasData && !snapshot.hasError && snapshot.data.snapshot.value != null){
            sellItemInformations = snapshot.data.snapshot.value;
            print(snapshot.data.snapshot.value);
            print(sellItemInformations["BookName"]);
          }
          return ListView(
            children: [
              Container(
                  width: double.infinity,
                  height: 50,
                  child: Center(child: Text("${sellItemInformations["BookName"]}", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),))
              ),
              ImageSlideshow(
                  width: double.infinity,
                  height: 300,
                  initialPage: 0,
                  children: [
                    Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Gutenberg_Bible%2C_Lenox_Copy%2C_New_York_Public_Library%2C_2009._Pic_01.jpg/447px-Gutenberg_Bible%2C_Lenox_Copy%2C_New_York_Public_Library%2C_2009._Pic_01.jpg"),
                    Image.network("https://cdn.elearningindustry.com/wp-content/uploads/2016/05/top-10-books-every-college-student-read-1024x640.jpeg")
                  ]),

            ],
          );
        },
      ),
    );

  }
}
