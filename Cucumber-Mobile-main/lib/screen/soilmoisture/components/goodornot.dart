import 'package:flutter/material.dart';
import 'package:projectcucumber/config/theme/theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:projectcucumber/utils.dart';

class GoodorNot extends StatefulWidget {
  const GoodorNot({super.key});

  @override
  State<GoodorNot> createState() => _GoodorNotState();
}

class _GoodorNotState extends State<GoodorNot> {
  double moistureLevel = 0; // Variable to store moisture level
  late Stream<DatabaseEvent> moistureStream; // Stream for real-time updates

  @override
  void initState() {
    super.initState();
    setupMoistureListener();
  }

  void setupMoistureListener() {
    // Get the reference to the moisture level data
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("1706605694/device_data/soil_condition/soil_moisture");

    // Setting up the stream for real-time updates
    moistureStream = ref.onValue;

    // Listening to the stream
    moistureStream.listen((DatabaseEvent event) {
      setState(() {
        // Update the moisture level when the value changes in the database
        moistureLevel = (event.snapshot.value as num).toDouble();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 450;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    // Maximum expected moisture level
    double maxMoistureLevel = 100;

    // Calculate the width of the bar based on the moisture level
    double barWidth = (moistureLevel / maxMoistureLevel) * 400 * fem;

    // Define gradient colors based on moisture level
    List<Color> gradientColors;
    if (moistureLevel < 20) {
      gradientColors = [Colors.green, Colors.yellow];
    } else if (moistureLevel < 40) {
      gradientColors = [Colors.yellow, Colors.orange];
    } else {
      gradientColors = [Colors.orange, Colors.red];
    }

    return Container(
      color: AppColors.homebg,
      padding: EdgeInsets.all(8), // Adjust padding based on fem
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 8.0 * fem),
                  child: Text(
                    'Moisture Level: ${moistureLevel.toStringAsFixed(0)}',
                    style: SafeGoogleFont(
                      'Inter',
                      fontSize: 20 * ffem,
                      fontWeight: FontWeight.w700,
                      height: 1.2125 * ffem / fem,
                      color: Color(0xff32d94e),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 10 * fem),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xffe8faf0),
              borderRadius: BorderRadius.circular(8.5 * fem),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: barWidth, // Use the calculated width
                height: 17 * fem,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.5 * fem),
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel the stream subscription when the widget is disposed
    moistureStream.drain();
  }
}