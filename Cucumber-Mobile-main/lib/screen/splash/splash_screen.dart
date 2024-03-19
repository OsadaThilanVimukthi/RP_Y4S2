import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projectcucumber/provider/sign_in_provider.dart';
import 'package:projectcucumber/screen/login/login_screen.dart';
import 'package:projectcucumber/util/next_screen.dart';
import '../nav/nav.dart';

// create a new widget called SplashScreen
class SplashScreen extends StatefulWidget {
  // give the SplashScreen a route name
  static String routeName = '/splash';
  // create a constructor for the SplashScreen
  const SplashScreen({Key? key}) : super(key: key);

  // create a new stateful widget called _SplashScreenState
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// create a new stateful widget called _SplashScreenState
class _SplashScreenState extends State<SplashScreen> {
  // init state
  @override
  void initState() {
    // read the SignInProvider
    final spm = context.read<SignInProvider>();
    super.initState();
    // create a timer of 2 seconds
    Timer(const Duration(seconds: 5), () {
      // if the user is not signed in
      spm.isSignedIn == false
          // go to the LoginScreen
          ? nextScreen(context, const LoginScreen())
          // if the user is signed in
          : nextScreen(context, const Nav());
    });
  }

  @override
  Widget build(BuildContext context) {
    // return a Scaffold with a SafeArea as a child
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage("assets/icons/Cucumber Farmy.gif"), // Your background image
              fit: BoxFit.cover, // This will fill the background with the image
            ),
          ),
        ),
      ),
    );
  }
}

