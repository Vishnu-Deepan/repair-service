import 'package:flutter/material.dart';

import '../models/weather_model.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherData? _weatherData;
  late String _isRaining;

  WeatherData? get weatherData => _weatherData;
  String get isRaining => _isRaining;

  void updateWeather(BuildContext context) async {
    try {
      Map<String, dynamic> weatherResult = await fetchWeatherData(context);
      _weatherData = weatherResult['weatherData'];
      _isRaining = weatherResult['isRaining'];
      notifyListeners();
    } catch (e) {
      print('Error updating weather: $e');
    }
  }
}
