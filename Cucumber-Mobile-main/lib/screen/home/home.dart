import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectcucumber/config/theme/app_bar.dart';
import 'package:projectcucumber/config/theme/theme.dart';
import 'package:projectcucumber/screen/home/components/fuitPedict.dart';
import 'package:projectcucumber/screen/home/components/leafPredict.dart';
import 'package:projectcucumber/screen/home/components/pestsPedict.dart';
import 'package:projectcucumber/screen/home/components/pricePredict.dart';
import 'package:projectcucumber/screen/home/components/soilPredict.dart';
import 'package:projectcucumber/screen/home/components/weatherForecast.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Welcome!",
        leadingImage: user.photoURL ?? '',
        actionImage: null,
        onLeadingPressed: () {
          print("Leading icon pressed");
        },
        onActionPressed: () {
          print("Action icon pressed");
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .center, // Aligns children to the center horizontally
          children: [
            // Introduction section with text and image
            SizedBox(height: 20), // Adds some space before the image
            Center(
              // Center the image
              child: Image.asset(
                "assets/images/smart-farm.png",
                width: 150, // Set your desired image width
                height: 100, // Set your desired image height
                fit: BoxFit.cover, // Cover the container's bounds
              ),
            ),
            SizedBox(height: 20), // Adds space after the image
            Text(
              "Enhance Your Cucumber Farming with AI",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
             SizedBox(height: 20),
            // Feature section with icons
            featureItem("Cucumber Marketing Performance Analysis", Icons.trending_up, pricePredict()),
            featureItem("Land Recommend for Cucumber", Icons.cloud, WeatherForecast()),
            featureItem("Cucumber Leaf Identification, Diseases Detection", Icons.eco, LeafPredict()),
            featureItem("Cucumber Fruit Identification, Diseases Detection", Icons.agriculture, FuitPedict()),
            featureItem("Cucumber With Pests Analysis", Icons.pest_control, PestsPedict()),
            featureItem("Cucumber Cultivation Analysis", Icons.terrain, SoilPredict()),
          ],
        ),
      ),
    );
  }

// Assuming `featureItem` is a method that returns a widget for each feature
  Widget featureItem(String title, IconData icon, Widget child) {
    return Center(
      // Center the feature item
      child: Column(
        children: [
          Icon(icon, size: 50, color: AppColors.colorPrimary),
          Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center, // Center align the text
          ),
          SizedBox(height: 8),
          child,
          // SizedBox(height: 8),
        ],
      ),
    );
  }
}
