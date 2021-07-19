import 'package:discuss_it/widgets/Item_list.dart';
import 'package:flutter/material.dart';

class ListAll extends StatelessWidget {
  static const route = "/list_all_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('list'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemBuilder: (ctx, index) => ItemList(7/5),
        itemCount: 10,
      ),
    );
  }
}
