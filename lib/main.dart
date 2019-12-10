import 'package:flutter/material.dart';

import 'package:study_buddy/state_container.dart';
import 'data/file_handler.dart';
import 'package:study_buddy/data/subjects_data_constructors.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:study_buddy/screens/summary_screen.dart';
import 'package:study_buddy/screens/subjects_screen.dart';
import 'package:study_buddy/screens/calendar_screen.dart';
import 'package:study_buddy/screens/user_settings_screen.dart';
import 'package:study_buddy/purchase_manager.dart';
import 'constants.dart' as Const;
import 'dart:async';

StreamSubscription subscription;
Stream purchaseUpdates;
final PurchaseManager purchaseManager = PurchaseManager(
    subscription: subscription);

void main() async {
  runApp(

      ///Application is wrapped within StateContainer to allow for rebuild of
      ///Stateless widgets and their required data sets when a 'Subject' or its
      ///information is 'CRUDded'
      StateContainer(child: StudyPlanner(await FileHandler().readFile())));
}

class StudyPlanner extends StatelessWidget {
  ///Accept initial data structure for app wide population
  StudyPlanner(this.values);

  final values;

  static bool firstLaunch = true;
  static StateContainerState inheritedWidget;

  final List<Subject> subjectList = <Subject>[];

  @override
  Widget build(BuildContext context) {
    print('StudyPlanner.build** Building Screen');
    inheritedWidget = StateContainer.of(context);
    _initUserPrefs();

    ///Initialize Data parent inheritance
    if (firstLaunch) {
      if (values != null) {
        print('StudyPlanner.build** Populating Data Parent');

        inheritedWidget.updateSubjectList(subjectListIn: values);
      }
    }
    firstLaunch = false;

    return MaterialApp(
      ///Switch input in settings decides
      theme: inheritedWidget.appTheme,
      title: "Study Planner",
      home: _HomeWidget(),
    );
  }

  _initUserPrefs() {
    if (inheritedWidget.appTheme == null) inheritedWidget.setAppTheme();
    if (inheritedWidget.timeFormat == null) inheritedWidget.setTimeFormat();
    if (inheritedWidget.summaryRange == null) inheritedWidget.setSummaryRange();
    if (inheritedWidget.autoRemoveAfter == null)
      inheritedWidget.setAutoRemoveAfter(firstLaunch: firstLaunch);
  }
}

class _HomeWidget extends StatefulWidget {
  ///Application navigation routes
  static final _pageChildren = [
    SummaryScreen(),
    SubjectsScreen(),
    CalendarScreen(),
  ];

  @override
  State createState() {
    return _HomeState(_pageChildren);
  }
}

class _HomeState extends State<_HomeWidget> {
  _HomeState([this.pageChildren]);

  @override
  void initState() {
    super.initState();
  }

  var pageChildren;
  final List<String> titles = ['Summary', 'Subjects', 'Calendars'];

  int _index = 0;

  final List<String> menuItems = [
    'Settings',
    'Privacy Policy',
    'Purchase Upgrade'
  ];

  static StateContainerState inheritedWidget;
  static DateTime pressedOn;

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  ///Functions wrapped inside a [firstLaunch] check are to be executed only
  ///   once on launch and are unsuitable for [initState()]
  static bool firstLaunch = true;
  static bool purchasesChecked = false;

  @override
  void dispose() {
    inheritedWidget.adManager.disposeBanner();
    subscription.cancel();
    super.dispose();
  }

  ///Called once on launch to verify version status.
  ///   assigns global inheritedWidget boolean value:
  ///     - True: if HAS been paid for
  ///     - False: if HAS NOT been paid for
  _checkPaidVersionStatus(BuildContext context) async {
    print('StudyPlanner._checkPaidVersionStatus** Loading purchases');
    await purchaseManager.initPurchaseManager(context);
    if (!purchasesChecked) {
      ///Update bool [inheritedWidget.isFullVersion] and set state
      ///   with new value.
      ///
      /// Notify that [purchaseStatus] has been checked for.
      setState(() {
//        if (purchaseManager.purchaseHistory.isNotEmpty) {
        print('_HomeState._checkPaidVersionStatus** Setting State');
        inheritedWidget.isFullVersion = purchaseManager.verifyPurchase();
//        }
        purchasesChecked = true;

        ///Remove option to purchase when full version
        if (inheritedWidget.isFullVersion) menuItems.removeAt(2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    inheritedWidget = StateContainer.of(context);

    if (firstLaunch) _checkPaidVersionStatus(context);

    ///Initialize and Show are in root build method to re initialize
    ///   upon returning from a form input, as [adManager.dispose] on launch of
    ///   a form input to prevent accidental clicks
    ///
    ///Initialize ad serving if upgrade has not been purchased.
    ///     !firstLaunch: Prevent ads being initialized before purchase
    ///         status has been verified
    ///     !inheritedWidget.isFullVersion: Only serve ads on free version
    ///     purchasesChecked: initialize only after purchase status checking
    if (!firstLaunch && !inheritedWidget.isFullVersion && purchasesChecked) {
      inheritedWidget.adManager.init();
      inheritedWidget.adManager.showBannerAd();
    }
    firstLaunch = false;

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        persistentFooterButtons: <Widget>[
          ///Add a buffer for ad serving location if !Paid
          (inheritedWidget.isFullVersion != null)
              ? (inheritedWidget.isFullVersion)
                  ? Container(
                      height: 0,
                    )
                  : Container(
                      height: 50,
                    )
              : Container(
                  height: 50,
                )
        ],
        key: scaffoldState,
        appBar: AppBar(
          title: Text((_index != 0)
              ? titles[_index]
              : '${inheritedWidget.summaryRange} Week Summary'),
          centerTitle: true,
          actions: <Widget>[
            _showPopupMenu(),
          ],
        ),
        body: pageChildren[_index],
        bottomNavigationBar: BottomNavigationBar(
            elevation: 3,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            currentIndex: _index,
            onTap: onTabTapped,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.view_list), title: Text(titles[0])),
              BottomNavigationBarItem(
                  icon: Icon(Icons.book), title: Text(titles[1])),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today), title: Text(titles[2])),
            ]),
      ),
    );
  }

  ///Executed when user is about to leave application,
  ///     'Double back button to exit feature'
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (pressedOn == null || now.difference(pressedOn).inSeconds >= 2) {
      pressedOn = now;
      scaffoldState.currentState.showSnackBar(SnackBar(
        content: Text('Press back again to exit'),
        duration: Duration(seconds: 2),
        backgroundColor: Theme.of(context).highlightColor,
      ));
      return Future.value(false);
    }
    return Future.value(true);
  }

  void onTabTapped(int index) => setState(() => _index = index);

  ///Main user menu
  _showPopupMenu() {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        return menuItems.map((String value) {
          return PopupMenuItem<String>(value: value, child: Text(value));
        }).toList();
      },
      onSelected: _menuSelectAction,
    );
  }

  ///Menu routing logic
  _menuSelectAction(String args) async {
    if (args == menuItems[0]) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => UserSettings()));
    } else if (args == menuItems[1]) {
      ///TODO: Switch between for testing purposes.
      ///SWITCH FOR RELEASE VERSIONS
      _launchPrivacyPolicy();
//      purchaseManager.consumePurchase();
    } else if (args == menuItems[2]) {
      print('_HomeState._menuSelectAction** $args');
      purchaseManager.makePurchase(purchaseManager.productDetails);
    }
  }

  _launchPrivacyPolicy() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Open Browser'),
            content:
                Text('You are about to be directed to the Privacy Policy.\n'
                    'Your browser will now open.'),
            actions: <Widget>[
              FlatButton(
                onPressed: () async {
                  print('_HomeState._launchPrivacyPolicy** Yes');
                  if (await canLaunch(Const.privacyPolicy)) {
                    await launch(Const.privacyPolicy);
                  } else {
                    throw 'Unable to launch Privacy Policy';
                  }
                  Navigator.pop(context);
                },
                child: Text('Continue'),
              ),
              FlatButton(
                onPressed: () {
                  print('_HomeState._launchPrivacyPolicy** No');
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              )
            ],
          );
        });
  }
}
