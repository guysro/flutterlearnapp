import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutterllearnapp/models/weather_stat_model.dart';

class CityModel {
  String name;
  double lat;
  double lng;
  late WeatherStatModel currentWeather;
  late List<WeatherStatModel> hourlyWeather;

  CityModel({
    required this.name,
    required this.lat,
    required this.lng,
    required this.currentWeather,
    required this.hourlyWeather
  });

  factory CityModel.defaultCity(){
    return CityModel(
      name: "", 
      lat: 51.5073219, 
      lng: -0.1276474, 
      currentWeather: WeatherStatModel.empty(),
      hourlyWeather: List.empty()
    );
  }

  void fetchWeatherData(double lat, double lng) async {
    http.Response res = await http.get(Uri.parse("https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lng&appid=3c1337f474bf021bc368451dfd604fca&units=metric"));

    Map<String, dynamic> dataJson = jsonDecode(res.body);

    Map<String, dynamic> currentData = dataJson['current'];
    currentWeather = WeatherStatModel.fromJSON(currentData);

    List<dynamic> hourlyWeatherData = dataJson['hourly'];
    hourlyWeatherData = hourlyWeatherData
      .map((hourlyMap) => WeatherStatModel.fromJSON(hourlyMap as Map<String, dynamic>))
      .toList();
  }

  String currentWeatherTime() {
    String dateTime = currentWeather.time.toString();
    String timeWithSec = dateTime.split(' ')[1];
    List<String> hmsList = timeWithSec.split(':');
    return "${hmsList[0]}:${hmsList[1]}";
  }
}