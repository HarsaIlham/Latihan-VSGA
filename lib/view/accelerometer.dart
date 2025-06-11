import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class Accelerometer extends StatefulWidget {
  const Accelerometer({super.key});

  @override
  State<Accelerometer> createState() => _AccelerometerState();
}

class _AccelerometerState extends State<Accelerometer> {
  double _x = 0.0, _y = 0.0, _z = 0.0;
  StreamSubscription<AccelerometerEvent>? _subAcc;

  bool _isListening = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _subAcc?.cancel();
    super.dispose();
  }

  void _listenAcc() {
    setState(() {
      _isListening = true;
    });

    _subAcc = accelerometerEventStream(
      samplingPeriod: Duration(milliseconds: 100),
    ).listen((event) {
      if (!mounted) return;
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        title: const Text(
          'Accelerometer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown[700],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('X: $_x', style: const TextStyle(fontSize: 24)),
            Text('Y: $_y', style: const TextStyle(fontSize: 24)),
            Text('Z: $_z', style: const TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _listenAcc,
              child: Text('Baca Sensor', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
