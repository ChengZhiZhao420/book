import 'package:firebase_auth/firebase_auth.dart';
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
        stream: FirebaseDatabase.instance
            .ref("MarketPlace/${widget.sellID}")
            .onValue,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData &&
              !snapshot.hasError &&
              snapshot.data.snapshot.value != null) {
            var sellItemInformations = snapshot.data.snapshot.value;
            print(snapshot.data.snapshot);
            return ListView(
              children: [
                Container(
                    width: double.infinity,
                    height: 50,
                    child: Center(
                        child: Text(
                      "${sellItemInformations["BookName"]}",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ))),
                ImageSlideshow(
                    width: double.infinity,
                    height: 300,
                    initialPage: 0,
                    children: [
                      Image.network(
                          "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Gutenberg_Bible%2C_Lenox_Copy%2C_New_York_Public_Library%2C_2009._Pic_01.jpg/447px-Gutenberg_Bible%2C_Lenox_Copy%2C_New_York_Public_Library%2C_2009._Pic_01.jpg"),
                      Image.network(
                          "https://cdn.elearningindustry.com/wp-content/uploads/2016/05/top-10-books-every-college-student-read-1024x640.jpeg")
                    ]),
                Container(color: Colors.grey,height: 5,width: double.infinity,),
                Center(
                  child: Column(
                    children: [
                      Text("Top Deal: ${sellItemInformations["Price"]}"),
                      const Text("You Save: \$23"),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      var ref = FirebaseDatabase.instance.ref("User/${FirebaseAuth.instance.currentUser!.uid}/OnCart/${widget.sellID}");

                      ref.once().then((value){
                        if(value.snapshot.exists){
                          showDialog(builder: (BuildContext context) {
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
                          }, context: context

                          );
                        }else{
                          ref.set({
                            "Price" : sellItemInformations["Price"],
                          });
                        }
                      });
                  },
                  child: const Text("Add Cart"),),
                ),
                Container(color: Colors.grey,height: 5,width: double.infinity,),
                const Text("About this Item", style: TextStyle(fontWeight: FontWeight.bold),),
                Text("${sellItemInformations["Description"]}", style: TextStyle(fontSize: 20),)
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
