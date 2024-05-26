import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../provider/location_provider.dart';

class WeatherData {
  final double lon;
  final double lat;
  final List<Weather> weather;
  final String base;
  final Main main;
  final int visibility;
  final Wind wind;
  final Clouds clouds;
  final int dt;
  final Sys sys;
  final int timezone;
  final int id;
  final String name;
  final int cod;

  WeatherData({
    required this.lon,
    required this.lat,
    required this.weather,
    required this.base,
    required this.main,
    required this.visibility,
    required this.wind,
    required this.clouds,
    required this.dt,
    required this.sys,
    required this.timezone,
    required this.id,
    required this.name,
    required this.cod,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      lon: json['coord']['lon'].toDouble(),
      lat: json['coord']['lat'].toDouble(),
      weather: (json['weather'] as List)
          .map((item) => Weather.fromJson(item))
          .toList(),
      base: json['base'],
      main: Main.fromJson(json['main']),
      visibility: json['visibility'],
      wind: Wind.fromJson(json['wind']),
      clouds: Clouds.fromJson(json['clouds']),
      dt: json['dt'],
      sys: Sys.fromJson(json['sys']),
      timezone: json['timezone'],
      id: json['id'],
      name: json['name'],
      cod: json['cod'],
    );
  }
}


class Weather {
  final int id;
  final String main;
  final String description;
  final String icon;

  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      id: json['id'],
      main: json['main'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class Main {
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final int seaLevel;
  final int grndLevel;

  Main({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.seaLevel,
    required this.grndLevel,
  });

  factory Main.fromJson(Map<String, dynamic> json) {
    return Main(
      temp: json['temp'].toDouble(),
      feelsLike: json['feels_like'].toDouble(),
      tempMin: json['temp_min'].toDouble(),
      tempMax: json['temp_max'].toDouble(),
      pressure: json['pressure'],
      humidity: json['humidity'],
      seaLevel: json['sea_level'],
      grndLevel: json['grnd_level'],
    );
  }
}

class Wind {
  final double speed;
  final int deg;
  final double gust;

  Wind({
    required this.speed,
    required this.deg,
    required this.gust,
  });

  factory Wind.fromJson(Map<String, dynamic> json) {
    return Wind(
      speed: json['speed'].toDouble(),
      deg: json['deg'],
      gust: json['gust'].toDouble(),
    );
  }
}

class Rain {
  final double hour;

  Rain({required this.hour});

  factory Rain.fromJson(Map<String, dynamic> json) {
    return Rain(hour: json['1h'].toDouble());
  }
}

class Clouds {
  final int all;

  Clouds({required this.all});

  factory Clouds.fromJson(Map<String, dynamic> json) {
    return Clouds(all: json['all']);
  }
}

class Sys {
  final String country;
  final int sunrise;
  final int sunset;

  Sys({
    required this.country,
    required this.sunrise,
    required this.sunset,
  });

  factory Sys.fromJson(Map<String, dynamic> json) {
    return Sys(
      country: json['country'],
      sunrise: json['sunrise'],
      sunset: json['sunset'],
    );
  }
}


Future<Map<String, dynamic>> fetchWeatherData(BuildContext context) async {
  try {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final double lat = locationProvider.location.latitude;
    final double lon = locationProvider.location.longitude;
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey';

    print('Fetching weather data from: $url');

    final response = await HttpClient().getUrl(Uri.parse(url));
    final httpResponse = await response.close();
    final responseBody = await httpResponse.transform(utf8.decoder).join();

    print('Response body: $responseBody');

    // Check if the response body is not null or empty
    if (responseBody != null && responseBody.isNotEmpty) {
      final dynamic jsonResponse = json.decode(responseBody);

      print('JSON response: $jsonResponse'); // Log the JSON response

      // Check if the JSON response contains data and is of type Map<String, dynamic>
      if (jsonResponse != null && jsonResponse is Map<String, dynamic>) {
        final weatherData = WeatherData.fromJson(jsonResponse);
        print(weatherData); // Print the entire WeatherData object

        // Determine if it's raining and save the result in a new variable
        String raining = isRaining(jsonResponse);

        // Create a new map containing both the weather data and the isRaining result
        Map<String, dynamic> result = {
          'weatherData': weatherData,
          'isRaining': raining,
        };

        return result;
      } else {
        throw Exception('Invalid JSON response: $jsonResponse');
      }
    } else {
      throw Exception('Empty or null response body');
    }
  } catch (e, stackTrace) {
    print('Error fetching weather data: $e\n$stackTrace');
    throw Exception('Failed to fetch weather data');
  }
}


String isRaining(Map<String, dynamic> weatherData) {
  List<dynamic> weatherConditions = weatherData['weather'];

  for (var condition in weatherConditions) {
    String id = condition['id'];

    if (id.toString() == '200' || id.toString() == '201' || id.toString() == '202' || id.toString() == '210' || id.toString() == '211' || id.toString() == '212' || id.toString() == '221' || id.toString() == '230' || id.toString() == '231' || id.toString() == '232'){
      return "Thunderstorm";
    }
    if (id.toString() == '301' || id.toString() == '302' || id.toString() == '310' || id.toString() == '311' || id.toString() == '312' || id.toString() == '321' || id.toString() == '313' || id.toString() == '314' || id.toString() == '300'){
      return "Drizzle";
    }
    if (id.toString() == '501' || id.toString() == '502' || id.toString() == '503' || id.toString() == '504' || id.toString() == '511' || id.toString() == '520' || id.toString() == '521' || id.toString() == '522' || id.toString() == '500' || id.toString() == '531'){
      return "Rain";
    }
    if (id.toString() == '801' || id.toString() == '802' || id.toString() == '803' || id.toString() == '804' || id.toString() == '800'){
      return "Clear";
    }
  }

  return "Snow";
}
