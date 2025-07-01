import 'dart:convert';
import 'dart:typed_data';

import 'package:flutterllearnapp/models/weather_stat_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterllearnapp/models/city_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_rembg/local_rembg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  CityModel currentCity = CityModel.defaultCity();
  
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
    hourlyWeather = hourlyWeather.sublist(0, 4);
    print(hourlyWeather);
    http.Response locRes = await http.get(Uri.parse("http://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lng&limit=1&appid=3c1337f474bf021bc368451dfd604fca"));
    
    List<dynamic> locData = jsonDecode(locRes.body);
    print(locData[0]['name']);
    String cityName = limitStringToWords(locData[0]['name'], 2);
    
    http.Response icon = await http.get(Uri.parse('https://openweathermap.org/img/wn/${currentWeather.iconString}@2x.png'));
    Uint8List bytes = icon.bodyBytes;
    LocalRembgResultModel rembgRes = await LocalRembg.removeBackground(imageUint8List: bytes);
    if(rembgRes.status == 1){
      currentWeather.iconBytes = Uint8List.fromList(rembgRes.imageBytes!);
    }
    else{
      currentWeather.iconBytes = bytes;
    }

    for (var weatherData in hourlyWeather) {
      http.Response icon = await http.get(Uri.parse('https://openweathermap.org/img/wn/${weatherData.iconString}@2x.png'));
      Uint8List bytes = icon.bodyBytes;
      LocalRembgResultModel rembgRes = await LocalRembg.removeBackground(imageUint8List: bytes);
      if(rembgRes.status == 1){
        weatherData.iconBytes = Uint8List.fromList(rembgRes.imageBytes!);
      }
      else{
        weatherData.iconBytes = bytes;
      }
    }

    currentCity = CityModel(
      name: cityName,
      lat: currentPosition.latitude, 
      lng: currentPosition.longitude, 
      currentWeather: currentWeather, 
      hourlyWeather: hourlyWeather
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
      child: loading ? _loadingCircle() : Column(
        children: [
          _dataBox(currentCity.currentWeather),
          SizedBox(height: 100,),
          SizedBox(
            height: 230,
            child: ListView.builder(
              itemCount: currentCity.hourlyWeather.length,
              itemBuilder: (context, index) {
                return _hourlyBox(currentCity.hourlyWeather[index]);
              },
              // separatorBuilder: (context, index) {
              //   return VerticalDivider(
              //     thickness: 3,
              //     radius: BorderRadius.all(Radius.circular(3)),
              //     endIndent: 60,
              //     color: Colors.black,
              //   );
              // },
              scrollDirection: Axis.horizontal,
            ),
          )
        ],
      ),
    );
  }

  Widget _loadingCircle() {

    return Container(
      alignment: Alignment.center,
      child: Column(
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
      ),
    );
  }

  Widget _hourlyBox(WeatherStatModel weather){
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(
          color: Colors.black,
          width: 2,
        )
      ),
      child: Column(
        children: [
          Text(
            "${weather.time.hour}:${weather.time.minute >= 10 ? weather.time.minute : "0${weather.time.minute}"}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Color.fromARGB(33, 255, 255, 255),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(29,22,23,0.11),
                  blurRadius: 40,
                  spreadRadius: 10
                )
              ],
            ),
            clipBehavior: Clip.none,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.memory(
                        weather.iconBytes,
                        height: 80,
                      )
                      // Image.network(
                      //   'https://openweathermap.org/img/wn/${weather.iconString}@2x.png',
                      //   loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      //     if (loadingProgress == null) {
                      //       return child;
                      //     }
                      //     return Center(
                      //       child: CircularProgressIndicator(
                      //         value: loadingProgress.expectedTotalBytes != null
                      //             ? loadingProgress.cumulativeBytesLoaded /
                      //                 loadingProgress.expectedTotalBytes!
                      //             : null,
                      //       ),
                      //     );
                      //   },
                      //   height: 80,
                      // ),
                      ,
                      Text(
                        weather.temp.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 26,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/icons/celsius.svg',
                        height: 22,
                      )
                    ],
                  ),
                ),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Feels Like: '
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weather.feelsLike.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 16,
                            
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/icons/celsius.svg',
                          height: 16,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/wind.svg',
                          height: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          weather.windSpeed.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'km/h',
                          style: TextStyle(
                            fontSize: 12,
                          
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                // Text(weatherTime())
              ],
            )
          ),
        ],
      ),
    );
  }

  Widget _dataBox(WeatherStatModel weather) {
    // from left to right: sky icon, temp, sky 
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(33, 255, 255, 255),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(29,22,23,0.11),
            blurRadius: 40,
            spreadRadius: 10
          )
        ],
      ),
      height: 100,
      clipBehavior: Clip.none,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.memory(
                weather.iconBytes,
                height: 80,
              )
              // Image.network(
              //   'https://openweathermap.org/img/wn/${weather.iconString}@2x.png',
              //   loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              //     if (loadingProgress == null) {
              //       return child;
              //     }
              //     return Center(
              //       child: CircularProgressIndicator(
              //         value: loadingProgress.expectedTotalBytes != null
              //             ? loadingProgress.cumulativeBytesLoaded /
              //                 loadingProgress.expectedTotalBytes!
              //             : null,
              //       ),
              //     );
              //   },
              //   height: 80,
              // ),
              ,
              SizedBox(
                width: 0,
              ),
              Text(
                weather.temp.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold
                ),
              ),
              SvgPicture.asset(
                'assets/icons/celsius.svg',
                height: 36,
              )
            ],
          ),
          
          Container(
            padding: EdgeInsets.only(top: 10, right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Feels Like: '
                ),
                Row(
                  children: [
                    Text(
                      weather.feelsLike.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 22,
                        
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/icons/celsius.svg',
                      height: 22,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/wind.svg',
                      height: 28,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      weather.windSpeed.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'km/h',
                      style: TextStyle(
                        fontSize: 12,

                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          // Text(weatherTime())
        ],
      )
    );
  }

  // ignore: unused_element
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