import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

// Function to determine the dolomite dose based on pH level
double getDolomiteDose(double pHLevel) {
  // Lookup table based on the information provided
  Map<double, double> pHToDolomiteDose = {
    5.7: 4.2,
    5.6: 4.6,
    5.5: 5.1,
    5.4: 5.5,
    5.3: 6.0,
    5.2: 6.4,
    5.1: 6.9,
    5.0: 7.3,
    4.9: 7.7,
    4.8: 8.3,
  };

  // Assuming pH levels are always within the range of the table
  return pHToDolomiteDose.entries
      .reduce(
          (a, b) => (pHLevel - a.key).abs() < (pHLevel - b.key).abs() ? a : b)
      .value;
}

class Dolomite extends StatefulWidget {
  const Dolomite({super.key});

  @override
  State<Dolomite> createState() => _DolomiteState();
}

class _DolomiteState extends State<Dolomite> {
  double pHLevel = 0; // Variable to store pH level
  late Stream<DatabaseEvent> pHStream; // Stream for real-time updates

  @override
  void initState() {
    super.initState();
    setupPHListener();
  }

  void setupPHListener() {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("1706605694/device_data/soil_condition/soil_pH");

    // Setting up the stream for real-time pH updates
    pHStream = ref.onValue;

    // Listening to the stream
    pHStream.listen((DatabaseEvent event) {
      setState(() {
        // Update the pH level when the value changes in the database
        pHLevel = (event.snapshot.value as num).toDouble();
      });
    });
  }

  final Shader textGradient = LinearGradient(
    colors: <Color>[
      Colors.blue, // Start color
      Colors.green, // End color
    ],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    double dolomiteDose = getDolomiteDose(pHLevel);

    return Container(
      padding: const EdgeInsets.all(5),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.80,
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Soil pH Analysis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader =
                            textGradient, // Apply the gradient to the text
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Recommended Dolomite Dose:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    '${dolomiteDose.toStringAsFixed(2)} Ton per Acre',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    pHStream.drain();
  }
}