/*
 *   main.dart
 *   lib
 * 
 *   Created by Fatih Balsoy on 8/15/22
 *   Last Modified by Fatih Balsoy on 8/15/22
 *   Copyright © 2022 Fatih Balsoy. All rights reserved.
 */

import 'package:campusparc_osu/theme.dart';
import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}
