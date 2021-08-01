import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/widgets/Calendar/Calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UpcomingScreen extends StatelessWidget {
  const UpcomingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      Movies(),
      Shows(),
    ]);
  }
}

class Movies extends StatelessWidget {
  Widget build(BuildContext context) {
    keys.dataType = DataType.movie;
    return FutureBuilder(
      future: Provider.of<DataProvider>(context).getScheduleFor(DateFormat('yyyy-MM-dd').format(DateTime.now()),context),
        builder: (ctx, snapshot) => Calendar());
  }
}

class Shows extends StatelessWidget {
  Widget build(BuildContext context) {
    keys.dataType = DataType.tvShow;
    return Center(child: Text('Shows'));
  }
}
