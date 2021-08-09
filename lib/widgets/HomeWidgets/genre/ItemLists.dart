import 'dart:math';
import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/screens/list_all_screen.dart';
import 'package:flutter/material.dart';

class ItemLists extends StatelessWidget {
  final _items;

  final double ratio;
  const ItemLists(
    this.ratio,
    this._items,
  );

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: MediaQuery.of(context).size.width * 0.41,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: ratio,
      ),
      scrollDirection: Axis.horizontal,
      itemBuilder: (_, index) => InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(ListAll.route, arguments: {
            'discover_type': Global.isMovie() ? MovieTypes.genre : TvTypes.genre,
            'genre': _items[index]
          });
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.primaries[Random().nextInt(Colors.primaries.length)]
                  .shade700,
              borderRadius: BorderRadius.circular(
                8.0,
              )),
          margin: const EdgeInsets.all(5),
          child: Center(
            child: Text(
              _items[index],
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  fontSize: 20),
            ),
          ),
        ),
      ),
      itemCount: _items.length,
    );
  }
}
