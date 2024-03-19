import 'package:projectcucumber/screen/analysis/analysis.dart';
import 'package:projectcucumber/screen/home/home.dart';
import 'package:projectcucumber/screen/leafdisease/leaf.dart';
import 'package:projectcucumber/screen/soilmoisture/soilmoisture.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:projectcucumber/config/theme/theme.dart';
import 'package:projectcucumber/screen/screen.dart';
import 'package:ionicons/ionicons.dart';
import '../fruitdisease/fruit.dart';

// A StatefulWidget for managing navigation between different screens in the app.
class Nav extends StatefulWidget {
  static String routeName = '/nav';
  const Nav({
    Key? key,
  }) : super(key: key);

  @override
  State<Nav> createState() => _NavState();
}

// The state class for Nav, handling bottom navigation and page switching.
class _NavState extends State<Nav> {
  // Member variables and methods...
  final user = FirebaseAuth.instance.currentUser!;
  final List<Widget> _pages = [];
  int _currentIndex = 0;

  // Initializes the pages for navigation and sets the initial state.
  @override
  void initState() {
    _pages.add(Home());
    _pages.add(Leaf());
    _pages.add(Soilmoisture());
    _pages.add(Fruit());
    _pages.add(ProfileScreen());
    super.initState();
  }

  // Builds the main UI of the Nav screen with a BottomNavigationBar.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors
            .white, // Set to white as it will be overwritten by the ShaderMask for selected items
        unselectedItemColor: AppColors.colorTint600,
        selectedLabelStyle:
            TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: _currentIndex == 0
                ? gradientIcon(Ionicons.home)
                : Icon(Ionicons.home, size: 22),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 1
                ? gradientIcon(Ionicons.leaf)
                : Icon(Ionicons.leaf, size: 22),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 2
                ? gradientIcon(Ionicons.speedometer)
                : Icon(Ionicons.speedometer, size: 22),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 3
                ? gradientIcon(Ionicons.bug)
                : Icon(Ionicons.bug, size: 22),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 4
                ? gradientIcon(Ionicons.person)
                : Icon(Ionicons.person, size: 22),
            label: '',
          ),
        ],
      ),
    );
  }

  // Creates a gradient icon for the navigation bar.
  Widget gradientIcon(IconData iconData) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.blue, // Replace with your desired start color
            Colors.green, // Replace with your desired end color
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Icon(
        iconData,
        size: 25,
        color: Colors.white, // Temporary color, will be covered by gradient
      ),
    );
  }

  // Handles tab selection in the BottomNavigationBar.
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
