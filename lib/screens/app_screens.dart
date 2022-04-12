import 'package:book/my_flutter_app_icons.dart';
import 'package:book/screens/addItem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AppHomePage extends StatefulWidget {
  final String userId;

  const AppHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  int _selectedIndex = 0;
  var userDefines = [];
  var userSellID = [];
  var marketID = [];
  var marketInfor = [];

  _AppHomePageState(){
    _sellInformation();
    _marketInformation();

    FirebaseDatabase.instance.ref("MarketPlace/").onChildChanged.listen((event) async{
      _sellInformation();
    });
  }

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
        child: Icon(Icons.add),
        tooltip: "Add Item",
      );
    } else {
      return null;
    }
  }

  void _sellInformation(){
    FirebaseDatabase.instance
        .ref()
        .child("User/" + FirebaseAuth.instance.currentUser!.uid + "/SellItem/")
        .once()
        .then((snapshot) {
          userDefines.clear();
          userSellID.clear();
      for (var key in snapshot.snapshot.children) {
        userDefines.add(key.value);
        userSellID.add(key.key);
      }
      setState(() {
        
      });
    }).catchError((onError) {
      print("Error");
    });
  }

  void _marketInformation(){
    FirebaseDatabase.instance
        .ref()
        .child("MarketPlace/")
        .once()
        .then((snapshot) {
      userDefines.clear();
      userSellID.clear();
      for (var key in snapshot.snapshot.children) {
        marketInfor.add(key.value);
        marketID.add(key.key);
      }
      setState(() {

      });
    }).catchError((onError) {
      print("Error");
    });
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
      } else {
        Icon icon;
        if (index == 1) {
          icon = const Icon(MyFlutterApp.local_grocery_store);
        } else if (index == 2) {
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
      /*ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {},
              title: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey)),
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
                child: Row(
                  children: [
                    Expanded(
                      flex: 35,
                      child: Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(
                                    "https://dbukjj6eu5tsf.cloudfront.net/sidearm.sites/broncoathletics.com/images/2014/9/24/LogoRelease1a.jpg"))),
                      ),
                    ),
                    Expanded(
                      flex: 65,
                      child: Container(
                        child: Row(
                          children: const [
                            Flexible(
                                child: Text(
                                    "ddddddddddddddddddddjjjjjjjjjjjj22222222222222222222222222"))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),*/
      Container(
        alignment: Alignment.center,
        color: Colors.blue,
        child: ListView.builder(
          itemCount: marketID.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Book Name: " + marketInfor[index]["BookName"]),
                  Text("Description: " + marketInfor[index]["Description"]),
                  Text("Price: " + marketInfor[index]["Price"]),
                ],
              ),
            );
          },
        ),
      ),
      Container(
        child: Text(widget.userId),
        alignment: Alignment.center,
        color: Colors.green,
      ),
      Container(
        child: RefreshIndicator(
          onRefresh: () {
            return Future.delayed(Duration(seconds: 2), () {
              _sellInformation();
            });
          },
          child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: userSellID.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(userSellID[index]),
                  onDismissed: (direction){
                    setState(() {
                      userDefines.removeAt(index);
                      userSellID.removeAt(index);
                      FirebaseDatabase.instance.ref("User/" + FirebaseAuth.instance.currentUser!.uid + "/SellItem/" + userSellID[index]);

                      ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('${userSellID[index]} dismissed')));
                      }
                    );
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Book Name: " + userDefines[index]["BookName"]),
                        Text("Description: " + userDefines[index]["Description"]),
                        Text("Price: " + userDefines[index]["Price"]),
                      ],
                    ),
                  ),
                );
              }),
        ),
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
