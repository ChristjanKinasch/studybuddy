import 'package:flutter/material.dart';
import 'package:study_buddy/date_time_values.dart' as dtv;

class DateTimeSelectors {
  DateTimeSelectors({this.context});

  BuildContext context;

  ///Display 'TimePicker' dialogues, Update state to display selected value
  selectDate({DateTime defaultDate}) async {
    ///await return value, null check (user cancel input)
    ///Format values and store
    var x = await showDatePicker(
        context: context,
        initialDate: (defaultDate != null) ? defaultDate : DateTime.now(),
        firstDate: DateTime(dtv.yearNow() - 1),
        lastDate: DateTime(dtv.yearNow() + 1));
    return (x != null) ? x : defaultDate;
  }

  ///Display Time pickers, Update state to display selected value
  selectTime({TimeOfDay defaultTime}) async {
    ///Display leading zero if necessary
    _prependZero(int val) => (val < 10) ? '0$val' : val;
    var x = await showTimePicker(
        context: context,
        initialTime: (defaultTime != null)
            ? defaultTime
            : TimeOfDay(minute: 00, hour: 00));
    return (x != null)
        ? '${_prependZero(x.hour)}:${_prependZero(x.minute)}'
        : '${_prependZero(defaultTime.hour)}:${_prependZero(defaultTime.minute)}';
  }
}
