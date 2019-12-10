import 'package:flutter/material.dart';
import 'package:study_buddy/date_time_values.dart' as dtv;
import 'package:study_buddy/stylesheet.dart' as sty;
import 'package:study_buddy/data/subjects_data_constructors.dart';
import 'package:study_buddy/state_container.dart';

class WeeklyCalendar extends StatefulWidget {
  @override
  State createState() => WeeklyCalendarState();
}

class WeeklyCalendarState extends State<WeeklyCalendar> {
  final List<Subject> active = <Subject>[];
  static List<Subject> subjectsData = <Subject>[];
  static DateTime startOfWeek;
  static StateContainerState inheritedWidget;

  @override
  Widget build(BuildContext context) {
    active.clear();
    inheritedWidget = StateContainer.of(context);
    subjectsData = inheritedWidget.subjectList;

    _filterCurrentLectures();

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
              ///Vertical Display Sun->Sat
              children: List.generate(7, (index) => _daysOfWeekCol(index))),
          Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:

                    ///Construct 'lectureCells' day by day
                    List.generate(7, (index) => _scheduleContainerCol(index))),
          ),
        ],
      ),
    );
  }

  ///Check DateTime values for 'startDate' and 'endDate'; Store 'active' subjects
  ///   within 'active' List for further processing
  _filterCurrentLectures() {
    print('WeeklyCalendar._filterCurrentLectures** Filtering active lectures');
    if (subjectsData != null)
      for (int i = 0; i < subjectsData.length; i++) {
        if (DateTime.now().isAfter(
                DateTime.parse(subjectsData[i].lectureSchedule.startDate)) &&
            DateTime.now().isBefore(
                DateTime.parse(subjectsData[i].lectureSchedule.endDate)))
          active.add(subjectsData[i]);
      }
  }

  ///Vertical Display Sun->Sat
  Widget _daysOfWeekCol(int index) => Expanded(
        child: Card(
          child: Container(width: 60,alignment: Alignment(0, 0),
            child: sty.medText(dtv.days[index]),
          ),
        ),
      );

  ///Retrieve and store values only if the 'day' matches the current
  ///   parent iteration
  ///
  /// LectureEntryCellInfo list is REconstructed every iteration; allowing for
  ///     the lectures to be ordered by 'timeFrame'
  ///
  /// Finally; the ordered list of 'lectureCells', is iterated over, the values
  ///     of each entry are used to construct and return a 'lectureDisplayCell'
  ///     widget.
  _scheduleContainerCol(int index) {
    List<Widget> dailySchedule = <Widget>[];
    List<LectureEntryCellInfo> lectureCells = <LectureEntryCellInfo>[];
    for (int i = 0; i < active.length; i++) {
      for (int j = 0; j < active[i].lectureSchedule.scheduleInfo.length; j++) {
        if (int.parse(active[i].lectureSchedule.scheduleInfo[j].day) == index) {
          lectureCells.add(LectureEntryCellInfo(
              subjectName: active[i].subjectName,
              color: active[i].attribs.color,
              timeFrame: active[i].lectureSchedule.scheduleInfo[j].time,
              location: active[i].lectureSchedule.scheduleInfo[j].location));
        }
      }
    }

    ///Order daily list by timeFrame asc
    print('WeeklyCalendar._scheduleContainerCol** Building ${dtv.days[index]}');
    lectureCells..sort((a, b) => a.timeFrame.compareTo(b.timeFrame));

    ///Filter and re assign time frames if user preference is set to '12hour time'
    if (inheritedWidget.timeFormat == 0) {
      _filter(String val) {
        var a = int.parse(val.substring(0, 2)),
            b = int.parse(val.substring(3, 5)),
            am = true;
        if (a >= 12) {
          a = a -= 12;
          am = false;
        }
        if (a == 0) a = 12;

        return '$a${(b < 10) ? (b == 0) ? '' : ':0$b' : ':$b'}${(am) ? 'am' : 'pm'}';
      }

      lectureCells.forEach(
          (val) => val.timeFrame = '${_filter(val.timeFrame.substring(0, 5))}'
              '-${_filter(val.timeFrame.substring(6, 11))}');
    }

    ///Construct 'displayCells'
    for (int i = 0; i < lectureCells.length; i++) {
      dailySchedule.add(_lectureDisplayCell(
          lectureCells[i].color,
          lectureCells[i].subjectName,
          lectureCells[i].timeFrame,
          lectureCells[i].location));
    }

    ///Populate 'day' row with lectureDisplayCells
    return Expanded(
      child: Container(
          child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                if (dailySchedule.length > 0) return dailySchedule[index];
              },
              scrollDirection: Axis.horizontal,
              itemCount: dailySchedule.length)),
    );
  }

  ///Lecture information cell container
  _lectureDisplayCell(
      Color color, String subjectName, String timeFrame, String location) {
    return Card(
      child: Row(
        children: <Widget>[
          Container(
            width: 15,
            color: color,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(child: sty.smlText(
                '${subjectName.substring(0, (subjectName.length > 5) ? 5 : subjectName.length)}'
                    '\n$timeFrame\n$location'),),
          ),
          Container(
            width: 15,
            color: color,
          ),
        ],
      ),
    );
  }
}

class LectureEntryCellInfo {
  String subjectName, timeFrame, location;
  Color color;

  LectureEntryCellInfo(
      {this.subjectName, this.timeFrame, this.location, this.color});
}
