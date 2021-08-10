import 'package:discuss_it/models/Global.dart';
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

class _CalendarState extends State<Calendar>
    with SingleTickerProviderStateMixin {
  DateTime today = DateTime.now();
  var isAllFilter = true;
  late DateTime currentDay;
  late List<Widget> dropMenu;
  late TabController _tabController;
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
    setState(() {
      isAllFilter = isAll;
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
      labelColor: Color.fromRGBO(172, 60, 204, 1),
      unselectedLabelColor: Colors.white,
      indicator: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(0, 0, 128, 1), width: 5),
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
      floatingActionButton: FilterButton(filterData, false),
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

class FilterButton extends StatefulWidget {
  final Function(bool) filterData;
  bool isFilterOpened;
  FilterButton(this.filterData, this.isFilterOpened);
  @override
  _FilterButtonState createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String title = Global.isMovie() ? 'All movies' : 'All shows';
  List<Widget> dropMenu = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
        reverseDuration: Duration(milliseconds: 200));
    List<ElevatedButton> dropButtons = [
      ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
          Color.fromRGBO(172, 60, 204, 1),
        )),
        onPressed: () {
          widget.filterData(true);
          _controller.reverse();
          title = Global.isMovie() ? 'All movies' : 'All shows';
        },
        child: Text(Global.isMovie() ? 'All movies' : 'All shows'),
      ),
      ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Color.fromRGBO(172, 60, 204, 1))),
        onPressed: () {
          widget.filterData(false);
          _controller.reverse();
          title = Global.isMovie() ? 'My movies' : 'My shows';
        },
        child: Text(Global.isMovie() ? 'My movies' : 'My shows'),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...dropMenu.toList(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!widget.isFilterOpened)
              ElevatedButton(
                onPressed: () {},
                child: Text(title),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromRGBO(172, 60, 204, 1))),
              ),
            IconButton(
                onPressed: () {
                  widget.isFilterOpened
                      ? _controller.reverse()
                      : _controller.forward();
                  setState(() {
                    widget.isFilterOpened = !widget.isFilterOpened;
                  });
                },
                icon: Icon(
                    widget.isFilterOpened ? Icons.close : Icons.filter_list_alt,
                    size: 40,
                    color: Color.fromRGBO(172, 60, 204, 1)))
          ],
        ),
      ],
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

        return Global.isMovie() ? MovieGrid(ids) : ShowGrid(ids, currDate);
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
              child: EpisodeList(episodes, (data as Show).network),
            )
          ],
        );
      },
      itemCount: ids.length,
    );
  }
}
