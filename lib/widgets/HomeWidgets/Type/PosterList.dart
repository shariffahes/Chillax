import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:discuss_it/widgets/Item_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PosterList extends StatefulWidget {
  final List<Movie> _items;

  PosterList(this._items);

  @override
  _PosterListState createState() => _PosterListState();
}

class _PosterListState extends State<PosterList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: widget._items
          .map(
            (movie) => Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(ItemDetails.route, arguments: movie);
                    },
                    child: Container(
                      height: 230,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: FadeInImage(
                              placeholder: AssetImage('assets/images/logo.png'),
                              image: NetworkImage(
                                movie.posterURL,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          IconButton(
                              alignment: AlignmentDirectional.topStart,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Provider.of<User>(context, listen: false)
                                    .addToWatchList(movie);
                              },
                              icon: Icon(
                                Icons.add_circle_rounded,
                                size: 35,
                                color: Colors.amber,
                              ))
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 140,
                    padding: const EdgeInsets.only(top: 10, bottom: 2),
                    child: Text(
                      movie.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius:
                                  BorderRadius.all(Radius.elliptical(90, 85))),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                "${movie.rate}",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              )
                            ],
                          )),
                    ],
                  )
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
