import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/widgets/Calendar/Schedule.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpcomingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      Movies(),
      Shows(),
    ]);
  }
}

class Movies extends StatefulWidget {
  @override
  _MoviesState createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  DateTime date = DateTime.now();
  void reset(DateTime newDate) {
    setState(() {
      date = newDate;
    });
  }

  Widget build(BuildContext context) {
    Global.dataType = DataType.movie;
    return FutureBuilder<List<int>>(
        future: Provider.of<DataProvider>(context, listen: false)
            .fetchMoviesSchedule(date, context),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Universal.loadingWidget();
          }
          if (snapshot.hasError) {
            return Universal.failedWidget();
          }

          return ScheduleScreen(
            date,
            ids: snapshot.data,
            resetDate: reset,
          );
        });
  }
}

class Shows extends StatelessWidget {
  Widget build(BuildContext context) {
    Global.dataType = DataType.tvShow;
    return FutureBuilder(
      future: Provider.of<DataProvider>(context, listen: false).fetchSchedule(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Universal.loadingWidget();
        if (snapshot.hasError) {
          print(snapshot.error);
          return Universal.failedWidget();
        }
        final List<Map<String, Object>> listOfShows = [];

        DataProvider.tvSchedule.forEach((key, value) {
          final date = DateTime.parse(value['date'] as String).toLocal();
     
          if (date.isAfter(DateTime.now().subtract(Duration(days: 1))))
            listOfShows.add(value);
        });
        return ScheduleScreen(DateTime.now(), shows: listOfShows);
      },
    );
  }
}
