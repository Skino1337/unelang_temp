import 'package:flutter/material.dart';


MaterialColor white = MaterialColor(
  0xFFFFFFFF,
  const <int, Color>{
    50: Color(0xFFFFFFFF),
    100: Color(0xFFFFFFFF),
    200: Color(0xFFFFFFFF),
    300: Color(0xFFFFFFFF),
    400: Color(0xFFFFFFFF),
    500: Color(0xFFFFFFFF),
    600: Color(0xFFFFFFFF),
    700: Color(0xFFFFFFFF),
    800: Color(0xFFFFFFFF),
    900: Color(0xFFFFFFFF),
  },
);



final appTheme = ThemeData(
  primarySwatch: white,
  scaffoldBackgroundColor:  Color.fromARGB(255, 238, 241, 248),
  textTheme: const TextTheme(
    headline1: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 12,
      color: Colors.black,
    ),
  ),
);
