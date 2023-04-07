import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../models/data_model.dart';
import '../providers/location_provider.dart';
import '../services/database_service.dart';
import '../widgets/drawer.dart';
import 'search_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key, this.locationWeather});

  final dynamic locationWeather;

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String cityName = '';

  @override
  void initState() {
    super.initState();
    // getLocationData();
    // updateUI(widget.locationWeather);
  }

  // Future<void> getLocationData() async {
  //   var weatherData = await Provider.of<Wearther>(context, listen: false)
  //       .getLocationWeather();
  // }

  var _isInit = true;
  final DatabaseManager _databaseManager = DatabaseManager();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        weatherData();
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> weatherData() async {
    final currentLocationDetails =
        await Provider.of<Wearther>(context, listen: false)
            .getLocationWeather()
            .then((value) {
      Provider.of<Wearther>(context, listen: false).getCityWeather(cityName);
    }).then((value) {
      Provider.of<Wearther>(context, listen: false).getLocationWeather();
    });
  }

  bool isFav = false;

  @override
  Widget build(BuildContext context) {
    final weatherdataprovider = Provider.of<Wearther>(
      context,
    );
    final cityWeatherProvider = Provider.of<Wearther>(context, listen: false);
    return Scaffold(
      key: _key,
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () async {
                var typedName = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const CityScreen();
                    },
                  ),
                );
                if (typedName != null) {
                  var weatherData =
                      await cityWeatherProvider.getCityWeather(typedName);
                  _databaseManager
                      .insertRecent(DataModel(
                    place: weatherdataprovider.deatils[0].place,
                    region: weatherdataprovider.deatils[0].state,
                  ))
                      .whenComplete(() {
                    log('sucess search insertion');
                  }).onError((error, stackTrace) {
                    if (typedName != '') {
                      cityWeatherProvider;
                    }
                  });
                }
              },
              child: const Icon(
                Icons.search,
                size: 35.0,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              weatherData();
            },
            icon: const Icon(
              Icons.home,
            ),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView.builder(
          itemCount: weatherdataprovider.deatils.length,
          itemBuilder: (_, index) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${weatherdataprovider.deatils[index].temp}°',
                // style: kTempTextStyle,
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                'FeelsLike > ${weatherdataprovider.deatils[index].pressure}',
                // style: kTempTextStyle,
              ),
              Consumer<FavProvider>(builder: (ctx, weatheValue, Widget? child) {
                return GestureDetector(
                  onTap: () {
                    if (weatheValue.icon == Icons.favorite_border_sharp) {
                      _databaseManager
                          .insertFav(
                        DataModel(
                          place: weatherdataprovider.deatils[index].place,
                          region: weatherdataprovider.deatils[index].state,
                        ),
                      )
                          .whenComplete(() {
                        log('success');
                      }).onError((error, stackTrace) {
                        log(error.toString());
                      });
                      isFav = true;
                      weatheValue.like();
                    } else {
                      _databaseManager
                          .deleteFav(DataModel(
                        place: weatherdataprovider.deatils[index].place,
                        region: weatherdataprovider.deatils[index].state,
                      ))
                          .whenComplete(() {
                        log('delete success');
                      }).onError((error, stackTrace) {
                        log(error.toString());
                      });
                      isFav = false;
                      weatheValue.dislike();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        weatheValue.icon,
                        color: isFav ? Colors.yellow : Colors.white,
                      ),
                      Text(
                        isFav ? "Remove from favourite" : "Add to favourite",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              Text(
                weatherdataprovider.deatils[index].temp_min.toStringAsFixed(2),
              ),
              Text(
                weatherdataprovider.deatils[index].dateandTime
                    .toIso8601String(),
              ),
              Text(
                weatherdataprovider.deatils[index].humidity,
              ),
              Image.network(
                weatherdataprovider.deatils[index].icon,
              ),
              Text(
                '${weatherdataprovider.deatils[index].description} in ${weatherdataprovider.deatils[index].place}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// void updateUI(dynamic weatherData) {
  //   setState(() {
  //     if (weatherData == null) {
  //       feelsLike = 0;
  //       temperature = 0;
  //       weatherIcon = 'Error';
  //       weatherMessage = 'Unable to get weather data';
  //       cityName = '';
  //       return;
  //     }
  //     double temp = weatherData['main']['temp'];
  //     double feels = weatherData['main']['feels_like'];
  //     temperature = temp.toInt();
  //     feelsLike = feels.toInt();
  //     var condition = weatherData['weather'][0]['id'];
  //     weatherIcon = weather.getWeatherIcon(condition);
  //     weatherMessage = weather.getMessage(temperature);
  //     cityName = weatherData['name'];
  //   });
  // }