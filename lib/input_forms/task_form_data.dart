import 'package:flutter/material.dart';
import 'package:study_buddy/data/subjects_data_constructors.dart';

class TaskFormData {
  ///Called when parent form is in 'edit' mode, variables are initialized
  ///   to display default values to be edited
  void populateFields(Task task) {
    print('TaskFormData.populateFields** ');
    taskName = task.taskName;
    taskCont = TextEditingController(text: taskName);

    deadline = DateTime.parse(task.deadline);

    notes = task.notes;
    notesCont = TextEditingController(text: notes);

    status = task.status;
  }

  String taskName;
  TextEditingController taskCont = TextEditingController();

  DateTime deadline;

  String notes;
  TextEditingController notesCont = TextEditingController();

  int status = 0;
}
