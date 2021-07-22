import 'package:flutter/material.dart';
import '../genre/ItemLists.dart';

class Genre extends StatelessWidget {
  final _items = [
    'Comedy',
    'Action',
    'Thriller',
    'Adventure',
    'Horror',
    'Family',
    'Cartoon',
    'Mystery',
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          alignment: AlignmentDirectional.topStart,
          child: Text(
            'Genre',
            style: TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
            //dynamic
            height: 200,
            width: double.infinity,
            child: ItemLists(5 / 3, _items)),
      ],
    );
  }
}
