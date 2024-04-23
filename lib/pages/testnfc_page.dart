import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nfc_basic_application/dafaults/defaults.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';


class TestNfcPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TestNfcPageState();
}

class TestNfcPageState extends State<TestNfcPage> {
  ValueNotifier<dynamic> result = ValueNotifier(null);

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
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(4),
                        constraints: BoxConstraints.expand(),
                        decoration: BoxDecoration(border: Border.all()),
                        child: SingleChildScrollView(
                          child: ValueListenableBuilder<dynamic>(
                            valueListenable: result,
                            builder: (context, value, _) =>
                                Text('${value ?? ''}'),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: GridView.count(
                        padding: EdgeInsets.all(4),
                        crossAxisCount: 2,
                        childAspectRatio: 4,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        children: [
                          ElevatedButton(
                              child: Text('Tag Read'), onPressed: _tagRead),
                          ElevatedButton(
                              child: Text('NfcA Read Memory'),
                              onPressed: _nfcaRead),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      );
  }

  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      result.value = tag.data;
      NfcManager.instance.stopSession();
    });
  }

  void _nfcaRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ntagA = NfcA.from(tag);
      if (ntagA == null) {
        result.value = 'Tag is not ntagA';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }
      Uint8List readCmd = Uint8List.fromList([0x30, 0x10]);
      try {
        Uint8List futureBytes = await ntagA.transceive(data: readCmd);
        result.value = futureBytes;
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
            )),
      ),
    );
  }
}
