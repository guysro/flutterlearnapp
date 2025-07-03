import 'dart:convert';

class WeatherStatModel {
  DateTime time;
  num temp;
  num feelsLike;
  String skyState;
  num uvIdx;
  num windSpeed;
  String iconString;

  WeatherStatModel({
    required this.temp,
    required this.feelsLike,
    required this.skyState,
    required this.time,
    required this.uvIdx,
    required this.windSpeed,
    required this.iconString,
  });

  factory WeatherStatModel.currentFromJSON(String jsonStr) {
    Map<String, dynamic> data = jsonDecode(jsonStr);

    Map<String, dynamic> currentData = data['current'];
    return WeatherStatModel(
      temp: currentData['temp'],
      feelsLike: currentData['feels_like'],
      skyState: currentData['weather'][0]['main'],
      time: currentData['dt'],
      uvIdx: currentData['uvi'],
      windSpeed: currentData['wind_speed'],
      iconString: "01d",
    );
  }

  factory WeatherStatModel.empty() {
    return WeatherStatModel(
      temp: 0,
      feelsLike: 0,
      skyState: "Sunny",
      time: DateTime.now(),
      uvIdx: 0,
      windSpeed: 0,
      iconString: "01d",
    );
  }

  factory WeatherStatModel.fromJSON(Map<String, dynamic> data) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      (data['dt']) * 1000,
      isUtc: false, // Assuming the dt timestamp is UTC,
    );

    return WeatherStatModel(
      temp: data['temp'],
      feelsLike: data['feels_like'],
      skyState: data['weather'][0]['main'],
      iconString: data['weather'][0]['icon'],
      time: dateTime,
      uvIdx: data['uvi'],
      windSpeed: data['wind_speed'],
    );
  }

  @override
  String toString() {
    return 'WeatherStatModel(\n'
        '  temp: $temp°C,\n'
        '  feelsLike: $feelsLike°C,\n'
        '  skyState: $skyState,\n'
        '  time: $time,\n'
        '  uvIdx: $uvIdx,\n'
        '  windSpeed: $windSpeed m/s\n'
        ')';
  }
}
