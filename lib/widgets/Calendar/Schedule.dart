import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/widgets/HomeWidgets/Type/PosterList.dart';
import 'package:discuss_it/widgets/Seasons/SeasonsCard.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MyEvent extends Event {
  final date;
  final dotIndicator;
  final Map<String, Object> data;

  MyEvent(this.date, this.dotIndicator, this.data)
      : super(date: date, dot: dotIndicator);
}

class ScheduleScreen extends StatefulWidget {
  List<Map<String, Object>>? shows;
  List<int>? ids;
  Function? resetDate;
  DateTime date;
  ScheduleScreen(
    this.date, {
    this.shows,
    this.ids,
    this.resetDate,
  });

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  bool isDone = false;
  late DateTime selectedDate;
  late Animation<double> _fadeAnimation;
  late AnimationController _ac;
  Map<DateTime, List<Event>> _events = {};
  late List<Map<String, Object>> shows;
  late String title;
  @override
  void initState() {
    _ac =
        AnimationController(vsync: this, duration: Duration(milliseconds: 295));
    _fadeAnimation = CurvedAnimation(parent: _ac, curve: Curves.easeIn);
    shows = widget.shows ?? [];
    selectedDate = widget.date;
    final releasedDate = DateFormat('dd MMM').format(widget.date);

    title = widget.ids != null ? 'On theater on $releasedDate' : 'My Schedule';
    super.initState();
  }

  Widget _dotEventIndicator = Container(
    margin: EdgeInsets.symmetric(horizontal: 1.0),
    color: Colors.amber,
    height: 5.0,
    width: 5.0,
  );

  List<int> added = [];
  void dismiss({List<Map<String, Object>>? currentShows}) {
    if (currentShows != null) shows = currentShows;
    if (isExpanded) {
      _ac.reset();
      setState(() {
        isExpanded = false;
        isDone = false;
      });
    } else {
      setState(() {
        isExpanded = true;
      });
      Future.delayed(Duration(milliseconds: 360), () {
        setState(() {
          isDone = true;
        });
        _ac.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    var grid = GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Device.screenType == ScreenType.tablet ? 3 : 2,
        childAspectRatio: 3 / 5,
      ),
      itemBuilder: (ctx, ind) {
        final id = widget.ids![ind];
        Data data = DataProvider.dataDB[id]!;
        final String genre = data.genre.length >= 1 ? data.genre[0] : '-';
        return PosterItem(
            data, Universal.footerContainer(genre, Icons.movie_filter_rounded));
      },
      itemCount: widget.ids?.length,
    );

    var list = ListView.builder(
      key: PageStorageKey(0),
      itemBuilder: (ctx, index) {
        final currentShow = shows[index];
        final String showName = currentShow['title'] as String;
        final number = currentShow['number'] as int;
        final epsName = currentShow['name'] as String;
        final season = currentShow['season'] as int;
        final epsId = currentShow['epsId'] as int;
        DateTime date = DateTime.parse(currentShow['date'] as String).toLocal();

        DateFormat formatDate = DateFormat('yyyy-MM-dd');
        date = DateTime.parse(formatDate.format(date)).toLocal();
        final today =
            DateTime.parse(formatDate.format(DateTime.now())).toLocal();
        final countDown = date.difference(today).inDays;

        final id = currentShow['id'] as int;
        if (_events[date] == null) {
          _events[date] = [MyEvent(date, _dotEventIndicator, currentShow)];
          added.add(id);
        } else {
          if (!added.contains(id)) {
            _events[date]!.add(MyEvent(date, _dotEventIndicator, currentShow));
            added.add(id);
          }
        }

        return SeasonCard(
            id, epsId, season, number, showName, epsName, countDown);
      },
      itemCount: shows.length,
    );
    return Stack(
      children: [
        GestureDetector(
          onLongPress: () {
            //dismiss();
          },
          child: Container(
              margin: EdgeInsets.only(top: screenHeight * 0.14),
              child: widget.ids != null ? grid : list),
        ),
        GestureDetector(
          onVerticalDragEnd: (_) {
            dismiss();
          },
          child: AnimatedContainer(
              duration: Duration(milliseconds: 350),
              curve: Curves.fastOutSlowIn,
              width: double.infinity,
              height: (isExpanded ? screenHeight * 0.54 : screenHeight * 0.13),
              decoration: BoxDecoration(
                  color: Global.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(29),
                    bottomRight: Radius.circular(29),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: isExpanded ? Colors.black26 : Colors.transparent,
                        spreadRadius: screenHeight)
                  ]),
              child: LayoutBuilder(
                builder: (ctx, constraints) => Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top + 15),
                          child: Column(
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber),
                              ),
                              if (isDone && widget.shows != null)
                                OutlinedButton(
                                  child: Text(
                                    'Return to my schedule',
                                    style: TextStyle(color: Colors.amber),
                                  ),
                                  onPressed: () {
                                    dismiss(currentShows: widget.shows);
                                    title = 'My Schedule';
                                  },
                                )
                            ],
                          )),
                      if (isDone)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: constraints.maxHeight * 0.65,
                            child: CalendarCarousel(
                             
                              selectedDateTime: selectedDate,
                              markedDateCustomShapeBorder: CircleBorder(
                                  side: BorderSide(color: Colors.yellow)),
                              markedDatesMap: EventList(events: _events),
                              markedDateIconBorderColor: Colors.amber,
                              weekdayTextStyle: TextStyle(color: Colors.white),
                              daysTextStyle: TextStyle(color: Colors.white),
                              weekendTextStyle: TextStyle(color: Global.accent),
                              headerTextStyle:
                                  TextStyle(color: Colors.amber, fontSize: 22),
                              onDayPressed: (date, events) {
                                selectedDate = date;
                                if (widget.resetDate != null) {
                                  widget.resetDate!(date);
                                  dismiss();
                                  return;
                                }
                                final diff =
                                    date.difference(DateTime.now()).inHours;
                                final List<Map<String, Object>> data = [];
                                events.forEach((event) {
                                  data.add((event as MyEvent).data);
                                });

                                if (diff > -24 && diff <= 0) {
                                  title = 'Today';
                                } else if (diff >= 0 && diff < 24) {
                                  title = 'Tomorrow';
                                } else {
                                  title = 'Later';
                                }
                                dismiss(currentShows: data);
                              },
                            ),
                          ),
                        ),
                      Spacer(),
                      if (!isExpanded)
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.arrow_downward_outlined,
                            color: Global.accent,
                          ),
                        ),
                      if (isDone)
                        Icon(
                          Icons.arrow_upward_rounded,
                          color: Global.accent,
                        ),
                    ]),
              )),
        ),
      ],
    );
  }
}
