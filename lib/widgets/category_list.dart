import 'package:discuss_it/screens/list_all_screen.dart';
import 'package:discuss_it/widgets/Item_list.dart';
import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  final String title;
  final List listOfItems;
  const CategoryList(this.title, this.listOfItems);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 25),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(ListAll.route);
                },
                child: Text('See all'),
              ),
            ],
          ),
        ),
        Container(
          //fix later to box constraint
          height: 270,
          child: ListView.builder(
            itemBuilder: (ctx, index) => ItemList(5 / 7),
            scrollDirection: Axis.horizontal,
            itemCount: listOfItems.length,
          ),
        ),
        Divider(
          thickness: 2,
        ),
      ],
    );
  }
}
