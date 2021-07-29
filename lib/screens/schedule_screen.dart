import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/keys.dart';
import 'package:flutter/material.dart';

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
    return Center(child: Text('Movies'));
  }
}

class Shows extends StatelessWidget {
  Widget build(BuildContext context) {
    keys.dataType = DataType.tvShow;
    return Center(child: Text('Shows'));
  }
}
