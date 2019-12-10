import 'dart:math';
import 'package:flutter/material.dart';
import 'package:study_buddy/widgets/task_list_panels.dart';
import 'package:study_buddy/stylesheet.dart' as sty;

///Returns random number from range '0->max'
int rng(var max) => new Random().nextInt(max);

///Screen width and height
double sWidth(BuildContext context) => MediaQuery.of(context).size.width;

double sHeight(BuildContext context) => MediaQuery.of(context).size.height;

///Order list by 'DateTime' ascending
sortListByDate(List<ExpansionPanelItem> list) =>
    list..sort((a, b) => a.taskInfo.deadline.compareTo(b.taskInfo.deadline));

///Display a confirmation dialog that requires the 'input' to be entered
/// in a 'TextField'.
///Returns true if user entered value matches the 'input' parameter
Future<bool> confirmRemove({name, context}) async {
//    String subjectName = subjectsData[subjectIndex].subjectName;
  TextEditingController inputField = TextEditingController();
  bool removed = false;
  String word = wordList[rng(wordList.length)];
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Confirm Removal'),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: sty.smlText('Enter the following into the text field to confirm removal of \'$name\''),
            ),
            sty.lrgText('$word'),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                decoration: InputDecoration(hintText: 'Input here...'),
                controller: inputField,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                  child: Text('Remove'),
                  color: Colors.red,
                  onPressed: () {
                    if (word.toLowerCase() == inputField.text.toLowerCase()) {
                      removed = true;
                      Navigator.pop(context);
                    }
                  },
                ),
                FlatButton(
                  child: Text('Keep'),
                  color: Colors.green,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ],
        );
      });
  return removed;
}

List<String> wordList = [
  'throat',
  'roomy',
  'pumped',
  'aback',
  'holiday',
  'tested',
  'truck',
  'bed',
  'five',
  'beam',
  'heap',
  'empty',
  'order',
  'cent',
  'fruit',
  'staking',
  'nice',
  'camp',
  'wrench',
  'unusual',
  'happy',
  'grip',
  'sofa',
  'detail',
  'thing',
  'wish',
  'disarm',
  'untidy',
  'coat',
  'girls',
  'spell'
];

///Task status values
List<String> statusList = [
  'Not started',
  'In progress',
  'Completed',
  'Overdue',
];
List<Color> statusColor = [
  Colors.black,
  Colors.orange,
  Colors.green,
  Colors.red,
];
