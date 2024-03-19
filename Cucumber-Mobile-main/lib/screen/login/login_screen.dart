// Import necessary packages
import 'package:projectcucumber/provider/internet_provider.dart';
import 'package:projectcucumber/provider/sign_in_provider.dart';
import 'package:projectcucumber/screen/nav/nav.dart';
import 'package:projectcucumber/util/next_screen.dart';
import 'package:projectcucumber/util/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:provider/provider.dart';

// Define the LoginScreen class
class LoginScreen extends StatefulWidget {
  final DateTime? selectedTime;
  static String routeName = '/login';
  const LoginScreen({super.key, this.selectedTime});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Define the state of the LoginScreen
class _LoginScreenState extends State<LoginScreen> {
  // Define global keys for the scaffold and button controllers
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController twitterController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController phoneController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    // Build the login screen UI
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
        padding:
            const EdgeInsets.only(left: 40, right: 40, top: 90, bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo and welcome message
            Flexible(
              flex: 2,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the contents vertically
                children: [
                  const Expanded(
                    // Wrap the Image with Expanded
                    child: Image(
                      image: AssetImage("assets/logo.png"),
                      fit: BoxFit.contain,
                      height: 250,
                      width: 250,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text("Welcome to",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text("Cucumber Farmy",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Welcome back you've been missed!",
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                ],
              ),
            ),

            // Rounded buttons for social media login
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google Sign In Button
                RoundedLoadingButton(
                  onPressed: () {
                    handleGoogleSignIn();
                  },
                  controller: googleController,
                  successColor: Colors.green,
                  width: MediaQuery.of(context).size.width * 0.80,
                  elevation: 0,
                  borderRadius: 25,
                  color: Colors.green,
                  child: const Wrap(
                    children: [
                      Icon(
                        FontAwesomeIcons.google,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text("Sign in with Google",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            const SizedBox(
              height: 60,
            ),
          ],
        ),
      )),
    );
  }

  // Function to handle Google Sign In
  Future handleGoogleSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      openSnackbar(context, "Check your Internet connection", Colors.red);
      googleController.reset();
    } else {
      await sp.signInWithGoogle().then((value) {
        if (sp.hasError == true) {
          openSnackbar(context, sp.errorCode.toString(), Colors.red);
          googleController.reset();
        } else {
          // checking whether user exists or not
          sp.checkUserExists().then((value) async {
            if (value == true) {
              // user exists
              await sp.getUserDataFromFirestore(sp.uid).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        googleController.success();
                        handleAfterSignIn();
                      })));
            } else {
              final DateTime selectedTime = widget.selectedTime ??
                  DateTime(2000, 1,
                      1); // Use a default value if widget.selectedTime is null
              sp.saveDataToFirestore(selectedTime).then((value) => sp
                  .saveDataToSharedPreferences()
                  .then((value) => sp.setSignIn().then((value) {
                        googleController.success();
                        handleAfterSignIn();
                      })));
            }
          });
        }
      });
    }
  }

  // Function to handle actions after successful sign in
  handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(context, const Nav());
    });
  }
}
