import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: TextFormField(
        decoration:
            InputDecoration(labelText: 'Enter a movie, show, or book name ...'),
      ),
    );
  }
}
