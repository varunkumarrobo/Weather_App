import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/location_provider.dart';
import 'screens/location_screen.dart';

void main() {
  runApp(
    const MyApp(),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Wearther(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => FavProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SearchIndexProvider(),
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LocationScreen(),
      ),
    );
  }
}
