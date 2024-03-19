import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:projectcucumber/config/theme/app_bar.dart';
import 'dart:convert';
import 'package:projectcucumber/config/theme/theme.dart';

// A StatefulWidget that manages the analysis and forecast data for cucumber farming.
class Analysis extends StatefulWidget {
  @override
  _AnalysisState createState() => _AnalysisState();
}

// The state associated with the Analysis StatefulWidget.
class _AnalysisState extends State<Analysis> {
  // Other member variables and methods...
  TextEditingController numDaysController = TextEditingController(text: "7");
  DateTime selectedDate = DateTime.now();
  List<dynamic> forecastData = [];
  String? selectedForecastDate;
  bool isLoading = false;
  String _location = '';
  List<String> locations = [
    'Colombo',
    'Mount Lavinia',
    'Kesbewa',
    'Moratuwa',
    'Maharagama',
    'Ratnapura',
    'Kandy',
    'Negombo',
    'Sri Jayewardenepura Kotte',
    'Kalmunai',
    'Trincomalee',
    'Galle',
    'Jaffna',
    'Athurugiriya',
    'Weligama',
    'Matara',
    'Kolonnawa',
    'Gampaha',
    'Puttalam',
    'Badulla',
    'Kalutara',
    'Bentota',
    'Matale',
    'Mannar',
    'Pothuhera',
    'Kurunegala',
    'Mabole',
    'Hatton',
    'Hambantota',
    'Oruwala'
  ];
  double? averageMaxTemp;
  double? averageRainSum;
  String? _selectedLocation;
  double? soilMoistureL;
  double? soilPH;
  String? mlIP = dotenv.env['MLIP']?.isEmpty ?? true
      ? dotenv.env['DEFAULT_IP']
      : dotenv.env['MLIP'];

  // Builds a widget that shows the cucumber farming recommendation.
  Widget buildCucumberFarmingRecommendationBar() {
    // Assuming these values are calculated or fetched
    double avgTemp = averageMaxTemp ?? 25;
    double rainSum = averageRainSum ?? 25;
    double soilPh = soilPH ?? 6.0; // Using the state variable
    double soilMoisture = soilMoistureL ?? 80.0; // Using the state variable

    double suitabilityScore = evaluateCucumberFarmingSuitability(
      avgTemp: avgTemp,
      rainSum: rainSum,
      soilPh: soilPh,
      soilMoisture: soilMoisture,
    );

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cucumber Farming Suitability For Next ${numDaysController.text} Days:",
            style: TextStyle(
              color: AppColors.colorPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          RecommendationBar(suitabilityScore: suitabilityScore),
        ],
      ),
    );
  }

  // Fetches soil data asynchronously and updates the state.
  Future<void> fetchSoilData() async {
    var snapshot = await FirebaseDatabase.instance
        .ref('1706605694/device_data/soil_condition')
        .get();
    var data = Map<String, dynamic>.from(snapshot.value as Map);

    setState(() {
      soilMoistureL = data['soil_moisture'];
      soilPH = data['soil_pH'];
    });
  }

  // Initializes state, fetches initial soil and forecast data.
  @override
  void initState() {
    super.initState();
    fetchSoilData();
    fetchForecastForDefaultDays();
  }

  // Calculates and displays the average temperature and rain sum.
  void calculateAndDisplayAverages(List<dynamic> data) {
    double totalMaxTemp = 0;
    double totalRainSum = 0;

    data.forEach((day) {
      totalMaxTemp += day["y_max_temp"];
      totalRainSum += day["y_rain_sum"];
    });

    setState(() {
      averageMaxTemp = totalMaxTemp / data.length;
      averageRainSum = totalRainSum / data.length;
    });
  }

  // Builds a widget showing the average maximum temperature.
  Widget buildAverageTempBar() {
    if (averageMaxTemp == null) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              "Average Max Temp For Next ${numDaysController.text} Days: ${averageMaxTemp!.toStringAsFixed(2)} °C"),
          SizedBox(height: 5),
          CustomLinearBar(
            value: averageMaxTemp!,
            maxValue: 50, // Adjust as per your data
            optimalValue: 25, // Adjust as per your data
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  // Builds a widget showing the average rainfall sum.
  Widget buildAverageRainSumBar() {
    if (averageRainSum == null) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              "Average Rain Sum For Next ${numDaysController.text} Days: ${averageRainSum!.toStringAsFixed(2)} mm"),
          SizedBox(height: 5),
          CustomLinearBar(
            value: averageRainSum!,
            maxValue: 8, // Adjust as per your data
            optimalValue: 5, // Adjust as per your data
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  // Builds a card for selecting the forecast date.
  Widget buildDateSelectorCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // This makes the column wrap its content
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.all(10), // Adjust the value as per your preference
              child: Text(
                'Select Date From Predicted Forecast Dates',
                style: TextStyle(
                  color: AppColors.colorPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (forecastData.isNotEmpty) buildForecastDateDropdown(),
            SizedBox(height: 4),
            Padding(
              padding:
                  EdgeInsets.all(10), // Adjust the value as per your preference
              child: Text(
                'Land Recomendation',
                style: TextStyle(
                  color: AppColors.colorPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            buildAverageTempBar(),
            buildAverageRainSumBar(),
            buildCucumberFarmingRecommendationBar(),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Builds a card containing forecast information input fields.
  Widget foreCastInformationCard() {
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // This makes the column wrap its content
            children: <Widget>[
              SizedBox(height: 10),
              buildDateSelector(),
              SizedBox(height: 10),
              _buildLocationDropdown(),
              SizedBox(height: 20),
              buildDaysInput(),
              SizedBox(height: 10),
              buildSubmitButton(),
              SizedBox(height: 10),
            ],
          ),
        ));
  }

  // Builds the main UI of the Analysis screen.
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: CustomAppBar(
        title: "Land Recomendation",
        leadingImage: 'assets/icons/Back.png',
        actionImage: null,
        // actionImage: null,
        onLeadingPressed: () {
          Navigator.pop(context);
          print("Leading icon pressed");
        },
        onActionPressed: () {
          print("Action icon pressed");
        },
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),
                    foreCastInformationCard(),
                    SizedBox(height: 10),
                    buildDateSelectorCard(),
                    SizedBox(height: 10),
                    if (selectedForecastDate != null) buildForecastCard(),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
    );
  }

  // Builds a dropdown for selecting a forecast date.
  Widget buildForecastDateDropdown() {
    // Ensure there's a valid default value
    if (selectedForecastDate == null && forecastData.isNotEmpty) {
      selectedForecastDate = forecastData.first["Date"];
    }

    // Ensure the current value is in the list of items
    var dates = forecastData.map((item) => item["Date"]).toList();
    if (!dates.contains(selectedForecastDate)) {
      selectedForecastDate = null;
    }
    return Center(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: DropdownButton<String>(
            value: selectedForecastDate,
            hint: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10), // Add padding here
              child: Text('Select Forecast Date',
                  style: TextStyle(color: Colors.green)),
            ),
            onChanged: (String? newValue) {
              setState(() {
                selectedForecastDate = newValue;
              });
            },
            items: forecastData.map<DropdownMenuItem<String>>((dynamic value) {
              return DropdownMenuItem<String>(
                value: value["Date"],
                child: Text(value["Date"]),
              );
            }).toList(),
            isExpanded: true,
            underline: Container(),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(20),
            iconSize: 24,
          ),
        ),
      ),
    );
  }

  // Builds a card displaying the selected forecast's details.
  Widget buildForecastCard() {
    var data = forecastData
        .firstWhere((element) => element["Date"] == selectedForecastDate);

    return ForecastCard(data: data);
  }

  // Builds a dropdown for selecting a location.
  Widget _buildLocationDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedLocation,
      decoration: InputDecoration(
        labelText: 'Select the location',
        prefixIcon: ShaderMask(
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
          blendMode: BlendMode
              .srcIn, // This blend mode applies the gradient to the icon
          child:
              Icon(Icons.location_on, color: Colors.white), // Temporary color
        ),
        // Icon for a modern look
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Rounded corners
          borderSide: BorderSide.none, // Hide the default border
        ),
        filled: true, // Enable fill color
        fillColor: Colors.grey[200], // Light grey fill color
        contentPadding: EdgeInsets.symmetric(
            vertical: 15, horizontal: 20), // Padding inside the dropdown
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
              color: Colors.grey[300]!, width: 1), // Light grey border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
              color: AppColors.colorPrimary,
              width: 2), // Thicker border when focused
        ),
      ),
      items: locations.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedLocation = newValue;
          _location = newValue ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a location';
        }
        return null;
      },
    );
  }

  // Builds a ListTile for selecting a custom date.
  ListTile buildDateSelector() {
    return ListTile(
      title: Text("Select Custom Date:",
          style: TextStyle(
            color: AppColors.colorPrimary,
            fontWeight: FontWeight.bold,
          )),
      subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
      trailing: Icon(Icons.calendar_today, color: AppColors.colorPrimary),
      onTap: () => _selectDate(context),
    );
  }

  // Builds a text input field for entering the number of days.
  Widget buildDaysInput() {
    return TextFormField(
      controller: numDaysController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Number of Days',
        prefixIcon: ShaderMask(
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
          blendMode: BlendMode
              .srcIn, // This blend mode applies the gradient to the icon
          child: Icon(Icons.timelapse, color: Colors.white), // Temporary color
        ),
        // Using a relevant icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Rounded corners
          borderSide: BorderSide.none, // Hides the default border
        ),
        filled: true, // Needed for fillColor to take effect
        fillColor: Colors.grey[200], // Light grey fill color for a modern look
        contentPadding: EdgeInsets.symmetric(
            vertical: 15, horizontal: 20), // Adjust padding
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
              color: Colors.grey[300]!, width: 1), // Light grey border color
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
              color: AppColors.colorPrimary,
              width: 2), // Thicker border when focused
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the number of days';
        }
        return null;
      },
    );
  }

  // Builds a submit button for the forecast.
  Widget buildSubmitButton() {
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
          if (_selectedLocation != null && numDaysController.text.isNotEmpty) {
            fetchForecast();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "Please select a location, date, and enter the number of days."),
            ));
          }
        },
        child: Text('Predict Weather Forecast',
            style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent, // Make the button transparent
          shadowColor: Colors.transparent, // No shadow
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0), // Rounded corners
          ),
        ),
      ),
    );
  }

  // Displays a date picker to select a custom date.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  // Fetches the forecast for default days asynchronously.
  Future<void> fetchForecastForDefaultDays() async {
    setState(() {
      isLoading = true;
    });

    // Assuming 'Kurunegala' as the default location
    _selectedLocation = locations.first;
    String formattedDate =
        "${selectedDate.toLocal().year}-${selectedDate.toLocal().month.toString().padLeft(2, '0')}-${selectedDate.toLocal().day.toString().padLeft(2, '0')}";

    final response = await http.get(Uri.parse(
        'http://$mlIP:8000/weather_forecast?location=$_selectedLocation&date=$formattedDate&num_days=${numDaysController.text}'));

    if (response.statusCode == 200) {
      setState(() {
        forecastData = json.decode(response.body);
        if (forecastData.isNotEmpty) {
          selectedForecastDate = forecastData[0]["Date"];
        }
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to load forecast data."),
      ));
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetches the weather forecast based on user inputs.
  Future<void> fetchForecast() async {
    setState(() {
      isLoading = true;
    });

    // Format the date to "YYYY-MM-DD"
    String formattedDate =
        "${selectedDate.toLocal().year}-${selectedDate.toLocal().month.toString().padLeft(2, '0')}-${selectedDate.toLocal().day.toString().padLeft(2, '0')}";

    final response = await http.get(Uri.parse(
        'http://$mlIP:8000/weather_forecast?location=$_selectedLocation&date=$formattedDate&num_days=${numDaysController.text}'));

    if (response.statusCode == 200) {
      setState(() {
        forecastData = json.decode(response.body);
        calculateAndDisplayAverages(forecastData);
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to load forecast data."),
      ));
      setState(() {
        isLoading = false;
      });
    }
  }
}

// A StatelessWidget representing a forecast card.
class ForecastCard extends StatelessWidget {
  final dynamic data;

  ForecastCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            ListTile(
              leading: ShaderMask(
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
                child: Icon(Icons.calendar_today, color: Colors.white),
              ),
              title: Text("Date: ${data["Date"]}"),
            ),
            Divider(),
            InfoRow(
              icon: Icons.thermostat,
              label: "Max Temp",
              value: "${data["y_max_temp"]} °C",
              iconShader: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.blue, // Replace with your desired start color
                    Colors.green, // Replace with your desired end color
                  ],
                ).createShader(bounds);
              },
            ),
            InfoRow(
              icon: Icons.thermostat_outlined,
              label: "Min Temp",
              value: "${data["y_min_temp"]} °C",
              iconShader: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.blue, // Replace with your desired start color
                    Colors.green, // Replace with your desired end color
                  ],
                ).createShader(bounds);
              },
            ),
            InfoRow(
              icon: Icons.opacity,
              label: "Rain Sum",
              value: "${data["y_rain_sum"]} mm",
              iconShader: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.blue, // Replace with your desired start color
                    Colors.green, // Replace with your desired end color
                  ],
                ).createShader(bounds);
              },
            ),
            InfoRow(
              icon: Icons.water_drop,
              label: "Rain Hours",
              value: "${data["y_rain_hours"]} hrs",
              iconShader: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.blue, // Replace with your desired start color
                    Colors.green, // Replace with your desired end color
                  ],
                ).createShader(bounds);
              },
            ),
            InfoRow(
              icon: Icons.air,
              label: "Wind Speed Max",
              value: "${data["y_windspeed_10m_max"]} km/h",
              iconShader: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.blue, // Replace with your desired start color
                    Colors.green, // Replace with your desired end color
                  ],
                ).createShader(bounds);
              },
            ),
          ],
        ),
      ),
    );
  }
}

double evaluateCucumberFarmingSuitability({
  required double avgTemp,
  required double rainSum,
  required double soilPh,
  required double soilMoisture,
}) {
  int suitableConditions = 0;
  if (avgTemp >= 20 && avgTemp <= 30) suitableConditions++;
  if (rainSum >= 30 && rainSum <= 50) suitableConditions++;
  if (soilPh >= 6.0 && soilPh <= 7.0) suitableConditions++;
  if (soilMoisture >= 40 && soilMoisture <= 60) suitableConditions++;

  return suitableConditions / 4.0; // Divided by the number of conditions
}

// A Stateless Widget that represents a row of information with an icon.
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Shader Function(Rect bounds)? iconShader; // New shader parameter

  InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconShader, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ShaderMask(
        shaderCallback: iconShader ??
            (Rect bounds) =>
                LinearGradient(colors: [Colors.black]).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Icon(icon, color: Colors.white), // Temp color
      ),
      title: Text(label),
      trailing: Text(value),
    );
  }
}

// A StatelessWidget for creating a custom linear progress bar.
class CustomLinearBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final double optimalValue;
  final Color color;

  const CustomLinearBar({
    Key? key,
    required this.value,
    required this.maxValue,
    required this.optimalValue,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fraction = (value / maxValue).clamp(0.0, 1.0);
    double optimalFraction = (optimalValue / maxValue).clamp(0.0, 1.0);

    return Stack(
      children: [
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Container(
          height: 20,
          width: MediaQuery.of(context).size.width * fraction,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * optimalFraction,
          child: Container(
            height: 20,
            width: 2,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

// A StatelessWidget that represents a bar indicating the suitability of cucumber farming.
class RecommendationBar extends StatelessWidget {
  final double suitabilityScore; // A score from 0 to 1 representing suitability

  const RecommendationBar({
    Key? key,
    required this.suitabilityScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: FractionallySizedBox(
        widthFactor: suitabilityScore,
        child: Container(
          decoration: BoxDecoration(
            color: suitabilityScore > 0.75
                ? Colors.green
                : suitabilityScore > 0.5
                    ? Colors.yellow
                    : Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
