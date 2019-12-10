import 'package:flutter/material.dart';
import 'package:study_buddy/date_time_values.dart' as dtv;

///Parent class 'Subject' comprises nested child classes.
///
/// The parent class and any subsequent child classes, each contain a means of
/// - Serializing(contained 'fromJson' factory)
/// - De-serializing(contained 'toJson' Map)
/// their respective values
class Subject {
  String subjectName;
  Attribs attribs;
  List<Task> tasks;
  LectureSchedule lectureSchedule;

  Subject({
    this.subjectName,
    this.attribs,
    this.tasks,
    this.lectureSchedule,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    var tasksList = json['tasks'] as List;

    List<Task> tasks = <Task>[];
    if (tasksList != null) {
      tasks = tasksList.map((i) => Task.fromJson(i)).toList();

      ///Check and mark 'overdue' tasks which have not been marked 'completed'
      tasks.forEach((val) => (DateTime.parse(val.deadline)
                  .isBefore(DateTime.now()) &&
              !DateTime.parse(val.deadline).isAtSameMomentAs(dtv.dateNow()) &&
              val.status != 2)
          ? val.status = 3
          : val.status = val.status);
    } else {
      tasks.add(Task(taskName: '', deadline: ''));
    }

    return Subject(
        subjectName: json['subjectName'],
        attribs: Attribs.fromJson(json['attribs']),
        tasks: tasks,
        lectureSchedule: LectureSchedule.fromJson(json['lectureSchedule']));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();

    data['subjectName'] = this.subjectName;
    if (this.attribs != null) {
      data['attribs'] = this.attribs.toJson();
    }
    if (this.tasks != null) {
      data['tasks'] = this.tasks.map((i) => i.toJson()).toList();
    }
    if (this.lectureSchedule != null) {
      data['lectureSchedule'] = this.lectureSchedule.toJson();
    }
    return data;
  }
}

class Attribs {
  IconData icon;
  Color color;

  Attribs({this.icon, this.color});

  factory Attribs.fromJson(Map<String, dynamic> json) {
    return Attribs(
      icon: _parseIcon(json['icon'].toString()),
      color: _parseColorVal(json['color'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();

    data['icon'] = this.icon.codePoint.toString();
    data['color'] = this.color.value.toString();
    return data;
  }
}

///Storing minimal values
_parseIcon(String val) => IconData(int.parse(val), fontFamily: 'MaterialIcons');

///Storing minimal values
_parseColorVal(String val) => Color(int.parse(val));

class Task {
  String taskName, deadline, notes;
  int status;

  Task({this.taskName, this.deadline, this.notes, this.status});

  Task.fromJson(Map<String, dynamic> json)
      : taskName = json['taskName'],
        deadline = json['deadline'],
        notes = json['notes'],
        status = int.parse(json['status']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['taskName'] = this.taskName;
    data['deadline'] = this.deadline;
    data['notes'] = this.notes;
    data['status'] = this.status.toString();
    return data;
  }
}

class LectureSchedule {
  String startDate, endDate;
  List<ScheduleInfo> scheduleInfo;

  LectureSchedule({this.startDate, this.endDate, this.scheduleInfo});

  factory LectureSchedule.fromJson(Map<String, dynamic> json) {
    var daysList = json['scheduleInfo'] as List;
    List<ScheduleInfo> days = <ScheduleInfo>[];

    days = daysList.map((i) => ScheduleInfo.fromJson(i)).toList();

    return LectureSchedule(
      startDate: json['startDate'],
      endDate: json['endDate'],
      scheduleInfo: days,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['startDate'] = this.startDate;
    data['endDate'] = this.endDate;
    if (this.scheduleInfo != null) {
      data['scheduleInfo'] = this.scheduleInfo.map((v) => v.toJson()).toList();
    }

    return data;
  }

  @override
  String toString() => 'Start: $startDate\nEnd: $endDate\n $scheduleInfo';
}

class ScheduleInfo {
  String day, time, location;

  ScheduleInfo({this.day, this.time, this.location});

  ScheduleInfo.fromJson(Map<String, dynamic> json)
      : day = json['day'],
        time = json['time'],
        location = json['location'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['day'] = this.day;
    data['time'] = this.time;
    data['location'] = this.location;
    return data;
  }

  @override
  String toString() => 'Day: $day - Time: $time - Location: $location';
}
