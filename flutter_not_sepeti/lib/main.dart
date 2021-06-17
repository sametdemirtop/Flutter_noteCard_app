import 'package:flutter/material.dart';
import 'package:flutter_not_sepeti/utils/databse_helper.dart';

import 'notlar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dbhepler = DatabaseHelper();
    dbhepler.kategorileriGetir();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: Notlar(),
    );
  }
}
