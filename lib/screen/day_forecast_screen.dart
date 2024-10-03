/// 5 day forcast

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DayForecastScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<DayForecastScreen> {
  Map<String, dynamic>? currentWeather;
  List<dynamic> forecast = [];
  String cityName = "London";

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    String apiKey = 'a521729886fc669ae138ed61ba1f335e';
    String city = 'London'; // Change city if needed
    final currentWeatherUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final forecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';

    try {
      final currentResponse = await http.get(Uri.parse(currentWeatherUrl));
      final forecastResponse = await http.get(Uri.parse(forecastUrl));

      if (currentResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        setState(() {
          currentWeather = json.decode(currentResponse.body);
          forecast = json.decode(forecastResponse.body)['list'];
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather for $cityName'),
      ),
      body: currentWeather == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Current Weather Display
          CurrentWeather(currentWeather: currentWeather!),

          SizedBox(height: 20),

          // 7-day forecast display
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: forecast.length,
              itemBuilder: (context, index) {
                final dayData = forecast[index];
                final dateTime = DateTime.parse(dayData['dt_txt']);
                final dayTemp = dayData['main']['temp'];
                final weatherIconCode = dayData['weather'][0]['icon'];

                // Format the date
                final formattedDate = DateFormat('EEE d MMM').format(dateTime);

                // Show only every 8th item to get daily forecast
                if (index % 8 == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(
                          formattedDate, // Date format like "Mon 2 Oct"
                          style: TextStyle(fontSize: 16),
                        ),
                        Image.network(
                          'https://openweathermap.org/img/wn/$weatherIconCode@2x.png',
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${dayTemp.toStringAsFixed(1)}°C',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(); // Skip non-daily entries
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for displaying current weather
class CurrentWeather extends StatelessWidget {
  const CurrentWeather({ required this.currentWeather}) : super();

  final Map<String, dynamic> currentWeather;

  @override
  Widget build(BuildContext context) {
    final temp = currentWeather['main']['temp'];
    final weatherDescription = currentWeather['weather'][0]['description'];
    final weatherIconCode = currentWeather['weather'][0]['icon'];
    final windSpeed = currentWeather['wind']['speed'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${temp.toStringAsFixed(1)}°C and rising',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          Image.network(
            'https://openweathermap.org/img/wn/$weatherIconCode@2x.png',
            width: 100,
            height: 100,
          ),
          Text(
            weatherDescription,
            style: TextStyle(fontSize: 20),
          ),
          Text('Wind: ${windSpeed.toStringAsFixed(1)} m/s Gentle Breeze'),
        ],
      ),
    );
  }
}
