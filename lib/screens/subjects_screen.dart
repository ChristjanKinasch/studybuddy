import 'package:flutter/material.dart';

import 'package:study_buddy/state_container.dart';

import 'package:study_buddy/data/subjects_data_constructors.dart';
import 'package:study_buddy/widgets/subject_item.dart';
import 'package:study_buddy/input_forms/subject_input_screen.dart';

import 'package:study_buddy/stylesheet.dart' as sty;
import 'package:study_buddy/helpers.dart' as hlp;
import 'package:study_buddy/constants.dart' as Const;

class SubjectsScreen extends StatelessWidget {
  ///Unclean list from 'InheritedWidget'
  static List<Subject> subjectsData = <Subject>[];

  ///Parsed list
  final subjectItems = <SubjectItem>[];

  ///Global reference for updating data set
  static StateContainerState inheritedWidget;

  @override
  Widget build(BuildContext context) {
    print('SubjectsScreen.build** Building Screen');

    ///Prevent multiplying values
    subjectItems.clear();

    ///Initialize Data parent inheritance
    inheritedWidget = StateContainer.of(context);
    subjectsData = inheritedWidget.subjectList;

    ///Parse data into desired format
    print('SubjectsScreen.build** Formatting data');
    if (subjectsData != null)
      for (int i = 0; i < subjectsData.length; i++) {
        subjectItems.add(SubjectItem(
          subjectIndex: i,
          subjectName: subjectsData[i].subjectName,
          icon: subjectsData[i].attribs.icon,
          color: subjectsData[i].attribs.color,
        ));
      }

    return Column(
      children: <Widget>[
        (subjectsData.isEmpty)
            ? Expanded(
                child: Center(child: sty.lrgText(Const.EMPTY_SUBJECTS_SCREEN)),
              )
            : Expanded(
                child: Container(
                  ///Create a GridView comprised of Subjects
                  child: new GridView.count(
                    crossAxisCount: (MediaQuery.of(context).orientation ==
                            Orientation.portrait)
                        ? 3
                        : 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: List.generate(subjectItems.length, (index) {
                      return Container(child: subjectItems[index]);
                    }),
                  ),
                ),
              ),

        ///Open 'SubjectInputScreen()'
        RaisedButton(
          child: sty.smlText('New Subject'),

          ///Launch Form
          onPressed: () => _returnInputValue(context),
        ),
      ],
    );
  }

  ///Launch 'SubjectInputScreen()'; await return value; write to disk
  void _returnInputValue(BuildContext context) async {
    final item = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubjectInputScreen()),
    );
    if (item != null) _updateSubjectList(item);
  }

  ///Append new entry to existing 'SubjectList' and write to disk
  _updateSubjectList(Subject item) async {
    List<Subject> values = inheritedWidget.subjectList;
    List<Subject> theList = <Subject>[];

    values.add(item);
    values.forEach((v) => theList.add(v));

    try {
      print(
          'SubjectsScreen._updateSubjectList** Updating Inherited Subject List');
      inheritedWidget.updateSubjectList(subjectListIn: theList);
    } catch (e) {
      print('SubjectsScreen._updateSubjectList** $e');
    }
  }
}
