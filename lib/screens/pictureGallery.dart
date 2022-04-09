
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<File> _image = [];
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickedFile!.path));
    });
    if (pickedFile?.path == null) retrieveLostData();
  }

  Future<void> retrieveLostData() async {
    final LostData response = (await picker.retrieveLostData()) as LostData;
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image.add(File(response.file!.path));
      });
    } else {
      print(response.file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Picture Gallery"),
        actions: [
          TextButton(onPressed: () { setState(() {
              Navigator.pop(context, _image);
          }); },
          child: const Text("Submit",
          style: TextStyle(color: Colors.white)),

          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemCount: _image.length,
                itemBuilder: (context, index){
                  return GestureDetector(
                    onLongPress:(){
                      showDialog(
                        context: context,
                        builder: (context){
                          return   AlertDialog(
                            title: Text("Do you want to delete this picture"),
                            actions: [
                              TextButton(
                                onPressed: (){
                                  setState(() {
                                    _image.removeAt(index);
                                    Navigator.pop(context);
                                  });
                                }, child: Text("Remove"),
                              ),
                              TextButton(
                                onPressed: (){
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                }, child: Text("Cancel"),
                              ),

                            ],
                          );
                        }
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: FileImage(_image[index]),
                              fit: BoxFit.cover)),
                    ),
                  );
                }
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.add),
        tooltip: "Add Picture",
      ),
    );
  }
}
