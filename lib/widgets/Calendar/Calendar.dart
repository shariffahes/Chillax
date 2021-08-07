import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/widgets/Calendar/EpisodeList.dart';
import 'package:discuss_it/widgets/HomeWidgets/Type/PosterList.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with TickerProviderStateMixin {
  DateTime today = DateTime.now();
  var isAllFilter = true;
  var isFilterOpened = false;
  late DateTime currentDay;
  late List<Widget> dropMenu;
  late TabController _tabController;
  late AnimationController _controller;
  String title = keys.isMovie() ? 'All movies' : 'All shows';
  List<String> days = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  List<Widget> createWeek(DateTime selectedDate) {
    int x = 0;
    List<Widget> daysWidget = days.map((day) {
      DateTime nextDay = selectedDate.add(Duration(days: x));
      x++;
      return Container(
        height: 66,
        width: 55,
        alignment: Alignment.center,
        child: Tab(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(days[nextDay.weekday - 1]),
            SizedBox(
              height: 8,
            ),
            Text(nextDay.day.toString()),
          ]),
        ),
      );
    }).toList();
    return daysWidget;
  }

  @override
  void initState() {
    super.initState();
    currentDay = today;
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(
      () {
        setState(() {
          currentDay = today.add(Duration(days: _tabController.index));
        });
      },
    );
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    List<ElevatedButton> dropButtons = [
      ElevatedButton(
        onPressed: () {
          filterData(true);
        },
        child: Text(keys.isMovie() ? 'All movies' : 'All shows'),
      ),
      ElevatedButton(
        onPressed: () {
          filterData(false);
        },
        child: Text(keys.isMovie() ? 'My movies' : 'My shows'),
      ),
    ];
    dropMenu = dropButtons
        .map(
          (button) => Container(
            height: 50,
            width: 120,
            alignment: Alignment.topCenter,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOut,
              ),
              child: button,
            ),
          ),
        )
        .toList();
  }

  void showDate() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1999),
            lastDate: DateTime(DateTime.now().year + 1))
        .then((value) {
      if (value != null) {
        setState(() {
          currentDay = value;
          today = value;
        });
      }
    });
  }

  void filterData(bool isAll) {
    _controller.reverse();
    setState(() {
      isAllFilter = isAll;
      isFilterOpened = false;
      if (isAll)
        title = keys.isMovie() ? 'All movies' : 'All shows';
      else
        title = keys.isMovie() ? 'My movies' : 'My shows';
    });
  }

  @override
  Widget build(BuildContext context) {
    var tabBar = TabBar(
      controller: _tabController,
      isScrollable: true,
      labelPadding: EdgeInsets.only(
        bottom: 14,
      ),
      labelColor: Colors.red,
      unselectedLabelColor: Colors.white,
      indicator: BoxDecoration(
          border: Border.all(color: Colors.red, width: 5),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          color: Colors.white),
      indicatorSize: TabBarIndicatorSize.label,
      tabs: createWeek(today),
    );
    var appBarTitle =
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(DateFormat('dd MMM yyy').format(currentDay)),
      IconButton(
          onPressed: showDate,
          icon: Icon(
            Icons.arrow_drop_down,
          ))
    ]);

    var appBar = AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            today = today.subtract(Duration(days: 7));
            currentDay = today;
          });
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () {
            setState(() {
              today = today.add(Duration(days: 7));
              currentDay = today;
            });
          },
        ),
      ],
      centerTitle: true,
      title: appBarTitle,
      toolbarHeight: 140,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
      ),
      bottom: tabBar,
    );

    return Scaffold(
      appBar: appBar,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isFilterOpened) ...dropMenu.toList(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isFilterOpened)
                ElevatedButton(onPressed: () {}, child: Text(title)),
              IconButton(
                  onPressed: () {
                    isFilterOpened
                        ? _controller.reverse()
                        : _controller.forward();
                    setState(() {
                      isFilterOpened = !isFilterOpened;
                    });
                  },
                  icon: Icon(
                    isFilterOpened ? Icons.close : Icons.filter_list_alt,
                    size: 40,
                    color: Colors.red,
                  ))
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: days
            .map((_) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Item(
                    DateFormat('yyyy-MM-dd').format(currentDay),
                    isAllFilter,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class Item extends StatelessWidget {
  String currDate;
  bool isAll;
  Item(this.currDate, this.isAll);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: Provider.of<DataProvider>(
        context,
        listen: false,
      ).getScheduleFor(currDate, isAll, context),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Universal.loadingWidget();
        if (snapshot.hasError) {
          print('err: ${snapshot.error}');
          return Universal.failedWidget();
        }

        final List<int> ids = snapshot.data!;

        return keys.isMovie() ? MovieGrid(ids) : ShowGrid(ids, currDate);
      },
    );
  }
}

class MovieGrid extends StatelessWidget {
  final List<int> ids;
  const MovieGrid(this.ids);

  Widget createContainer(String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Universal.footerContainer(time, Icons.timer),
        Universal.footerContainer('Netflix', Icons.tv)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 3 / 5,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemBuilder: (ctx, ind) {
        final _data = DataProvider.dataDB[ids[ind]]!;
        String releaseDate = _data.releasedDate;

        return PosterItem(
          _data,
          createContainer(
            DateFormat().add_jm().format(DateTime.parse(releaseDate).toLocal()),
          ),
        );
      },
      itemCount: ids.length,
    );
  }
}

class ShowGrid extends StatelessWidget {
  final List<int> ids;
  final String date;
  const ShowGrid(this.ids, this.date);

  @override
  Widget build(BuildContext context) {
    final schedule = DataProvider.tvSchedule[date];
    return ListView.builder(
      itemBuilder: (ctx, index) {
        final data = DataProvider.dataDB[ids[index]]!;

        List<Episode> episodes = schedule![ids[index]]!;

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              data.name,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 350,
              child: EpisodeList(episodes),
            )
          ],
        );
      },
      itemCount: ids.length,
    );
  }
}
