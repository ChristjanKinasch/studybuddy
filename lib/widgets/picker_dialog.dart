import 'package:flutter/material.dart';
import 'package:study_buddy/stylesheet.dart' as sty;
import 'package:study_buddy/helpers.dart' as hlp;
import 'package:study_buddy/state_container.dart';

///Assigns form data values correctly. Validation required on form submit

class PickerDialogs {
  PickerDialogs({this.context, this.fdata});

  BuildContext context;
  final fdata;

  StateContainerState inheritedWidget;

  selectIcon() async {
    inheritedWidget = StateContainer.of(context);
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text((inheritedWidget.isFullVersion)
                  ? 'Select Icon'
                  : 'Select Icon - (Paid Feature)'),
              children: <Widget>[
                Container(
                  width: hlp.sWidth(context),
                  height: 225,
                  child: GridView.count(
                    crossAxisCount: 5,
                    children: List.generate(
                        fdata.icons.length,
                        (index) => InkWell(
                            onTap: () {
                              if (inheritedWidget.isFullVersion) {
                                fdata.icon = fdata.icons[index];
                                Navigator.pop(context);
                              }
                            },
                            child: Icon(
                              fdata.icons[index],
                              size: 40.0,
                            ))),
                  ),
                )
              ]);
        });
  }

  selectColor() async {
    inheritedWidget = StateContainer.of(context);

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text((inheritedWidget.isFullVersion)
                  ? 'Select Color'
                  : 'Select Color - (Paid Feature)'),
              children: <Widget>[
                Container(
                  width: hlp.sWidth(context),
                  height: 225,
                  child: GridView.count(
                      crossAxisCount: 5,
                      children: List.generate(
                        fdata.colors.length,
                        (index) => InkWell(
                              onTap: () {
                                if (inheritedWidget.isFullVersion) {
                                  fdata.color = fdata.colors[index];
                                  Navigator.pop(context);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: fdata.colors[index],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0))),
                                ),
                              ),
                            ),
                      )),
                )
              ]);
        });
  }
}
