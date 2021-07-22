import 'dart:math';

import 'package:flutter/material.dart';

class ItemLists extends StatelessWidget {
  final _items;
  final double ratio;
  ItemLists(this.ratio, this._items);
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
        onTap: () {},
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
