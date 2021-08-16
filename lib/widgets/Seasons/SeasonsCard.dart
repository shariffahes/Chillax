import 'package:discuss_it/widgets/Seasons/ShowEpisodes.dart';
import 'package:flutter/material.dart';


class SeasonsView extends StatelessWidget {
  SeasonsView({Key? key}) : super(key: key);
  List<String> url = [
    'https://m.media-amazon.com/images/M/MV5BZTRhNzg0ZTgtZmMyYy00Yjc5LTkyNTAtNzEzODIyZDE5NTNmXkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_FMjpg_UX1000_.jpg',
    'https://www.dccomics.com/sites/default/files/field/image/TitansS2_blog_5d5c3b184956c0.38671675.jpg',
    'https://m.media-amazon.com/images/M/MV5BZTRhNzg0ZTgtZmMyYy00Yjc5LTkyNTAtNzEzODIyZDE5NTNmXkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_FMjpg_UX1000_.jpg',
    'https://www.dccomics.com/sites/default/files/field/image/TitansS2_blog_5d5c3b184956c0.38671675.jpg',
    'https://m.media-amazon.com/images/M/MV5BZTRhNzg0ZTgtZmMyYy00Yjc5LTkyNTAtNzEzODIyZDE5NTNmXkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_FMjpg_UX1000_.jpg',
    'https://www.dccomics.com/sites/default/files/field/image/TitansS2_blog_5d5c3b184956c0.38671675.jpg',
  ];
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: url
          .map(
            (e) => GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context, builder: (ctx) => EpisodePreview());
                },
                child: SeasonCard(e)),
          )
          .toList(),
    );
  }
}

class SeasonCard extends StatelessWidget {
  const SeasonCard(this.url);
  final String url;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      height: 110,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            blurRadius: 4,
            spreadRadius: 1,
            color: Colors.grey.shade400,
            offset: Offset(0, 2)),
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 110,
            margin: const EdgeInsets.only(right: 12),
            child: Image.network(
              url,
              fit: BoxFit.cover,
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Season 1',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Text('Rate 9.0'),
                Text('2020'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
