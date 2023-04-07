class DataModel {
  String place;
  String region;

  DataModel({
    required this.place,
    required this.region,
  });

  DataModel fromJson(json) {
    return DataModel(place: json['place'], region: json['region']);
  }

  Map<String, dynamic> toJson() {
    return {'place': place, 'region': region};
  }
}

class WeatherDeatilsModel {
  final String place;
  final String state;
  final String description;
  final double temp_min;
  final double temp_max;
  final String humidity;
  final String icon;
  final double temp;
  final double tempF;
  final bool isCelsius;
  final String pressure;
  final List<String> suggestion;
  final DateTime dateandTime;

  WeatherDeatilsModel({
    required this.place,
    required this.state,
    required this.icon,
    required this.description,
    required this.temp_min,
    required this.temp_max,
    required this.humidity,
    required this.temp,
    required this.tempF,
    required this.isCelsius,
    required this.pressure,
    required this.dateandTime,
    required this.suggestion,
  });
}
