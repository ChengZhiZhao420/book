import 'package:book/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_screens.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 40,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQsADXjA0KKNnAxRGUlYr1_0WKjFCmjuVbPoZCea-A8buYnLfZQqCv2kuWoSs6m55TYl8o&usqp=CAU')
                        ,fit: BoxFit.fill
                  )
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),

            Expanded(
              flex: 25,
              child: Container(
                child: Column(
                  children: [
                    TextField(
                      controller: usernameController,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                      ),
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                  ],
                )

              ),
            ),

            Expanded(
              flex: 35,
              child: Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 105, vertical: 15),
                      ),
                      child: Text("Log In"),
                      onPressed: () {
                        Future result = FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: usernameController.text, password: passwordController.text).
                        then((value){
                          User user = FirebaseAuth.instance.currentUser!;
                          String userId = user.uid;
                          print("Successful");
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AppHomePage(userId: userId)),
                          );
                        }).catchError((error) {
                          print("Failed");
                        });

                      },
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      ),
                      child: Text("Sign Up"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
