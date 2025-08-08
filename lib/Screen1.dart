import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:climaa/Screen2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Screen1 extends StatefulWidget {
  Screen1({super.key, required this.weatherdata});
  final Map<String, dynamic> weatherdata;

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
  var cityName = "Unknown";
  var currentWeather = "Unknown";
  var tempIncel = "0";
  var emoji = "🌤️";

  @override
  void initState() {
    super.initState();
    if (widget.weatherdata.isNotEmpty) {
      print('City: ${widget.weatherdata['name']}');
      updateUI(widget.weatherdata);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/screen1.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        print('Navigation button pressed');
                        print('Weather main: ${widget.weatherdata['weather'][0]['main']}');
                        updateUI(widget.weatherdata);
                      },
                      icon: Icon(
                        Icons.navigation,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        var cityName = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Screen2()),
                        );
                        print('Returned city name: $cityName');

                        // Fixed the null check
                        if (cityName != null && cityName.toString().isNotEmpty) {
                          await getWeatherDatafromCityName(cityName.toString());
                        }
                      },
                      icon: Icon(
                        Icons.location_on,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    Text(
                      cityName,
                      style: TextStyle(
                        fontSize: 33,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emoji, style: TextStyle(fontSize: 60)),
                        SizedBox(width: 10),
                        Text(
                          tempIncel,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 33,
                          ),
                        ),
                        Text(
                          "°",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 33,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          currentWeather,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String KelvintoCel(var temp) {
    var tempIncel = temp - 273.15;
    String tempinstring = tempIncel.floor().toString();
    return tempinstring;
  }

  // Fixed: Added Future<void> and proper error handling
  Future<void> getWeatherDatafromCityName(String cityName) async {
    try {
      var url = Uri.https(
        'api.openweathermap.org',
        '/data/2.5/weather',
        {'q': cityName, 'appid': apiKey},
      );

      print('Requesting weather for city: $url');

      var response = await http.get(url).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        var data = response.body;
        var weatherdata = jsonDecode(data);
        updateUI(weatherdata);
      } else {
        print('Error fetching city weather: ${response.statusCode}');
        // You could show a snackbar or dialog here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('City not found or API error')),
        );
      }
    } catch (e) {
      print('Error in getWeatherDatafromCityName: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching weather: $e')),
      );
    }
  }

  void updateUI(weatherdata) {
    if (weatherdata == null || weatherdata['weather'] == null) {
      print('Weather data is null or incomplete');
      return;
    }

    try {
      var weatherid = weatherdata['weather'][0]['id'];
      String newEmoji = "🌤️"; // default

      if (weatherid >= 200 && weatherid < 300) {
        newEmoji = "🌩️";
      } else if (weatherid >= 300 && weatherid < 400) {
        newEmoji = "⛈️";
      } else if (weatherid >= 500 && weatherid < 600) {
        newEmoji = "🌧️";
      } else if (weatherid >= 600 && weatherid < 700) {
        newEmoji = "❄️";
      } else if (weatherid >= 700 && weatherid < 800) {
        newEmoji = "🌨️";
      }

      setState(() {
        emoji = newEmoji;
        var temp = weatherdata['main']['temp'];
        tempIncel = KelvintoCel(temp);
        cityName = weatherdata['name'] ?? "Unknown";
        currentWeather = weatherdata['weather'][0]['main'] ?? "Unknown";
      });

      print('UI updated - City: $cityName, Temp: $tempIncel°, Weather: $currentWeather');
    } catch (e) {
      print('Error updating UI: $e');
    }
  }
}