import 'package:flutter/material.dart';

import 'package:study_buddy/state_container.dart';

import 'package:study_buddy/data/subjects_data_constructors.dart';
import 'package:study_buddy/widgets/task_list_panels.dart';
import 'package:study_buddy/input_forms/task_input_screen.dart';
import 'package:study_buddy/input_forms/subject_input_screen.dart';

import 'package:study_buddy/helpers.dart' as hlp;
import 'package:study_buddy/stylesheet.dart' as sty;

class SubjectInformationScreen extends StatelessWidget {
  SubjectInformationScreen({this.subjectIndex});

  final subjectIndex;
  static List<Subject> subjectsData;
  static List<ExpansionPanelItem> taskItemDisplay = <ExpansionPanelItem>[];

  ///Global reference for updating data set
  static BuildContext _context;
  static StateContainerState inheritedWidget;

  static List<String> dropDownMenuItems = [
    'Edit Subject',
    'Delete Subject',
//    'Edit / Remove Tasks'
  ];

  @override
  Widget build(BuildContext context) {
    print('SubjectInformationScreenState.build** Building State');

    taskItemDisplay.clear();

    ///Initialize Data parent inheritance
    inheritedWidget = StateContainer.of(context);
    _context = context;

    subjectsData = inheritedWidget.subjectList;

    buildTaskDisplay();
    return Scaffold(
        persistentFooterButtons: <Widget>[
          (inheritedWidget.isFullVersion)
              ? Container(
                  height: 0,
                )
              : Container(
                  height: 110,
                )
        ],
        appBar: AppBar(
          title: Text('${subjectsData[subjectIndex].subjectName}'),
          actions: <Widget>[_showPopupMenu()],
        ),
        body: Column(
          children: <Widget>[
            Expanded(

                ///Child 'ExpansionPanelList' widget
                child: TaskListPanels(
              countdown: false,
//              notifyToUpdate: notifyChildToUpdate,
              taskItemDisplay: taskItemDisplay,
            )),
            RaisedButton(
              onPressed: () {
                _launchTaskInputForm();
              },
              child: sty.lrgText('+'),
            ),
          ],
        ));
  }

  ///Parse all tasks for selected subject and format for display
  ///include position within subject tasks object for reference in editing
  buildTaskDisplay() {
    if (subjectsData != null &&
        subjectsData[subjectIndex].tasks != null &&
        subjectsData[subjectIndex].tasks.length > 0) {
      for (int i = 0; i < subjectsData[subjectIndex].tasks.length; i++) {
        taskItemDisplay.add(ExpansionPanelItem(
            taskInfo: Task(
                taskName: subjectsData[subjectIndex].tasks[i].taskName,
                deadline: subjectsData[subjectIndex].tasks[i].deadline,
                notes: subjectsData[subjectIndex].tasks[i].notes,
                status: subjectsData[subjectIndex].tasks[i].status),
            subjectIndex: subjectIndex,
            taskIndex: i));
      }
    }

    hlp.sortListByDate(taskItemDisplay);
  }

  ///Options menu declaration: see 'dropDownMenuItems' list
  _showPopupMenu() {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        return dropDownMenuItems.map((String value) {
          return PopupMenuItem<String>(value: value, child: Text(value));
        }).toList();
      },
      onSelected: _selectionAction,
    );
  }

  ///Handle user's selection from within the 'PopupMenu'
  _selectionAction(String args) async {
    if (args == dropDownMenuItems[0]) {
      _launchSubjectInputForm();
    } else if (args == dropDownMenuItems[1]) {
      if (await hlp.confirmRemove(
          name: subjectsData[subjectIndex].subjectName, context: _context)) {
        inheritedWidget.removeSubject(subjectIndex: subjectIndex);
        Navigator.pop(_context);
      }
    }
    /* else if (args == dropDownMenuItems[2]) {
      notifyChildToUpdate();
    }*/
  }

/*  ///Update values within the child's data set and notify it to 'Build State'
  notifyChildToUpdate() {
    setState(() {
      taskItemDisplay.forEach((val) {
        val.isEditable = !val.isEditable;
      });
    });
  }*/

  ///Launch 'SubjectInputScreen()' with 'subjectIndex' to pre populate form;
  /// await return value; write to disk
  void _launchSubjectInputForm() async {
    final item = await Navigator.push(
        _context,
        MaterialPageRoute(
            builder: (context) => SubjectInputScreen(
                  subjectIndex: subjectIndex,
                  subjectName: subjectsData[subjectIndex].subjectName,
                )));

    if (item != null)
      inheritedWidget.editSubject(subjectIndex: subjectIndex, subject: item);
  }

  ///Launch 'TaskInputScreen()'; await return value; write to disk
  void _launchTaskInputForm() async {
    final item = await Navigator.push(
      _context,
      MaterialPageRoute(builder: (context) => TaskInputScreen()),
    );
    if (item != null)
      _updateSubjectList(subjectsData[subjectIndex]..tasks.add(item));
  }

  _updateSubjectList(Subject item) {
    List<Subject> values = inheritedWidget.subjectList;
    List<Subject> theList = <Subject>[];

    ///Replace selected 'Subject' in the structure and rewrite to disk
    values
      ..removeAt(subjectIndex)
      ..insert(subjectIndex, item)
      ..forEach((v) => theList.add(v));

    try {
      print(
          'SubjectInformationScreenState._updateSubjectList** Updating Subject List');
      inheritedWidget.updateSubjectList(subjectListIn: theList);
    } catch (e) {
      print('SubjectInformationScreenState._updateSubjectList** $e');
    }
  }
}
