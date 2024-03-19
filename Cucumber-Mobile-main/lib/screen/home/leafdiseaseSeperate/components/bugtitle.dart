import 'package:flutter/material.dart';
import 'package:projectcucumber/config/theme/theme.dart';
import 'package:projectcucumber/utils.dart';

// A StatefulWidget for displaying the title of the cucumber fruit disease analysis section.
class bugtitle extends StatefulWidget {
  const bugtitle({super.key});

  @override
  State<bugtitle> createState() => _nameState();
}

// State class for bugtitle, managing the UI for the disease analysis title.
class _nameState extends State<bugtitle> {
  @override
  // Builds the widget for the title with dynamic text scaling based on screen width.
  Widget build(BuildContext context) {
    double baseWidth = 450;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Container(
      color: AppColors.homebg,
      padding: EdgeInsets.all(10 * fem), // Adjust padding based on fem
      child: Row(
        children: [
          Expanded(
            child: Container(
              // soilmoisturelevelE7b (31:196)
              // margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 10 * fem),
              child: Text(
                'CUCUMBER FRUIT DISEASE ANALYSIS',
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