import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/widgets/ListWidget/CardItem.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ListItems extends StatelessWidget {
  final List<int> _movieList;
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
              body = Universal.loadingWidget();
              break;
            case LoadStatus.failed:
              body = Universal.failedWidget();
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
        
        itemBuilder: (_, index) {
          Data data =
              DataProvider.dataDB[_movieList[index]] ?? Global.defaultData;
          return CardItem(
           data,
          );
        },
        itemCount: _movieList.length,
      ),
    );
  }
}
