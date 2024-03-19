import 'package:flutter/material.dart';
import 'dart:io';
import 'package:projectcucumber/utils.dart';

// A StatelessWidget for displaying an image from a provided path.
class ImageBox extends StatelessWidget {
  final String imagePath;
  const ImageBox({Key? key, required this.imagePath}) : super(key: key);

  @override
  // Builds a widget to display the image with adaptive sizing.
  Widget build(BuildContext context) {
    double baseWidth = 450;
    double fem = MediaQuery.of(context).size.width / baseWidth;

    return SizedBox(
      width: 341 * fem,
      height: 225 * fem,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10 * fem),
        child: imagePath.isNotEmpty
            ? Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/images/image.jpg',
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
