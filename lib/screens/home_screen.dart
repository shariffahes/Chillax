import 'package:discuss_it/widgets/HomeWidgets/search/SearchWidget.dart';
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
  //Set the number of discover types that will be in the home screen
  //Skip the first 2 discover types (genre,trending)
  final List<DiscoverTypes> listOfTitles =
      DiscoverTypes.values.skip(keys.mainList).toList();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        SearchWidget(),
        Trending(DiscoverTypes.trending),
        Container(
            padding: const EdgeInsets.all(5),
            child: Genre(DiscoverTypes.genre)),
        ...listOfTitles.map((type) => Type(type)).toList(),
      ]),
    );
  }
}
