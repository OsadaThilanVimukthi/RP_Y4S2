// Import necessary packages
import 'package:flutter/material.dart';
import 'package:projectcucumber/config/theme/theme.dart';
import 'package:projectcucumber/utils.dart';

// Create a stateful widget for the soil moisture title
class SoilmoistureTitle extends StatefulWidget {
  // Define the key for the widget
  const SoilmoistureTitle({super.key});

  // Create the state of the widget
  @override
  State<SoilmoistureTitle> createState() => _nameState();
}

// State of the widget
class _nameState extends State<SoilmoistureTitle> {
  // Build the widget
  @override
  Widget build(BuildContext context) {
    // Define the base width
    double baseWidth = 450;
    // Get the width of the device
    double fem = MediaQuery.of(context).size.width / baseWidth;
    // Get a more accurate width
    double ffem = fem * 0.97;

    return Container(
      // Set the background color
      color: AppColors.homebg,
      // Adjust the padding based on the fem
      padding: EdgeInsets.all(10 * fem),
      child: Row(
        children: [
          // Expand the container to fill the parent widget
          Expanded(
            child: Container(
              // Set the margin
              // margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 10 * fem),
              child: Text(
                'SOIL MOISTURE LEVEL',
                // Set the font and style
                style: SafeGoogleFont(
                  'Inter',
                  fontSize: 15 * ffem,
                  fontWeight: FontWeight.w700,
                  height: 1.2125 * ffem / fem,
                  color: Color(0xff000000),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

