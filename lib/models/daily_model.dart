
class DailyModel {
  DateTime dateTime;
  double minDeg;
  double maxDeg;
  String iconString;

  DailyModel({
    required this.dateTime,
    required this.iconString,
    required this.maxDeg,
    required this.minDeg
  });

  factory DailyModel.fromJSON(Map<String, dynamic> daily){
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
        (daily['dt']) * 1000,
        isUtc: false // Assuming the dt timestamp is UTC,
    );
    return DailyModel(
      dateTime: dateTime, 
      iconString: daily['weather'][0]['icon'], 
      maxDeg: daily['temp']['max'], 
      minDeg: daily['temp']['min']
    );
  }
}