import '../widgets/HomeWidgets/search/SearchWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/keys.dart';
import '../widgets/HomeWidgets/Type/Type.dart';
import '../widgets/HomeWidgets/genre/Genre.dart';
import '../widgets/HomeWidgets/trending/Trending.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<DiscoverTypes> listOfTitles =
      DiscoverTypes.values.skip(keys.mainList).toList();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        SearchWidget(),
        Trending(DiscoverTypes.boxoffice),
        Container(
            padding: const EdgeInsets.all(5),
            child: Genre(DiscoverTypes.genre)),
        ...listOfTitles.map((type) => Type(type)).toList(),
      ]),
    );
  }
}
