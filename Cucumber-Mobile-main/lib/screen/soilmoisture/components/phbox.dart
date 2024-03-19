import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:projectcucumber/config/theme/theme.dart';
import 'package:projectcucumber/utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class Phbox extends StatefulWidget {
  const Phbox({super.key});

  @override
  State<Phbox> createState() => _PhboxState();
}

class _PhboxState extends State<Phbox> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  late Stream<DatabaseEvent> _phValueStream;
  double currentTemperature = 0;
  String currentDate = '';
  String formattedTime = "Loading..";

  @override
  void initState() {
    super.initState();
    _loadCurrentWeather();
    _loadCurrentDate();
    fetchTimestamp();
    // Initializing the stream as a broadcast stream
    _phValueStream = _dbRef
        .child('1706605694/device_data/soil_condition/soil_pH')
        .onValue
        .asBroadcastStream();
  }

  Color getPhColor(double phValue) {
    if (phValue < 7) {
      return Colors.red; // Acidic
    } else if (phValue > 7) {
      return Colors.blue; // Basic
    } else {
      return Colors.green; // Neutral
    }
  }

  void _loadCurrentWeather() async {
    double temp = await getCurrentTemperature();
    setState(() {
      currentTemperature = temp;
    });
  }

  void _loadCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd.MM.yy'); // Format the date as needed
    setState(() {
      currentDate = formatter.format(now);
    });
  }

  void fetchTimestamp() {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("1706605694/device_data/soil_condition");

    ref.child("timestamp").onValue.listen((event) {
      final timestamp = event.snapshot.value;
      if (timestamp != null) {
        setState(() {
          formattedTime = convertTimestampToTime(timestamp);
        });
      }
    });
  }

  String convertTimestampToTime(dynamic timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var formattedDate =
        DateFormat('h:mm a').format(date); // Example format: 10:00 PM
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 450;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return Container(
      color: AppColors.homebg,
      padding: EdgeInsets.all(10 * fem),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 10 * fem),
              width: double.infinity,
              height: 86 * fem,
              decoration: BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.circular(10 * fem),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1c000000),
                    offset: Offset(0 * fem, 0 * fem),
                    blurRadius: 8.5 * fem,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        24 * fem, 24 * fem, 109 * fem, 22 * fem),
                    height: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 5 * fem, 0 * fem),
                          width: 100 * fem,
                          height: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 0 * fem, 5 * fem),
                                width: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0 * fem, 0 * fem, 8 * fem, 0 * fem),
                                      width: 16 * fem,
                                      height: 16 * fem,
                                      child: Image.asset(
                                        'assets/page-1/images/rectangle-4-E6d.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    StreamBuilder(
                                      stream: _phValueStream,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<DatabaseEvent>
                                              snapshot) {
                                        if (snapshot.hasData) {
                                          DataSnapshot dataSnapshot =
                                              snapshot.data!.snapshot;
                                          double phValue = double.tryParse(
                                                  dataSnapshot.value
                                                      .toString()) ??
                                              0.0;
                                          return Text(
                                            'pH: $phValue',
                                            style: SafeGoogleFont(
                                              'Inter',
                                              fontSize: 18 * ffem,
                                              fontWeight: FontWeight.w700,
                                              height: 1.2125 * ffem / fem,
                                              color: Color(0xff000000),
                                            ),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          return Text('Loading..');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Soil pH',
                                style: SafeGoogleFont(
                                  'Inter',
                                  fontSize: 10 * ffem,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2125 * ffem / fem,
                                  color: Color(0xff818182),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 18 * fem),
                          width: 22 * fem,
                          height: 22 * fem,
                          child: StreamBuilder(
                            stream: _phValueStream,
                            builder: (BuildContext context,
                                AsyncSnapshot<DatabaseEvent> snapshot) {
                              if (snapshot.hasData) {
                                DataSnapshot dataSnapshot =
                                    snapshot.data!.snapshot;
                                double phValue = double.tryParse(
                                        dataSnapshot.value.toString()) ??
                                    7.0; // Default to neutral if parsing fails
                                return Icon(
                                  FontAwesomeIcons.exclamationTriangle,
                                  size: 22 * fem,
                                  color: getPhColor(
                                      phValue), // Dynamically set color based on pH value
                                );
                              } else {
                                return Icon(
                                  FontAwesomeIcons.exclamationTriangle,
                                  size: 22 * fem,
                                  color: Colors
                                      .grey, // Default color when loading or error
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        22 * fem, 25 * fem, 22 * fem, 22 * fem),
                    width: 116 * fem,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue, // Replace with your desired start color
                          Colors.green, // Replace with your desired end color
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10 * fem),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 4 * fem),
                          width: double.infinity,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [

                              Text(
                                '$formattedTime', // Display the timestamp here
                                style: SafeGoogleFont(
                                  'Inter',
                                  fontSize: 15 * ffem,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2125 * ffem / fem,
                                  color: Color(0xffffffff),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              0 * fem, 0 * fem, 0 * fem, 0 * fem),
                          child: Text(
                            '$currentDate',
                            style: SafeGoogleFont(
                              'Inter',
                              fontSize: 10 * ffem,
                              fontWeight: FontWeight.w700,
                              height: 1.2125 * ffem / fem,
                              color: Color(0xa0ffffff),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<double> getCurrentTemperature() async {
    // Placeholder for fetching temperature. Replace with actual API call.
    return 38.0; // Example temperature
  }
}
