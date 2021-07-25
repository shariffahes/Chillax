import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:flutter/material.dart';

class WatchList extends StatelessWidget {
  final Movie _movie;
  final User _userProv;
  const WatchList(this._movie, this._userProv);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            width: 170,
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.elliptical(70, 90)),
                child: Image.network(_movie.backDropURL)),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _movie.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Row(
                  children: [
                    Text(
                      'Movie',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(
                      width: 13,
                    ),
                    Icon(
                      Icons.circle,
                      size: 9,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(
                      width: 13,
                    ),
                    Text(
                      '2h',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(
                      width: 13,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _userProv.watchComplete(_movie.id);
            },
            icon: Icon(
              _userProv.isWatched(_movie.id)
                  ? Icons.check_circle_rounded
                  : Icons.check_circle_outline_rounded,
              size: 33,
            ),
          )
        ],
      ),
    );
  }
}
