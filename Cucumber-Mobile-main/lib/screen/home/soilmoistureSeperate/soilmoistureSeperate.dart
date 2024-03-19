import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectcucumber/config/theme/app_bar.dart';
import 'package:projectcucumber/config/theme/theme.dart';
import 'package:projectcucumber/screen/soilmoisture/components/SoilConditionCheckWidget.dart';
import 'package:projectcucumber/screen/soilmoisture/components/dolomite.dart';
import 'package:projectcucumber/screen/soilmoisture/components/goodornot.dart';
import 'package:projectcucumber/screen/soilmoisture/components/phbox.dart';
import 'package:projectcucumber/screen/soilmoisture/components/title.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class soilmoistureSeperate extends StatefulWidget {
  @override
  _soilmoistureSeperateState createState() => _soilmoistureSeperateState();
}

class _soilmoistureSeperateState extends State<soilmoistureSeperate> {
  String soilCondition = '';
  Color textColor = const Color.fromRGBO(0, 0, 0, 1); // Default text color
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  List<String> recommendations = [];
  final user = FirebaseAuth.instance.currentUser!;

  void updateSoilCondition(String result) {
    var rng = Random();
    List<String> goodRecommendations = [
      'Regularly test soil pH and nutrient levels for optimal growth.',
      'Consider using organic mulches to maintain soil moisture and temperature.',
      'Incorporate compost to improve soil structure and nutrient content.',
      'Practice crop rotation to prevent soil nutrient depletion.',
      'Utilize green manure to enrich the soil naturally.',
    ];
    List<String> badRecommendations = [
      'Adjust watering schedules to avoid over or under-watering.',
      'Add a liming material to your soil to quickly raise pH.',
      'Mix wood ash into the soil to also remove impurities.',
      'Incorporate organic matter to improve soil fertility.',
      'Test for and address any soil compaction issues.',
    ];

    List<String> newRecommendations =
        result == 'Good' ? goodRecommendations : badRecommendations;

    setState(() {
      soilCondition = result;
      textColor = result == 'Good' ? Colors.green : Colors.red;
    });
    // Shuffle the recommendations randomly
    newRecommendations.shuffle(rng);
    // Remove old items
    var oldItemCount = recommendations.length;
    for (int i = oldItemCount - 1; i >= 0; i--) {
      listKey.currentState?.removeItem(
        i,
        (context, animation) =>
            _buildItem(recommendations[i], animation, 0), // Pass a dummy index
        duration: const Duration(milliseconds: 200),
      );
    }

    // Clear the current recommendations after the animations
    Future.delayed(Duration(milliseconds: 200 * oldItemCount), () {
      setState(() {
        recommendations.clear();
        recommendations.addAll(newRecommendations);
        // Insert new items
        for (int i = 0; i < newRecommendations.length; i++) {
          listKey.currentState?.insertItem(i);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 420;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Soil Indicator",
        leadingImage:'assets/icons/Back.png',
        actionImage: null,
        onLeadingPressed: () {
          print("Leading icon pressed");
          Navigator.pop(context);
        },
        onActionPressed: () {
          print("Action icon pressed");
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Phbox(),
              SoilmoistureTitle(),
              GoodorNot(),
              Dolomite(),
              SizedBox(height: 8),
              SoilConditionCheckWidget(onResult: updateSoilCondition),
              SizedBox(height: 10), // Add some space
              if (soilCondition.isNotEmpty)
                Container(
                  width: 450 * fem,
                  padding: EdgeInsets.all(10 * fem),
                  decoration: BoxDecoration(
                    color: Colors.green[50], // Light green background
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3), // Changes position of shadow
                      ),
                    ],
                  ),
                  child: Text(
                    'Current Soil Condition is $soilCondition',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18 * ffem,
                      fontWeight: FontWeight.w700,
                      height: 1.2125 * ffem / fem,
                      color: textColor,
                    ),
                  ),
                ),
              SizedBox(height: 5),
              if (recommendations.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Follow these recommendations for better crop yield.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.colorPrimary,
                    ),
                  ),
                ),
              SizedBox(height: 5),
              SizedBox(
                height: 400, // Set a fixed height for the AnimatedList
                child: AnimatedList(
                  key: listKey,
                  initialItemCount: recommendations.length,
                  itemBuilder: (context, index, animation) {
                    return _buildItem(recommendations[index], animation, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
      String recommendation, Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        color: Colors.green[50], // Light green card background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: ListTile(
          leading: Container(
            width: 40.0, // Circle diameter
            height: 40.0, // Circle diameter
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Colors.blue, // Start color
                  Colors.green, // End color
                ],
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
          title: Text(
            recommendation,
            style: TextStyle(
                fontSize: 14, color: Colors.green[800]), // Dark green text
          ),
          trailing: Icon(Icons.eco, color: Colors.green[600]), // Eco icon
        ),
      ),
    );
  }
}
