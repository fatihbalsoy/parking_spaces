/*
 *   main.dart
 *   lib
 * 
 *   Created by Fatih Balsoy on 8/15/22
 *   Copyright © 2023 Fatih Balsoy. All rights reserved.
 */

import 'package:campusparc_osu/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

SharedPreferences? preferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  preferences = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme,
      // debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
