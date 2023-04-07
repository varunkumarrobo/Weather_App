import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';


import '../models/data_model.dart';

const apiKey = 'e031dcd3ad8b42c64dce6e16089389d6';
const openWeatherMapURL = 'https://api.openweathermap.org/data/2.5/weather';

// https://api.openweathermap.org/data/2.5/weather?q=udupi&appid=e031dcd3ad8b42c64dce6e16089389d6&units=metric

class Wearther with ChangeNotifier {
  List<WeatherDeatilsModel> _details = [];

  List<WeatherDeatilsModel> get deatils {
    return [..._details];
  }

  Future<void> getCityWeather(String cityName) async {
    final url =
        Uri.parse("$openWeatherMapURL?q=$cityName&appid=$apiKey&units=metric");
    final response = await http.get(url);
    try {
      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        return;
      }
      final List<WeatherDeatilsModel> loadedProducts = [];
      // log(extractedData.toString());
      loadedProducts.add(WeatherDeatilsModel(
        place: extractedData['name'],
        description: extractedData['weather'][0]['description'],
        dateandTime: DateTime.now().add(
          Duration(
            seconds: extractedData["timezone"] -
                DateTime.now().timeZoneOffset.inSeconds,
          ),
        ),
        humidity: extractedData['main']['humidity'].toString(),
        icon:
            // ignore: prefer_interpolation_to_compose_strings
            "${"http://openweathermap.org/img/w/" + extractedData["weather"][0]["icon"]}.png",
        isCelsius: true,
        pressure: extractedData['main']['pressure'].toString(),
        state: extractedData['sys']['country'],
        suggestion: [],
        temp: extractedData['main']['temp'],
        tempF: 100.0,
        temp_max: extractedData['main']['temp_max'],
        temp_min: extractedData['main']['temp_min'],
      ));
      _details = loadedProducts;
      notifyListeners();
      print(
        json.decode(response.body),
      );
    } catch (e) {
      rethrow;
    }
    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }

  Future<void> getLocationWeather() async {
    Location location = Location();
    await location.getCurrentLocation();
    final url = Uri.parse(
        "$openWeatherMapURL?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey&units=metric");
    final response = await http.get(url);
    try {
      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        return;
      }
      final List<WeatherDeatilsModel> loadedProducts = [];
      // extractedData.forEach((prodId, prodData) {
      log('abcd ${extractedData.toString()}');
      loadedProducts.add(WeatherDeatilsModel(
        place: extractedData['name'],
        description: extractedData['weather'][0]['description'],
        dateandTime: DateTime.now().add(
          Duration(
              seconds: extractedData["timezone"] -
                  DateTime.now().timeZoneOffset.inSeconds),
        ),
        humidity: extractedData['main']['humidity'].toString(),
        icon:
            // ignore: prefer_interpolation_to_compose_strings
            "${"http://openweathermap.org/img/w/" + extractedData["weather"][0]["icon"]}.png",
        isCelsius: true,
        pressure: extractedData['main']['pressure'].toString(),
        state: extractedData['sys']['country'],
        suggestion: [],
        temp: extractedData['main']['temp'],
        tempF: 100.0,
        temp_max: extractedData['main']['temp_max'],
        temp_min: extractedData['main']['temp_min'],
      ));
      _details = loadedProducts;
      notifyListeners();
      print(
        json.decode(response.body),
      );
    } catch (e) {
      rethrow;
    }
    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }

  Future<Response> getSuggestions(search) {
    return http.get(
        Uri.parse(
            "https://api.foursquare.com/v3/autocomplete?query=${search}&types=geo"),
        headers: {
          'Authorization': 'fsq3v9UR8pMBS27YSiEoMbx8W1/t2ZWe8JfNyxCneK0eiVQ=',
          'accept': 'application/json'
        });
  }
}

class FavProvider extends ChangeNotifier {
  IconData icon = Icons.favorite_border_sharp;
  dislike() {
    icon = Icons.favorite_border_sharp;
    notifyListeners();
  }

  like() {
    icon = Icons.favorite;
    notifyListeners();
  }

  update() {
    notifyListeners();
  }
}

class SearchIndexProvider extends ChangeNotifier {
  int index = 0;
  IndexOne() {
    index = 1;
    notifyListeners();
  }

  IndexZero() {
    index = 0;
    notifyListeners();
  }
}

class Location {
  late double latitude;
  late double longitude;

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      log("getcurrentlocation ${e.toString()}");
    }
  }
}



