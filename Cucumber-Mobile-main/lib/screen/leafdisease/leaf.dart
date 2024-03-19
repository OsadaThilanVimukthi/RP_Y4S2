import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:projectcucumber/config/theme/app_bar.dart';
import 'package:projectcucumber/config/theme/theme.dart';
import 'package:projectcucumber/screen/leafdisease/components/fruitcapture.dart';
import 'package:projectcucumber/screen/leafdisease/components/imagebox.dart';

// A StatefulWidget for analyzing leaf diseases in cucumber plants.
class Leaf extends StatefulWidget {
  @override
  _LeafState createState() => _LeafState();
}

// The state class for Leaf, managing the leaf disease analysis process.
class _LeafState extends State<Leaf> {
  // Various member variables and methods...
  String _capturedImagePath = '';
  String _analysisResult = '';
  Color textColor = Colors.black;
  List<String> recommendationList = [];
  final user = FirebaseAuth.instance.currentUser!;
  String? mlIP = dotenv.env['MLIP']?.isEmpty ?? true
      ? dotenv.env['DEFAULT_IP']
      : dotenv.env['MLIP'];

  // Called when an image is captured, handles image analysis.
  void _onImageCaptured(String path) async {
    setState(() {
      _capturedImagePath = path;
    });
    var result = await _uploadImage(path);
    _processResult(result);
  }

  // Uploads an image to a server endpoint for leaf disease analysis.
  Future<Map<String, dynamic>> _uploadImage(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://$mlIP:8000/cucumber_leaf'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200
          ? jsonDecode(response.body)
          : {'error': 'Server error with status code: ${response.statusCode}'};
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  // Processes the result from the image analysis and updates the UI.
  void _processResult(Map<String, dynamic> result) {
    if (result.containsKey('error')) {
      _analysisResult = result['error'];
      recommendationList = [];
    } else {
      String diseaseClass = result['class_disease'] ?? 'Unknown disease class';
      _analysisResult = 'Disease Class: $diseaseClass';
      recommendationList = _getRecommendations(diseaseClass);
      textColor = Colors.red;
    }
    setState(() {});
  }

  // Generates a list of recommendations based on the disease class.
  List<String> _getRecommendations(String diseaseClass) {
    switch (diseaseClass) {
      case "Healthy leaves":
        return [
          "Your cucumber leaves are healthy. Continue with regular care and monitoring.",
          "Ensure balanced watering and adequate sunlight for continued plant health.",
          "Regularly check for pests or early signs of disease as a preventive measure.",
          "Consider applying a balanced, slow-release fertilizer for optimal growth.",
          "Mulch around the base to maintain soil moisture and temperature."
        ];
      case "downy mildew stage 1":
        return [
          "Remove and destroy affected leaves to prevent spread.",
          "Apply a fungicide suitable for downy mildew. Follow label instructions.",
          "Improve air circulation around plants by spacing them properly.",
          "Ensure that the plants are not overcrowded to reduce humidity.",
          "Water in the morning so leaves can dry out during the day."
        ];
      case "downy mildew stage 2":
        return [
          "Prune heavily infected areas. Sanitize tools after use.",
          "Use a stronger fungicide specifically labeled for downy mildew control.",
          "Avoid overhead watering to reduce leaf wetness.",
          "Consider applying a systemic fungicide for more severe infections.",
          "Regularly monitor the plant's health and remove any new affected areas promptly."
        ];
      case "powdery mildew stage 1":
        return [
          "Apply a mixture of baking soda, water, and dish soap as an early treatment.",
          "Increase air circulation and reduce humidity around the plants.",
          "Water the plants at the base to avoid wetting the foliage.",
          "Avoid high nitrogen fertilizers which can increase susceptibility.",
          "Regularly inspect leaves for signs of mildew and treat immediately if spotted."
        ];
      case "powdery mildew stage 2":
        return [
          "Use a sulfur-based fungicide to control the spread of powdery mildew.",
          "Remove severely affected leaves and dispose of them properly.",
          "Consider organic options like neem oil for treatment.",
          "Ensure good air flow around the plants, especially during humid conditions.",
          "Avoid watering late in the day to ensure leaves stay dry overnight."
        ];
      default:
        return ["No specific recommendations available for this condition."];
    }
  }

  // Builds the main UI of the Leaf screen.
  @override
  Widget build(BuildContext context) {
    // Determine if there's content to show which would affect the layout
    bool hasContent =
        _capturedImagePath.isNotEmpty || recommendationList.isNotEmpty;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Leaf Disease Analysis",
        leadingImage: user.photoURL ?? '',
        actionImage: null,
        onLeadingPressed: () {
          print("Leading icon pressed");
        },
        onActionPressed: () {
          print("Action icon pressed");
        },
      ),
      body: hasContent ? _contentLayout() : _centeredLayout(),
    );
  }

  Widget _centeredLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: buildInitialContent(),
        ),
      ),
    );
  }

  Widget _contentLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          // Wrap the Column with Center
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Align items to the start vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center items horizontally
            children: buildContent(),
          ),
        ),
      ),
    );
  }

  List<Widget> buildContent() {
    // Return the list of widgets that make up the content of the page
    return [
      Text(
        "Capture image of the cucumber leaf using the scan button below!",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.colorPrimary,
        ),
      ),
      SizedBox(height: 20),
      ImageBox(imagePath: _capturedImagePath),
      SizedBox(height: 20),
      if (_analysisResult.isNotEmpty) _buildResultContainer(_analysisResult),
      SizedBox(height: 10),
      if (recommendationList.isNotEmpty) _buildRecommendationSection(),
      SizedBox(height: 20),
      Fruitcapture(onImageCaptured: _onImageCaptured),
      SizedBox(height: 20),
    ];
  }

  List<Widget> buildInitialContent() {
    // Return the list of widgets that make up the content of the page
    return [
      Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/arugula.png'), // Replace 'your_image.png' with the actual image name
            fit: BoxFit.cover,
          ),
        ),
      ),
      SizedBox(height: 20),
      Text(
        "Capture image of the cucumber leaf using the scan button below!",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.colorPrimary,
        ),
      ),
      SizedBox(height: 20),
      ImageBox(imagePath: _capturedImagePath),
      SizedBox(height: 20),
      if (_analysisResult.isNotEmpty) _buildResultContainer(_analysisResult),
      if (recommendationList.isNotEmpty) _buildRecommendationSection(),
      Fruitcapture(onImageCaptured: _onImageCaptured),
      SizedBox(height: 20),
    ];
  }

  // Builds a container widget to display the analysis result.
  Widget _buildResultContainer(String result) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        result,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  // Builds a section to display recommendations.
  Widget _buildRecommendationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "Follow these recommendations for better harvest:",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.colorPrimary,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: recommendationList.length,
          itemBuilder: (context, index) {
            return _buildRecommendationItem(recommendationList[index], index);
          },
        ),
      ],
    );
  }

  // Builds a widget for each recommendation item.
  Widget _buildRecommendationItem(String recommendation, int index) {
    return Card(
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: _buildRecommendationLeading(index),
        title: Text(
          recommendation,
          style: TextStyle(fontSize: 14, color: Colors.green[800]),
        ),
        trailing: Icon(Icons.eco, color: Colors.green[600]),
      ),
    );
  }

  // Builds a leading widget for the recommendation items.
  Widget _buildRecommendationLeading(int index) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }
}
