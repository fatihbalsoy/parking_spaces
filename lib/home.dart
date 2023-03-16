/*
 *   home.dart
 *   lib
 * 
 *   Created by Fatih Balsoy on 8/15/22
 *   Copyright © 2023 Fatih Balsoy. All rights reserved.
 */

import 'dart:convert';

import 'package:campusparc_osu/main.dart';
import 'package:campusparc_osu/spaces.dart';
import 'package:campusparc_osu/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.title = "Parking Spaces"}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String favoritesKey = "favorites_prefs";
  Map<String, bool> starred = {};
  Map<String, double> occupancies = {};
  Map<String, double> networkCache = {};

  @override
  void initState() {
    super.initState();
    spaces.forEach((key, value) {
      starred.addEntries([MapEntry(key, false)]);
    });
    List<String> saved = preferences!.getStringList(favoritesKey) ?? [];
    for (String key in saved) {
      starred.update(key, (value) => true);
      getOccupancy(key, true);
    }
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
        onPressed: () {
          launchUrl(Uri.parse("https://maps.google.com"));
        },
        tooltip: 'Start Driving',
        child: const Icon(Icons.time_to_leave),
      ),
    );
  }

  setPreferences(String key, bool value) {
    List<String> list = preferences!.getStringList(favoritesKey) ?? [];
    if (value) {
      list.add(key);
    } else {
      list.remove(key);
    }
    preferences!.setStringList(favoritesKey, list);
    getOccupancy(key, value);
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
                  setPreferences(key, starred[key]!);
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
                ? Stack(alignment: Alignment.centerRight, children: [
                    const Text(
                      "100%",
                      style: TextStyle(color: Colors.transparent),
                    ),
                    Text("${(occupancies[key]! * 100).round()}%")
                  ])
                : null,
            onTap: () => MapsLauncher.launchQuery(spaces[key]!["address"]!),
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
          "Sec-Fetch-Site": "cross-site"
        },
        body:
            '{"requiredData": {"$key": {"_zoneId": "${spaces[key]!["zoneId"]}", "occupancy":["occupancyRate","occupancyLastUpdate"]}}}');
  }

  double getOccupancy(String key, bool add) {
    if (!networkCache.containsKey(key)) {
      fetchOccupancyFromInternet(key).then((response) {
        var json = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
        Map occupancyRate = json["data"][key]["occupancy"][0]["occupancyRate"];
        double occupancy =
            occupancyRate.containsKey("value") ? occupancyRate["value"] : 0.0;
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
