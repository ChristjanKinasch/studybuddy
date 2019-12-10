import 'package:flutter/material.dart';

import 'package:study_buddy/screens/subject_information_screen.dart';
import 'package:study_buddy/stylesheet.dart' as sty;

///Route to Task Details

class SubjectItem extends StatelessWidget {
  ///Constructor for Grid Item creation
  SubjectItem({this.subjectIndex, this.subjectName, this.icon, this.color});

  final int subjectIndex;
  final String subjectName;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Container(
            height: 20,
            color: color,
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubjectInformationScreen(
                            subjectIndex: subjectIndex,
                          )),
                );
              },
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(icon, size: 30),
                    sty.medText(subjectName),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
