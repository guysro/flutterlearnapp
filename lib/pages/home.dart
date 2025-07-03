import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    searchControler.addListener(() {
      _onChange();
    });
    super.initState();
  }

  _onChange(){
    placeSuggestion(searchControler.text);
  }

  void placeSuggestion(String input) async {
    const String apiKey = 'AIzaSyAK0_XCp4SpqPVDxuJnh4Rjz_NDgmuhXv0';
    try{
      String bassedUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String requst = '$bassedUrl?input=$input&key=$apiKey&sessiontoken=$token';
      var response = await http.get(Uri.parse(requst));
      var data = jsonDecode(response.body);
      if(kDebugMode){
        print(data);
      }
      if(response.statusCode == 200){
        setState(() {
          listOfLocation = data['predictions'];
        });
      } else {
        throw Exception('Failed to load suggestion');
      }
    }
    catch(e){
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: searchControler,
              decoration: InputDecoration(
                hint: Text("Search")
              ),
              onChanged: (value){
                setState(() {
                  
                });
              },
            ),
            Visibility(
              visible: searchControler.text.isEmpty?false:true,
              child: Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: listOfLocation.length,
                  itemBuilder: (context,index){
                    return GestureDetector(
                      onTap: () {
                        // TODO: geocode selected text and transfer to weather view
                        searchControler.text = listOfLocation[index]['description'];
                      },
                      child: ListTile(
                        title: Text(
                          listOfLocation[index]['description'],
                        ),
                      ),
                    );
                  },
                )
              ),
            ),
            Visibility(
              visible: searchControler.text.isEmpty?true:false,
              child: Container(
                margin: EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: (){
                    // TODO: get current location and transfer to weather view
                  }, 
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.my_location,
                        color: Colors.green,
                      ),
                      Text(
                        'My Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}