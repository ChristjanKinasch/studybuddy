import 'package:flutter/material.dart';
import 'package:study_buddy/data/subjects_data_constructors.dart';
import 'package:study_buddy/data/file_handler.dart';
import 'package:study_buddy/data/user_preferences.dart';
import 'package:study_buddy/ad_manager.dart';

class StateContainer extends StatefulWidget {
  final Widget child;

  final List<Subject> subjectList;

  StateContainer({this.child, this.subjectList});

  static StateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(InheritedContainer)
            as InheritedContainer)
        .data;
  }

  @override
  State createState() => StateContainerState();
}

class StateContainerState extends State<StateContainer> {
  ///Data set to be inherited to entire application children
  List<Subject> subjectList = <Subject>[];

  ThemeData appTheme;

  ///Time values stored in TwentyFour Hour format.
  ///   if 0: filtered and converted in [weeklyCalendar._filter]
  ///0 = Twelve Hour
  ///1 = TwentyFour Hour
  int timeFormat;

  ///(multiplied by 7+1 in [summaryScreen.rangeLimit])
  ///1 = 1 week
  ///2 = 2 weeks
  ///3 = 3 weeks
  ///4 = 4 weeks
  int summaryRange;

  ///Checked once on startup in [main.build]
  ///0 = 30 days
  ///1 = 60 days
  ///2 = 90 days
  int autoRemoveAfter;

  UserPreferences prefs = UserPreferences();

  ///Restricted features:
  ///   - Icon selection
  ///       - Viewing is available. Selection is not
  ///   - Colour selection
  ///       - Viewing is available. Selection is not
  ///   - Ad serving
  ///       - Full version removes ads
  ///   - Menu changes
  ///       - Remove purchase option
  ///       - Replace with
  bool isFullVersion=false;

  final AdManager adManager = AdManager();

  showBanner() => adManager?.showBannerAd();

  hideBanner() => adManager?.disposeBanner();

  ///Receives an updated copy of 'subjectList'; null check; reassigns inherited
  ///   'subjectList' and writes to file to save
  void updateSubjectList({List<Subject> subjectListIn}) async {
    if (subjectListIn == null) {
      print('StateContainerState.updateSubjectList** Null Subject List');
    } else {
      print('StateContainerState.updateSubjectList** Assigning SubjectList');
      subjectList = subjectListIn;
      await FileHandler().writeFile(subjectListIn);
    }
  }

  ///Replaces the edited 'task' with the updated task at the same position;
  ///   then calls 'updateSubjectList' to save changes
  void editTask({int subjectIndex, int taskIndex, Task taskInformation}) {
    if (taskInformation != null) {
      subjectList[subjectIndex].tasks
        ..removeAt(taskIndex)
        ..insert(taskIndex, taskInformation);
      updateSubjectList(subjectListIn: subjectList);
    }
  }

  ///Removes the selected 'task'; then calls 'updateSubjectList' to save changes
  void removeTask({int subjectIndex, int taskIndex}) {
    subjectList[subjectIndex].tasks.removeAt(taskIndex);
    updateSubjectList(subjectListIn: subjectList);
    setState(() {});
  }

  ///Replaces the edited 'subject' with the updated task at the same position;
  ///   then calls 'updateSubjectList' to save changes
  void editSubject({int subjectIndex, Subject subject}) {
    if (subject != null) {
      subject.tasks = subjectList[subjectIndex].tasks;
      updateSubjectList(
          subjectListIn: subjectList
            ..removeAt(subjectIndex)
            ..insert(subjectIndex, subject));
    }
    setState(() {});
  }

  ///Removes the selected 'subject'; then calls 'updateSubjectList' to save changes
  void removeSubject({int subjectIndex}) {
    subjectList.removeAt(subjectIndex);
    updateSubjectList(subjectListIn: subjectList);
  }

  ///User Preference Settings
  ///Cases correspond to selected index of Radio Button values stored
  ///   in SharedPreferences
  ///Defaults:
  ///   appTheme: 0 - Dark
  ///   timeFormat: 1 - 24 hour
  ///   summaryRange: 1 - 2 weeks
  ///   autoRemoveAfter: 0 - 1 month
  setAppTheme() async {
    int userPrefs = await prefs.getThemesPrefs();
    setState(() {
      appTheme = (userPrefs == 0 || userPrefs == null)
          ? ThemeData.dark()
          : ThemeData.light();
    });
    print('StateContainerState.setAppTheme** $appTheme');
  }

  setTimeFormat() async {
    int userPrefs = await prefs.getTimeFormatPrefs();
    setState(() {
      timeFormat = (userPrefs == 1 || userPrefs == null) ? 1 : 0;
    });
    print('StateContainerState.setTimeFormat** $timeFormat');
  }

  setSummaryRange() async {
    int userPrefs = await prefs.getSummaryRangePrefs();
    setState(() {
      switch (userPrefs) {
        case 0:
          summaryRange = 1;
          break;
        case 2:
          summaryRange = 3;
          break;
        case 3:
          summaryRange = 4;
          break;
        default:
          summaryRange = 2;
      }
    });
    print('StateContainerState.setSummaryRange** $summaryRange');
  }

  setAutoRemoveAfter({firstLaunch}) async {
    int userPrefs = await prefs.getAutoRemovePrefs();
    setState(() {
      switch (userPrefs) {
        case 1:
          autoRemoveAfter = 60;
          break;
        case 2:
          autoRemoveAfter = 90;
          break;
        default:
          autoRemoveAfter = 30;
          break;
      }
    });

    ///Only on first launch
    ///   If marked as completed and tasks is outside the 'Auto-Remove' threshold
    ///       Remove task
    if (firstLaunch) {
      int removed = 0;
      for (var i = 0; i < subjectList.length; ++i) {
        for (var j = 0; j < subjectList[i].tasks.length; ++j) {
          if (DateTime.parse(subjectList[i].tasks[j].deadline)
                      .difference(DateTime.now())
                      .inDays <
                  -autoRemoveAfter &&
              subjectList[i].tasks[j].status == 2) {
            subjectList[i].tasks.removeAt(j);
            removed++;
          }
        }
      }
      print('StateContainerState.setAutoRemoveAfter**'
          ' $removed: tasks auto-removed');
      updateSubjectList(subjectListIn: subjectList);
    }
    print('StateContainerState.setAutoRemoveAfter** $autoRemoveAfter');
  }

  @override
  Widget build(BuildContext context) => InheritedContainer(
        data: this,
        child: widget.child,
      );
}

class InheritedContainer extends InheritedWidget {
  final StateContainerState data;

  InheritedContainer({Key key, @required this.data, @required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedContainer oldWidget) => true;
}
