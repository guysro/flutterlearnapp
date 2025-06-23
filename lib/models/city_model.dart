class CityModel {
  String name;
  String country;
  double lat;
  double lng;

  CityModel({
    required this.name,
    required this.country,
    required this.lat,
    required this.lng
  });


  factory CityModel.fromCsvRow(List<String> row){
    if(row.length != 4){
      throw FormatException('CSV row must have exactly 4 columns: name, country, lat, lng');
    }
    return CityModel(
      name: row[0].trim(),
      country: row[3].trim(),
      lat: double.parse(row[2].trim()),
      lng: double.parse(row[1].trim()),
    );
  }

  static List<CityModel> getCities() {
    List<CityModel> cities = [];

    // String filePath = AssetManager. ("assets/files/cities.csv");
    // File file = File(filePath);
    // if(file.existsSync()){
    //   return [];
    // }

    // try {
    //   fileData = file.readAsStringSync();
    // } catch (e) {
    //   print(e);
    // }

    // String fileData = rootBundle.loadString('assets/files/cities.csv');
    // List<String> lines = const LineSplitter().convert(fileData);
    // if(lines.isEmpty){
    //   print("lines empty");
    //   return [];
    // }
    // for (var i = 0; i < lines.length; i++) {
    //   String line = lines[i].trim();
    //   print(line);
    //   if(line.isEmpty){
    //     continue;
    //   }

    //   List<String> values = line.split(',');
    //   try {
    //     cities.add(CityModel.fromCsvRow(values));
    //   // ignore: empty_catches
    //   } catch (e){}
    // }

    return cities;
  }
}