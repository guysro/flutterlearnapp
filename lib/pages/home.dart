import 'dart:convert';

import 'package:flutterllearnapp/models/weather_stat_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    
    // print(currentPosition.toString());
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

    String timezone = dataJson['timezone'];
    String cityName = timezone.split('/')[1];

    currentCity = CityModel(
      name: cityName,
      lat: currentPosition.latitude, 
      lng: currentPosition.longitude, 
      currentWeather: currentWeather, 
      hourlyWeather: hourlyWeather
    );  
    print(currentCity.currentWeather.toString());
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

  Container _body() {
    return Container(
        alignment: Alignment.center,
        child:loading ? _loadingCircle() : _dataBox()
      );
  }

  Column _loadingCircle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xffDDDADA)),
          strokeWidth: 5.0,
          strokeCap: StrokeCap.square,
          backgroundColor: Color.fromARGB(159, 0, 0, 0),
          constraints: BoxConstraints(minHeight: 100, minWidth: 100),
          padding: EdgeInsets.only(bottom: 100),
        ),
      ],
    );
  }

  Column _dataBox() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(currentCity.name),
        Text("${currentCity.currentWeather.temp}"),
        Text("${currentCity.currentWeather.feelsLike}"),
        Text("${currentCity.currentWeather.uvIdx}" ),
        Text("${currentCity.currentWeather.windSpeed}"),
      ],
      );
  }

  Container _searchField() {
    return Container();
    // return Container(
    //         margin: EdgeInsets.only(top: 40, left: 20, right: 20),
    //         decoration: BoxDecoration(
    //           boxShadow: [
    //             BoxShadow(
    //               color: Color.fromRGBO(29,22,23,0.11),
    //               blurRadius: 40,
    //               spreadRadius: 0.0
    //             ),
    //           ]
    //         ),
    //         child: Autocomplete<CityModel>(
    //           optionsBuilder: (inputValue) {
    //             if (inputValue.text.isEmpty){
    //               return List.empty();
    //             } else {
    //               List<CityModel> options = cities.where((city) => city.name.toLowerCase().contains(inputValue.text.toLowerCase())).toList();
    //               options.sort((s1, s2) {
    //                 int index1 = s1.name.indexOf(inputValue.text);
    //                 int index2 = s2.name.indexOf(inputValue.text);
    //                 return index1.compareTo(index2);
    //               });
    //               return options;
    //             }
    //           },
    //           fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
    //             return TextField(
    //               controller: textEditingController,
    //               focusNode: focusNode,
    //               onEditingComplete: onFieldSubmitted,
    //               decoration: InputDecoration(
    //                 filled: true,
    //                 fillColor: Colors.white,
    //                 contentPadding: EdgeInsets.all(15),
    //                 hintText: 'Search City',
    //                 hintStyle: TextStyle(
    //                   color: Color(0xffDDDADA),
    //                   fontSize: 16
    //                 ),
    //                 prefixIcon: Padding(
    //                   padding: const EdgeInsets.all(12.0),
    //                   child: SvgPicture.asset(
    //                     'assets/icons/search.svg',
    //                     width: 20,
    //                     height: 20,
    //                     ),
    //                 ),
    //                 border: OutlineInputBorder(
    //                   borderRadius: BorderRadius.circular(15),
    //                   borderSide: BorderSide.none
    //                 )
    //               ),
    //             );
    //           },
    //           optionsViewBuilder: (context, onSelected, options) {
    //             return Material(
    //               child: 
    //               ListView.separated(
    //                 padding: const EdgeInsets.symmetric(vertical: 20),
    //                 itemCount: options.length,
    //                 separatorBuilder: (context, index) {
    //                   return const Divider();
    //                 },
    //                 itemBuilder: (context, index) {
    //                   final city = options.elementAt(index);
    //                   return ListTile(
    //                     title: Text(city.name),
    //                   );
    //                 },
    //               ),
    //             );
    //           },
    //           onSelected: (city) => debugPrint(city.name),
    //           displayStringForOption: ((city) => city.name),
    //         ),
          // );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        'Weather',
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