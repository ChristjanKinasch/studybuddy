import 'package:flutter/material.dart';

import 'package:study_buddy/state_container.dart';
import 'package:study_buddy/data/subjects_data_constructors.dart';

import 'package:study_buddy/input_forms/task_input_screen.dart';

import 'package:study_buddy/helpers.dart' as hlp;
import 'package:study_buddy/date_time_values.dart' as dtv;
import 'package:study_buddy/stylesheet.dart' as sty;
import 'package:study_buddy/constants.dart' as Const;

class TaskListPanels extends StatefulWidget {
  TaskListPanels({this.countdown, this.notifyToUpdate, this.taskItemDisplay});

  final bool countdown;
  final Function notifyToUpdate;
  final List<ExpansionPanelItem> taskItemDisplay;

  @override
  State createState() {
    print('TaskListPanels.createState** CreatingState');
    return TaskListPanelsState(
        countdown: countdown, taskItemDisplay: taskItemDisplay);
  }
}

class TaskListPanelsState extends State<TaskListPanels> {
  TaskListPanelsState({this.countdown, this.taskItemDisplay});

  final bool countdown;
  List<ExpansionPanelItem> taskItemDisplay;
  static StateContainerState inheritedWidget;

  @override
  Widget build(BuildContext context) {
    print('TaskListPanelsState.build** Building State');

    ///Reference data set for processing within editing controls
    inheritedWidget = StateContainer.of(context);

    return (taskItemDisplay.isEmpty)
        ? Center(child: sty.lrgText(Const.EMPTY_TASK_LIST),)
        : ListView(
            children: <Widget>[
              Container(
                ///Build ExpansionPanelList; populate with 'taskItemDisplay'
                ///   List entries; received from parent via main constructor
                child: ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      taskItemDisplay[index].isExpanded = !isExpanded;
                    });
                  },
                  children: taskItemDisplay
                      .map<ExpansionPanel>((ExpansionPanelItem item) {
                    return ExpansionPanel(
                        canTapOnHeader: true,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return Row(
                            children: <Widget>[
                              _showEditPanel(item),
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(10),
                                  onTap: () => setState(
                                      () => item.isExpanded = !item.isExpanded),
                                  onLongPress: () =>
                                      setState(() => item.isEditable = true),
                                  leading: _displayLeadingDateFormat(item),
                                  title: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          (item.subjectName != null)
                                              ? Icon(item.attribs.icon)
                                              : Container(),
                                          (item.subjectName != null)
                                              ? Text(item.subjectName)
                                              : Container(),
                                        ],
                                      ),
                                      Text('${item.taskInfo.taskName}')
                                    ],
                                  ),
                                  subtitle: Text(
                                    hlp.statusList[item.taskInfo.status],
                                    style: _statusColor(item),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },

                        ///Container for extra notes, displayed upon panel expansion
                        body: ListTile(
                          subtitle: sty.medText(item.taskInfo.notes),
                        ),
                        isExpanded: item.isExpanded);
                  }).toList(),
                ),
              ),
            ],
          );
  }

  _statusColor(item) {
    if (item.taskInfo.status != 0) {
      return TextStyle(color: hlp.statusColor[item.taskInfo.status]);
    }
  }

  _displayLeadingDateFormat(ExpansionPanelItem item) {
    DateTime deadline = DateTime.parse(item.taskInfo.deadline);
    int deadlineDifference = deadline.difference(dtv.dateNow()).inDays;
    if (deadline.isAtSameMomentAs(dtv.dateNow())) {
      return Text('Due\nToday');
    }
    if (countdown) {
      if (deadline.isBefore(dtv.dateNow())) {
        deadlineDifference = deadlineDifference.abs();
        return Text('$deadlineDifference days\nago');
      }
      return Text('In $deadlineDifference\ndays');
    } else {
      return Text('${deadline.day}\n'
          '${dtv.months[deadline.month - 1].substring(0, 3)}');
    }
  }

  ///Provides extra actions for each panel
  ///   - First: Allow for editing task entry; upon selection, passes
  ///       selected item's information to 'editItem' function for processing
  ///
  ///   - Second: Allow for removal of task entry; upon selection, passes
  ///       selected item's information to 'removeItem' function for processing
  _showEditPanel(ExpansionPanelItem item) {
    return (item.isEditable)
        ? Column(
            children: <Widget>[
              FlatButton(
                child: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    item.isEditable = false;
                  });
                },
              ),
              FlatButton(
                  child: Icon(Icons.edit),
                  onPressed: () {
                    _editItem(item, context);
                  }),
              FlatButton(
                child: Icon(Icons.delete),
                onPressed: () async {
                  await _removeItem(item, context);
                  setState(() {});
                },
              ),
            ],
          )
        : Container();
  }

  ///Navigate to TaskInputScreen, and pre populates the form with the
  ///   selected task's information
  ///Values returned from TaskInputScreen are passed into the 'inheritedWidget''s
  ///   'editTask' function for processing
  _editItem(ExpansionPanelItem item, BuildContext context) async {
    inheritedWidget.editTask(
        subjectIndex: item.subjectIndex,
        taskIndex: item.taskIndex,
        taskInformation: await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TaskInputScreen(item.subjectIndex, item.taskIndex))));
  }

  ///Display a confirmation dialog before calling the 'inheritedWidget''s
  ///   'removeTask' function for processing
  ///
  _removeItem(ExpansionPanelItem item, BuildContext context) async {
    if (await hlp.confirmRemove(
        name: item.taskInfo.taskName, context: context)) {
      inheritedWidget.removeTask(
          subjectIndex: item.subjectIndex, taskIndex: item.taskIndex);
      setState(() {});
    }
    print(
        'TaskListPanelsState._removeItem**  ${item.subjectIndex} - ${item.taskIndex}'
        ' at ${taskItemDisplay.indexOf(item)} removed');
  }
}

///Object container, stores necessary information for constructing, display,
///   and processing task information
class ExpansionPanelItem {
  String subjectName;
  Attribs attribs;
  Task taskInfo;
  bool isExpanded, isEditable;
  int subjectIndex, taskIndex, onDay;

  ExpansionPanelItem(
      {this.subjectName,
      this.attribs,
      this.taskInfo,
      this.isExpanded = false,
      this.isEditable = false,
      this.subjectIndex,
      this.taskIndex,
      this.onDay});
}
