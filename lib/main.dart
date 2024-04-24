import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nfc_basic_application/dafaults/defaults.dart';
import 'package:flutter_nfc_basic_application/pages/date_page.dart';
import 'package:flutter_nfc_basic_application/pages/home_page.dart';
import 'package:flutter_nfc_basic_application/pages/lora_page.dart';
import 'package:flutter_nfc_basic_application/pages/testnfc_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

var indexClicked = 0;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final pages = [
    HomePage(),
    DatePage(),
    LoraPage(),
    TestNfcPage(),
  ];

  void Function() updateState(int index) {
    return () {
      setState(() {
        indexClicked = index;
      });
      Navigator.pop(context);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue[300],
        title: Text(
          'mAQM NFC Tools',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: pages[indexClicked],
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/images/drawer.jpg'),
                ),
              ),
              padding: EdgeInsets.all(0),
              child: Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          AssetImage('assets/images/BitLogoOnly.png'),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Mini Air Quality Monitor',
                      style: GoogleFonts.pacifico(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    SizedBox(
                      height: 1,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  AppDrawerTile(
                    index: 0,
                    onTileTap: updateState(0),
                  ),
                  AppDrawerTile(
                    index: 1,
                    onTileTap: updateState(1),
                  ),
                  AppDrawerTile(
                    index: 2,
                    onTileTap: updateState(2),
                  ),
                  AppDrawerTile(
                    index: 3,
                    onTileTap: updateState(3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppDrawerTile extends StatelessWidget {
  const AppDrawerTile({
    super.key,
    required this.index,
    required this.onTileTap,
  });

  final int index;
  final void Function() onTileTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTileTap,
      leading: Icon(
        Defaults.drawerItemIcon[index],
        size: 35,
        color: indexClicked == index
            ? Defaults.drawerItemSelectedColor
            : Defaults.drawerItemColor,
      ),
      title: Text(Defaults.drawerItemText[index],
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: indexClicked == index
                ? Defaults.drawerItemSelectedColor
                : Defaults.drawerItemColor,
          )),
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
