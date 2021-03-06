import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/Enums.dart';
import '../../../models/providers/Movies.dart';
import '../../../screens/list_all_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Type/PosterList.dart';

class Type extends StatelessWidget {
  final MovieTypes? movieType;
  final TvTypes? showType;
  final int k;
  Type(
    this.movieType,
    this.showType,
    this.k
  );

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            alignment: AlignmentDirectional.topStart,
            child: Text(
              movieType?.toNormalString().capitalize() ??
                  showType!.toNormalString().capitalize(),
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
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
            child: Text(
              'View all',
              style: TextStyle(color: Global.primary),
            ),
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
            height: 40.h,
            child: PosterList(_data,k),
          );
        },
      ),
    ]);
  }
}
