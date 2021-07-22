import 'dart:math';
import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/screens/list_all_screen.dart';
import 'package:flutter/material.dart';

class ItemLists extends StatelessWidget {
  final _items;
  final DiscoverTypes type;
  final double ratio;
  ItemLists(this.ratio, this._items, this.type);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 200,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: ratio,
      ),
      scrollDirection: Axis.horizontal,
      itemBuilder: (_, index) => InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(ListAll.route, arguments: {'type' : type, 'genre' : _items[index]});
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.primaries[Random().nextInt(Colors.primaries.length)]
                  .shade700,
              borderRadius: BorderRadius.circular(
                8.0,
              )),
          margin: EdgeInsets.all(5),
          child: Center(
            child: Text(
              _items[index],
              style: TextStyle(
                  fontWeight: FontWeight.w300,
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
