import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// A StatefulWidget for capturing an image of a fruit.
class Fruitcapture extends StatefulWidget {
  final Function(String) onImageCaptured;
  const Fruitcapture({Key? key, required this.onImageCaptured})
      : super(key: key);

  @override
  _FruitcaptureState createState() => _FruitcaptureState();
}

// The state class for Fruitcapture, handling the image capture functionality.
class _FruitcaptureState extends State<Fruitcapture> {
  Future<void> _captureImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      widget.onImageCaptured(image.path);
    }
  }

  @override
  // Builds the widget with a gesture detector for image capture.
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _captureImage,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/page-1/images/camera.png'), // Replace 'your_image.png' with the actual image name
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}