import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_buddy/constants.dart' as Const;

///Helper class.
///[getMethods] are used for reading values from [SharedPreferences]
///
///[setMethods] are used for writing values to [SharedPreferences]
class UserPreferences {
  Future<int> getThemesPrefs() async {
    var prefs = await SharedPreferences.getInstance();
    return Future.value(prefs.getInt(Const.THEMES_PREFS) ?? 0);
  }

  Future<int> getTimeFormatPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.value(prefs.getInt(Const.TIME_FORMAT_PREFS) ?? 1);
  }

  Future<int> getSummaryRangePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.value(prefs.getInt(Const.SUMMARY_RANGE_PREFS) ?? 1);
  }

  Future<int> getAutoRemovePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.value(prefs.getInt(Const.AUTO_REMOVE_COMPLETED_PREFS) ?? 0);
  }

  Future<bool> setThemesPrefs(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(Const.THEMES_PREFS, value);
  }

  Future<bool> setTimeFormatPrefs(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(Const.TIME_FORMAT_PREFS, value);
  }

  Future<bool> setSummaryRangePrefs(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(Const.SUMMARY_RANGE_PREFS, value);
  }

  Future<bool> setAutoRemovePrefs(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(Const.AUTO_REMOVE_COMPLETED_PREFS, value);
  }
}
