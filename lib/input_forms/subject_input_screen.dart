import 'package:flutter/material.dart';

import 'package:study_buddy/state_container.dart';

import 'package:study_buddy/data/subjects_data_constructors.dart';
import 'package:study_buddy/input_forms/subject_form_data.dart';

import 'package:study_buddy/widgets/picker_dialog.dart';
import 'package:study_buddy/widgets/date_time_selectors.dart';

import 'package:study_buddy/date_time_values.dart' as dtv;
import 'package:study_buddy/helpers.dart' as hlp;
import 'package:study_buddy/stylesheet.dart' as sty;

class SubjectInputScreen extends StatelessWidget {
  final int subjectIndex;
  final String subjectName;

  SubjectInputScreen({this.subjectIndex, this.subjectName});

  static StateContainerState inheritedWidget;

  @override
  Widget build(BuildContext context) {
    inheritedWidget = StateContainer.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(
              (subjectIndex == null) ? 'Create Subject' : 'Edit $subjectName'),
        ),
        body: Container(
          child: SubjectInputForm(subjectIndex: subjectIndex, context: context),
        ));
  }
}

class SubjectInputForm extends StatefulWidget {
  final int subjectIndex;
  final BuildContext context;

  SubjectInputForm({this.subjectIndex, this.context});

  final SubjectFormData blankFormData = SubjectFormData();
  final SubjectFormData populatedFormData = SubjectFormData();

  static StateContainerState inheritedWidget;

  @override
  State createState() => (subjectIndex == null) ? blankForm() : populatedForm();

  populatedForm() {
    print('SubjectInputForm.populatedForm** Populating form values');
    inheritedWidget = StateContainer.of(context);
    return SubjectInputFormState(
        subjectIndex: subjectIndex,
        fdata: populatedFormData
          ..populateFields(inheritedWidget.subjectList[subjectIndex]));
  }

  blankForm() {
    print('SubjectInputForm.blankForm** Initializing empty form');
    blankFormData.icon =
        blankFormData.icons[hlp.rng(blankFormData.icons.length)];

    blankFormData.color =
        blankFormData.colors[hlp.rng(blankFormData.colors.length)];
    return SubjectInputFormState(
        subjectIndex: subjectIndex, fdata: blankFormData);
  }
}

class SubjectInputFormState extends State<SubjectInputForm> {
  final int subjectIndex;

  final SubjectFormData fdata;

  SubjectInputFormState({this.subjectIndex, this.fdata});

  ///Date and Time picker widgets
  ///Initialized with context in 'build'
  static DateTimeSelectors _dtselect;
  static PickerDialogs _pickerDialogs;

  static StateContainerState inheritedWidget;

  ///Relevant form state ('fdata') is initialized and passed from parent via constructor
  ///   - 'fdata' holds input values
  ///
  ///Upon form submission; values stored within 'fdata' are check in the
  ///   'validateInput' function.
  ///Invalid input will trigger a dialog, which describes the nature of the error
  ///to the user
  ///
  ///A successful validation triggers 'structSubjectInformation' which converts 'fdata'
  ///   values into an object instance; which is then returned to parent, triggering
  ///   a 'write values to disk' event.
  ///
  ///Must I explain everything?

  @override
  Widget build(BuildContext context) {
    _dtselect = DateTimeSelectors(context: context);
    _pickerDialogs = PickerDialogs(context: context, fdata: fdata);
    inheritedWidget = StateContainer.of(context);
    if (!inheritedWidget.isFullVersion) {
      if (inheritedWidget.adManager.isLoaded) {
        inheritedWidget.hideBanner();
      }
    }

    ///...fine
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),

                ///'subjectName' input... obviously
                child: TextField(
                    maxLength: 20,
                    controller: fdata.subjectCont,
                    decoration: InputDecoration(
                      hintText: 'Subject Name...',
                    )),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ///Opens 'IconSelection' dialogue
                  Text('Icon'),
                  IconButton(
                      iconSize: 40,
                      color: Theme.of(context).highlightColor,
                      onPressed: () async {
                        await _pickerDialogs.selectIcon();
                        setState(() {});
                      },
//                      tooltip: 'test',
                      icon: Icon(
                        fdata.icon,
                      )),

                  ///Opens 'ColourSelection' dialogue
                  Text('Colour'),

                  FlatButton(
                      shape: CircleBorder(),
                      onPressed: () async {
                        await _pickerDialogs.selectColor();
                        setState(() {});
                      },
                      color: fdata.color,
                      child: (fdata.color == null)
                          ? sty.medText('Color')
                          : Container()),
                ],
              ),
              _datePicker(),
              _scheduleInputBlockContainer(),

              ///Final 'Submit' button.
              ///Take a guess what happens in the '_validateInput()' function
            ],
          ),
        ),
        RaisedButton(
          onPressed: () {
            _validateInput();
          },
          child: sty.smlText('Submit'),
        ),
      ],
    );
  }

  ///Display 'DatePicker' dialogues, setState to display selected value
  _datePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          color: Theme.of(context).highlightColor,
          onPressed: () async {
            fdata.startDate =
                await _dtselect.selectDate(defaultDate: fdata.startDate);

            setState(() {});
          },
          child: sty.medText(dtv.dateTimeFormatted(fdata.startDate)),
        ),
        sty.lrgText('- '),
        RaisedButton(
            color: Theme.of(context).highlightColor,
            onPressed: () async {
              fdata.endDate =
                  await _dtselect.selectDate(defaultDate: fdata.endDate);

              setState(() {});
            },
            child: sty.medText(
              dtv.dateTimeFormatted(fdata.endDate),
            ))
      ],
    );
  }

  ///Create and remove ScheduleInput blocks
  _scheduleInputBlockContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      child: Column(
        children: <Widget>[
          sty.lrgText('Schedule Information'),

          ///Container for ScheduleInput blocks
          Column(
              children: List.generate(
            fdata.dayInputBuilders.length,
            (index) => Card(elevation: 3, child: _inputBlockDisplay(index)),
          )),

          ///Create a ScheduleInput block with a corresponding textInputController
          RaisedButton(
            onPressed: () {
              fdata.dayInputBuilders.add(DayInputBuilder());
              fdata.locationCont.add(TextEditingController());
              setState(() {});
            },
            child: Icon(Icons.add),
          )
        ],
      ),
    );
  }

  ///Creates instance on user buttons press
  ///
  /// Input fields for _DayInputBuilder
  ///
  /// contains fields for 'DayOfWeek', 'TimeFrame', and 'Location'
  _inputBlockDisplay(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _dropdownSelect(index),
              ),
              (fdata.dayInputBuilders.length > 0)

                  ///Remove a ScheduleInput block and its corresponding textInputController
                  ? FlatButton(
                      onPressed: () {
                        fdata.dayInputBuilders.removeAt(index);
                        fdata.locationCont.removeAt(index);
                        setState(() {});
                      },
                      child: Icon(Icons.remove),
                    )
                  : Container()
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ///Open 'TimeSelector' input dialog for 'startTime'
              ///Display the selected time, '00:00' if empty value
              FlatButton(
                color: Theme.of(context).highlightColor,
                onPressed: () async {
                  fdata.dayInputBuilders[index].startTime =
                      await _dtselect.selectTime(
                          defaultTime: TimeOfDay(
                              hour: int.parse(fdata
                                  .dayInputBuilders[index].startTime
                                  .substring(0, 2)),
                              minute: int.parse(fdata
                                  .dayInputBuilders[index].startTime
                                  .substring(3, 5))));
                  setState(() {});
                },
                child: sty.medText(fdata.dayInputBuilders[index].startTime),
              ),
              sty.lrgText('- '),

              ///Open 'TimeSelector' input dialog for 'endTime'
              ///Display the selected time, '00:00' if empty value
              FlatButton(
                color: Theme.of(context).highlightColor,
                onPressed: () async {
                  fdata.dayInputBuilders[index].finishTime =
                      await _dtselect.selectTime(
                          defaultTime: TimeOfDay(
                              hour: int.parse(fdata
                                  .dayInputBuilders[index].finishTime
                                  .substring(0, 2)),
                              minute: int.parse(fdata
                                  .dayInputBuilders[index].finishTime
                                  .substring(3, 5))));

                  setState(() {});
                },
                child: sty.medText(fdata.dayInputBuilders[index].finishTime),
              ),
            ],
          ),

          ///Location input
          Container(
            width: 250,
            child: TextField(
              controller: fdata.locationCont[index],
              decoration: InputDecoration(hintText: 'Location...'),
            ),
          )
        ],
      ),
    );
  }

  ///Day of week picker for Schedule input
  _dropdownSelect(int index) {
    return Center(
      child: DropdownButton<String>(
        items: dtv.days.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String newValue) => setState(() {
          ///Assign selected value to index of builder
          fdata.dayInputBuilders[index].day = dtv.days.indexOf(newValue);
          print('SubjectInputFormState._dropdownSelect** updated');
        }),

        ///Set hint to selected value
        hint: sty.medText((fdata.dayInputBuilders[index].day != 9)
            ? dtv.days[fdata.dayInputBuilders[index].day]
            : 'Select a day'),
      ),
    );
  }

  ///Checking for valid input inside static instance of 'FormData()'
  ///   'gucci' is set to false if any input is not valid
  ///
  ///     !gucci
  ///       - Display dialogue with error message
  ///
  ///     gucci
  ///       - Construct and return Subject object
  ///
  _validateInput() {
    String errortitle = 'Please complete the following fields:';
    String errormsg = '';
    bool gucci = true;

    print('SubjectInputFormState._validateInput** Validating form input');

    ///Validation for 'subjectName' 'TextField' input field
    if (fdata.subjectCont.text == '' || fdata.subjectCont.text == null) {
      errormsg += '- Subject Name\n';
      gucci = false;
    } else {
      fdata.subjectName = fdata.subjectCont.text;
    }

    ///Start date is before End date
    if (fdata.startDate.isAfter(fdata.endDate)) {
      gucci = false;
      errormsg += '- Start date must be before End date';
    }

    ///Validate each Lecture Schedule input field
    if (fdata.dayInputBuilders != null) {
      for (int i = 0; i < fdata.dayInputBuilders.length; i++) {
        if (fdata.dayInputBuilders[i].day == 9 ||
            fdata.dayInputBuilders[i].startTime == '' ||
            fdata.dayInputBuilders[i].finishTime == '' ||
            fdata.locationCont[i].text == '') {
          gucci = false;
          errormsg += '- Lecture Schedule field #${i + 1}\n';
        } else {
          fdata.dayInputBuilders[i].location = fdata.locationCont[i].text;
        }
      }
    }

    ///If validation checks are successful; return the 'subjectInformation' to
    ///   parent for processing
    ///
    ///If validation checks are UNsuccessful; display dialog with error message
    (gucci)
        ? print('SubjectInputFormState._validateInput** Validation Success')
        : print('SubjectInputFormState._validateInput** Validation Error');
    (gucci)
        ? Navigator.pop(context, _structSubjectInformation())
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

  ///Retrieve values from static instance of 'FormData()'
  ///Populate an instance of 'Subject' object. return value to parent screen
  ///via 'Navigator.pop'
  _structSubjectInformation() {
    print('SubjectInputFormState._structSubjectInformation** Building Subject');

    ///Lists and variables used for building Object instance
    String subjectName;
    Attribs attribs;
    List<Task> tasks = <Task>[];
    LectureSchedule lectureSchedule;
    List<ScheduleInfo> dayAndTime = <ScheduleInfo>[];

    ///Retrieve values from 'FormData' static reference
    subjectName = fdata.subjectName;

    ///Assign random default values if no selection was made

    ///Compile Attributes
    attribs = Attribs(icon: fdata.icon, color: fdata.color);

    ///Create entries for each day if box was ticked.
    if (fdata.dayInputBuilders != null) {
      for (int i = 0; i < fdata.dayInputBuilders.length; i++) {
        dayAndTime.add(ScheduleInfo(
            day: fdata.dayInputBuilders[i].day.toString(),
            time:
                '${fdata.dayInputBuilders[i].startTime}-${fdata.dayInputBuilders[i].finishTime}',
            location: fdata.dayInputBuilders[i].location));
      }
    }

    ///Compile Lecture schedule
    lectureSchedule = LectureSchedule(
        startDate: fdata.startDate.toString(),
        endDate: fdata.endDate.toString(),
        scheduleInfo: dayAndTime);

    print(
        'SubjectInputFormState._structSubjectInformation** Returning Subject');

    ///Return final object
    return Subject(
        subjectName: subjectName,
        attribs: attribs,
        tasks: tasks,
        lectureSchedule: lectureSchedule);
  }
}

///Storing Schedule input block information
class DayInputBuilder {
  DayInputBuilder(
      //Set default to 9 for validation
      {this.day = 9,
      this.startTime = '00:00',
      this.finishTime = '00:00',
      this.location = ''});

  int day;
  String startTime, finishTime, location;
}
