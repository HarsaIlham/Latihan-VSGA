import 'package:flutter/material.dart';
import 'package:latihan_vsga/view/transaksi_page.dart';
import 'package:latihan_vsga/view/home_page.dart';
import 'package:latihan_vsga/view/login_page.dart';
import 'package:latihan_vsga/view/map_gudang.dart';
import 'package:latihan_vsga/view/produk.dart';
import 'package:latihan_vsga/view/user_page.dart';

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
      home: LoginPage(),
      routes: {
        '/login' : (context) => const LoginPage(),
        '/home' : (context) => const HomePage(),
        '/ruang_senjata' : (context) => const Produk(),
        '/transaksi-page' : (context) => const TransaksiPage(),
        '/map_gudang' : (context) => const MapGudang(),
        '/user-page': (context) => const UserPage(),
      },
    );
  }
}

