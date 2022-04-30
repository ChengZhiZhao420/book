import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
        stream: FirebaseDatabase.instance
            .ref("MarketPlace/${widget.sellID}")
            .onValue,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData &&
              !snapshot.hasError &&
              snapshot.data.snapshot.value != null &&
              snapshot.connectionState == ConnectionState.active) {
            var sellItemInformation = snapshot.data.snapshot.value;
            List map = sellItemInformation["Property"];
            List<Widget> photoList = [];
            for (var element in map) {
              if(element != null){
                photoList.add(Image.network(element));
              }
            }
            return ListView(
              children: [
                Container(
                    width: double.infinity,
                    height: 50,
                    child: Center(
                        child: Text(
                      "${sellItemInformation["BookName"]}",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ))),
                ImageSlideshow(
                    width: double.infinity,
                    height: 300,
                    initialPage: 0,
                    children: photoList),
                Container(
                  color: Colors.grey,
                  height: 5,
                  width: double.infinity,
                ),
                Center(
                  child: Column(
                    children: [
                      Text("Top Deal: ${sellItemInformation["Price"]}"),
                      const Text("You Save: \$23"),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      var ref = FirebaseDatabase.instance.ref(
                          "User/${FirebaseAuth.instance.currentUser!.uid}/OnCart/${widget.sellID}");

                      ref.once().then((value) {
                        if (value.snapshot.exists) {
                          showDialog(
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Item was on cart"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: const Text("Cancel"),
                                    )
                                  ],
                                );
                              },
                              context: context);
                        } else {
                          ref.set({
                            "Price": sellItemInformation["Price"],
                          });
                        }
                      });
                    },
                    child: const Text("Add Cart"),
                  ),
                ),
                Container(
                  color: Colors.grey,
                  height: 5,
                  width: double.infinity,
                ),
                const Text(
                  "About this Item",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${sellItemInformation["Description"]}",
                  style: TextStyle(fontSize: 20),
                )
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
