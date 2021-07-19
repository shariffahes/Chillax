import 'package:flutter/material.dart';

class WatchListScreen extends StatelessWidget {
  const WatchListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        Movies(),
        Shows(),
      ],
    );
  }
}

class Movies extends StatelessWidget {
  Widget build(BuildContext context) {
    return Center(child: Text('Movies'));
  }
}

class Shows extends StatelessWidget {
  Widget build(BuildContext context) {
    return Center(child: Text('Shows'));
  }
}
