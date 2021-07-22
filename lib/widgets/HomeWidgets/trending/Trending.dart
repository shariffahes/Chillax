import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class Trending extends StatelessWidget {
  final _items = [
    'https://image.tmdb.org/t/p/w500/tehpKMsls621GT9WUQie2Ft6LmP.jpg',
    'https://image.tmdb.org/t/p/w500/620hnMVLu6RSZW6a5rwO8gqpt0t.jpg',
    'https://image.tmdb.org/t/p/w500/wjQXZTlFM3PVEUmKf1sUajjygqT.jpg'
  ];

  final AutoScrollController _controller = AutoScrollController();

  void _scrollToIndex(int index) async {
    await _controller.scrollToIndex(index,
        preferPosition: AutoScrollPosition.middle);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Now Playing',
            style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
          ),
        ),
        AspectRatio(
          //dynamic
          aspectRatio: 7 / 3,
          child: ListView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) => AutoScrollTag(
              key: ValueKey(index),
              controller: _controller,
              index: index,
              child: GestureDetector(
                onHorizontalDragDown: (details) {
                  _scrollToIndex((index + 1) % _items.length);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(
                        8.0,
                      )),
                  margin: EdgeInsets.all(5),
                  //dynamic
                  height: 300,
                  //dynamic
                  width: 360,
                  //dynamic
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(_items[index], fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            itemCount: _items.length,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            icons(Icons.tv_outlined),
            icons(Icons.alarm_outlined),
            icons(Icons.movie_outlined),
            icons((Icons.person_outline)),
          ],
        )
      ],
    );
  }
}

class icons extends StatelessWidget {
  final IconData icon;

  const icons(this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 55,
          color: Colors.red,
        ),
        Text('rate'),
      ],
    );
  }
}
