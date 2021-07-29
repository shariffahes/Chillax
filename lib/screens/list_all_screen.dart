import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/widgets/ListWidget/ListItems.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/providers/Movies.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListAll extends StatelessWidget {
  static const route = "/list_all_screen";
  final _controller = RefreshController();

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Object discoverType = data['discover_type'];
    final String? genre = data['genre'] ?? null;
    final String? searchText = data['text'] ?? null;
    MovieTypes? movieType;
    TvTypes? showType;

    if (keys.isMovie())
      movieType = discoverType as MovieTypes;
    else
      showType = discoverType as TvTypes;

    DataProvider _dataProvider =
        Provider.of<DataProvider>(context, listen: false);
    List<Data> _data = _dataProvider.getDataBy(movieType, showType);

    Future<void> load() async {
      await _dataProvider.loadMore(movieType, showType, context,
          genre: genre ?? null, searchName: searchText ?? null);
      _controller.loadComplete();
    }

    Future<List<Data>> _fetchData() async {
      if (genre != null)
        return _dataProvider.fetchDataBy(genre, context);
      else
        return _dataProvider.searchFor(searchText!, context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(movieType?.toShortString() ?? showType!.toShortString()),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, 1);
          return true;
        },
        child: FutureBuilder<List<Data>>(
          future: (genre != null || searchText != null ? _fetchData() : null),
          builder: (_, snapshot) {
            if (snapshot.hasError) return Text('An error has occured :(');

            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(
                child: CircularProgressIndicator(),
              );
            //_data = !snapshot.hasData ? _data : snapshot.data!.cast<Movie>();
            return Consumer<DataProvider>(
              builder: (_, prov, __) {
                _data = prov.getDataBy(movieType, showType);

                return ListItems(_data, _controller, load);
              },
            );
          },
        ),
      ),
    );
  }
}
