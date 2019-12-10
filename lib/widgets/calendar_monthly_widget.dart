import 'package:flutter/material.dart';

import 'package:study_buddy/state_container.dart';
import 'package:study_buddy/data/subjects_data_constructors.dart';
import 'package:study_buddy/widgets/task_list_panels.dart';

import 'package:study_buddy/stylesheet.dart' as sty;
import 'package:study_buddy/date_time_values.dart' as dtvals;

class MonthlyCalendar extends StatefulWidget {
  @override
  State createState() => MonthlyCalendarState();
}

///TODO: replace static year with relative year
class MonthlyCalendarState extends State<MonthlyCalendar> {
  ///Values for determining current Date.
  ///Simpler than splitting and parsing a String value
  final int day = DateTime.now().day,
      month = DateTime.now().month - 1,
      year = DateTime.now().year;

  final List<_MonthGridContainer> _pages = <_MonthGridContainer>[];

  @override
  Widget build(BuildContext context) {
    var dateOffset;

    ///Calculate initial offset and create Monthly grids for current year
    ///Add to PageView children for cycling
    for (int i = 0; i < 12; i++) {
      dateOffset = dtvals.dayFromDate(day: 1, month: i, year: year);
      _pages.add(_MonthGridContainer(
        dateOffset: dateOffset,
        day: day,
        month: i,
        year: year,
      ));
    }

    return Container(
      child: PageView(
        children: _pages,
        controller: PageController(initialPage: month),
      ),
    );
  }
}

///Container for ONE Calendar Month
///   Contains
///     - Headings for current month and year display
///     - DateCell Generation
///
/// Responsible for filtering tasks for the current month and delegates indicator
/// creation further down
class _MonthGridContainer extends StatelessWidget {
  _MonthGridContainer({
    @required this.dateOffset,
    @required this.day,
    @required this.month,
    @required this.year,
  });

  final int dateOffset, day, month, year;

  ///Unclean list from 'InheritedWidget'
  static List<Subject> subjectsData = <Subject>[];

  final List<ExpansionPanelItem> currentMonthTasks = <ExpansionPanelItem>[];

  @override
  Widget build(BuildContext context) {
    ///prevent values from multiplying exponentially
    currentMonthTasks.clear();

    ///Initialize Data parent inheritance
    final inheritedWidget = StateContainer.of(context);
    subjectsData = inheritedWidget.subjectList;

    ///Parsed list
    List<_CalendarCells> calCells = <_CalendarCells>[];

    int numCells = dtvals.daysInMonth(month, year) + dateOffset;

    _sortSelectedMonthTasks();

    ///pass list of days tasks.
    for (int i = 0; i <= numCells; i++) {
      calCells.add(_CalendarCells(
          index: i,
          dateOffset: dateOffset,
          day: day,
          month: month,
          year: year,
          tasksList: currentMonthTasks));
    }

    return Container(
      child: Column(
        children: <Widget>[
          ///Headings for current month and year display
          sty.lrgText(dtvals.months[month]),
          sty.medText(year.toString()),
          Divider(),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) => _daysCol(index))),
          Divider(),

          ///Generate Date Cells
          Expanded(
            child: Container(
              child: GridView.count(
                crossAxisCount: 7,
                children: List.generate(
                  (numCells),
                  (index) => Container(
                        child: Column(
                          children: <Widget>[
                            Expanded(child: calCells[index]),
                          ],
                        ),
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///display String days
  Widget _daysCol(int index) => Column(
        children: <Widget>[sty.medText(dtvals.days[index])],
      );

  ///Filter subject data by current month deadline.
  ///Store necessary data in object array to pass to _CalCell
  _sortSelectedMonthTasks() {
    if (subjectsData != null)
      for (int i = 0; i < subjectsData.length; i++) {
        ///iterate through tasks
        if (subjectsData[i].tasks != null) {
          for (int j = 0; j < subjectsData[i].tasks.length; j++) {
            ///check if task is within current month ...
            if ((DateTime.parse(subjectsData[i].tasks[j].deadline).month - 1) ==
                month) {
              currentMonthTasks.add(ExpansionPanelItem(
                subjectName: subjectsData[i].subjectName,
                subjectIndex: i,
                taskIndex: j,
                onDay: DateTime.parse(subjectsData[i].tasks[j].deadline).day,
                attribs: Attribs(
                    color: subjectsData[i].attribs.color,
                    icon: subjectsData[i].attribs.icon),
                taskInfo: Task(
                    taskName: subjectsData[i].tasks[j].taskName,
                    deadline: subjectsData[i].tasks[j].deadline,
                    notes: subjectsData[i].tasks[j].notes,
                    status: subjectsData[i].tasks[j].status),
              ));
            }
          }
        }
      }
  }
}

/// CalendarCells returns appropriate number of Cells,
/// includes offset from start of month to match day of week
class _CalendarCells extends StatelessWidget {
  _CalendarCells(
      {@required this.index, // i
      @required this.dateOffset,
      @required this.day,
      @required this.month,
      @required this.year,
      @required this.tasksList});

  final index, dateOffset, day, month, year;
  final List<ExpansionPanelItem> tasksList;
  final List<Widget> boxes = <Widget>[];

  @override
  Widget build(BuildContext context) {
    boxes.clear();
    var displayNum = index + 1 - dateOffset;

    ///Build date Cells
    ///offset start of month with blank cells
    return (index < dateOffset) ? Card() : _calCell(displayNum, context);
  }

  ///Individual Cell
  Widget _calCell(int displayNum, BuildContext context) {
    return Card(
      ///Highlight current day
      color: _highlight(displayNum),
      child: InkWell(
        onTap: () {
          _launchTaskListPanels(displayNum, context);
          print(
              '_CalendarCells._calCell** Tapped $displayNum: ${dtvals.months[month]}');
        },
        child: Container(
          child: GridTile(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ///Day Numbers
                sty.smlText('$displayNum'),

                ///Deadline indication boxes
                _buildTaskBoxes(displayNum),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _launchTaskListPanels(int displayNum, BuildContext context) {
    List<ExpansionPanelItem> taskItemDisplay = <ExpansionPanelItem>[];

    tasksList.forEach((val) {
      if (val.onDay == displayNum)
        taskItemDisplay.add(ExpansionPanelItem(
            subjectName: val.subjectName,
            attribs: Attribs(color: val.attribs.color, icon: val.attribs.icon),
            taskIndex: val.taskIndex,
            onDay: val.onDay,
            subjectIndex: val.subjectIndex,
            taskInfo: Task(
                taskName: val.taskInfo.taskName,
                deadline: val.taskInfo.deadline,
                notes: val.taskInfo.notes,
                status: val.taskInfo.status)));
    });

    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            _TaskView(taskItemDisplay: taskItemDisplay)));
  }

  ///Iterate taskData Lists and display color coded box indicator where
  /// deadlines align to current CalendarCell
  Widget _buildTaskBoxes(int displayNum) {
    if (tasksList.length > 0) {
      tasksList.forEach((i) {
        ///If task day aligns with current cell. add box
        if (i.onDay == displayNum) {
          ///Colour coded tasks indication box within cell
          boxes.add(Container(
            width: 10.0,
            height: 10.0,
            color: i.attribs.color,
          ));
        }
      });
    }

    ///Coloured boxes list contained within date cell
    return (boxes.length > 0)
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(boxes.length, (index) => boxes[index]))
        : Row();
  }

  ///Highlight current day in red
  _highlight(int index) {
    if ((index == day) &&
        (month == DateTime.now().month - 1) &&
        (year == DateTime.now().year)) return Colors.red[200];
  }
}

///Work in progress
class _TaskView extends StatelessWidget {
  _TaskView({this.taskItemDisplay});

  final List<ExpansionPanelItem> taskItemDisplay;
  static StateContainerState inheritedWidget;

  @override
  Widget build(BuildContext context) {
    inheritedWidget = StateContainer.of(context);

    return Scaffold(
      persistentFooterButtons: <Widget>[
        (inheritedWidget.isFullVersion)
            ? Container(height: 0)
            : Container(height: 110)
      ],
      appBar: AppBar(
        leading: FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        title: Text('Due on this day'),
      ),
      body: TaskListPanels(
        countdown: false,
        taskItemDisplay: taskItemDisplay,
      ),
    );
  }
}
