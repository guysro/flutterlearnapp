import 'package:flutter/material.dart';
import 'package:flutterllearnapp/models/daily_model.dart';
import 'package:flutterllearnapp/widgets/daily_box.dart';

class DailyList extends StatelessWidget {
  const DailyList({super.key, required this.dailyWeather, required this.days});

  final List<DailyModel> dailyWeather;
  final List<String> days;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        height: 400,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(29, 22, 23, 0.11),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
            border: BoxBorder.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            itemCount: dailyWeather.length,
            itemBuilder: (context, index) {
              return DailyBox(days: days, weather: dailyWeather[index], isToday: index == 0);
            },
            separatorBuilder: (context, index) {
              return Divider(color: Colors.black, thickness: 1, height: 0);
            },
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
      ),
    );
  }
}
