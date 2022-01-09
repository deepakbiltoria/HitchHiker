import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shotgun/constants.dart';
import 'package:shotgun/screens/registration_screen.dart';
import 'package:shotgun/widgets/progress_Dialog.dart';

import '../main.dart';
import 'main_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String idScreen = 'login';
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 45.0,
              ),
              Image(
                image: AssetImage('assets/images/logo.png'),
                height: 250.0,
                width: 400.0,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 1.0,
              ),
              Text(
                'Co-Pilot Login',
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      style: TextStyle(fontSize: 14.0),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: !kObscureTextState,
                      style: TextStyle(fontSize: 14.0),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    ElevatedButton(
                      // primary is background color and onprimary is text and icon color
                      style: ElevatedButton.styleFrom(
                          primary: Colors.yellow,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0))),
                      child: Container(
                          height: 50.0,
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 18.0, fontFamily: 'Brand Bold'),
                            ),
                          )),
                      onPressed: () {
                        if (!emailTextEditingController.text.contains('@')) {
                          displayToastMessage(
                              'Email address is not valid', context);
                        } else if (passwordTextEditingController.text.length <
                            6) {
                          displayToastMessage(
                              'password is mandatory and must be atleast 6 characters',
                              context);
                        } else if (passwordTextEditingController.text.isEmpty) {
                          displayToastMessage(
                              'password is mandatory and must be atleast 6 characters',
                              context);
                        } else {
                          // login and authenticate userl
                          loginAndAuthenticateUser(context);
                          print('login button clicked');
                        }
                      },
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextButton(
                  onPressed: () {
                    logout(context);
                  },
                  child: Text('SIGN OUT'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RegistrationScreen.idScreen, (route) => false);
                  },
                  child: Text('Do not have an account? Register here'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> loginAndAuthenticateUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(message: 'Authenticating, Please Wait....try');
        });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailTextEditingController.text,
          password: passwordTextEditingController.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Navigator.pop(context);
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Navigator.pop(context);
        print('Wrong password provided for that user.');
      }
    }
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        Navigator.pushNamedAndRemoveUntil(
            context, MainScreen.idScreen, (route) => false);
        displayToastMessage('You are logged in now', context);
        print('logged in');
      } else {
        _auth.signOut();
        displayToastMessage(
            'no record exist for the user, please create new account', context);
        print('logged out');
      }
    });
  }

  //FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logout(BuildContext context) async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _auth.signOut();
        displayToastMessage('Sign Out', context);
        // Navigator.pushNamedAndRemoveUntil(
        //     context, MainScreen.idScreen, (route) => false);
        // displayToastMessage('You are logged in now', context);
        print('logging out');
      } else {
        _auth.signOut();
        displayToastMessage(
            'no record exist for the user, please create new account', context);
        print('logged out');
      }
    });
  }

  // Future<void> loginAndAuthenticateUser(BuildContext context) async {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return ProgressDialog(message: 'Authenticating, Please Wait....try');
  //       });
  //   final User? firebaseUser = (await _auth
  //           .signInWithEmailAndPassword(
  //               email: emailTextEditingController.text,
  //               password: passwordTextEditingController.text)
  //           .catchError((errMsg) {
  //     Navigator.pop(context);
  //     displayToastMessage("error: " + errMsg.toString(), context);
  //   }))
  //       .user;
  //
  //   if (firebaseUser != null) //user created
  //   {
  //     userRef.child(firebaseUser.uid).once().then((DatabaseEvent snap) {
  //       // modification used parent datatype "dataevent in place of DataSnapshot"
  //       if (snap.snapshot.value != null) {
  //         Navigator.pushNamedAndRemoveUntil(
  //             context, MainScreen.idScreen, (route) => false);
  //         displayToastMessage('You are logged in now', context);
  //         print('logged in');
  //       } else {
  //         Navigator.pop(context);
  //         _auth.signOut();
  //         displayToastMessage(
  //             'no record exist for the user, please create new account',
  //             context);
  //         print('logged out');
  //       }
  //     });
  //   } else {
  //     // error occured - display error msg
  //     Navigator.pop(context);
  //     displayToastMessage('cant not signIn', context);
  //   }
  // }
}
