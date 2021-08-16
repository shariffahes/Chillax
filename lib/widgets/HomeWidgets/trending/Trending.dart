import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class Trending extends StatefulWidget {
  MovieTypes movieType;
  TvTypes showType;
 
  Trending(this.movieType, this.showType);

  @override
  _TrendingState createState() => _TrendingState();
}

class _TrendingState extends State<Trending> {
  Map<int, List<int>> _itemsData = {
    0: [-1],
    1: [
      -1,
    ]
  };

  var ind = 0;

  final AutoScrollController _controller = AutoScrollController();

  void _scrollToIndex(int index) async {
    await _controller.scrollToIndex(index,
        preferPosition: AutoScrollPosition.middle);
    setState(() {
      ind = index;
    });
  }

  @override
  void initState() {
    super.initState();

    Object discover = Global.isMovie() ? widget.movieType : widget.showType;

    Provider.of<DataProvider>(context, listen: false)
        .fetchDataListBy(discover, context)
        .then((value) {
      setState(() {
        _itemsData[Global.dataType.index] = Global.isMovie()
            ? value.getDataBy(widget.movieType, null)
            : value.getDataBy(null, widget.showType);
      });
    });

   
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
            Global.isMovie()
                ? widget.movieType.toNormalString()
                : widget.showType.toNormalString(),
            style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
          ),
        ),
        ViewCards(
          _controller,
          _scrollToIndex,
          _itemsData[Global.dataType.index]!,
        ),
        SizedBox(
          height: 13,
        ),
        InfoRow(_itemsData[Global.dataType.index]!, ind),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final List<int> _list;
  final int ind;

  const InfoRow(
    this._list,
    this.ind,
  );

  @override
  Widget build(BuildContext context) {
    Data data = DataProvider.dataDB[_list[ind]] ?? Global.defaultData;

    var duration =
        Global.isMovie() ? (data as Movie).duration : (data as Show).runTime;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        icons(
          Icons.star_outline,
          (_list.isNotEmpty ? data.rate : '-'),
        ),
        icons(Icons.calendar_today_outlined,
            (_list.isNotEmpty ? data.yearOfRelease.toString() : '-')),
        icons(
            Icons.timer_outlined, _list.isNotEmpty ? duration.toString() : '-'),
        icons(
          Icons.language,
          (_list.isNotEmpty ? data.language : '-'),
        ),
      ],
    );
  }
}

class icons extends StatelessWidget {
  final IconData icon;
  final String value;
  const icons(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 44,
          color: Global.primary,
        ),
        Text(value),
      ],
    );
  }
}

class ViewCards extends StatelessWidget {
  final AutoScrollController _controller;
  final Function(int ind) _scrollToIndex;
  List<int> list;

  ViewCards(
    this._controller,
    this._scrollToIndex,
    this.list,
  );

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 7 / 4,
      child: ListView.builder(
        key: PageStorageKey('trending'),
        
        physics: ScrollPhysics(parent: NeverScrollableScrollPhysics()),
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          int id = list[index];
          return AutoScrollTag(
            key: ValueKey(index),
            controller: _controller,
            index: index,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(PreviewItem.route,
                    arguments: (DataProvider.dataDB[list[index]] ??
                        Global.defaultData));
              },
              onPanUpdate: (details) {
                if (details.delta.dx > 0)
                  _scrollToIndex(
                      (index - 1) == 0 ? list.length - 1 : index - 1);
                else
                  _scrollToIndex((index + 1) % list.length);
              },
              child: Consumer<PhotoProvider>(
                builder: (ctx, image, child) {
                  List<String> backdrop = [
                    Global.defaultImage,
                    Global.defaultImage
                  ];
                  if (Global.isMovie())
                    backdrop = image.getMovieImages(list[index]) ?? backdrop;
                  else {
                    backdrop = image.getShowImages(list[index]) ?? backdrop;
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(172, 60, 204, 1),
                      borderRadius: BorderRadius.circular(
                        12.0,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(backdrop[1]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    margin: const EdgeInsets.all(5),
                    height: 300,
                    width: 360,
                    child: child,
                  );
                },
                child: Text(
                  DataProvider.dataDB[id]?.name ?? '-',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    backgroundColor: Colors.white70,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: list.length,
      ),
    );
  }
}

class LoadingSkeleton extends StatefulWidget {
  final Widget child;
  LoadingSkeleton(this.child);
  @override
  _LoadingSkeletonState createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
            child: ClipRRect(
          child: AnimatedBuilder(
            animation: controller,
            builder: (ctx, child) => FractionallySizedBox(
              widthFactor: 2,
              alignment: AlignmentGeometryTween(
                      begin: Alignment(-1 - 0.2 * 3, 0),
                      end: Alignment(1.0 + 0.2 * 3, 0))
                  .chain(CurveTween(curve: Curves.easeOut))
                  .evaluate(controller)!,
              child: child,
            ),
            child: const DecoratedBox(
                decoration: const BoxDecoration(
              gradient: const LinearGradient(
                colors: const [Color.fromARGB(0, 255, 255, 255), Colors.white],
              ),
            )),
          ),
        ))
      ],
    );
  }
}
