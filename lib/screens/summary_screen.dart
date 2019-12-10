import 'package:flutter/material.dart';

import 'package:study_buddy/state_container.dart';
import 'package:study_buddy/data/subjects_data_constructors.dart';

import 'package:study_buddy/widgets/task_list_panels.dart';

import 'package:study_buddy/date_time_values.dart' as dtv;

///Display upcoming tasks within the next 2 weeks(allow user defined range?).

class SummaryScreen extends StatelessWidget {
  ///Unclean list from 'InheritedWidget'
  static List<Subject> subjectsData = <Subject>[];

  ///Parsed list
  final taskItemDisplay = <ExpansionPanelItem>[];

  ///Global reference for updating data set
  static StateContainerState inheritedWidget;

  @override
  Widget build(BuildContext context) {
    ///Prevent multiplying values
    taskItemDisplay.clear();

    ///Initialize Data parent inheritance
    inheritedWidget = StateContainer.of(context);
    subjectsData = inheritedWidget.subjectList;

    ///Parse data into desired format
    buildTaskDisplay();

    return Container(
      child: TaskListPanels(countdown: true, taskItemDisplay: taskItemDisplay),
    );
  }

  ///Define date range, FUTURE: allow for user defined range?
  ///
  ///'DateTime.utc' constructor allows 'lazy overflow'.
  ///   meaning it will automatically adjust for month end dates.
  buildTaskDisplay() {
    print('SummaryScreen.buildTaskDisplay** Filtering Tasks');
    var rangeLimit = (inheritedWidget.summaryRange != null)
            ? (inheritedWidget.summaryRange * 7) + 1
            : 15,
        _dateRange = DateTime.utc(
            dtv.yearNow(), dtv.monthNow(), dtv.dayNow() + rangeLimit);
    DateTime taskDeadline;

    ///Standard null checks
    if (subjectsData != null) {
      for (int i = 0; i < subjectsData.length; i++) {
        if (subjectsData[i].tasks != null && subjectsData[i].tasks.length > 0) {
          ///Iterate tasks list
          ///   - check if task is within the max date range
          ///   If true, clean and add entry to the list
          for (int j = 0; j < subjectsData[i].tasks.length; j++) {
            ///Assigned to variable for readability in 'if conditions'
            taskDeadline = DateTime.parse(subjectsData[i].tasks[j].deadline);
            if (taskDeadline.isBefore(_dateRange) &&
                    taskDeadline.isAfter(DateTime.now()) ||
                taskDeadline.isAtSameMomentAs(dtv.dateNow()) ||
                subjectsData[i].tasks[j].status == 3) {
              taskItemDisplay.add(ExpansionPanelItem(
                  subjectName: subjectsData[i].subjectName,
                  attribs: Attribs(icon: subjectsData[i].attribs.icon),
                  taskInfo: Task(
                      taskName: subjectsData[i].tasks[j].taskName,
                      deadline: subjectsData[i].tasks[j].deadline,
                      notes: subjectsData[i].tasks[j].notes,
                      status: subjectsData[i].tasks[j].status),
                  isExpanded: false,
                  subjectIndex: i,
                  taskIndex: j));
            }
          }
        }
      }
    }

    ///Order list ascending, assign to object list
    taskItemDisplay
        .sort((a, b) => a.taskInfo.deadline.compareTo(b.taskInfo.deadline));
  }
}
