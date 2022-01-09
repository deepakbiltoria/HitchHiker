import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shotgun/constants.dart';
import 'package:shotgun/main.dart';
import 'package:shotgun/screens/login_screen.dart';
import 'package:shotgun/screens/main_screen.dart';
import 'package:shotgun/widgets/progress_Dialog.dart';

class RegistrationScreen extends StatelessWidget {
  TextEditingController nameTextEditingController = TextEditingController();

  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController phoneTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();

  static const String idScreen = 'registration';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 30.0,
              ),
              Image(
                height: 200.0,
                width: 350.0,
                image: AssetImage('assets/images/logo.png'),
              ),
              SizedBox(
                height: 1.0,
              ),
              Text(
                'Co-Pilot Registation',
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
                      controller: nameTextEditingController,
                      style: TextStyle(fontSize: 14.0),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      style: TextStyle(fontSize: 14.0),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                    ),
                    TextField(
                      controller: phoneTextEditingController,
                      style: TextStyle(fontSize: 14.0),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                    ),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: !kObscureTextState,
                      style: TextStyle(fontSize: 14.0),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(fontSize: 14.0),
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (nameTextEditingController.text.length < 4) {
                            displayToastMessage(
                                'name must be atleast 5 characters', context);
                          } else if (!emailTextEditingController.text
                              .contains('@')) {
                            displayToastMessage(
                                'Email address is not valid', context);
                          } else if (phoneTextEditingController.text.isEmpty) {
                            displayToastMessage(
                                'Phone Number is mandatory', context);
                          } else if (passwordTextEditingController.text.length <
                              6) {
                            displayToastMessage(
                                'password must be atleast 6 characters',
                                context);
                          } else {
                            //regiNewUserCredential(context);
                            registerNewUser(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.yellow,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        child: Container(
                          height: 50.0,
                          child: Center(
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                  fontSize: 18.0, fontFamily: "Brand Bold"),
                            ),
                          ),
                        ))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginScreen.idScreen, (route) => false);
                  },
                  child: Text('already have an account? Login here'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(message: 'Registering, Please Wait....try');
        });

    final User? firebaseUser = (await _auth
            .createUserWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMessage("error: " + errMsg.toString(), context);
    }))
        .user;
    if (firebaseUser != null) //user created
    {
      // save user info to database
      Map userDataMap = {
        'name': nameTextEditingController.text.trim(),
        'email': emailTextEditingController.text.trim(),
        'phone': phoneTextEditingController.text.trim()
      };
      userRef.child(firebaseUser.uid).set(userDataMap);
      displayToastMessage(
          'hey congratulations, your account has been created', context);
      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.idScreen, (route) => false);
    } else {
      // error occured - display error msg
      Navigator.pop(context);
      displayToastMessage('newUserAccount has not been created', context);
    }
  }

  Future<void> regiNewUserCredential(BuildContext context) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: emailTextEditingController.text,
              password: passwordTextEditingController.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}

void displayToastMessage(String msg, BuildContext context) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
