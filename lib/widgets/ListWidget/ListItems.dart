import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/widgets/ListWidget/CardItem.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ListItems extends StatelessWidget {
  final List<Movie> _movieList;
  final RefreshController _controller;
  final void Function() load;

  ListItems(this._movieList, this._controller, this.load);

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: false,
      footer: CustomFooter(
        builder: (_, state) {
          Widget body;
          switch (state) {
            case LoadStatus.idle:
              body = Icon(Icons.arrow_upward);
              break;
            case LoadStatus.loading:
              body = CircularProgressIndicator();
              break;
            case LoadStatus.failed:
              body = Text('Failed');
              break;
            default:
              body = Icon(Icons.refresh);
              break;
          }
          return Center(
            child: body,
          );
        },
      ),
      enablePullUp: true,
      controller: _controller,
      onLoading: load,
      child: ListView.builder(
        itemBuilder: (_, index) => CardItem(
          _movieList[index],
        ),
        itemCount: _movieList.length,
      ),
    );
  }
}
