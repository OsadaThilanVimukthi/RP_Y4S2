import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:projectcucumber/config/theme/app_bar.dart';
import 'package:projectcucumber/config/theme/theme.dart';
import 'package:projectcucumber/screen/fruitdisease/components/fruitcapture.dart';
import 'package:projectcucumber/screen/fruitdisease/components/imagebox.dart';
import 'package:http_parser/http_parser.dart';

// A StatefulWidget for performing and displaying results of cucumber disease analysis.
class fruitdiseaseSeperate extends StatefulWidget {
  @override
  _fruitdiseaseSeperateState createState() => _fruitdiseaseSeperateState();
}

// The state class for Fruit, handling image capture and disease analysis.
class _fruitdiseaseSeperateState extends State<fruitdiseaseSeperate> {
  // Various member variables and methods...
  String _capturedImagePath = '';
  String _analysisResult = '';
  String _recommendation = "";
  Color textColor = Colors.black;
  String ccCondition = '';
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  List<String> recommendationList = [];
  bool _isLoading = false; // New variable for loading state
  Map<String, dynamic> _secondResult = {};
  String? mlIP = dotenv.env['MLIP']?.isEmpty ?? true
      ? dotenv.env['DEFAULT_IP']
      : dotenv.env['MLIP'];
  final user = FirebaseAuth.instance.currentUser!;

  // Called when an image is captured, handles image analysis and updates the UI.
  void _onImageCaptured(String path) async {
    setState(() {
      _isLoading = true; // Set loading to true
      _capturedImagePath = path;
    });

    var firstResult = await uploadImage(path);

    setState(() {
      _isLoading = false; // Set loading to false after responses are received
      _analysisResult =
          "Result: ${firstResult['result']}\nClass: ${firstResult['class']}";
      _generateRecommendation(firstResult['class']);
    });
  }

  // Uploads an image to a server endpoint for analysis and returns the result.
  Future<Map<String, dynamic>> uploadImage(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://$mlIP:8000/cucumber_disease'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Parse the response body
        var data = jsonDecode(response.body);
        return data;
      } else {
        // Handle the situation where the server responds with an error
        return {
          'error': 'Server responded with status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Handle any other type of error (e.g., network error)
      return {
        'error': 'An error occurred: $e',
      };
    }
  }

// Generates recommendations based on the analysis result.
  void _generateRecommendation(String classLabel) {
    // Clear existing recommendations if the class label is 'Other'
    if (classLabel == "Other") {
      setState(() {
        ccCondition = classLabel;
        textColor = Colors.red;
        _recommendation = "This is not Cucumber. No recommendations available.";
        recommendationList
            .clear(); // Clear the list to not show any recommendations
      });
      return; // Exit the method early as there's no need to generate recommendations
    }

    List<String> recommendations;

    if (classLabel == "Fresh Cucumber") {
      recommendations = [
        "Maintain consistent watering to avoid stress on the plants. Overwatering and underwatering can both be harmful.",
        "Apply a balanced, slow-release fertilizer monthly to provide essential nutrients. Cucumbers are heavy feeders and benefit from additional nutrition.",
        "Inspect for pests such as aphids, cucumber beetles, and spider mites regularly. Use organic or chemical controls as needed.",
        "Prune dead or yellowing leaves to encourage healthy growth and improve air circulation around the plant.",
        "Use mulch around the base of the plants to retain soil moisture, regulate soil temperature, and suppress weeds.",
        "Provide support with trellises or stakes to promote vertical growth, which improves air circulation and reduces disease risks.",
        "Ensure adequate spacing between plants to prevent overcrowding, which can lead to increased disease and pest pressure.",
        "Monitor for signs of nutrient deficiencies and address them promptly with appropriate fertilization."
      ];
    } else {
      recommendations = [
        "Check soil pH and nutrient levels to ensure they are within the optimal range for your specific plants. Adjust as necessary.",
        "Look for signs of disease such as leaf spots, wilting, or unusual growth patterns. Early detection is key to effective management.",
        "Adjust your watering schedule based on the plant's needs, weather conditions, and soil moisture. Avoid both overwatering and underwatering.",
        "Protect plants from intense sun exposure, especially during the hottest part of the day, to prevent leaf burn and heat stress.",
        "Consult a gardening expert or extension service for specific advice tailored to your garden's conditions and local climate.",
        "Consider adding organic matter or compost to improve soil structure and fertility.",
        "Rotate crops each year to prevent soil-borne diseases and reduce pest problems.",
        "Mulch around plants to help retain soil moisture, regulate temperature, and suppress weeds."
      ];
    }

    setState(() {
      ccCondition = classLabel;
      textColor = classLabel == 'Fresh Cucumber' ? Colors.green : Colors.red;
      _recommendation = recommendations.join('\n');
      recommendationList = _recommendation.split('\n');
    });
  }

  // Builds the main UI of the Fruit screen.
  @override
  Widget build(BuildContext context) {
    // Determine if there's content to show which would affect the layout
    bool hasContent =
        _capturedImagePath.isNotEmpty || recommendationList.isNotEmpty;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Disease Analysis",
        leadingImage: 'assets/icons/Back.png',
        actionImage: null,
        onLeadingPressed: () {
          Navigator.pop(context);
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
        "Capture image of the cucumber using below scan button!",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13, // Adjusted for better readability
          fontWeight: FontWeight.bold,
          color: AppColors.colorPrimary,
        ),
      ),
      SizedBox(height: 20),
      ImageBox(imagePath: _capturedImagePath),
      SizedBox(height: 20),
      if (ccCondition.isNotEmpty)
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(10),
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
            '$_analysisResult',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      SizedBox(height: 10),
      // Only show this text if there are recommendations to follow
      if (ccCondition.isNotEmpty && recommendationList.isNotEmpty)
        Text(
          "Follow these recommendations for better harvest.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.colorPrimary,
          ),
        ),
      SizedBox(height: 10),
      if (ccCondition.isNotEmpty && recommendationList.isNotEmpty)
        Container(
          height: 350, // Adjust the height as needed
          child: ListView.builder(
            itemCount: recommendationList.length,
            itemBuilder: (context, index) {
              return _buildRecommendationItem(recommendationList[index], index);
            },
          ),
        ),
      SizedBox(height: 5),
      Fruitcapture(onImageCaptured: _onImageCaptured),
      SizedBox(height: 20),
    ];
  }

  List<Widget> buildInitialContent() {
    // Return the list of widgets that make up the content of the page
    return [
      Text(
        "Capture image of the cucumber using below scan button!",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13, // Adjusted for better readability
          fontWeight: FontWeight.bold,
          color: AppColors.colorPrimary,
        ),
      ),
      SizedBox(height: 20),
      ImageBox(imagePath: _capturedImagePath),
      SizedBox(height: 20),
      if (ccCondition.isNotEmpty)
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(10),
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
            '$_analysisResult',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      SizedBox(height: 10),
      if (ccCondition.isNotEmpty)
        Text(
          "Follow these recommendations for better harvest.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.colorPrimary,
          ),
        ),
      SizedBox(height: 10),
      if (ccCondition.isNotEmpty)
        Container(
          height: 350, // Adjust the height as needed
          child: ListView.builder(
            itemCount: recommendationList.length,
            itemBuilder: (context, index) {
              return _buildRecommendationItem(recommendationList[index], index);
            },
          ),
        ),
      SizedBox(height: 5),
      Fruitcapture(onImageCaptured: _onImageCaptured),
      SizedBox(height: 20),
    ];
  }

  // Builds a widget to display each recommendation item.
  Widget _buildRecommendationItem(String recommendation, int index) {
    return Card(
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Container(
          width: 40, // Circle diameter
          height: 40, // Circle diameter
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFF2196F3), // Start color
                Color(0xFF4CAF50), // End color
              ],
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
        ),
        title: Text(
          recommendation,
          style: TextStyle(fontSize: 14, color: Colors.green[800]),
        ),
        trailing: Icon(FontAwesomeIcons.bug, color: Colors.green[600]),
      ),
    );
  }
}
