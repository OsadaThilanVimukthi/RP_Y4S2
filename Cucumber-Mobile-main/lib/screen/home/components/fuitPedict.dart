import 'package:flutter/material.dart';
import 'package:projectcucumber/screen/home/fruitdiseaseSeperate/fruitdiseaseSeperate.dart';
// import 'package:projectcucumber/screen/home/fruitdiseaseSeperate/fruitdiseaseSeperate.dart';

// A StatelessWidget for a custom button that navigates to the PricePredictorScreen.
class FuitPedict extends StatelessWidget {
  // Constructor for priceButton
  FuitPedict({Key? key}) : super(key: key);

  @override
  // Builds the button with specific design and functionality.
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue, // Replace with your desired start color
            Colors.green, // Replace with your desired end color
          ],
        ),
        borderRadius: BorderRadius.circular(50.0), // Rounded corners
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => fruitdiseaseSeperate()),
          );
        },
        child: Text('Fruit Disease Analysis',
            style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent, // Make the button transparent
          shadowColor: Colors.transparent, // No shadow
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0), // Rounded corners
          ),
          minimumSize: Size(double.infinity, 10),
        ),
      ),
    );
  }
}
