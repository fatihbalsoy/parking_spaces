/*
 *   home.dart
 *   lib
 * 
 *   Created by Fatih Balsoy on 8/15/22
 *   Last Modified by Fatih Balsoy on 8/15/22
 *   Copyright © 2022 Fatih Balsoy. All rights reserved.
 */

import 'dart:convert';
import 'dart:math';

import 'package:campusparc_osu/spaces.dart';
import 'package:campusparc_osu/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title = "Parking Spaces"}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, bool> starred = {};
  Map<String, double> occupancies = {};
  Map<String, double> networkCache = {};

  @override
  void initState() {
    super.initState();
    spaces.forEach((key, value) {
      starred.addEntries([MapEntry(key, false)]);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasStarred = starred.containsValue(true);
    Iterable<MapEntry<String, bool>> onlyStarred =
        starred.entries.where((element) => element.value == true);
    int stars = onlyStarred.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        foregroundColor: appTheme.textTheme.headline1?.color,
        backgroundColor: appTheme.dialogBackgroundColor,
        elevation: 0,
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          if (hasStarred && index == 0) {
            return const ListTile(title: Text("Favorites"));
          } else if (hasStarred && index < stars + 1) {
            String key = onlyStarred.elementAt(index - 1).key;
            return tile(key, inFavorites: true);
          } else {
            int listIndex = hasStarred ? index - 1 - stars : index;
            String key = spaces.entries.elementAt(listIndex).key;
            return tile(key, inFavorites: false);
          }
        },
        itemCount: hasStarred ? spaces.length + 1 + stars : spaces.length,
        separatorBuilder: (BuildContext context, int index) {
          return index == stars && hasStarred ? const Divider() : Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Set drive time',
        child: const Icon(Icons.time_to_leave),
      ),
    );
  }

  Widget tile(String key, {required bool inFavorites}) {
    String name = spaces[key]!["name"] ?? "";
    bool isStarred = (starred[key] ?? false);
    return !inFavorites && isStarred
        ? Container()
        : ListTile(
            leading: IconButton(
              color: isStarred ? appTheme.primaryColor : null,
              icon: Icon(isStarred ? Icons.star : Icons.star_border),
              onPressed: () {
                setState(() {
                  starred.update(key, (value) => !value);
                  if (!occupancies.containsKey(key) && !isStarred) {
                    occupancies.addAll({key: getOccupancy(key, true)});
                  } else if (isStarred) {
                    occupancies.remove(key);
                  }
                });
              },
            ),
            title: Text(name),
            subtitle: occupancies.containsKey(key)
                ? LinearProgressIndicator(value: occupancies[key])
                : null,
            trailing: occupancies.containsKey(key)
                ? Text("${(occupancies[key]! * 100).round()}%")
                : null,
            onTap: () {},
          );
  }

  Future<http.Response> fetchOccupancyFromInternet(String key) {
    return http.post(
        Uri.parse(
            "https://api2-usaeast.spotparking.com.au/1.4/dynamic/complex"),
        headers: {
          "Accept": "*/*",
          "Accept-Language": "en-US,en;q=0.9",
          "Cache-Control": "no-cache",
          "Connection": "keep-alive",
          "Content-Type": "text/plain;charset=UTF-8",
          "DNT": "1",
          "Origin": "https://sureparc.campusparc.com",
          "Pragma": "no-cache",
          "Referer": "https://sureparc.campusparc.com/",
          "Sec-Fetch-Dest": "empty",
          "Sec-Fetch-Mode": "cors",
          "Sec-Fetch-Site": "cross-site",
          // "User-Agent":
          //     "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5112.81 Safari/537.36 Edg/104.0.1293.47",
          // "sec-ch-ua":
          //     "\"Chromium\";v=\"104\", \" Not A;Brand\";v=\"99\", \"Microsoft Edge\";v=\"104\"",
          // "sec-ch-ua-mobile": "?0",
          // "sec-ch-ua-platform": "\"macOS\""
        },
        body:
            '{"requiredData": {"$key": {"_zoneId": "${spaces[key]!["zoneId"]}", "occupancy":["occupancyRate","occupancyLastUpdate"]}}}');
  }

  double getOccupancy(String key, bool add) {
    if (!networkCache.containsKey(key)) {
      fetchOccupancyFromInternet(key).then((response) {
        var json = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
        double occupancy =
            json["data"][key]["occupancy"][0]["occupancyRate"]["value"];
        setState(() {
          networkCache.addAll({key: occupancy});
          if (add) {
            occupancies.addAll({key: occupancy});
          }
        });
      });
      return 0.0;
    } else {
      return networkCache[key]!;
    }
  }
}
