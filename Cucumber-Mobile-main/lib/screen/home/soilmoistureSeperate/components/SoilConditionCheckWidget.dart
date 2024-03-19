import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:projectcucumber/config/theme/theme.dart';

class SoilConditionCheckWidget extends StatelessWidget {
  final Function(String) onResult; // Callback function to send result back
  String? mlIP = dotenv.env['MLIP']?.isEmpty ?? true
      ? dotenv.env['DEFAULT_IP']
      : dotenv.env['MLIP'];

  SoilConditionCheckWidget({Key? key, required this.onResult})
      : super(key: key);

  // Function to check the soil condition
  void checkSoilCondition() async {
    // Get the pH and moisture percentage from Firebase
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    DatabaseEvent phEvent =
        await ref.child("1706605694/device_data/soil_condition/soil_pH").once();
    DatabaseEvent moistureEvent = await ref
        .child("1706605694/device_data/soil_condition/soil_moisture")
        .once();

    // Convert the values to double
    double phValue = double.tryParse(phEvent.snapshot.value.toString()) ?? 7.0;
    double moisturePercentage =
        double.tryParse(moistureEvent.snapshot.value.toString()) ?? 0.0;

    // Send the values to the ML server
    var url = Uri.parse('http://$mlIP:8000/soil_condition');
    var response = await http.post(url,
        body: jsonEncode(
            {'soil_pH': phValue, 'soil_moisture': moisturePercentage}),
        headers: {"Content-Type": "application/json"});

    // Check the response
    if (response.statusCode == 200) {
      // Parse the response
      var result = jsonDecode(response.body);
      onResult(result['predicted_soil_condition']);
    } else {
      onResult("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.blue, // Replace with your desired start color
            Colors.green, // Replace with your desired end color
          ],
        ),
        borderRadius: BorderRadius.circular(18.0), // Rounded corners
      ),
      child: ElevatedButton(
        onPressed: () {
          checkSoilCondition();
        },
        child:
            Text('Check Soil Condition', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent, // Make the button transparent
          shadowColor: Colors.transparent, // No shadow
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0), // Rounded corners
          ),
        ),
      ),
    );
  }
}