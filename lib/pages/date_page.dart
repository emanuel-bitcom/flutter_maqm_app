import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nfc_basic_application/dafaults/defaults.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

class DatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DatePageState();
}

class DatePageState extends State<DatePage> {
  ValueNotifier<dynamic> result = ValueNotifier(null);

  final TextEditingController yearController = TextEditingController();
  String yearLabel = 'year';
  final TextEditingController monthController = TextEditingController();
  String monthLabel = 'month';
  final TextEditingController dayController = TextEditingController();
  String dayLabel = 'day';
  final TextEditingController weekdayController = TextEditingController();
  String weekdayLabel = 'weekday 1 = Sunday';
  String weekdayLabelShort = 'weekday';
  final TextEditingController hourController = TextEditingController();
  String hourLabel = 'hour';
  final TextEditingController minuteController = TextEditingController();
  String minuteLabel = 'minute';
  final TextEditingController secondController = TextEditingController();
  String secondLabel = 'second';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<bool>(
        future: NfcManager.instance.isAvailable(),
        builder: (context, ss) => ss.data != true
            ? Center(child: Text('NfcManager.isAvailable(): ${ss.data}'))
            : Flex(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                direction: Axis.vertical,
                children: [
                  Flexible(
                    flex: 6,
                    child: GridView.count(
                      padding: EdgeInsets.all(4),
                      crossAxisCount: 2,
                      childAspectRatio: 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      children: [
                        CenteredLabel(label: yearLabel),
                        FlexDateTextField(
                            numberController: yearController, label: yearLabel),
                        CenteredLabel(label: monthLabel),
                        FlexDateTextField(
                            numberController: monthController,
                            label: monthLabel),
                        CenteredLabel(label: dayLabel),
                        FlexDateTextField(
                            numberController: dayController, label: dayLabel),
                        CenteredLabel(label: weekdayLabelShort),
                        FlexDateTextField(
                            numberController: weekdayController,
                            label: weekdayLabel),
                        CenteredLabel(label: hourLabel),
                        FlexDateTextField(
                            numberController: hourController, label: hourLabel),
                        CenteredLabel(label: minuteLabel),
                        FlexDateTextField(
                            numberController: minuteController,
                            label: minuteLabel),
                        CenteredLabel(label: secondLabel),
                        FlexDateTextField(
                            numberController: secondController,
                            label: secondLabel),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: _tagFillDate,
                      child: Text('Fill current date'),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: _tagWriteDate,
                      child: Text('Write date'),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _tagFillDate() {
    return setState(() {
      DateTime now = DateTime.now();
      int year_int = now.year;
      int month_int = now.month;
      int day_int = now.day;
      int weekday_int = now.weekday + 1;
      if (weekday_int == 8) weekday_int = 1;
      int hour_int = now.hour;
      int minute_int = now.minute;
      int second_int = now.second;
      yearController.text = year_int.toString();
      monthController.text = month_int.toString();
      dayController.text = day_int.toString();
      weekdayController.text = weekday_int.toString();
      hourController.text = hour_int.toString();
      minuteController.text = minute_int.toString();
      secondController.text = second_int.toString();
    });
  }

  void _tagWriteDate() {
    int year_int = int.parse(yearController.text) - 2000;
    int month_int = int.parse(monthController.text);
    int month_bcd = month_int % 10 + ((month_int / 10).floor() << 4);
    int day_int = int.parse(dayController.text);
    int weekday_int = int.parse(weekdayController.text);
    int hour_int = int.parse(hourController.text);
    int minute_int = int.parse(minuteController.text);
    int second_int = int.parse(secondController.text);

    /**
     * Error proofing
     *  */
    if (year_int > 99 || year_int < 0) year_int = 0;
    if (month_bcd > 0x12 || month_bcd < 0x01) month_bcd = 0x01;
    if (day_int < 1 || day_int > 31) day_int = 1;
    if (weekday_int > 7 || weekday_int < 1) weekday_int = 1;
    if (hour_int > 23 || hour_int < 0) hour_int = 0;
    if (minute_int > 59 || minute_int < 0) minute_int = 0;
    if (second_int > 59 || second_int < 0) second_int = 0;

    Uint8List year_write_cmd =
        Uint8List.fromList([0xA2, 0x10, year_int, 0, 0, 0]);
    Uint8List month_write_cmd =
        Uint8List.fromList([0xA2, 0x12, month_bcd, 0, 0, 0]);
    Uint8List day_write_cmd =
        Uint8List.fromList([0xA2, 0x11, day_int, 0, 0, 0]);
    Uint8List weekday_write_cmd =
        Uint8List.fromList([0xA2, 0x13, weekday_int, 0, 0, 0]);
    Uint8List hour_write_cmd =
        Uint8List.fromList([0xA2, 0x14, hour_int, 0, 0, 0]);
    Uint8List minute_write_cmd =
        Uint8List.fromList([0xA2, 0x15, minute_int, 0, 0, 0]);
    Uint8List second_write_cmd =
        Uint8List.fromList([0xA2, 0x16, second_int, 0, 0, 0]);
    Uint8List flag_write_cmd =
        Uint8List.fromList([0xA2, 0x18, 0xFF, 0xFF, 0xFF, 0xFF]);

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ntagA = NfcA.from(tag);
      if (ntagA == null) {
        result.value = 'Tag is not ntagA';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }
      try {
        Uint8List futureBytes = await ntagA.transceive(data: year_write_cmd);
        result.value = futureBytes;
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
      try {
        Uint8List futureBytes = await ntagA.transceive(data: month_write_cmd);
        result.value += futureBytes;
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
      try {
        Uint8List futureBytes = await ntagA.transceive(data: day_write_cmd);
        result.value += futureBytes;
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
      try {
        Uint8List futureBytes = await ntagA.transceive(data: weekday_write_cmd);
        result.value += futureBytes;
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
      try {
        Uint8List futureBytes = await ntagA.transceive(data: hour_write_cmd);
        result.value += futureBytes;
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
      try {
        Uint8List futureBytes = await ntagA.transceive(data: minute_write_cmd);
        result.value += futureBytes;
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
      try {
        Uint8List futureBytes = await ntagA.transceive(data: second_write_cmd);
        result.value += futureBytes;
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
      try {
        Uint8List futureBytes = await ntagA.transceive(data: flag_write_cmd);
        result.value += futureBytes;
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
      // result.value = ntagA.;
      NfcManager.instance.stopSession();
    });
  }
}

class CenteredLabel extends StatelessWidget {
  const CenteredLabel({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
    );
  }
}

class FlexDateTextField extends StatelessWidget {
  const FlexDateTextField({
    super.key,
    required this.numberController,
    required this.label,
  });

  final TextEditingController numberController;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4),
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(border: Border.all()),
      child: TextField(
        controller: numberController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[400],
          ),
          floatingLabelAlignment: FloatingLabelAlignment.center,
        ),
      ),
    );
  }
}
