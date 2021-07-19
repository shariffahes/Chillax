import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/widgets/Item_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListAll extends StatelessWidget {
  static const route = "/list_all_screen";

  @override
  Widget build(BuildContext context) {
    final type = ModalRoute.of(context)!.settings;
    MovieProvider _movieProvider =
        Provider.of<MovieProvider>(context, listen: false);
        
    return Scaffold(
      appBar: AppBar(
        title: Text('list'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemBuilder: (ctx, index) => Center(
          child: Image.asset('assets/images/logo.png'),
        ),
        //ItemList(7/5),
        itemCount: 10,
      ),
    );
  }
}
