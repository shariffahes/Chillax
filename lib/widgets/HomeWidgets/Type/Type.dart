import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import '../../../models/Enums.dart';
import '../../../models/providers/Movies.dart';
import '../../../screens/list_all_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Type/PosterList.dart';

class Type extends StatelessWidget {
  final MovieTypes? movieType;
  final TvTypes? showType;

  Type(
    this.movieType,
    this.showType,
  );

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            alignment: AlignmentDirectional.topStart,
            child: Text(
              movieType?.toNormalString() ?? showType!.toNormalString(),
              style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                ListAll.route,
                arguments: {
                  'discover_type': showType ?? movieType,
                },
              );
            },
            child: Text('View all',style: TextStyle(color: Color.fromRGBO(172, 60, 204, 1)),),
          ),
        ],
      ),
      FutureBuilder<DataProvider>(
        future: Provider.of<DataProvider>(context, listen: false)
            .fetchDataListBy(movieType ?? showType!, context),
        builder: (_, snapshot) {
          if (snapshot.hasError)
            //replace by somthing better

            return Universal.failedWidget();
          if (snapshot.connectionState == ConnectionState.waiting)
            return Universal.loadingWidget();
          List<int> _data = snapshot.data!.getDataBy(movieType, showType);

          return Container(
            height: 340,
            child: PosterList(_data),
          );
        },
      ),
    ]);
  }
}
