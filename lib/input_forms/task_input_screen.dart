import 'package:flutter/material.dart';

import 'package:study_buddy/state_container.dart';

import 'package:study_buddy/data/subjects_data_constructors.dart';
import 'package:study_buddy/widgets/date_time_selectors.dart';
import 'package:study_buddy/input_forms/task_form_data.dart';

import 'package:study_buddy/helpers.dart' as hlp;
import 'package:study_buddy/stylesheet.dart' as sty;
import 'package:study_buddy/date_time_values.dart' as dtv;

class TaskInputScreen extends StatelessWidget {
  final int subjectIndex, taskIndex;

  TaskInputScreen([this.subjectIndex, this.taskIndex]);

  static StateContainerState inheritedWidget;

  @override
  Widget build(BuildContext context) {
    inheritedWidget = StateContainer.of(context);


    return Scaffold(
        appBar: AppBar(
          title: sty.smlText('Add a Task'),
        ),
        body: Container(
          child: TaskInputForm(subjectIndex, taskIndex, context),
        ));
  }
}

class TaskInputForm extends StatefulWidget {
  ///Retrieving correct entries when an EDIT request is sent
  final int subjectIndex, taskIndex;
  final BuildContext context;

  TaskInputForm([this.subjectIndex, this.taskIndex, this.context]);

  static var inheritedWidget;

  ///TaskFormData contains
  ///   - Variables to store input data
  ///   - Void function to populate variables with selected task information
  final TaskFormData populatedFormData = TaskFormData();
  final TaskFormData blankFormData = TaskFormData();

  ///Null checks instance variables
  ///Used to either
  ///   - Pre populate the form with the selected entry's information for editing
  ///   OR
  ///   - Initialize a blank form for a creating a new entry
  @override
  State createState() => (subjectIndex == null && taskIndex == null)
      ? blankForm()
      : populatedForm();

  populatedForm() {
    print('TaskInputForm.populatedForm** Populating form values');
    inheritedWidget = StateContainer.of(context);

    return TaskInputFormState(
        subjectIndex: subjectIndex,
        taskIndex: taskIndex,
        fdata: populatedFormData
          ..populateFields(
              inheritedWidget.subjectList[subjectIndex].tasks[taskIndex]));
  }

  blankForm() {
    print('TaskInputForm.blankForm** Initializing empty form');
    return TaskInputFormState(
        subjectIndex: subjectIndex, taskIndex: taskIndex, fdata: blankFormData);
  }
}

class TaskInputFormState extends State<TaskInputForm> {
  final int subjectIndex, taskIndex;
  final TaskFormData fdata;

  TaskInputFormState({this.subjectIndex, this.taskIndex, this.fdata});

  static DateTimeSelectors _dtselect;

  static StateContainerState inheritedWidget;

  ///Relevant form state ('fdata') is initialized and passed from parent via constructor
  ///   - 'fdata' holds input values
  ///
  ///Upon form submission; values stored within 'fdata' are checked in the
  ///   'validateInput' function.
  ///Invalid input will trigger a dialog, which describes the nature of the error
  ///to the user
  ///
  ///A successful validation triggers 'structTaskInformation' which converts 'fdata'
  ///values into an object instance; which is then returned to parent, triggering
  ///a 'write values to disk' event.
  @override
  Widget build(BuildContext context) {
    inheritedWidget = StateContainer.of(context);
    _dtselect = DateTimeSelectors(context: context);
    if (!inheritedWidget.isFullVersion) {
      if (inheritedWidget.adManager.isLoaded) {
        inheritedWidget.hideBanner();
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      child: Container(
        child: Column(
          children: <Widget>[
            ///Input field for Task Name
            TextField(
                controller: fdata.taskCont,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Task Name...',
                )),
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  color: Theme.of(context).highlightColor,
                  child: sty.medText((fdata.deadline == null)
                      ? 'Deadline'
                      : dtv.dateTimeFormatted(fdata.deadline)),
                  onPressed: () async {
                    fdata.deadline =
                        await _dtselect.selectDate(defaultDate: fdata.deadline);
                    setState(() {});
                  },
                ),

                ///Allow for updating the tasks status
                _dropDownStatusSelect(),
              ],
            ),

            ///DatePicker field for deadline
            Padding(padding: EdgeInsets.symmetric(vertical: 10)),

            ///Input field for Additional Notes
            Expanded(
              child: TextField(
                  maxLines: null,
                  maxLength: 150,
                  minLines: 3,
                  controller: fdata.notesCont,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Task notes...',
                  )),
            ),

            ///Submit button
            RaisedButton(
              onPressed: () {
                _validateInput();
              },
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }

  ///Allow for updating the tasks status
  _dropDownStatusSelect() {
    return DropdownButton<String>(
      items: hlp.statusList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          child: Text(value),
          value: value,
        );
      }).toList(),
      onChanged: (String newValue) {
        setState(() {
          fdata.status = hlp.statusList.indexOf(newValue);
        });
      },
      hint: Text(hlp.statusList[fdata.status]),
    );
  }

  ///Checking for valid input contained within member variables
  ///   'gucci' is set to false if any input is not valid
  ///
  ///     !gucci
  ///       - Display dialogue with error message
  ///
  ///     gucci
  ///       - Construct and return Task object
  _validateInput() {
    String errortitle = 'Please complete the following fields:';
    String errormsg = '';
    bool gucci = true;

    ///Standard Null or Empty check
    if (fdata.taskCont.text == '' || fdata.taskCont.text == null) {
      gucci = false;
      errormsg += '- Task Name\n';
    } else {
      fdata.taskName = fdata.taskCont.text;
    }

    ///Standard Null or Empty check
    if (fdata.notesCont.text == '' || fdata.notesCont.text == null) {
      fdata.notes = '';
    } else {
      fdata.notes = fdata.notesCont.text;
    }

    ///Standard Null or Empty check
    if (fdata.deadline == null) {
      gucci = false;
      errormsg += '- Deadline';
    }

    ///If validation checks are successful; return the 'taskInformation' to
    ///   parent for processing
    ///
    ///If validation checks are UNsuccessful; display dialog with error message
    (gucci)
        ? print('TaskInputFormState._validateInput** Validation Success')
        : print('TaskInputFormState._validateInput** Validation Error');
    (gucci)
        ? Navigator.pop(context, _structTaskInformation())
        : showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: sty.medText(errortitle),
                content: sty.smlText(errormsg),
                actions: <Widget>[
                  FlatButton(
                    child: sty.medText('Okay'),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              );
            });
  }

  ///Retrieve values from 'fdata' variables
  ///Create and return an instance of Task to parent screen
  _structTaskInformation() {
    print(fdata.deadline);
    fdata.deadline = DateTime.utc(
        fdata.deadline.year, fdata.deadline.month, fdata.deadline.day);
    return Task(
        taskName: fdata.taskName,
        deadline: fdata.deadline.toString(),
        notes: fdata.notes,
        status: fdata.status);
  }
}
