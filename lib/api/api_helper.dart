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
        print('API Response: ${response.body}');

        WeatherDataModel weatherData = WeatherDataModel.fromJson(jsonData);
        return weatherData;
      } else {
        print(
            'Failed to load weather data. Status code: ${response.statusCode}');
        return null;
    }
  }

  Future<List?> getHourlyWeather(double lat, double lon) async {
    final String url = Urls.getHourlyUrls(lat, lon);

      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('API Response: ${response.body}');

        // Extracting hourly forecast data
        return jsonData['list'];
      } else {
        print('Failed to load hourly weather data. Status code: ${response.statusCode}');
        return null;
      }

    }


}
