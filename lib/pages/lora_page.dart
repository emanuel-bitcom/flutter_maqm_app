import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_basic_application/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

class LoraPage extends StatefulWidget {
  const LoraPage({super.key});

  @override
  State<LoraPage> createState() => _LoraPageState();
}

class _LoraPageState extends State<LoraPage> {
  ValueNotifier<dynamic> result = ValueNotifier(null);

  final TextEditingController appKeyController = TextEditingController();
  String appKeyLabel = 'AppKey';
  final TextEditingController appEuiController = TextEditingController();
  String appEuiLabel = 'AppEUI';

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
                    flex: 14,
                    child: GridView.count(
                      padding: EdgeInsets.all(4),
                      crossAxisCount: 1,
                      childAspectRatio: 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      children: [
                        CenteredLabel(
                          label: appEuiLabel,
                        ),
                        FlexHexTextField(
                            hexLength: 8,
                            numberController: appEuiController,
                            label: appEuiLabel),
                        CenteredLabel(label: appKeyLabel),
                        FlexHexTextField(
                            hexLength: 16,
                            numberController: appKeyController,
                            label: appKeyLabel),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: _tagWriteLoraSettings,
                      child: Text('Write Lora Settings'),
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

  List<int> hexStringToUint8List(String hexString) {
    int number = int.parse(hexString, radix: 16);
    return List<int>.generate(4, (i) => (number >> ((3 - i) * 8)) & 0xFF);
  }

  Uint8List buildWriteCommand(
      int writeCommand, int writeAddress, List<int> writeData) {
    List<int> concatenatedList = []
      ..addAll([writeCommand, writeAddress])
      ..addAll(writeData);
    return Uint8List.fromList(concatenatedList);
  }

  void _tagWriteLoraSettings() {
    /**Strings have a strict length requirement */
    if ((appEuiController.text.length != 16) ||
        (appKeyController.text.length != 32)) {
      return;
    }

    int writeCommand = 0xA2;
    List<int> writeEuiAddresses = [0x04, 0x05];
    List<int> writeKeyAddresses = [0x08, 0x09, 0x0A, 0x0B];
    List<int> writeFlagAddress = [0x0C];

    String appEuiFirstHalf = appEuiController.text.substring(0, 8);
    String appEuiSecondHalf = appEuiController.text.substring(8, 16);

    List<int> appEuiFirstList = hexStringToUint8List(appEuiFirstHalf);
    List<int> appEuiSecondList = hexStringToUint8List(appEuiSecondHalf);

    Uint8List writeCmdAppEuiFirst =
        buildWriteCommand(writeCommand, writeEuiAddresses[0], appEuiFirstList);
    Uint8List writeCmdAppEuiSecond =
        buildWriteCommand(writeCommand, writeEuiAddresses[1], appEuiSecondList);

    String appKeyFirstQuarter = appKeyController.text.substring(0, 8);
    String appKeySecondQuarter = appKeyController.text.substring(8, 16);
    String appKeyThirdQuarter = appKeyController.text.substring(16, 24);
    String appKeyFourthQuarter = appKeyController.text.substring(24, 32);

    List<int> appKeyFirstQuarterList = hexStringToUint8List(appKeyFirstQuarter);
    List<int> appKeySecondQuarterList =
        hexStringToUint8List(appKeySecondQuarter);
    List<int> appKeyThirdQuarterList = hexStringToUint8List(appKeyThirdQuarter);
    List<int> appKeyFourthQuarterList =
        hexStringToUint8List(appKeyFourthQuarter);

    Uint8List writeCmdAppKeyFirst = buildWriteCommand(
        writeCommand, writeKeyAddresses[0], appKeyFirstQuarterList);
    Uint8List writeCmdAppKeySecond = buildWriteCommand(
        writeCommand, writeKeyAddresses[1], appKeySecondQuarterList);
    Uint8List writeCmdAppKeyThird = buildWriteCommand(
        writeCommand, writeKeyAddresses[2], appKeyThirdQuarterList);
    Uint8List writeCmdAppKeyFourth = buildWriteCommand(
        writeCommand, writeKeyAddresses[3], appKeyFourthQuarterList);

    List<int> flag = [0xFF, 0xFF, 0xFF, 0xFF];

    Uint8List writeCmdFlag =
        buildWriteCommand(writeCommand, writeFlagAddress[0], flag);

    List<Uint8List> commands = [
      writeCmdAppEuiFirst,
      writeCmdAppEuiSecond,
      writeCmdAppKeyFirst,
      writeCmdAppKeySecond,
      writeCmdAppKeyThird,
      writeCmdAppKeyFourth,
      writeCmdFlag,
    ];

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        var ntagA = NfcA.from(tag);
        if (ntagA == null) {
          result.value = 'Tag is not ntagA';
          NfcManager.instance.stopSession(errorMessage: result.value);
          return;
        }

        /**
         * Send all the data via NFC
         */
        for (int i = 0; i < commands.length; i++) {
          try {
            Uint8List futureBytes =
                await ntagA.transceive(data: commands[i]);
            result.value = futureBytes;
          } catch (e) {
            result.value = e;
            NfcManager.instance
                .stopSession(errorMessage: result.value.toString());
            return;
          }
        }
      },
    );
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

class FlexHexTextField extends StatefulWidget {
  final TextEditingController numberController;

  FlexHexTextField({
    super.key,
    required this.numberController,
    required this.label,
    required this.hexLength,
  });

  final String label;
  final int hexLength;

  @override
  State<FlexHexTextField> createState() => _FlexHexTextFieldState();
}

class _FlexHexTextFieldState extends State<FlexHexTextField> {
  String _hexString = '';
  String _hexText = '';
  final TextEditingController hexStringController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4),
      constraints: BoxConstraints.expand(),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black26,
          width: 2,
        ),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: TextField(
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: 10,
        ),
        cursorHeight: 15,
        cursorRadius: Radius.circular(10),
        controller: hexStringController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: Colors.grey[400],
            )),
        onChanged: (value) {
          setState(() {
            _hexString = '';
            _hexText = '';
            int j = 0;
            for (int i = 0, j = 0; i < value.length; i++) {
              if (((value[i].codeUnitAt(0) >= 48 &&
                          value[i].codeUnitAt(0) <= 57) || // 0-9
                      (value[i].codeUnitAt(0) >= 65 &&
                          value[i].codeUnitAt(0) <= 70) || // A-F
                      (value[i].codeUnitAt(0) >= 97 &&
                          value[i].codeUnitAt(0) <= 102)) &&
                  j / 2 < widget.hexLength) {
                //it is a valid value so increase the value index
                j++;
                // a-f
                _hexString += value[i];
                _hexText += value[i].toUpperCase();
                if ((j) % 2 == 0) {
                  _hexText += ' ';
                }
              }
            }
            widget.numberController.text = _hexString;
            hexStringController.text = _hexText;
            hexStringController.selection = TextSelection.fromPosition(
                TextPosition(offset: hexStringController.text.length));
          });
        },
      ),
    );
  }
}
