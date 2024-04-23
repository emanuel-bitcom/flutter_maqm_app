import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nfc_basic_application/main.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  image: AssetImage('assets/images/mAQM.jpg'),
                ),
              ),),
    );
  }
}