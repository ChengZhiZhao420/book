import 'package:flutter/material.dart';

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
    );

  }
}
