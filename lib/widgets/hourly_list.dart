import 'package:flutter/material.dart';
import 'package:flutterllearnapp/models/weather_stat_model.dart';
import 'package:flutterllearnapp/widgets/hourly_box.dart';

class HourlyList extends StatelessWidget {
  const HourlyList({
    super.key,
    required this.hourlyWeather,
  });

  final List<WeatherStatModel> hourlyWeather;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        height: 115,
        child: 
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(29,22,23,0.11),
                  blurRadius: 40,
                  spreadRadius: 10
                )
              ],
              border: BoxBorder.all(
                color: Colors.black,
                width: 1
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Color.fromARGB(33, 255, 255, 255),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              padding: EdgeInsets.all(0),
              itemCount: hourlyWeather.length,
              itemBuilder: (context, index) {
                return HourlyBox(weather: hourlyWeather[index]);
              },
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) {
                return VerticalDivider(color: Colors.black, thickness: 1,width: 0,);
              },
              physics: PageScrollPhysics(),
            ),
          ),
      ),
    );
  }
}
