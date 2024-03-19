import 'package:flutter/widgets.dart';
import 'package:projectcucumber/screen/screen.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (context) => const LoginScreen(),
  SplashScreen.routeName: (context) => const SplashScreen(),
  ProfileScreen.routeName: (context) => ProfileScreen(),
};
