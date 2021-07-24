import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/widgets/Item_details.dart';
import 'package:flutter/material.dart';

class ItemList extends StatelessWidget {
  final Movie movie;
  //final Function(BuildContext ctx, Movie movie) _presentPopUp;
  ItemList(this.movie); //this._presentPopUp);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.3,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            image: NetworkImage(movie.backDropURL),
            fit: BoxFit.cover,
          ),
        ),
        child: ListTile(
          onTap: () {
            Navigator.of(context)
                .pushNamed(ItemDetails.route, arguments: movie);
          },
          onLongPress: () {
          //  _presentPopUp(context, movie);
          },
          title: Container(
            color: Colors.white60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    movie.name,
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
