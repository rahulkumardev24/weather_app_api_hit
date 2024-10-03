// lib/utils/urls.dart
class Urls {
  /// api keys
  static const String apiKey = 'a521729886fc669ae138ed61ba1f335e';
  static String getWeatherUrl(String location) {
    return 'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey&units=metric';
  }

  static String getHourlyUrls(double lat, double lon) {
    return 'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
  }

  static String getHourlyUrlsCity(String city) {
    return 'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';
  }
}