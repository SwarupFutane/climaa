import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'Screen1.dart';
import 'location.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String errorMessage = '';
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      getlocation();
    }
  }

  void getlocation() async {
    try {
      Location location = Location();
      bool locationObtained = await location.getCurrentlocation();

      if (!locationObtained) {
        setState(() {
          hasError = true;
          errorMessage = 'Failed to get location. Please enable location services and grant permission.';
        });
        return;
      }

      double lat = location.latitude;
      double lon = location.longitude;

      var apikey = dotenv.env['OPENWEATHER_API_KEY'];

      if (apikey == null || apikey.isEmpty) {
        setState(() {
          hasError = true;
          errorMessage = 'API key not found. Please check your .env file.';
        });
        return;
      }

      var url = Uri.https(
        'api.openweathermap.org',
        '/data/2.5/weather',
        {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'appid': apikey,
        },
      );

      print('Requesting weather data from: $url');

      var response = await http.get(url).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Weather data received: $data');

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Screen1(weatherdata: data),
            ),
          );
        }
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Failed to fetch weather data. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error in getlocation: $e');
      setState(() {
        hasError = true;
        errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: hasError
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  hasError = false;
                  errorMessage = '';
                });
                getlocation();
              },
              child: Text('Retry'),
            ),
          ],
        )
            : SpinKitDoubleBounce(
          color: Colors.grey,
          size: 50.0,
        ),
      ),
    );
  }
}