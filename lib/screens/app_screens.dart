
import 'package:book/my_flutter_app_icons.dart';
import 'package:book/screens/addItem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'order_Gallery.dart';

class AppHomePage extends StatefulWidget {
  final String userId;

  const AppHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  int _selectedIndex = 0;
  int _totalPrice = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  FloatingActionButton? _getButton(int index) {
    if (index == 2) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => addItem(userId: widget.userId)));
        },
        child: const Icon(Icons.add),
        tooltip: "Add Item",
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List items = [];
    AppBar _appBarOptions(int index) {
      if (index == 0) {
        return AppBar(
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      /* Clear the search field */
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      }
      else if(index == 1){
        return AppBar(
          title: const Icon(MyFlutterApp.local_grocery_store),

        );
      }
      else {
        Icon icon;
        if (index == 2) {
          icon = const Icon(MyFlutterApp.import_export);
        } else {
          icon = const Icon(Icons.account_box_outlined);
        }
        return AppBar(
          title: icon,
        );
      }
    }

    List<Widget> _widgetLists = [
      Container(
        alignment: Alignment.center,
        color: Colors.blue,
        child: StreamBuilder(
          stream: FirebaseDatabase.instance
              .ref()
              .child("MarketPlace").onValue,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            print("page 1 $snapshot");
            if(snapshot.hasData && !snapshot.hasError && snapshot.data.snapshot.value != null && snapshot.connectionState == ConnectionState.active){
              List marketPlaceSellInformation = [];
              List marketPlaceSellID = [];
              Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
              map.forEach((key, value) {
                if(!key.toString().startsWith(FirebaseAuth.instance.currentUser!.uid)){
                  marketPlaceSellID.add(key);
                  marketPlaceSellInformation.add(value);
                }
              });

              return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  itemCount: marketPlaceSellInformation.length,
                  itemBuilder: (context, index){
                    return GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => OrderGallery(sellID: marketPlaceSellID[index])));
                      },
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Book Name: " + marketPlaceSellInformation[index]["BookName"]),
                            Text("Description: " + marketPlaceSellInformation[index]["Description"]),
                            Text("Price: " + marketPlaceSellInformation[index]["Price"]),
                          ],
                        ),
                      ),
                    );
                  }, );
            }
            else{
              return Card(child: Text("no value"),);
            }
          },),
      ),
      Container(
        child: Stack(
          children: [
            StreamBuilder(
              stream: FirebaseDatabase.instance
                  .ref()
                  .child("User/" + FirebaseAuth.instance.currentUser!.uid + "/OnCart/").onValue,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                print("page2 $snapshot");
                if(snapshot.hasData && !snapshot.hasError && snapshot.data.snapshot.value != null && snapshot.connectionState == ConnectionState.active){
                  List prices = [];
                  List sellID = [];

                  Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                  map.forEach((key, value) {
                    sellID.add(key);
                    prices.add(value);
                  });

                  return ListView.builder(
                      itemCount: prices.length,
                      itemBuilder: (context, index){
                        return Dismissible(
                          key: UniqueKey() ,
                          onDismissed: (direction){
                            setState(() {
                              DatabaseReference df = FirebaseDatabase.instance.ref();
                              df.child("User/" + FirebaseAuth.instance.currentUser!.uid + "/OnCart/" + sellID[index]).remove();
                            });
                          },
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Sell ID: ${sellID[index]}"),
                                Text("Price: ${prices[index]["Price"]}")
                              ],
                            ),
                          ),
                        );
                      });
                }
                else{
                  return Card(child: Text("no value"),);
                }
              },),
          ],
        ),
        alignment: Alignment.center,
        color: Colors.green,
      ),
      Container(
        child: StreamBuilder(
          stream: FirebaseDatabase.instance
              .ref()
              .child("User/" + FirebaseAuth.instance.currentUser!.uid + "/SellItem/").onValue,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            print("page 3 $snapshot");
            if(snapshot.hasData && !snapshot.hasError && snapshot.data.snapshot.value != null && snapshot.connectionState == ConnectionState.active){
              List sellInformation = [];
              List sellID = [];
              Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
              map.forEach((key, value) {
                sellID.add(key);
                sellInformation.add(value);
              });

              return ListView.builder(
                  itemCount: sellInformation.length,
                  itemBuilder: (context, index){
                    return Dismissible(
                      key: UniqueKey() ,
                      onDismissed: (direction){
                        setState(() {
                          DatabaseReference df = FirebaseDatabase.instance.ref();

                          df.child("User/" + FirebaseAuth.instance.currentUser!.uid + "/SellItem/" + sellID[index]).remove();
                          df.child("MarketPlace/" + sellID[index]).remove().then((value){
                            print("Remove market place successful");
                          }).catchError((onError){
                            print("Remove market place failed${onError.toString()}");

                          });

                        });
                      },
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Book Name: " + sellInformation[index]["BookName"]),
                            Text("Description: " + sellInformation[index]["Description"]),
                            Text("Price: " + sellInformation[index]["Price"]),
                          ],
                        ),
                      ),
                    );
                  });
            }
            else{
              return Card(child: Text("no value"),);
            }
          },),
        alignment: Alignment.center,
        color: Colors.blue,
      ),
      Container(
        child: Text("text1"),
        alignment: Alignment.center,
        color: Colors.greenAccent,
      ),
    ];

    return Scaffold(
        appBar: _appBarOptions(_selectedIndex),
        body: Center(
          child: _widgetLists.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(
                  MyFlutterApp.local_grocery_store,
                ),
                label: 'Shopping Cart'),
            BottomNavigationBarItem(
                icon: Icon(
                  MyFlutterApp.import_export,
                ),
                label: 'Sell Book'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_box_outlined), label: 'Profile')
          ],
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
          backgroundColor: Colors.white30,
        ),
        floatingActionButton: _getButton(_selectedIndex));
  }
}