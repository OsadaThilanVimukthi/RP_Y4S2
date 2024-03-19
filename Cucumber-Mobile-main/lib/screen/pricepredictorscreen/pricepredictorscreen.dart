import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectcucumber/config/theme/app_bar.dart';
import 'package:projectcucumber/config/theme/theme.dart';

// A StatefulWidget for predicting market prices of agricultural produce.
class PricePredictorScreen extends StatefulWidget {
  static String routeName = '/pricePredictorScreen';

  PricePredictorScreen({Key? key}) : super(key: key);

  @override
  _PricePredictorScreenState createState() => _PricePredictorScreenState();
}

// State class for PricePredictorScreen, managing price prediction functionality.
class _PricePredictorScreenState extends State<PricePredictorScreen> {
  // Various member variables and methods...
  final _formKey = GlobalKey<FormState>();
  String _location = '';
  int _numMonths = 0;
  double _expectedHarvestAmount = 0.0;
  double _retailRatio = 0;
  Map<String, dynamic> _response = {};
  bool _isLoading = false;
  List<String> locations = [
    'Galle',
    'Thissamaharama',
    'Rathnapura',
    'Gampaha',
    'Bandarawela',
    'Embilipitiya',
    'Veyangoda',
    'Meegoda',
    'Kurunegala',
    'Keppetipola',
    'Dehiattakandiya',
    'Hambanthota',
    'Jaffna',
    'Polonnaruwa',
    'Nikaweratiya',
    'Trinco',
    'Kaluthara',
    'Badulla',
    'Anuradapuraya',
    'Vavuniya',
    'Matale',
    'Mannar',
    'Dabulla',
    'Mullathivu',
    'Kandy',
    'Matara',
    'Thabuththegama',
    'Nuwara Eliya',
    'Ampara',
    'Monaragala',
    'Colombo',
    'Hanguranketha',
    'Puttalam',
    'Batticaloa',
    'Kegalle',
    'Galenbidunuwewa',
    'Kilinochchi'
  ];
  String? mlIP = dotenv.env['MLIP']?.isEmpty ?? true
      ? dotenv.env['DEFAULT_IP']
      : dotenv.env['MLIP'];
  bool _isWholesale = true; // Default to wholesale mode

  String? _selectedLocation;

  // Initializes the selected location and sets up the form.
  @override
  void initState() {
    super.initState();
    _selectedLocation = locations.isNotEmpty ? locations[0] : null;
  }

  // Submits the form data and handles the API call for price prediction.
  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid == true) {
      setState(() {
        _isLoading = true; // Start loading
      });

      _formKey.currentState?.save();
      final response = await _sendDataToAPI();

      setState(() {
        _isLoading = false; // Stop loading
        _response = json.decode(response.body);
      });
    }
  }

  // Sends the form data to the server API and receives the prediction response.
  Future<http.Response> _sendDataToAPI() {
    return http.post(
      Uri.parse('http://$mlIP:8000/function1'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'location': _location,
        'num_months': _numMonths,
        'expected_harvest_amount': _expectedHarvestAmount,
        'retail_ratio': _isWholesale ? 0 : 1, // Set based on switch state
      }),
    );
  }

  // Builds the main UI of the PricePredictorScreen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Market Price Predictor",
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Text(
                'Prediction Details',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.colorPrimary),
              ),
              SizedBox(height: 20),
              _buildLocationDropdown(),
              SizedBox(height: 10),
              _buildNumberInputField(
                label: 'Harvest Months',
                icon: Icons.calendar_today,
                onSave: (value) => _numMonths = int.parse(value!),
              ),
              SizedBox(height: 10),
              _buildNumberInputField(
                label: 'Expected Harvest Amount (KG)',
                icon: Icons.agriculture,
                onSave: (value) =>
                    _expectedHarvestAmount = double.parse(value!),
              ),
              SizedBox(height: 10),
              _buildModeSwitch(),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue, // Start color of the gradient
                      Colors.green, // End color of the gradient
                    ],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.transparent, // Make the button transparent
                    shadowColor: Colors.transparent, // No shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text('Predict Market Price',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(height: 20),
              _buildResponseDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  // Creates a dropdown for selecting a location.
  Widget _buildLocationDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedLocation,
      decoration: InputDecoration(
        labelText: 'Select the location',
        prefixIcon: Icon(Icons.location_on,
            color: AppColors.colorPrimary), // Icon for a modern look
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

  Widget _buildModeSwitch() {
    return ListTile(
      leading: Icon(_isWholesale ? Icons.business : Icons.store,
          color: AppColors.colorPrimary),
      title: Text(_isWholesale ? 'Wholesale Mode' : 'Retail Mode'),
      trailing: Switch(
        value: _isWholesale,
        onChanged: (bool value) {
          setState(() {
            _isWholesale = value;
          });
        },
        activeTrackColor: Colors.lightGreenAccent,
        activeColor: AppColors.colorPrimary,
      ),
    );
  }

  // Displays the response received from the server API.
  Widget _buildResponseDisplay() {
    if (_response.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Prediction Results',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.colorPrimary),
        ),
        SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: Icon(Icons.location_city, color: AppColors.colorPrimary),
            title: Text('Location: ${_response['location']}'),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.trending_up, color: AppColors.colorPrimary),
            title: Text('Highest Income: \$${_response['highest_income']}'),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.date_range, color: AppColors.colorPrimary),
            title: Text('Harvest Month: ${_response['harvest_month']}'),
          ),
        ),
        Card(
          child: ListTile(
            leading:
                Icon(Icons.stacked_bar_chart, color: AppColors.colorPrimary),
            title: Text('Cultivation Start: ${_response['cultivation_start']}'),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.local_activity, color: AppColors.colorPrimary),
            title: Text(
                'Best Neighbor: ${_response['best_neighbor']['location']} (\$${_response['best_neighbor']['income']})'),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.compare, color: AppColors.colorPrimary),
            title: Text('Comparison: ${_response['comparison_result']}'),
          ),
        ),
        SizedBox(height: 20),
        _buildNeighborIncomeList(),
      ],
    );
  }

  // Creates a list to display income data of neighboring locations.
  Widget _buildNeighborIncomeList() {
    var neighborLocations = _response['neighbor_locations'] as List<dynamic>;

    return ExpansionTile(
      title: Text(
        'Neighbor Locations Income',
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.colorPrimary),
      ),
      children: neighborLocations.map((neighbor) {
        return ListTile(
          title: Text(neighbor['location']),
          trailing: Text('\$${neighbor['income']}'),
        );
      }).toList(),
    );
  }

  // Creates a text input field for the form.
  Widget _buildTextInputField({
    required String label,
    required IconData icon,
    required Function(String?) onSave,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.colorPrimary),
        border: OutlineInputBorder(), // Added border
      ),
      onSaved: onSave,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  // Creates a number input field for the form.
  Widget _buildNumberInputField(
      {required String label,
      required IconData icon,
      required Function(String?) onSave,
      final Color? iconColor}) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon,
            color: AppColors
                .colorPrimary), // Changed to prefixIcon for a more modern look
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Rounded corners
          borderSide: BorderSide.none, // Hides the default border
        ),
        filled: true, // Needed for fillColor to take effect
        fillColor: Colors.grey[200], // Light grey fill color for a modern look
        contentPadding: EdgeInsets.symmetric(
            vertical: 15, horizontal: 20), // Adjust padding for aesthetics
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
      onSaved: onSave,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
