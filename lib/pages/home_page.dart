import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nfc_basic_application/main.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitHeight,
            image: AssetImage('assets/images/mAQM.jpg'),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Discover mAQM",
                style: GoogleFonts.pacifico(
                  fontSize: 30,
                  color: Colors.lightBlue[50],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
