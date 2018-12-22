import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';

const double _kPickerSheetHeight = 236.0; //216
const double _kPickerHeight = 180.0; 
const double _kPickerItemHeight = 32.0;

class Utilities {
  DateTime pickDate;

  static Future<DateTime> getDatePicker({
    @required BuildContext context,
    @required DateTime initialDate,
    @required DateTime firstDate,
    @required DateTime lastDate,
    SelectableDayPredicate selectableDayPredicate,
    CupertinoDatePickerMode partsNeeded = CupertinoDatePickerMode.date,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
    Locale locale,
    TextDirection textDirection,
  }) async {
    DateTime selDate;
    TimeOfDay selTime; //only used for Android

    if (Platform.isIOS) {
      selDate = await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (BuildContext context) {
          return _buildBottomPicker(
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Colors.grey[200],
                  child: Row(
                    children: <Widget>[
                      CupertinoButton(
                        child: Text("Cancel"),
                        onPressed: (){
                          Navigator.of(context).pop(); //returns nothing
                        },
                      ),
                      Spacer(),
                      CupertinoButton(
                        child: Text("Done"),
                        onPressed: (){
                          Navigator.of(context).pop(selDate); //returns selected date
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: _kPickerHeight, //approx 56 px less then sheet height, allowing for height of row with buttons
                  child: CupertinoDatePicker(
                    mode: partsNeeded, //date, time or datetime
                    initialDateTime: initialDate,
                    minimumDate: firstDate,
                    maximumDate: lastDate,
                    minimumYear: firstDate.year,
                    maximumYear: lastDate.year,
                    onDateTimeChanged: (DateTime newDateTime) {
                      selDate = newDateTime;
                      print("new val for selDate: ${selDate.toString()}");
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
      
    } else { //android
      if (partsNeeded == CupertinoDatePickerMode.date) {
        selDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate
        );
      } else if (partsNeeded == CupertinoDatePickerMode.time) {
        selTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: initialDate.hour, minute: initialDate.minute),
        );
        if (selTime != null) {
          //they picked a time, so 'merge' it with the initial date into the selDate value...
          selDate = DateTime(initialDate.year, initialDate.month, initialDate.day, selTime.hour, selTime.minute);
        }
      } else {
        //both - first prompt for date, then use that and 'add' to it with time
        selDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate
        );
        if (selDate != null) {
          selTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: initialDate.hour, minute: initialDate.minute),
          );
          if (selTime != null) {
            //they picked a time, so 'merge' it with the selDate value...
            selDate = DateTime(selDate.year, selDate.month, selDate.day, selTime.hour, selTime.minute);
          }
        }

      }
    }

    return selDate;
  }

  
      
    
}

Widget _buildBottomPicker(Widget picker) {
  return Container(
    height: _kPickerSheetHeight,
    //padding: const EdgeInsets.only(top: 6.0),
    color: CupertinoColors.white,
    child: DefaultTextStyle(
      style: const TextStyle(
        color: CupertinoColors.black,
        fontSize: 20.0,
      ),
      child: GestureDetector(
        // Blocks taps from propagating to the modal sheet and popping.
        onTap: () {},
        child: SafeArea(
          top: false,
          child: picker,
        ),
      ),
    ),
  );
}

