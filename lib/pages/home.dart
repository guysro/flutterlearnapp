import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterllearnapp/models/city_model.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CityModel> cities = [];

  void _getCities() async {
    // String fileData = await rootBundle.loadString('assets/files/cities.csv');
    // List<String> lines = const LineSplitter().convert(fileData);
    // if(lines.isEmpty){
    //   print("lines empty");
    // }
    // for (var i = 0; i <  2/*lines.length*/; i++) {
    //   String line = lines[i].trim();
    //   print(line);
    //   if(line.isEmpty){
    //     continue;
    //   }

    //   List<String> values = line.split(',');
    //   try {
    //     cities.add(CityModel.fromCsvRow(values));
    //   } catch (e){
    //     // print(e);
    //   }
    // }


  }

  @override
  void initState() {
    _getCities();
  }

  @override
  Widget build(BuildContext context) {
    _getCities();
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          _searchField(),


          // SizedBox(height: 40,),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.only(left: 24),
          //       child: Text(
          //         'Category',
          //         style: TextStyle(
          //           color: Colors.black,
          //           fontSize: 22,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ),
          //     SizedBox(height: 15,),
          //     Container(
          //       height: 150,
          //       color: Colors.green,
          //       child: ListView.builder(
          //         itemCount: categories.length,
          //         itemBuilder: (context, index) {
          //           return Container();
          //         },
          //       ),
          //     )
          //   ],
          // )
        ],
      ),
    );
  }

  Container _searchField() {
    return Container(
            margin: EdgeInsets.only(top: 40, left: 20, right: 20),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(29,22,23,0.11),
                  blurRadius: 40,
                  spreadRadius: 0.0
                ),
              ]
            ),
            child: Autocomplete<CityModel>(
              optionsBuilder: (inputValue) {
                if (inputValue.text.isEmpty){
                  return List.empty();
                } else {
                  List<CityModel> options = cities.where((city) => city.name.toLowerCase().contains(inputValue.text.toLowerCase())).toList();
                  options.sort((s1, s2) {
                    int index1 = s1.name.indexOf(inputValue.text);
                    int index2 = s2.name.indexOf(inputValue.text);
                    return index1.compareTo(index2);
                  });
                  return options;
                }
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onEditingComplete: onFieldSubmitted,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(15),
                    hintText: 'Search City',
                    hintStyle: TextStyle(
                      color: Color(0xffDDDADA),
                      fontSize: 16
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        'assets/icons/search.svg',
                        width: 20,
                        height: 20,
                        ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none
                    )
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Material(
                  child: 
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: options.length,
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemBuilder: (context, index) {
                      final city = options.elementAt(index);
                      return ListTile(
                        title: Text(city.name),
                      );
                    },
                  ),
                );
              },
              onSelected: (city) => debugPrint(city.name),
              displayStringForOption: ((city) => city.name),
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
            'assets/icons/arrow-right.svg',
            height: 13,
            width: 50,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {

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
              'assets/icons/dots.svg',
              height: 13,
              width: 50,
            ),
          ),
        ),  
      ],
    );
  }
}