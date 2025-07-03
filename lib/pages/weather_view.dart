import 'dart:convert';

import 'package:flutterllearnapp/models/daily_model.dart';
import 'package:flutterllearnapp/models/weather_stat_model.dart';
import 'package:flutterllearnapp/widgets/daily_list.dart';
import 'package:flutterllearnapp/widgets/data_box.dart';
import 'package:flutterllearnapp/widgets/hourly_list.dart';
import 'package:flutterllearnapp/widgets/loading_circle.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterllearnapp/models/city_model.dart';

class WeatherViewPage extends StatefulWidget {
  final double lat;
  final double lng;

  const WeatherViewPage({super.key, required this.lat, required this.lng});

  @override
  State<WeatherViewPage> createState() => _WeatherViewPageState();
}

class _WeatherViewPageState extends State<WeatherViewPage> {
  bool loading = true;
  bool defaultView = true;
  CityModel currentCity = CityModel.defaultCity();

  final List<String> days = List.of([
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ]);

  String limitStringToWords(String text, int wordLimit) {
    if (wordLimit <= 0) {
      return '';
    }
    List<String> words = text
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (words.length <= wordLimit) {
      return text.trim();
    }
    List<String> limitedWords = words.sublist(0, wordLimit);
    return limitedWords.join(' ');
  }

  void _getCurrentCity() async {
    setState(() {
      loading = true;
    });

    http.Response res = await http.get(
      Uri.parse(
        "https://api.openweathermap.org/data/3.0/onecall?lat=${widget.lat}&lon=${widget.lng}&appid=3c1337f474bf021bc368451dfd604fca&units=metric&exclude=minutely,alerts",
      ),
    );

    Map<String, dynamic> dataJson = jsonDecode(res.body);

    Map<String, dynamic> currentData = dataJson['current'];
    WeatherStatModel currentWeather = WeatherStatModel.fromJSON(currentData);

    List<dynamic> hourlyWeatherData = dataJson['hourly'];
    List<WeatherStatModel> hourlyWeather = hourlyWeatherData
        .map(
          (hourlyMap) =>
              WeatherStatModel.fromJSON(hourlyMap as Map<String, dynamic>),
        )
        .toList();

    List<dynamic> dailyWeatherData = dataJson['daily'];
    List<DailyModel> dailyWeather = dailyWeatherData
        .map((dayMap) => DailyModel.fromJSON(dayMap as Map<String, dynamic>))
        .toList();

    hourlyWeather = hourlyWeather.sublist(1, 24);
    http.Response locRes = await http.get(
      Uri.parse(
        "http://api.openweathermap.org/geo/1.0/reverse?lat=${widget.lat}&lon=${widget.lng}&limit=1&appid=3c1337f474bf021bc368451dfd604fca",
      ),
    );

    List<dynamic> locData = jsonDecode(locRes.body);
    String cityName = limitStringToWords(locData[0]['name'], 2);

    currentCity = CityModel(
      name: cityName,
      lat: widget.lat,
      lng: widget.lng,
      currentWeather: currentWeather,
      hourlyWeather: hourlyWeather,
      dailyWeather: dailyWeather,
    );

    setState(() {
      loading = false;
    });
  }

  void reloadWeather() {
    _getCurrentCity();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentCity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: _body(),
    );
  }

  Widget _body() {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      child: loading ? LoadingCircle() : _getCurrentView(),
    );
  }

  Widget _getCurrentView() {
    if (!defaultView) {}
    return _currentDayView();
  }

  SingleChildScrollView _currentDayView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          DataBox(weather: currentCity.currentWeather),
          SizedBox(height: 30),
          HourlyList(hourlyWeather: currentCity.hourlyWeather),
          SizedBox(height: 30),
          DailyList(dailyWeather: currentCity.dailyWeather, days: days),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        currentCity.name,
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xffF7F8F8),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/icons/left-arrow.svg',
            height: 25,
            width: 50,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            reloadWeather();
          },
          child: Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xffF7F8F8),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            width: 37,
            child: SvgPicture.asset(
              'assets/icons/refresh.svg',
              height: 20,
              width: 50,
            ),
          ),
        ),
      ],
    );
  }
}
