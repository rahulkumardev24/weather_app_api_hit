import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/weather_model.dart';
import 'urls.dart';

class ApiHelper {
  /// Get whether Data api
  Future<WeatherDataModel?> getWeatherData(String location) async {
    final String url = Urls.getWeatherUrl(location);

    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      WeatherDataModel weatherData = WeatherDataModel.fromJson(jsonData);
      return weatherData;
    }
  }

  Future<List?> getHourlyWeather(
      {double? lat, double? lon, String? city, bool isLatLong = true}) async {
    /// if lat log the send latLong urls if city then send city urls
    String url =
        "https://api.openweathermap.org/data/2.5/forecast?${isLatLong ? "lat=$lat&lon=$lon" : "q=$city"}&appid=${Urls.apiKey}&units=metric";

    /// we can also use this
    /* if(isLatLong){
      url = Urls.getHourlyUrls(lat!, lon!);
    } else {
      url = Urls.getHourlyUrlsCity(city!);
    }*/
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return jsonData['list'];
    }
  }
}
