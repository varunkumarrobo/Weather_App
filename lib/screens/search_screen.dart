import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../widgets/constants.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  String? cityName;
  List<String> suggestion = [];
  TextEditingController searchController = TextEditingController();

  getSuggestionData(city) async {
    await Provider.of<Wearther>(context).getSuggestions(city).then((response) {
      suggestion.clear();
      for (var item in jsonDecode(response.body)["results"]) {
        var cityName = item['text']['primary'] as String;
        int index = cityName.indexOf(',');
        suggestion.add(cityName.substring(0, index));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage('images/city_background.jpg'),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 50.0,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: kTextFieldInputDecoration,
                  onChanged: (value) {
                    setState(() {
                      cityName = value;
                      log(
                        suggestion.toString(),
                      );
                      suggestion.clear();
                    });
                  },
                  onSubmitted: (value) async {
                    Navigator.pop(context, cityName);
                  },
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height - 490,
                color: Colors.transparent,
                child: FutureBuilder<dynamic>(
                  future: getSuggestionData(
                    searchController.text,
                  ),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(10.0),
                        itemCount: suggestion.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return SizedBox(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  searchController.text = suggestion[index];
                                  suggestion.clear();
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Text(
                                  suggestion[index],
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Text('Error');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
