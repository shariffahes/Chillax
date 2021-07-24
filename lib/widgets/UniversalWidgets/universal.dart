import 'package:flutter/material.dart';

class Universal {
  static RoundedRectangleBorder roundedShape(double radius) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static Widget loadingWidget() {
    return Center(child: CircularProgressIndicator());
  }

  static Widget failedWidget() {
    return Center(child: Text('Failed'));
  }

  static Widget rateContainer(double rate) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.all(Radius.elliptical(90, 85))),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
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
                rate.toString(),
                style: TextStyle(
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

}
