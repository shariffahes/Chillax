import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
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
  var isAllFilter = false;
  late DateTime currentDay;

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

  void filterData() {
    setState(() {
      isAllFilter = !isAllFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = keys.isMovie()
        ? (isAllFilter ? 'All movies' : 'My movies')
        : (isAllFilter ? 'All shows' : 'My shows');

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
      floatingActionButton: ElevatedButton.icon(
        label: Text(title),
        onPressed: filterData,
        icon: Icon(Icons.arrow_drop_down),
      ),
      body: TabBarView(
        controller: _tabController,
        children: days
            .map((e) => Padding(
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
    return FutureBuilder<List<Data>>(
      future: Provider.of<DataProvider>(
        context,
        listen: false,
      ).getScheduleFor(currDate, isAll, context),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Universal.loadingWidget();
        if (snapshot.hasError) return Universal.failedWidget();

        final _data = snapshot.data!;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 3 / 5,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          itemBuilder: (ctx, ind) => _data.isEmpty
              ? Center(
                  child: Text('No new movies today'),
                )
              : PosterItem(
                  _data[ind],
                  createContainer(DateFormat().add_jm().format(
                      DateTime.parse(_data[ind].releasedDate).toLocal()))),
          itemCount: _data.length,
        );
      },
    );
  }
}
