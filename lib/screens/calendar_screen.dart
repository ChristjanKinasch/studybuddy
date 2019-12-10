import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:study_buddy/widgets/calendar_monthly_widget.dart';
import 'package:study_buddy/widgets/calendar_weekly_widget.dart';

///Contains 'PageView' comprising of 'WeeklyCalendarWidget', and
///'MonthlyCalendarWidget'; allowing simple transition between via
///vertical swipe

class CalendarScreen extends StatefulWidget {
  @override
  State createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  final PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      scrollDirection: Axis.vertical,
      children: <Widget>[_weekly(), _monthly()],
    );
  }

  _weekly() => Column(
        children: <Widget>[
          Expanded(child: WeeklyCalendar()),

          ///Indicator of afforded gesture
          Listener(
            onPointerUp: (opm) => turnPage(1),
            child: Container(
              width: double.infinity,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 30,
              ),
            ),
          ),
        ],
      );

  _monthly() {
    ///TODO: implement direction capture and decision based on average
//    List<double> dy = <double>[];
    return Column(
      children: <Widget>[
        ///Indicator of afforded gesture
        Listener(
          onPointerUp: (opm) => turnPage(0),
          child: Container(
//            color: Colors.blueGrey,
            width: double.infinity,
            child: Icon(
              Icons.keyboard_arrow_up,
              size: 30,
            ),
          ),
        ),

        Expanded(
            child: Listener(
                onPointerMove: (opm) {
//                  dy.add(opm.delta.dy);
//                  print('$TAG DY:${dy.length}');
                  if (opm.delta.dy > 10) turnPage(0);
                },
                child: MonthlyCalendar())),
      ],
    );
  }

  turnPage(int pageNum) {
    controller.animateToPage(pageNum,
        duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
  }
}
