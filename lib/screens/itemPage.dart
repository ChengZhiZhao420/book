
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class itemScreen extends StatefulWidget {
  const itemScreen({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  _itemScreenState createState() => _itemScreenState();
}

class _itemScreenState extends State<itemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id.toString()),
      ),
      body: Center(
        child: Column(
          children: [
            //Photo of ur goods
            Expanded(
              flex: 75,
              child: Container(
                child: Center(
                  child: Column(

                  )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
