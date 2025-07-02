import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterllearnapp/models/daily_model.dart';

class DailyBox extends StatelessWidget {
  const DailyBox({
    super.key,
    required this.days,
    required this.weather,
  });

  final List<String> days;
  final DailyModel weather;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              days[weather.dateTime.weekday - 1],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            clipBehavior: Clip.none,
            alignment: Alignment.centerRight,
            child: Row(
              spacing: 25,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  'assets/icons/icon-${weather.iconString}.svg',
                  width: 28,
                ),
                
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/up.svg',
                      height: 18,
                    ),
                    Text(
                      weather.maxDeg.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/icons/celsius.svg',
                      height: 18,
                    ),
                  ],
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/down.svg',
                      height: 18,
                    ),
                    Text(
                      weather.minDeg.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/icons/celsius.svg',
                      height: 18,
                    ),
                  ],
                )
              ],
            )
          ),
          
        ],
      ),
    );
  }
}
