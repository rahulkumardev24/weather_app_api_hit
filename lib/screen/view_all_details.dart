import 'package:flutter/material.dart';

class ViewAllDetails extends StatefulWidget {
  final String? currentLocation;
  final String? description;
  final String? feelsLike;
  final String? temp;
  final String? wind;
  final String? pressure;
  final String? humidity;
  final String? minTum;
  final String? maxTum;

  const ViewAllDetails({
    Key? key,
    this.currentLocation,
    this.description,
    this.feelsLike,
    this.temp,
    this.wind,
    this.pressure ,
    this.humidity ,
    this.maxTum ,
    this.minTum
  }) : super(key: key);

  @override
  State<ViewAllDetails> createState() => _ViewAllDetailsState();
}

class _ViewAllDetailsState extends State<ViewAllDetails> {
  MediaQueryData? mqData;

  // Define the list of weather data (icons, titles, and corresponding data)
  List<Map<String, dynamic>> weatherData = [];

  @override
  void initState() {
    super.initState();
    weatherData = [
      {
        "icon": Icons.thermostat,
        "title": "Temperature",
        "value": "${widget.temp} °C",
      },
      {
        "icon": Icons.air,
        "title": "Feels Like",
        "value": "${widget.feelsLike} °C",
      },
      {
        "icon": Icons.wind_power,
        "title": "Wind Speed",
        "value": "${widget.wind} m/s",
      },
      {
        "icon": Icons.cloud,
        "title": "Description",
        "value": widget.description ?? 'N/A',
      },
      {
        "icon" : Icons.thermostat ,
        "title" : "Pressure" ,
        "value" : "${widget.pressure} MB" ,
      }
      ,
      {
        "icon" : Icons.waves_sharp ,
        "title" : "Humidity" ,
        "value" : "${widget.humidity} %" ,
      }
      ,
      {
        "icon" : Icons.thermostat  ,
        "title" : "Min Temperature" ,
        "value" : "${widget.minTum} °C" ,
      }
      ,
      {
        "icon" : Icons.thermostat ,
        "title" : "Max Temperature" ,
        "value" : "${widget.maxTum} °C" ,
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    mqData = MediaQuery.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Image.asset(
            "assets/images/background2.jpg",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // Main content
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
              ///................................CARD........................//
                SizedBox(
                  width: mqData!.size.width * 0.95,
                  height: mqData!.size.height * 0.3,
                  child: Card(
                    color: Colors.lightBlueAccent.withOpacity(0.4),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Location and location icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.currentLocation ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.lightBlueAccent,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // Add functionality for location here
                                    },
                                    icon: const Icon(
                                      Icons.location_on_sharp,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Weather description
                          Text(
                            widget.description ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),

                          // Temperature
                          Text(
                            "${widget.temp ?? 'N/A'}°C",
                            style: const TextStyle(
                              fontSize: 60,
                              color: Colors.white,
                            ),
                          ),

                          // Feels like temperature
                          Text(
                            "Feels like: ${widget.feelsLike ?? 'N/A'}°C",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),


                const SizedBox(height: 20),

              ///.........................LIST....................//
                Expanded(
                  child: ListView.builder(
                    itemCount: weatherData.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: SizedBox(
                          width: mqData!.size.width * 0.9,
                          height: mqData!.size.height * 0.1,
                          child: Card(
                            color: Colors.black45,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(weatherData[index]['icon'], size: 20, color: Colors.white),
                                Text(weatherData[index]['title'], style: const TextStyle(fontSize: 20, color: Colors.white)),
                                Text(weatherData[index]['value'], style: const TextStyle(fontSize: 20, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
