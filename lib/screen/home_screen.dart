import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_app_api_hit/screen/view_all_details.dart';
import '../api/api_helper.dart';
import '../model/weather_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

TextEditingController locationController = TextEditingController();

class _HomeScreenState extends State<HomeScreen> {
  Future<WeatherDataModel?>? futureWeather;

  /// hourly
  Future<List?>? futureHourlyWeather;
  String _currentLocation = "Location....";
  bool _isSearchVisible = false;
  final ApiHelper _apiHelper = ApiHelper();

  /// weather
  Future<void> _fetchWeather() async {
    if (locationController.text.isNotEmpty) {
      setState(() {
        _currentLocation = locationController.text;
        futureWeather = _apiHelper.getWeatherData(locationController.text);
        futureHourlyWeather = _apiHelper.getHourlyWeather(
            city: locationController.text, isLatLong: false);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _getAreaLocation();
    setState(() {});
  }

  String formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat.jm().format(dateTime); // Format time to AM/PM
  }

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
          SingleChildScrollView(
            child: Center(
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
                            onPressed: () {
                              // Fetch weather data for typed location
                              _fetchWeather(); // Call the fetch weather function
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

                  const SizedBox(
                    height: 10,
                  ),

                  /// Weather data display
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
                            SizedBox(
                              width: mqData!.size.width * 0.95,
                              height: mqData!.size.height * 0.3,
                              child: Card(
                                color: Colors.lightBlueAccent.withOpacity(0.4),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                _currentLocation,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationColor:
                                                        Colors.lightBlueAccent),
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    _getAreaLocation();
                                                  },
                                                  icon: const Icon(
                                                    Icons.location_on_sharp,
                                                    size: 20,
                                                    color: Colors.red,
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(
                                        weatherData.weather?[0].description ??
                                            'N/A',
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),

                                      /// Temperature
                                      Text(
                                        "${weatherData.main?.temp ?? 'N/A'}°C",
                                        style: const TextStyle(
                                            fontSize: 60, color: Colors.white),
                                      ),

                                      /// feel like
                                      Text(
                                        "Feels like: ${weatherData.main?.feelsLike ?? 'N/A'}°C",
                                        style: const TextStyle(
                                            fontSize: 15, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 120,
                            ),

                            /// ...................Three box.........................//
                            SizedBox(
                              width: double.infinity,
                              height: 120,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                          Colors.blue, // Second color (blue)
                                        ],
                                        begin: Alignment
                                            .centerLeft, // Starting point of the gradient
                                        end: Alignment
                                            .topRight, // Ending point of the gradient
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const Icon(
                                            Icons.wind_power,
                                            color: Colors.white,
                                          ),
                                          const Text(
                                            "Wind speed",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            "${weatherData.wind?.speed ?? 'N/A'} m/s",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  /// pressure
                                  Container(
                                    width: mqData!.size.width * 0.3,
                                    height: mqData!.size.height * 0.2,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.yellow, // First color (yellow)
                                          Colors.blue, // Second color (blue)
                                        ],
                                        begin: Alignment
                                            .topCenter, // Starting point of the gradient
                                        end: Alignment
                                            .bottomCenter, // Ending point of the gradient
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const Icon(
                                            Icons.thermostat,
                                            color: Colors.white,
                                          ),
                                          const Text(
                                            "Pressure",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            "${weatherData.main?.pressure ?? 'N/A'} MB",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: mqData!.size.width * 0.3,
                                    height: mqData!.size.height * 0.2,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.yellow, // First color (yellow)
                                          Colors.blue, // Second color (blue)
                                        ],
                                        end: Alignment
                                            .centerLeft, // Starting point of the gradient
                                        begin: Alignment
                                            .topRight, // Ending point of the gradient
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const Icon(
                                            Icons.waves,
                                            color: Colors.white,
                                          ),
                                          const Text(
                                            "Humidity",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            "${weatherData.main?.humidity ?? 'N/A'}%",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            ///.......................Hourly Forecast...................//
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hourly Forecast",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),

                            /// here call  fetchHourlyWeather
                            SizedBox(
                              width: mqData!.size.width * 0.95,
                              child: Card(
                                color: Colors.white,
                                child: FutureBuilder<List?>(
                                  future: futureHourlyWeather,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return const Text(
                                          "Error fetching hourly data");
                                    } else if (snapshot.hasData) {
                                      final hourlyData = snapshot.data!;
                                      return SizedBox(
                                        height: mqData!.size.height * 0.2,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: hourlyData.length,
                                          itemBuilder: (context, index) {
                                            final hourlyItem =
                                                hourlyData[index];
                                            final timestamp = hourlyItem['dt'];
                                            final temp =
                                                hourlyItem['main']['temp'];
                                            final description =
                                                hourlyItem['weather'][0]
                                                    ['description'];
                                            final iconCode =
                                                hourlyItem['weather'][0]
                                                    ['icon'];

                                            // Build the URL for the weather icon
                                            final iconUrl =
                                                'https://openweathermap.org/img/w/$iconCode.png';
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(formatTime(timestamp)),
                                                  Image.network(
                                                    iconUrl,
                                                    height: 70,
                                                    width: 70,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Container(
                                                      width: 70,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: Colors
                                                              .lightBlueAccent),
                                                      child: Text(
                                                        "$temp°C",
                                                        textAlign:
                                                            TextAlign.center,
                                                      )),
                                                  Text(description),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }
                                    return const Text(
                                        "No hourly data available");
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return const Center(child: Text("No data available"));
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  ///......................... VIEW MORE BUTTON ...........................//
                  FutureBuilder<WeatherDataModel?>(
                    future:
                        futureWeather, // Assuming this is where you're fetching weather data
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final weatherData = snapshot.data!;

                        return SizedBox(
                          width: mqData!.size.width * 0.9,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                backgroundColor: Colors.deepOrangeAccent,
                                foregroundColor: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewAllDetails(
                                    currentLocation: _currentLocation,
                                    description: weatherData.weather?[0]
                                        .description, // Pass description
                                    feelsLike: weatherData.main?.feelsLike
                                        ?.toString(), // Pass feels like temperature
                                    temp: weatherData.main?.temp?.toString(),
                                    wind: weatherData.wind?.speed.toString(),
                                    pressure:
                                        weatherData.main?.pressure.toString(),
                                    humidity:
                                        weatherData.main?.humidity.toString(),
                                    maxTum:
                                        weatherData.main?.tempMax.toString(),
                                    minTum:
                                        weatherData.main?.tempMin.toString(),
                                  ),
                                ),
                              );
                            },
                            child: const Text("View All Details"),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fetch location and weather data
  Future<void> _getAreaLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      String location = place.locality ?? "Unknown";

      setState(() {
        _currentLocation = location;
        locationController.text = '';
        futureWeather = _apiHelper.getWeatherData(location);
        futureHourlyWeather = _apiHelper.getHourlyWeather(
            lat: position.latitude, lon: position.longitude);
      });
    }
  }

  void _checkPermissions() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
  }
}
