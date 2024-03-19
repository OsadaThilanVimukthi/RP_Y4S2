import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePic extends StatelessWidget {
  // Get the current user from Firebase Auth
  final user = FirebaseAuth.instance.currentUser!;
  
  // Create a ProfilePic widget with a photoURL
  ProfilePic(String? photoURL, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Return a SizedBox with a height and width of 130
    return SizedBox(
      height: 130,
      width: 130,
      // Create a Stack with a fit of expand, clipBehavior of none, and children
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          // Create a CircleAvatar with a backgroundImage of the user's photoURL
          CircleAvatar(
            backgroundImage: NetworkImage(user.photoURL!),
          ),
          // Create a Positioned with a right of -16 and bottom of 0
          Positioned(
            right: -16,
            bottom: 0,
            // Create a SizedBox with a height of 46 and width of 46
            child: SizedBox(
              height: 46,
              width: 46,
              // Create a TextButton with a style of foregroundColor of white, shape of RoundedRectangleBorder with a borderRadius of 50, side of const BorderSide with a color of white, and backgroundColor of const Color with a value of 0xFFF5F6F9
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFF5F6F9),
                ),
                // Create an onPressed callback
                onPressed: () {},
                // Create a SvgPicture with an asset of the Camera Icon
                child: SvgPicture.asset("assets/icons/Camera Icon.svg"),
              ),
            ),
          )
        ],
      ),
    );
  }
}