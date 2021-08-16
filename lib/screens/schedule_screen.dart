import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/widgets/Calendar/Schedule.dart';
import 'package:flutter/material.dart';


class UpcomingScreen extends StatelessWidget {
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
    Global.dataType = DataType.movie;
    return ScheduleScreen();
      
  }
}

class Shows extends StatelessWidget {
  Widget build(BuildContext context) {
    Global.dataType = DataType.tvShow;
    return  ScheduleScreen();
      
  }
}
