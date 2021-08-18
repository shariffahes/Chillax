import 'package:discuss_it/widgets/Seasons/SeasonsCard.dart';
import 'package:flutter/material.dart';


class EpisodePreview extends StatelessWidget {
  const EpisodePreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // SeasonCard(
            //     'https://heroichollywood.com/wp-content/uploads/2019/01/Titans-DC-Universe-Banner-1280x720.jpg'),
          ],
        ),
      ),
    );
  }
}
