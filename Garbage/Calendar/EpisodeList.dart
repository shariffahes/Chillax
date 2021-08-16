import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/widgets/HomeWidgets/Type/PosterList.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EpisodeList extends StatelessWidget {
  final List<Episode> episodes;
  final String network;
  const EpisodeList(this.episodes, this.network);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (ctx, ind) {
        return PosterItem(
            episodes[ind],
            Row(children: [
              Universal.footerContainer(
                  DateFormat()
                      .add_jm()
                      .format(DateTime.parse(episodes[ind].releasedDate)),
                  Icons.timer),
              SizedBox(
                width: 2,
              ),
              if(network != '-')
              Universal.footerContainer(network, Icons.tv)
            ]));
      },
      itemCount: episodes.length,
    );
  }
}
