import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/widgets/Seasons/SeasonsCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

class ScheduleScreen extends StatefulWidget {
  ScheduleScreen({Key? key}) : super(key: key);

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  bool isDone = false;
  late Animation<double> _fadeAnimation;
  late AnimationController _ac;

  @override
  void initState() {
    _ac =
        AnimationController(vsync: this, duration: Duration(milliseconds: 295));
    _fadeAnimation = CurvedAnimation(parent: _ac, curve: Curves.easeIn);
    super.initState();
  }

  String title = 'My Schedule';
  void dismiss() {
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

    return Stack(
      children: [
        GestureDetector(
          onLongPress: () {
            print('object');
            dismiss();
          },
          child: Container(
              margin: EdgeInsets.only(top: screenHeight * 0.1),
              child: SeasonsView()),
        ),
        GestureDetector(
          onVerticalDragEnd: (_) {
            dismiss();
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 350),
            curve: Curves.fastOutSlowIn,
            width: double.infinity,
            height: (isExpanded ? screenHeight * 0.52 : screenHeight * 0.10),
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
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20),
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber),
                ),
              ),
              if (isDone)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: screenHeight * 0.4,
                    child: CalendarCarousel(
                      weekdayTextStyle: TextStyle(color: Colors.white),
                      daysTextStyle: TextStyle(color: Colors.white),
                      weekendTextStyle: TextStyle(color: Global.accent),
                      headerTextStyle:
                          TextStyle(color: Colors.amber, fontSize: 22),
                      onDayPressed: (date, _) {
                        final diff = date.day - DateTime.now().day;
                        print(diff);
                        if (diff == 0) {
                          title = 'Today';
                        } else if (diff >= 1 && diff < 2) {
                          title = 'Tomorrow';
                        } else {
                          title = 'Later';
                        }
                        dismiss();
                      },
                    ),
                  ),
                ),
              if (!isExpanded)
                Padding(
                  padding: const EdgeInsets.all(5.0),
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
          ),
        ),
      ],
    );
  }
}
