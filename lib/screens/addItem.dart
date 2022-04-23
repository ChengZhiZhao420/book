import 'dart:io';
import 'package:book/screens/pictureGallery.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class addItem extends StatefulWidget {
  final String userId;

  const addItem({Key? key, required this.userId}) : super(key: key);

  @override
  _addItemState createState() => _addItemState();
}

class _addItemState extends State<addItem> {
  List<File> _image = [];
  @override
  Widget build(BuildContext context) {
    TextEditingController bookDescriptionController = TextEditingController();
    TextEditingController bookNameController = TextEditingController();
    TextEditingController bookPriceController = TextEditingController();

    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: bookNameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Book Name',
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: bookPriceController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Book Price',
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: bookDescriptionController,
            minLines: 6,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Book Description',
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () async {
              _image = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Gallery()));

              if (_image.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Empty Image List")));
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Image Added")));
              }
            },
            child: Text("Select Photo"),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () async {
              bool dataBase = false;
              bool storage = false;

              var timeStamp = DateTime.now().millisecondsSinceEpoch;
              String sellId = "" + widget.userId + "~" + timeStamp.toString();
              DatabaseReference df = FirebaseDatabase.instance.ref();

              df.child("User/" + widget.userId + "/SellItem/" + sellId)
                  .set({
                "BookName": bookNameController.text,
                "Description": bookDescriptionController.text,
                "Price": bookPriceController.text,
                "Sold" : false
              }).then((value) {
                dataBase = true;
                print("Update Database Successful");
              }).catchError((error) {
                print("Update Database Failed");
              }); //async


              df.child("MarketPlace/$sellId")
                  .set({
                "BookName": bookNameController.text,
                "Description": bookDescriptionController.text,
                "Price": bookPriceController.text,
                "Sold" : false
              }).then((value) {
                print("Update MarketPlace Successful");
              }).catchError((onError) {
                print("Update MarketPlace Failed");
              });

              int i = 0;
              for (var img in _image) {
                var ref = firebase_storage.FirebaseStorage.instance
                    .ref()
                    .child('images/$sellId/$i');

                ref.putFile(img).then((value) {
                  storage = true;
                  print("Update Storage Successful");
                }).catchError((error) {
                  print("Update Storage Failed");
                });

                i++;
              }

              if (dataBase && storage) {
                print("Both Successful");
                Navigator.pop(context);
              } else {
                showDialog(
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Submission Failed"),
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
              }
            },
            child: Text("Submit"),
          ),
          Container(
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
