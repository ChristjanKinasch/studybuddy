import 'package:flutter/material.dart';
import 'package:study_buddy/input_forms/subject_input_screen.dart';
import 'package:study_buddy/data/subjects_data_constructors.dart';
import 'package:study_buddy/date_time_values.dart' as dtv;

class SubjectFormData {
  ///Called when parent form is in 'edit' mode, variables are initialized
  ///   to display default values to be edited
  void populateFields(Subject subjectData) {
    print('SubjectFormData.populateFields**');

    var scheduleInfo = subjectData.lectureSchedule.scheduleInfo;

    ///SubjectName
    subjectName = subjectData.subjectName;
    subjectCont =
        TextEditingController(text: (subjectName == null) ? null : subjectName);

    ///Attribs
    icon = subjectData.attribs.icon;
    color = subjectData.attribs.color;

    ///Lecture Schedule
    startDate = DateTime.parse(subjectData.lectureSchedule.startDate);
    endDate = DateTime.parse(subjectData.lectureSchedule.endDate);

    ///ScheduleInfo
    for (int i = 0; i < scheduleInfo.length; i++) {
      dayInputBuilders.add(DayInputBuilder(
          day: int.parse(scheduleInfo[i].day),
          startTime: scheduleInfo[i].time.substring(0, 5),
          finishTime: scheduleInfo[i].time.substring(6, 11),
          location: scheduleInfo[i].location));
      locationCont.add(TextEditingController(text: scheduleInfo[i].location));
    }
  }

  ///SubjectName
  String subjectName;
  TextEditingController subjectCont = TextEditingController();

  ///Attribs
  IconData icon;
  Color color;

  ///Lecture Schedule
  DateTime startDate =
      DateTime.utc(dtv.yearNow(), dtv.monthNow(), dtv.dayNow() - 1);
  DateTime endDate = DateTime.utc(dtv.yearNow(), 12, 31);

  ///ScheduleInfo
  List<DayInputBuilder> dayInputBuilders = <DayInputBuilder>[];
  List<TextEditingController> locationCont = <TextEditingController>[];

  ///Compiled list of icons used to populate 'IconSelection' dialogue
  List<IconData> icons = [
    Icons.ac_unit,
    Icons.account_balance,
    Icons.work,
    Icons.monetization_on,
    Icons.poll,
    Icons.show_chart,
    Icons.add,
    Icons.border_color,
    Icons.account_box,
    Icons.favorite_border,
    Icons.http,
    Icons.camera_alt,
    Icons.camera,
    Icons.android,
    Icons.attach_money,
    Icons.audiotrack,
    Icons.cloud,
    Icons.business,
    Icons.casino,
    Icons.category,
    Icons.code,
    Icons.functions,
    Icons.directions_bike,
    Icons.flash_on,
    Icons.format_paint,
    Icons.palette,
    Icons.brush,
    Icons.gavel,
    Icons.language,
    Icons.landscape,
    Icons.laptop,
    Icons.local_florist,
    Icons.lock,
    Icons.pets,
    Icons.public,
    Icons.school,
    Icons.whatshot,
  ];

  ///Compiled list of colors used to populate 'ColorSelection' dialogue
  List<Color> colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];
}
