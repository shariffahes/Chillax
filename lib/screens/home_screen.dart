import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/widgets/HomeWidgets/search/SearchWidget.dart';
import 'package:flutter/material.dart';
import '../widgets/HomeWidgets/search/SearchWidget.dart';
import 'package:flutter/rendering.dart';
import '../models/Global.dart';
import '../widgets/HomeWidgets/Type/Type.dart';
import '../widgets/HomeWidgets/genre/Genre.dart';
import '../widgets/HomeWidgets/trending/Trending.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  //Prepare the home screen main titles
  final List<MovieTypes> listOfMovieTitles =
      MovieTypes.values.skip(Global.mainList).toList();
  final List<TvTypes> listOfShowTitles =
      TvTypes.values.skip(Global.mainList).toList();
  @override
  Widget build(BuildContext context) {
    return TabBarView(
      physics: NeverScrollableScrollPhysics(),
      children: [
        MainScreen(DataType.movie, listOfTitles: listOfMovieTitles),
        MainScreen(DataType.tvShow, listOfTitles: listOfShowTitles),
      ],
    );
  }
}



class MainScreen extends StatelessWidget {
  final DataType type;
  MainScreen(
    this.type, {
    required this.listOfTitles,
  });

  final List<Object> listOfTitles;

  @override
  Widget build(BuildContext context) {
    Global.dataType = type;

    return SingleChildScrollView(
      child: Column(children: [
        SearchWidget(),
        Trending(
          MovieTypes.boxoffice,
          TvTypes.played,
        ),
        Container(padding: const EdgeInsets.all(5), child: Genre()),
        ...listOfTitles.map((e) {
          if (e is MovieTypes) return Type(e, null);

          return Type(null, e as TvTypes);
        }).toList(),
      ]),
    );
  }
}
