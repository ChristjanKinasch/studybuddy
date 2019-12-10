import 'package:flutter/material.dart';
import 'package:study_buddy/data/user_preferences.dart';
import 'package:study_buddy/state_container.dart';

///Used by radio button groups to display, and assign available settings
enum AvailableThemes { Dark, Light }
enum TimeFormat { Twelve, TwentyFour }
enum SummaryDisplayRangeInWeeks { One, Two, Three, Four }
enum AutoRemoveCompletedInMonths { One, Two, Three }

class UserSettings extends StatefulWidget {
  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  ///Retrieving SharedPreferences Keys
  UserPreferences userPrefs = UserPreferences();

  ///Data parent
  StateContainerState inheritedWidget;

  ///ENUM references
  AvailableThemes _themeGroup;
  TimeFormat _timeFormatGroup;
  SummaryDisplayRangeInWeeks _summaryRangeGroup;
  AutoRemoveCompletedInMonths _autoRemoveGroup;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  ///Populate fields with user set values
  ///   If no user values were selected, defaults are set via
  ///   null aware operation
  _loadPreferences() async {
    _themeGroup =
        AvailableThemes.values.elementAt(await userPrefs.getThemesPrefs());
    _timeFormatGroup =
        TimeFormat.values.elementAt(await userPrefs.getTimeFormatPrefs());
    _summaryRangeGroup = SummaryDisplayRangeInWeeks.values
        .elementAt(await userPrefs.getSummaryRangePrefs());
    _autoRemoveGroup = AutoRemoveCompletedInMonths.values
        .elementAt(await userPrefs.getAutoRemovePrefs());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    inheritedWidget = StateContainer.of(context);
    print('_UserSettingsState.build**\n'
        '''
        $_themeGroup
        $_timeFormatGroup
        $_summaryRangeGroup
        $_autoRemoveGroup
        ''');
    return Scaffold(
      persistentFooterButtons: <Widget>[
        (inheritedWidget.isFullVersion)
            ? Container(height: 0)
            : Container(height: 110)
      ],
      appBar: AppBar(
        title: Text('App Settings'),
      ),
      body: ListView(
        children: <Widget>[
          Text('Theme'),
          _themeSelections(),
          Divider(),
          Text('Time Format'),
          _timeFormatSelection(),
          Divider(),
          Text('Summary Display Range'),
          _summaryDisplayRangeSelection(),
          Divider(),
          Text('Auto Remove Completed Tasks After'),
          _autoRemoveTasksSelection(),
          Divider()
        ],
      ),
    );
  }

  ///User selects [Theme] from [_themeGroup] radio button group
  ///   Selected value is saved to shared preferences by calling [setAppTheme] in
  ///   [user_preferences.dart];
  ///   Inherited widget value is update, where app state is rebuilt
  ///   to immediately respond to changes
  _themeSelections() {
    localOnChange(AvailableThemes value) {
      setState(() {
        _themeGroup = value;
        userPrefs.setThemesPrefs(AvailableThemes.values.indexOf(_themeGroup));
      });
      inheritedWidget.setAppTheme();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: ListTile(
            title: Text('Dark'),
            leading: Radio(
                value: AvailableThemes.Dark,
                groupValue: _themeGroup,
                onChanged: localOnChange),
          ),
        ),
        Expanded(
          child: ListTile(
            title: Text('Light'),
            leading: Radio(
                value: AvailableThemes.Light,
                groupValue: _themeGroup,
                onChanged: localOnChange),
          ),
        ),
      ],
    );
  }

  ///User selects [TimeFormat] from [_timeFormatGroup] radio button group
  ///   Selected value is saved to shared preferences by calling [setTimeFormat]
  ///   in [user_preferences.dart];
  ///   Inherited widget value is update, where app state is rebuilt
  ///   to immediately respond to changes
  _timeFormatSelection() {
    localOnChange(TimeFormat value) {
      setState(() {
        setState(() => _timeFormatGroup = value);
        userPrefs
            .setTimeFormatPrefs(TimeFormat.values.indexOf(_timeFormatGroup));
      });
      inheritedWidget.setTimeFormat();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: ListTile(
              title: Text('12-Hour'),
              leading: Radio(
                  value: TimeFormat.Twelve,
                  groupValue: _timeFormatGroup,
                  onChanged: localOnChange)),
        ),
        Expanded(
          child: ListTile(
              title: Text('24-Hour'),
              leading: Radio(
                  value: TimeFormat.TwentyFour,
                  groupValue: _timeFormatGroup,
                  onChanged: localOnChange)),
        ),
      ],
    );
  }

  ///User selects [SummaryRange] from [_summaryRangeGroup] radio button group
  ///   Selected value is saved to shared preferences by calling [setSummaryRange]
  ///   in [user_preferences.dart];
  ///   Inherited widget value is update, where app state is rebuilt
  ///   to immediately respond to changes
  _summaryDisplayRangeSelection() {
    localOnChange(SummaryDisplayRangeInWeeks value) {
      setState(() {
        _summaryRangeGroup = value;
        userPrefs.setSummaryRangePrefs(
            SummaryDisplayRangeInWeeks.values.indexOf(_summaryRangeGroup));
      });
      inheritedWidget.setSummaryRange();
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: ListTile(
                  title: Text('1 Week'),
                  leading: Radio(
                      value: SummaryDisplayRangeInWeeks.One,
                      groupValue: _summaryRangeGroup,
                      onChanged: localOnChange)),
            ),
            Expanded(
              child: ListTile(
                  title: Text('2 Weeks'),
                  leading: Radio(
                      value: SummaryDisplayRangeInWeeks.Two,
                      groupValue: _summaryRangeGroup,
                      onChanged: localOnChange)),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: ListTile(
                  title: Text('3 Weeks'),
                  leading: Radio(
                      value: SummaryDisplayRangeInWeeks.Three,
                      groupValue: _summaryRangeGroup,
                      onChanged: localOnChange)),
            ),
            Expanded(
              child: ListTile(
                  title: Text('4 Weeks'),
                  leading: Radio(
                      value: SummaryDisplayRangeInWeeks.Four,
                      groupValue: _summaryRangeGroup,
                      onChanged: localOnChange)),
            ),
          ],
        ),
      ],
    );
  }

  ///User selects [AutoRemove] from [_autoRemoveGroup] radio button group
  ///   Selected value is saved to shared preferences by calling [setAutoRemove]
  ///   in [user_preferences.dart];
  ///   Inherited widget value is update, where app state is rebuilt
  ///   to immediately respond to changes
  _autoRemoveTasksSelection() {
    localOnChange(AutoRemoveCompletedInMonths value) {
      setState(() {
        _autoRemoveGroup = value;
        userPrefs.setAutoRemovePrefs(
            AutoRemoveCompletedInMonths.values.indexOf(_autoRemoveGroup));
      });
      inheritedWidget.setAutoRemoveAfter(firstLaunch: false);
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: ListTile(
                  title: Text('1 Month'),
                  leading: Radio(
                      value: AutoRemoveCompletedInMonths.One,
                      groupValue: _autoRemoveGroup,
                      onChanged: localOnChange)),
            ),
            Expanded(
              child: ListTile(
                  title: Text('2 Months'),
                  leading: Radio(
                      value: AutoRemoveCompletedInMonths.Two,
                      groupValue: _autoRemoveGroup,
                      onChanged: localOnChange)),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: ListTile(
                  title: Text('3 Months'),
                  leading: Radio(
                      value: AutoRemoveCompletedInMonths.Three,
                      groupValue: _autoRemoveGroup,
                      onChanged: localOnChange)),
            ),
          ],
        ),
      ],
    );
  }
}
