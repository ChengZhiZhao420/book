
import 'package:book/my_flutter_app_icons.dart';
import 'package:book/screens/addItem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'CheckOut.dart';
import 'order_Gallery.dart';

class AppHomePage extends StatefulWidget {
  final String userId;

  const AppHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  int _selectedIndex = 0;
  List onCartPrices = [];
  List onCartSellID = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget? _getButton(int index) {
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
    } else if (index == 1) {
      return SizedBox(
        width: 150,
        child: FloatingActionButton(
          shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.zero
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CheckOutMain(
                        cartPrices: onCartPrices, cartID: onCartSellID)));
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text("Check Out",style: TextStyle(fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_forward_ios_sharp),
              ],
            ),
          )
        ),
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
      } else if (index == 1) {
        return AppBar(
          title: Column(
            children: [
              Text(
                "Your Cart",
                style: TextStyle(color: Colors.black),
              )
            ],
          ),
        );
      } else {
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
        color: Colors.white,
        child: StreamBuilder(
          stream: FirebaseDatabase.instance.ref().child("MarketPlace").onValue,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            print("page 1 $snapshot");
            if (snapshot.hasData &&
                !snapshot.hasError &&
                snapshot.data.snapshot.value != null &&
                snapshot.connectionState == ConnectionState.active) {
              List marketPlaceSellInformation = [];
              List marketPlaceSellID = [];
              List photoUrl = [];
              Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
              map.forEach((key, value) {
                if (!key
                    .toString()
                    .startsWith(FirebaseAuth.instance.currentUser!.uid)) {
                  marketPlaceSellID.add(key);
                  marketPlaceSellInformation.add(value);
                }
              });

              marketPlaceSellInformation.forEach((element) {
                List temp = [];
                temp = element["Property"];
                photoUrl.add(temp[1]);
              });

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisExtent: 300),
                itemCount: marketPlaceSellInformation.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => OrderGallery(
                                  sellID: marketPlaceSellID[index])));
                    },
                    child: Card(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(photoUrl[index]),
                          ))),
                          Text(
                            "Book Name: " +
                                marketPlaceSellInformation[index]["BookName"],
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Card(
                child: Text("no value"),
              );
            }
          },
        ),
      ),
      Container(
        child: Stack(
          children: [
            StreamBuilder(
              stream: FirebaseDatabase.instance
                  .ref()
                  .child("User/" +
                      FirebaseAuth.instance.currentUser!.uid +
                      "/OnCart/")
                  .onValue,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                print("page2 $snapshot");
                if (snapshot.hasData &&
                    !snapshot.hasError &&
                    snapshot.data.snapshot.value != null &&
                    snapshot.connectionState == ConnectionState.active) {
                  Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                  List photoList = [];
                  onCartSellID.clear();
                  onCartPrices.clear();

                  map.forEach((key, value) {
                    onCartSellID.add(key);
                    onCartPrices.add(value);
                  });

                 /* for(int i = 0; i < onCartSellID.length; i++){
                    FirebaseDatabase.instance
                        .ref("MarketPlace/${onCartSellID[i]}/Property").get().then((value){
                          print(value.value);
                          List? list = value.value as List?;
                          photoList.add(list![0]);
                    });
                  }*/

                  return ListView.builder(
                      itemCount: onCartPrices.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Dismissible(
                            key: UniqueKey(),
                            onDismissed: (direction) {
                              setState(() {
                                DatabaseReference df =
                                    FirebaseDatabase.instance.ref();
                                df
                                    .child("User/" +
                                        FirebaseAuth.instance.currentUser!.uid +
                                        "/OnCart/" +
                                        onCartSellID[index])
                                    .remove();
                              });
                            },
                            background: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFE6E6),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Spacer(),
                                  // SvgPicture.asset("assets/icons/Trash.svg"),
                                ],
                              ),
                            ),
                            child: Row(children: [
                              SizedBox(
                                width: 88,
                                child: AspectRatio(
                                  aspectRatio: 0.88,
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF5F6F9),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Image.network(
                                        onCartPrices[index]["Image"]),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${onCartPrices[index]["BookName"]}",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                      maxLines: 2,
                                    ),
                                    SizedBox(height: 10),
                                    Text.rich(
                                        TextSpan(
                                          text: "\$${onCartPrices[index]["Price"]}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600, color: Colors.black),
                                          children: [
                                            TextSpan(
                                                text: " x1",
                                                style: Theme.of(context).textTheme.bodyText1),
                                          ],
                                        ),
                                    )]),
                             /* Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //Text("Sell ID: ${onCartSellID[index]}"),
                                    Text(
                                        "Price: ${onCartPrices[index]["Price"]}")
                                  ],
                                ),
                              ),*/
                            ]),
                          ),
                        );
                      });
                } else {
                  return Card(
                    child: Text("no value"),
                  );
                }
              },
            ),
          ],
        ),
        alignment: Alignment.center,
        color: Colors.white,
      ),
      Container(
        child: StreamBuilder(
          stream: FirebaseDatabase.instance
              .ref()
              .child("User/" +
                  FirebaseAuth.instance.currentUser!.uid +
                  "/SellItem/")
              .onValue,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData &&
                !snapshot.hasError &&
                snapshot.data.snapshot.value != null &&
                snapshot.connectionState == ConnectionState.active) {
              List sellInformation = [];
              List sellID = [];
              Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
              map.forEach((key, value) {
                sellID.add(key);
                sellInformation.add(value);
              });

              return ListView.builder(
                  itemCount: sellInformation.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        setState(() {
                          DatabaseReference df =
                              FirebaseDatabase.instance.ref();
                          Reference ds =
                              FirebaseStorage.instance.ref("images/");

                          df
                              .child("User/" +
                                  FirebaseAuth.instance.currentUser!.uid +
                                  "/SellItem/" +
                                  sellID[index])
                              .remove();
                          df
                              .child("MarketPlace/" + sellID[index])
                              .remove()
                              .then((value) {
                            print("Remove market place successful");
                          }).catchError((onError) {
                            print(
                                "Remove market place failed${onError.toString()}");
                          });
                          ds.child("${sellID[index]}/").listAll().then((value) {
                            value.items.forEach((element) {
                              element.delete();
                            });
                          });
                        });
                      },
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Book Name: " +
                                sellInformation[index]["BookName"]),
                            Text("Description: " +
                                sellInformation[index]["Description"]),
                            Text("Price: " + sellInformation[index]["Price"]),
                          ],
                        ),
                      ),
                    );
                  });
            } else {
              return Card(
                child: Text("no value"),
              );
            }
          },
        ),
        alignment: Alignment.center,
        color: Colors.white,
      ),
      Container(
        child: Center(
          child: Column(
            children: [Text("Last Name: ")],
          ),
        ),
        alignment: Alignment.center,
        color: Colors.white,
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
