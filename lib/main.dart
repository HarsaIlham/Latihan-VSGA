import 'package:flutter/material.dart';
import 'package:latihan_vsga/view/accelerometer.dart';
import 'package:latihan_vsga/view/home_page.dart';
import 'package:latihan_vsga/view/login_page.dart';
import 'package:latihan_vsga/view/map_gudang.dart';
import 'package:latihan_vsga/view/ruang_senjata.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Latihan VSGA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      routes: {
        '/login' : (context) => const LoginPage(),
        '/home' : (context) => const HomePage(),
        '/ruang_senjata' : (context) => const RuangSenjata(),
        '/accelerometer' : (context) => const Accelerometer(),
        '/map_gudang' : (context) => const MapGudang(),
      },
    );
  }
}

