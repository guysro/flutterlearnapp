import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterllearnapp/models/weather_stat_model.dart';

class DataBox extends StatelessWidget {
  const DataBox({
    super.key,
    required this.weather,
  });

  final WeatherStatModel weather;

  @override
  Widget build(BuildContext context) {
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
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(left: 10),
                child: SvgPicture.asset(
                  'assets/icons/icon-${weather.iconString}.svg',
                  width: 50,
                ),
              ),
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
}
