import 'package:discuss_it/models/providers/Movies.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>
    with SingleTickerProviderStateMixin {
  DateTime today = DateTime.now();
  late DateTime currentDay;
  late TabController _tabController;

  List<Widget> createWeek(DateTime selectedDate) {
    List<String> days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(DateFormat('dd MMM yyyy').format(currentDay)),
          IconButton(
              onPressed: () {
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
              },
              icon: Icon(
                Icons.arrow_drop_down,
              ))
        ]),
        toolbarHeight: 120,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
        ),
        bottom: TabBar(
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
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TimeLine(),
          Text('data'),
          Text('test'),
          Text('data'),
          Text('test'),
          Text('data'),
          Text('test'),
        ],
      ),
    );
  }
}

class TimeLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text('7:00'),
                Container(
                  height: 4 * 110,
                  child: VerticalDivider(
                    thickness: 3,
                    color: Colors.red,
                  ),
                ),
                Text('7:00'),
                Container(
                  height: 4 * 110,
                  child: VerticalDivider(
                    thickness: 3,
                    color: Colors.red,
                  ),
                )
              ],
            ),
            Column(
              children: [
                Card(
                  color: Colors.black,
                  child: Container(
                    height: 100,
                    width: 60,
                  ),
                ),
                Card(
                  color: Colors.black,
                  child: Container(
                    height: 100,
                    width: 60,
                  ),
                ),
                Card(
                  color: Colors.black,
                  child: Container(
                    height: 100,
                    width: 60,
                  ),
                ),
                Card(
                  color: Colors.black,
                  child: Container(
                    height: 100,
                    width: 60,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
