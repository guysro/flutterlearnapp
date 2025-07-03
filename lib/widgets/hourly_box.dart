import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterllearnapp/models/weather_stat_model.dart';

class HourlyBox extends StatelessWidget {
  const HourlyBox({super.key, required this.weather});

  final WeatherStatModel weather;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${weather.time.hour}:${weather.time.minute >= 10 ? weather.time.minute : "0${weather.time.minute}"}",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          clipBehavior: Clip.none,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/icon-${weather.iconString}.svg',
                    width: 35,
                  ),
                  Row(
                    children: [
                      Text(
                        weather.temp.toStringAsFixed(0),
                        style: TextStyle(fontSize: 26),
                      ),
                      SvgPicture.asset('assets/icons/celsius.svg', height: 22),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
