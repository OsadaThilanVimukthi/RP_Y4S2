import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:projectcucumber/config/theme/app_bar.dart';
import 'package:projectcucumber/config/theme/theme.dart';
import 'package:projectcucumber/screen/fruitdisease/components/fruitcapture.dart';
import 'package:projectcucumber/screen/fruitdisease/components/imagebox.dart';
import 'package:http_parser/http_parser.dart';

// A StatefulWidget for performing and displaying results of cucumber disease analysis.
class pestsSeperate extends StatefulWidget {
  @override
  _pestsSeperateState createState() => _pestsSeperateState();
}

// The state class for Fruit, handling image capture and disease analysis.
class _pestsSeperateState extends State<pestsSeperate> {
  // Various member variables and methods...
  String _capturedImagePath = '';
  String _analysisResult = '';
  String _recommendation = "";
  Color textColor = Colors.black;
  String ccCondition = '';
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  List<String> recommendationList = [];
  bool _isLoading = false; // New variable for loading state
  Map<String, List<String>> _secondResult = {};
  String? mlIP = dotenv.env['MLIP']?.isEmpty ?? true
      ? dotenv.env['DEFAULT_IP']
      : dotenv.env['MLIP'];
  String pestsCondition = '';
  Map<String, dynamic> _pestsResult = {};

  final Map<String, List<String>> recommendations = {
    'Aphids': [
      'Use insecticidal soaps or oils.',
      'Encourage natural predators like ladybugs.',
      'Remove heavily infested leaves or plants.',
      'Apply foliar sprays of water to dislodge aphids.',
      'Use chemical insecticides as a last resort.',
    ],
    'Fruit fly': [
      'Use fruit fly traps or baits.',
      'Remove and destroy infested fruits.',
      'Use netting to cover fruit trees.',
      'Regularly monitor for early detection.',
      'Apply appropriate insecticides if necessary.',
    ],
    'Pumpkin Beetle': [
      'Handpick beetles and destroy them.',
      'Use floating row covers to protect plants.',
      'Apply neem oil or insecticidal soap.',
      'Rotate crops to prevent soil-borne populations.',
      'Use chemical pesticides if infestation is severe.',
    ],
    'Serpentine leafminer': [
      'Remove and destroy infested leaves.',
      'Use yellow sticky traps to monitor and reduce adult populations.',
      'Encourage natural enemies like parasitic wasps.',
      'Avoid excessive nitrogen fertilizer use.',
      'Apply systemic insecticides if needed.',
    ],
    'Whitefly': [
      'Use yellow sticky traps to catch adults.',
      'Introduce natural predators like Encarsia formosa.',
      'Apply insecticidal soaps or neem oil.',
      'Ensure proper ventilation if in a greenhouse.',
      'Use chemical insecticides as a last resort.',
    ],
  };

  // Called when an image is captured, handles image analysis and updates the UI.
  void _onImageCaptured(String path) async {
    setState(() {
      _isLoading = true;
      _capturedImagePath = path;
    });

    var pestsResult = await uploadImageForPestsAnalysis(path);

    setState(() {
      _isLoading = false;
      _pestsResult = pestsResult;
      print("Analysis Result: $pestsResult");
    });
  }

  // Uploads an image to a second server endpoint for additional analysis.
  Future<Map<String, dynamic>> uploadImageForPestsAnalysis(
      String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://$mlIP:8000/cucumber_with_pests'), // Corrected endpoint
      );

      request.headers.addAll({
        'accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imagePath,
        contentType: MediaType(
            'image', 'jpeg'), // Ensure this matches your server's expectation
      ));

      request.fields['confidence'] =
          '0.1'; // Added confidence field as per the curl example

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        _generateRecommendation(data); // Call to generate recommendations
        return data;
      } else {
        return {
          'error': 'Server responded with status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'error': 'An error occurred: $e',
      };
    }
  }

// Assuming recommendations are properly defined in your class
  void _generateRecommendation(Map<String, dynamic> analysisResult) {
    Map<String, List<String>> structuredRecommendations = {};

    for (var result in analysisResult['results']) {
      String pestName = result['predicted_class'];
      List<String>? pestRecommendations = recommendations[pestName];
      if (pestRecommendations != null) {
        List<String> numberedRecommendations = [];
        for (int i = 0; i < pestRecommendations.length; i++) {
          numberedRecommendations.add('${i + 1}. ${pestRecommendations[i]}');
        }
        structuredRecommendations[pestName] = numberedRecommendations;
      }
    }

    setState(() {
      _analysisResult = analysisResult['message'];
      _secondResult = structuredRecommendations;
      pestsCondition = analysisResult['results'].isEmpty ? '' : 'Detected';
    });
  }

  // Builds the main UI of the Fruit screen.
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    print(
        "Building UI with recommendationList length: ${recommendationList.length}");
    return Scaffold(
      appBar: CustomAppBar(
        title: "Pests Analysis",
        leadingImage: 'assets/icons/Back.png',
        actionImage: null,
        onLeadingPressed: () {
          print("Leading icon pressed");
          Navigator.pop(context);
        },
        onActionPressed: () {
          print("Action icon pressed");
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator()) // Show loading indicator
            : SingleChildScrollView(
                child: Center(
                  // Wrap Column in Center
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Capture image of the pests using below scan button!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13, // Adjusted for better readability
                          fontWeight: FontWeight.bold,
                          color: AppColors.colorPrimary,
                        ),
                      ),
                      SizedBox(height: 10),
                      ImageBox(imagePath: _capturedImagePath),
                      SizedBox(height: 10),
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
                      SizedBox(height: 5),
                      if (_pestsResult.isNotEmpty)
                        _buildModelResponseCard(_pestsResult),
                      SizedBox(height: 5),
                      ..._secondResult.entries.map((entry) {
                        return _buildRecommendationsCard(
                            entry.key, entry.value);
                      }).toList(),
                      SizedBox(height: 10),
                      if (recommendationList.isNotEmpty)
                        Text(
                          "Follow these recommendations for destroy pests.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.colorPrimary,
                          ),
                        ),
                      SizedBox(height: 10),
                      if (recommendationList.isNotEmpty)
                        Container(
                          height: 350, // Adjust the height as needed
                          child: ListView.builder(
                            itemCount: recommendationList.length,
                            itemBuilder: (context, index) {
                              return _buildRecommendationItem(
                                  recommendationList[index], index);
                            },
                          ),
                        ),
                      SizedBox(height: 5),
                      Fruitcapture(onImageCaptured: _onImageCaptured),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildModelResponseCard(Map<String, dynamic> analysisResult) {
    return Card(
      color: Colors.lightBlue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Model Analysis Results',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            Divider(color: Colors.blue[300], thickness: 1),
            ...analysisResult['results'].map<Widget>((result) {
              return Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.bug_report, color: Colors.blue[600]),
                    title: Text(
                      '${result['predicted_class']}',
                      style: TextStyle(fontSize: 16.0, color: Colors.blue[800]),
                    ),
                    subtitle: Text(
                      'Confidence: ${(result['confidence'] * 100).toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 14.0, color: Colors.blue[600]),
                    ),
                  ),
                  Divider(color: Colors.blue[200], thickness: 1),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Builds a widget to display each recommendation item.
  Widget _buildRecommendationItem(String recommendation, int index) {
    return Card(
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[400],
          child: Text(
            '${index + 1}',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
        title: Text(
          recommendation,
          style: TextStyle(fontSize: 14, color: Colors.green[800]),
        ),
        trailing: Icon(Icons.eco, color: Colors.green[600]), // Example icon
      ),
    );
  }

  // Builds a card to display results from the second analysis endpoint.
  Widget _buildRecommendationsCard(
      String pestName, List<String> recommendations) {
    return Card(
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations for $pestName',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            Divider(color: Colors.green[300], thickness: 1),
            Column(
              children: recommendations.asMap().entries.map((entry) {
                int idx = entry.key;
                String recommendation = entry.value;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[400],
                    child: Text(
                      '${idx + 1}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    recommendation,
                    style: TextStyle(fontSize: 14.0, color: Colors.green[800]),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
