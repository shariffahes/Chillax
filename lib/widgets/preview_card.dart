import 'package:flutter/material.dart';

class PreviewCard extends StatelessWidget {
  final String title;
  final IconData symbol;
  const PreviewCard(this.title, this.symbol);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        color: Colors.orange,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                title,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w300,fontSize: 44),
              ),
            ),
            SizedBox(width: 15,),
            Icon(symbol,size: 180,color: Colors.white,),
          ],
        ));
  }
}
