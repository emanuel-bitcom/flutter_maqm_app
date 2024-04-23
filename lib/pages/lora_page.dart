import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_basic_application/main.dart';
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
                      flex: 4,
                      child: GridView.count(
                        padding: EdgeInsets.all(4),
                        crossAxisCount: 2,
                        childAspectRatio: 4,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        children: [
                          CenteredLabel(label: appEuiLabel),
                          FlexDateTextField(
                              numberController: appEuiController,
                              label: appEuiLabel),
                          CenteredLabel(label: appKeyLabel),
                          FlexDateTextField(
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
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _tagWriteLoraSettings,
                        child: Text('Write Lora Settings'),
                      ),
                    ),
                  ],
                ),
        ),
      );
  }
  void _tagWriteLoraSettings() {
    
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