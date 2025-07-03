import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterllearnapp/pages/weather_view.dart';
import 'package:flutterllearnapp/widgets/loading_circle.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchControler = TextEditingController();
  final String token = '1234567890';

  var uuid = const Uuid();
  List<dynamic> listOfLocation = [];

  bool loading = false;

  @override
  void initState() {
    searchControler.addListener(() {
      _onChange();
    });
    loading = false;
    super.initState();
  }

  void _onChange() {
    placeSuggestion(searchControler.text);
  }

  void placeSuggestion(String input) async {
    const String apiKey = 'AIzaSyAK0_XCp4SpqPVDxuJnh4Rjz_NDgmuhXv0';
    try {
      String bassedUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String requst = '$bassedUrl?input=$input&key=$apiKey&sessiontoken=$token';
      var response = await http.get(Uri.parse(requst));
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        // print(data);
      }
      if (response.statusCode == 200) {
        setState(() {
          listOfLocation = data['predictions'];
        });
      } else {
        throw Exception('Failed to load suggestion');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: loading ? LoadingCircle() : _locationSearch(context),
    );
  }

  Widget _locationSearch(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.only(bottom: 100),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(29, 22, 23, 0.11),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: searchControler,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hint: Text("Search", style: TextStyle(fontSize: 20)),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            Flexible(
              child: Visibility(
                visible: searchControler.text.isEmpty ? false : true,
                child: ListView.separated(
                  clipBehavior: Clip.antiAlias,
                  padding: EdgeInsets.all(0),
                  shrinkWrap: true,
                  itemCount: listOfLocation.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        searchControler.text =
                            listOfLocation[index]['description'];

                        http.Response response = await http.get(
                          Uri.parse(
                            "https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyAK0_XCp4SpqPVDxuJnh4Rjz_NDgmuhXv0&address=${listOfLocation[index]['description']}",
                          ),
                        );
                        Map<String, dynamic> data = jsonDecode(response.body);

                        Map<String, dynamic> location =
                            data['results'][0]['geometry']['location'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WeatherViewPage(
                              lat: location['lat'],
                              lng: location['lng'],
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(listOfLocation[index]['description']),
                        leading: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x11000000),
                          ),
                          child: Icon(Icons.location_on),
                        ),
                        trailing: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: () {
                            searchControler.text =
                                listOfLocation[index]['description'];
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0x08000000),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(Icons.arrow_outward),
                          ),
                        ),
                      ),
                      // ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(height: 0, thickness: 1);
                  },
                ),
              ),
            ),
            Visibility(
              visible: searchControler.text.isEmpty ? true : false,
              child: Container(
                margin: EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    bool serviceEnabled =
                        await Geolocator.isLocationServiceEnabled();
                    if (!serviceEnabled) {
                      setState(() {
                        loading = false;
                      });
                      return;
                    }

                    LocationPermission premission;
                    premission = await Geolocator.checkPermission();
                    if (premission == LocationPermission.denied) {
                      premission = await Geolocator.requestPermission();
                      if (premission == LocationPermission.denied) {
                        setState(() {
                          loading = false;
                        });
                        return;
                      }
                    }

                    if (premission == LocationPermission.deniedForever) {
                      setState(() {
                        loading = false;
                      });
                      return;
                    }
                    Position currentPosition =
                        await Geolocator.getCurrentPosition();

                    double lat = currentPosition.latitude;
                    double lng = currentPosition.longitude;

                    setState(() {
                      loading = false;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WeatherViewPage(lat: lat, lng: lng),
                      ),
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.my_location, color: Colors.green),
                      Text(
                        'My Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        'Weather',
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }
}
