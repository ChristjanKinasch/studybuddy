import 'dart:core';

///DateTime formatting and value retrieval helper functions
int dayNow() => DateTime.now().day;

int monthNow() => DateTime.now().month;

int yearNow() => DateTime.now().year;

DateTime dateNow() => DateTime.utc(yearNow(), monthNow(), dayNow());

String convertTimeToTwelve(String twentyFour) {
  String twelveHour = '';
  return twelveHour;
}

String dateTimeFormatted(DateTime args) {
  return '${args.day}\n${months[args.month - 1].substring(0, 3)}\n${args.year}';
}

///For standard month display
List<String> months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

///For standard day display
List<String> days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

///building cellCount
int daysInMonth(int month, int year) {
  int numDays;
  switch (month) {
    case 1:
      numDays = (isLeapYear(year)) ? 29 : 28;
      break;
    case 3:
    case 5:
    case 8:
    case 10:
      numDays = 30;
      break;
    default:
      numDays = 31;
      break;
  }
  return numDays;
}

///Checking for leap years
bool isLeapYear(int year) {
  if (year % 4 != 0) {
    return false;
  } else if (year % 400 == 0) {
    return true;
  } else if (year % 100 == 0) {
    return false;
  } else {
    return true;
  }
}

///Returns Day of the week as a String for any given date
///Used for
/// - Creating beginning of month offset in 'CalendarMonthlyWidget'
/// - Calculating month to month overflow for use in range based display within 'SummaryScreen'
/// - Assigning correct day of week to 'SummaryItem' display
///
///cv - Century Value
///   - Not necessary for values other than 0 for this purpose
///   - From 1600s, code cycle repeats [0,5,3,1]
///d - day in month
///m - month code
///y - last 2 digits of year
///a - step 1
///b - step 2
///c - step 3
///x - step 4
///e - if Jan, or Feb within a Leap Year
///z - final product - Day code, index Based, Sunday=0; Friday=5

///Each value corresponds to a month
List<int> monthCodes = [0, 3, 3, 6, 1, 4, 6, 2, 5, 0, 3, 5];

int dayFromDate({int day, int month, int year}) {
  ///Processed inputs
  int cv = 0,
      d = day,
      m = monthCodes[month],
      y = int.parse(year.toString().substring(2, 4));

  int a, b, c, x, z;
  int e;
  ((month == 0) || (month == 1) && (isLeapYear(year))) ? e = 1 : e = 0;

  ///Steps
  a = d + m;
  (a > 6) ? b = a - (_highestMultiple(d, 7)) : b = a;
  a = y - _highestMultiple(y, 28);
  c = a ~/ 4;
  x = a + c + cv - e;
  z = x + b - _highestMultiple(x + b, 7);

  ///Account for potential index error
  (z == 0) ? z = 7 : z -= 1;

  return z;
}

int _highestMultiple(int x, int s) {
  var i = 0;
  while (i < x) {
    i += s;
  }
  return i - s;
}

/// End Day from Date matching algorithm
