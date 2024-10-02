import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../model/weather_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

TextEditingController locationController = TextEditingController();

class _HomeScreenState extends State<HomeScreen> {
  Future<WeatherDataModel?>? futureWeather;
  String _currentLocation = "Location....";
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  MediaQueryData? mqData;
  Widget build(BuildContext context) {
    mqData = MediaQuery.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content overlay
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      "assets/icons/cast.png",
                      width: 30,
                      height: 30,
                      color: Colors.white,
                    ),
                    const Text(
                      "Whether",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                    // Search icon
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        size: 30,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSearchVisible =
                              !_isSearchVisible; // Toggle visibility
                        });
                      },
                    ),
                  ],
                ),

                /// Show search box if _isSearchVisible is true
                if (_isSearchVisible)
                  SizedBox(
                    width: mqData!.size.width * 0.9,
                    child: TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.deepOrange, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.deepOrange, width: 2),
                        ),
                        hintText: "Search location",
                        hintStyle: const TextStyle(color: Colors.white),
                        suffixIcon: IconButton(
                          onPressed: () async {
                            if (locationController.text.isEmpty) {
                              // If text field is empty, do nothing or show a message
                              // You can also keep this to get the current location if desired.
                            } else {
                              // Fetch weather data for typed location
                              setState(() {
                                _currentLocation = locationController
                                    .text; // Update current location
                                futureWeather = getWeatherData(
                                    locationController.text.toString());
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentLocation,
                      style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.lightBlueAccent),
                    ),
                    IconButton(
                        onPressed: () {
                          _getAreaLocation();
                        },
                        icon: const Icon(
                          Icons.location_on_sharp,
                          size: 25,
                          color: Colors.red,
                        )),
                  ],
                ),

                const SizedBox(
                  height: 40,
                ),

                // Weather data display
                FutureBuilder<WeatherDataModel?>(
                  future: futureWeather,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text("Error fetching data");
                    } else if (snapshot.hasData) {
                      final weatherData = snapshot.data!;
                      return Column(
                        children: [
                          /// weather
                          Text(
                            weatherData.weather?[0].description ?? 'N/A',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                          /// Temperature
                          Text(
                            "${weatherData.main?.temp ?? 'N/A'}°C",
                            style: const TextStyle(
                                fontSize: 60, color: Colors.white),
                          ),
                          /// fill like 
                          Text(
                            "Feels like: ${weatherData.main?.feelsLike ?? 'N/A'}°C",
                            style: const TextStyle(
                                fontSize: 15, color: Colors.white),
                          ),
                          
                          /// ...................Three box.........................//
                          SizedBox(
                            width: double.infinity,
                            height: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                               children: [
                                 /// wind speed
                                 Container(
                                   width: mqData!.size.width * 0.3,
                                   height: mqData!.size.height * 0.2,
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(20),
                                     gradient: const LinearGradient(
                                       colors: [
                                         Colors.yellow, // First color (yellow)
                                         Colors.blue,   // Second color (blue)
                                       ],
                                       begin: Alignment.topCenter, // Starting point of the gradient
                                       end: Alignment.bottomCenter, // Ending point of the gradient
                                     ),
                                   ),
                                   child: Padding(
                                     padding: const EdgeInsets.all(8.0),
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                       children: [
                                         const Icon(Icons.wind_power , color: Colors.white,),
                                         const Text("Wind speed" , style: TextStyle(color: Colors.white),),
                                         Text(
                                           "${weatherData.wind?.speed ?? 'N/A'} m/s", style: const TextStyle(color: Colors.white),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ) ,
                                 /// pressure
                                 Container(
                                   width: mqData!.size.width * 0.3,
                                   height: mqData!.size.height * 0.2,
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(20),
                                     gradient: const LinearGradient(
                                       colors: [
                                         Colors.yellow, // First color (yellow)
                                         Colors.blue,   // Second color (blue)
                                       ],
                                       begin: Alignment.topCenter, // Starting point of the gradient
                                       end: Alignment.bottomCenter, // Ending point of the gradient
                                     ),
                                   ),
                                   child: Padding(
                                     padding: const EdgeInsets.all(8.0),
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                       children: [
                                         const Icon(Icons.thermostat , color: Colors.white,),
                                         const Text("Pressure" , style: TextStyle(color: Colors.white),),
                                         Text(
                                           "${weatherData.main?.pressure ?? 'N/A'} MB", style: TextStyle(color: Colors.white),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ) ,
                                 Container(
                                   width: mqData!.size.width * 0.3,
                                   height: mqData!.size.height * 0.2,
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(20),
                                     gradient: const LinearGradient(
                                       colors: [
                                         Colors.yellow, // First color (yellow)
                                         Colors.blue,   // Second color (blue)
                                       ],
                                       begin: Alignment.topCenter, // Starting point of the gradient
                                       end: Alignment.bottomCenter, // Ending point of the gradient
                                     ),
                                   ),
                                   child: Padding(
                                     padding: const EdgeInsets.all(8.0),
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                       children: [
                                         const Icon(Icons.water_drop_outlined , color: Colors.white,),
                                         const Text("Humidity" , style: TextStyle(color: Colors.white),),
                                         Text(
                                           "${weatherData.main?.humidity ?? 'N/A'} %", style: const TextStyle(color: Colors.white),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ) ,

                               ],
                            ),
                          ) ,
 
                          Text(
                              "Location: ${weatherData.name}, ${weatherData.sys?.country ?? ''}"),


                          Text("Clouds: ${weatherData.clouds?.all ?? 'N/A'}%"),
                          Text(
                              "Visibility: ${weatherData.visibility ?? 'N/A'} m"),
                        ],
                      );
                    } else {
                      return const Text("No data available");
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<WeatherDataModel?> getWeatherData(String location) async {
    String apiKey = 'a521729886fc669ae138ed61ba1f335e';
    String url =
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey&units=metric';

    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      print('API Response: ${response.body}');

      WeatherDataModel weatherData = WeatherDataModel.fromJson(jsonData);
      return weatherData;
    } else {
      print('Failed to load weather data');
      return null;
    }
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await _getAreaLocation();
    } else {
      setState(() {
        _currentLocation = "Location permission is denied.";
      });
    }
  }

  Future<void> _getAreaLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Position: Lat ${position.latitude}, Long ${position.longitude}');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String location =
            "${place.locality}"; // Get the locality or any other detail you want
        print('Location: $location');

        setState(() {
          _currentLocation = location; // Update the current location to display
          locationController.text = ''; // Clear the input field
          futureWeather = getWeatherData(
              location); // Fetch weather data for the current location
        });
      } else {
        print('No placemarks found.');
      }
    } catch (e) {
      print('Failed to get location: $e');
      setState(() {
        _currentLocation = "Failed to get location: ${e.toString()}";
      });
    }
  }
}
