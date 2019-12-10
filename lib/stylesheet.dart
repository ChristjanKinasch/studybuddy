import 'package:flutter/material.dart';

///Testing viability of a dedicated stylesheet
///
/// All standard decoration values will be created, and accessed from here
Text smlText(String text) => Text(
      text,
      style: TextStyle(
        fontSize: 14.0,
        letterSpacing: 3.0,
      ),
      textAlign: TextAlign.center,
    );

Text medText(String text) => Text(
      text,
      style: TextStyle(
        fontSize: 18.0,
        letterSpacing: 3.0,
      ),
      textAlign: TextAlign.center,
    );

Text lrgText(String text) => Text(
      text,
      style: TextStyle(
        fontSize: 22.0,
        letterSpacing: 3.0,
      ),
      textAlign: TextAlign.center,
    );
