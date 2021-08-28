import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardItem extends StatelessWidget {
  final Data _data;

  CardItem(this._data);
  BorderRadius roundedBorder(double edge1, double edg2) {
    return BorderRadius.only(
      topLeft: Radius.circular(edge1),
      topRight: Radius.circular(edg2),
      bottomLeft: Radius.circular(edg2),
      bottomRight: Radius.circular(edge1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(PreviewItem.route, arguments: _data);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: roundedBorder(17, 50),
        ),
        margin: const EdgeInsets.all(10),
        elevation: 7,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: 130,
              margin: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                  color: Global.primary,
                  borderRadius: roundedBorder(22, 55)),
              child: ClipRRect(
                borderRadius: roundedBorder(22, 55),
                child: Universal.imageSource(_data.id, 0, context)
                ),
              ),
            
            Flexible(
              fit: FlexFit.tight,
              child: InfoColumn(_data),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoColumn extends StatelessWidget {
  const InfoColumn(this._data);

  final Data _data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      width: 240,
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _data.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Consumer<User>(
                    builder: (ctx, user, _) {
                      final status = user.getStatus(_data.id);

                      return Universal.createIcon(status, user, _data);
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Text(
              _data.genreToString(),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          Universal.footerContainer(_data.rate, Icons.star),
          SizedBox(
            height: 2,
          ),
          Expanded(
            child: Container(
              height: 70,
              width: 200,
              child: Text(
                _data.overview,
                style: TextStyle(
                  fontSize: 15,
                ),
                //height/17.5
                maxLines: 70 ~/ 17.5,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}
