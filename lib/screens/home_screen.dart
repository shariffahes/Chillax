import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/widgets/HomeWidgets/search/SearchWidget.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../widgets/HomeWidgets/search/SearchWidget.dart';
import 'package:flutter/rendering.dart';
import '../models/Global.dart';
import '../widgets/HomeWidgets/Type/Type.dart';
import '../widgets/HomeWidgets/genre/Genre.dart';
import '../widgets/HomeWidgets/trending/Trending.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
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
        MainScreen(DataType.movie, 0, listOfTitles: listOfMovieTitles),
        MainScreen(DataType.tvShow, 4, listOfTitles: listOfShowTitles),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MainScreen extends StatefulWidget {
  final DataType type;
  int k;
  MainScreen(
    this.type,
    this.k, {
    required this.listOfTitles,
  });

  final List<Object> listOfTitles;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    Global.dataType = widget.type;
    int key = widget.k;

    return SingleChildScrollView(
      child: Column(children: [
        SearchWidget(),
        Trending(
          MovieTypes.boxoffice,
          TvTypes.played,
          key++,
        ),
        Container(padding: const EdgeInsets.all(5), child: Genre()),
        ...widget.listOfTitles.map((e) {
          if (e is MovieTypes) return Type(e, null, key++);

          return Type(
            null,
            e as TvTypes,
            key++,
          );
        }).toList(),
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
