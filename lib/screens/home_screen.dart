import 'package:discuss_it/widgets/category_list.dart';
import 'package:discuss_it/widgets/preview_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> listOfTitles = ['Trending', 'Best', 'Awarded'];
    return Scaffold(
      body: ListView(children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.30,
            child: PreviewCard('Books', Icons.book)),
        ...listOfTitles
            .map((e) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CategoryList(e, listOfTitles),
                ))
            .toList(),
      ]),
    );
  }
}
