import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const Color colorPrimary = Color.fromARGB(255, 55, 162, 117);
  static const Color colorPrimaryLight = Color.fromRGBO(176, 176, 202, 1);
  static const Color colorPrimaryDark = Color.fromRGBO(145, 2, 3, 1);
  static const Color colorTint900 = Color.fromRGBO(27, 32, 43, 1);
  static const Color colorTint800 = Color.fromRGBO(47, 55, 71, 1);
  static const Color colorTint700 = Color.fromRGBO(76, 85, 102, 1);
  static const Color colorTint600 = Color.fromRGBO(116, 128, 148, 1);
  static const Color colorTint500 = Color.fromRGBO(163, 174, 190, 1);
  static const Color colorTint400 = Color.fromRGBO(205, 213, 223, 1);
  static const Color colorTint300 = Color.fromRGBO(227, 232, 239, 1);
  static const Color colorTint200 = Color.fromRGBO(238, 242, 247, 1);
  static const Color colorTint100 = Color.fromRGBO(248, 250, 252, 1);
  static const Color colorWarning = Color.fromRGBO(255, 182, 48, 1);

  static const Color colorborder = Color.fromRGBO(236, 233, 252, 1);
  static const Color colorsleep = Color.fromRGBO(253, 236, 226, 1);
  static const Color colorstardyourdaycard = Color.fromRGBO(250, 250, 252, 1);
  static const Color colorstardyourdaycardborder = Color.fromRGBO(241, 238, 247, 1);

  static const Color homebg = Color.fromRGBO(255, 255, 255, 1);

  static const Color font1 = Color(0xFF000000);
  static const Color font2 = Color(0xFF515151);
  static const Color font3 = Color(0xFF241E1B);
  static const Color font4 = Color(0xFF9F9A95);
  static const Color font5 = Color(0xFF424242);
  static const Color fontgreen = Color(0xFF027300);
  static const Color font6 = Color(0xFF7D7775);

  static const Color cardleft = Color(0xFFE6D6E9);
  static const Color cardright = Color(0xFFC7E6E9);
  static const Color cardsolid = Color(0xFFFEFAEF);

  static const Color rose = Color(0xFFFEE0EB);
  static const Color yell = Color(0xFFFFFEAC7);

  static const Color thikrose = Color(0xFFFEE0E0);
  static const Color thikgreen = Color(0xFFFE0FEFA);
  static const Color lightgreen = Color(0xFFE0FEEE);
  static const Color lightyellow = Color(0xFFFE0FEEE);

  static const Color yellogradiant = Color(0xFFF8DE85);
  static const Color bluegradiant = Color(0xFFFE3F6FF);
}

ThemeData theme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    fontFamily: "Fredoka",
    appBarTheme: appBarTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

AppBarTheme appBarTheme() {
  return AppBarTheme(
    color: Colors.white,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.black),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    toolbarTextStyle: const TextTheme(
      titleLarge: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
    ).bodyMedium,
    titleTextStyle: const TextTheme(
      titleLarge: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
    ).titleLarge,
  );
}