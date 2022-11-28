import 'package:flutter/material.dart';
import 'package:music_app/pages/layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          textTheme: const TextTheme(
              bodyText1: TextStyle(color: Colors.white, fontSize: 15),
              bodyText2: TextStyle(color: Colors.white, fontSize: 20)),
        ),
        initialRoute: '$LayoutPage',
        routes: {
          '$LayoutPage': (_) => const LayoutPage(),
        });
  }
}
