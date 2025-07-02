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
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  CityModel currentCity = CityModel.defaultCity();
  
  final List<String> days = List.of([
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ]);

  String limitStringToWords(String text, int wordLimit) {
    if (wordLimit <= 0) {
      return '';
    }
    List<String> words = text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
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
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      return;
    }

    LocationPermission premission; 
    premission = await Geolocator.checkPermission();
    if(premission == LocationPermission.denied){
      premission = await Geolocator.requestPermission();
      if(premission == LocationPermission.denied){
        return;
      }
    }

    if(premission == LocationPermission.deniedForever){
      return;
    }

    Position currentPosition = await Geolocator.getCurrentPosition();
    
    print(currentPosition.toString());
    
    double lat = currentPosition.latitude;
    double lng = currentPosition.longitude;
    http.Response res = await http.get(Uri.parse("https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lng&appid=3c1337f474bf021bc368451dfd604fca&units=metric"));

    Map<String, dynamic> dataJson = jsonDecode(res.body);

    Map<String, dynamic> currentData = dataJson['current'];
    WeatherStatModel currentWeather = WeatherStatModel.fromJSON(currentData);

    List<dynamic> hourlyWeatherData = dataJson['hourly'];
    List<WeatherStatModel> hourlyWeather = hourlyWeatherData
      .map((hourlyMap) => WeatherStatModel.fromJSON(hourlyMap as Map<String, dynamic>))
      .toList();

    List<dynamic> dailyWeatherData = dataJson['daily'];
    List<DailyModel> dailyWeather = dailyWeatherData
      .map((dayMap) => DailyModel.fromJSON(dayMap as Map<String, dynamic>))
      .toList();

    hourlyWeather = hourlyWeather.sublist(1, 24);    
    http.Response locRes = await http.get(Uri.parse("http://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lng&limit=1&appid=3c1337f474bf021bc368451dfd604fca"));
    
    List<dynamic> locData = jsonDecode(locRes.body);
    print(locData[0]['name']);
    String cityName = limitStringToWords(locData[0]['name'], 2);
    
    currentCity = CityModel(
      name: cityName,
      lat: currentPosition.latitude, 
      lng: currentPosition.longitude, 
      currentWeather: currentWeather, 
      hourlyWeather: hourlyWeather,
      dailyWeather: dailyWeather
    );  
    
    // print(currentCity.currentWeather.toString());
    setState(() {
      loading = false;
    });
  }

  void reloadWeather(){
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
      body: _body()
    );
  }

  Widget _body() {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      child: loading ? LoadingCircle() : SingleChildScrollView(
        child: Column(
          children: [
            DataBox(weather: currentCity.currentWeather),
            SizedBox(height: 30,),
            HourlyList(currentCity: currentCity),
            SizedBox(height: 30),
            DailyList(currentCity: currentCity, days: days)
          ],
        ),
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
          fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
        },
        child: Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xffF7F8F8),
            borderRadius: BorderRadius.circular(10)
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
              borderRadius: BorderRadius.circular(10)
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
