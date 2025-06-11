import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class MapGudang extends StatefulWidget {
  const MapGudang({super.key});

  @override
  State<MapGudang> createState() => _MapGudangState();
}

class _MapGudangState extends State<MapGudang> {
  MapController mapController = MapController();
  final LatLng _lokasiGudang = const LatLng(-8.172602, 113.689432);
  LatLng? _lokasiSaatIni;
  bool _isLoading = true;
  String? _errorMessage;

  List<LatLng> _rute = [];
  double _jarak = 0.0;
  String _durasi = '';
  bool _showRute = false;

  @override
  void initState() {
    super.initState();
    _getLokasiSaatIni();
  }
  Future<void> _getLokasiSaatIni() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _lokasiSaatIni = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Izin lokasi ditolak';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Izin lokasi ditolak'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
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
          'Lokasi Gudang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[700],
      ),
      body:
          _lokasiSaatIni == null
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: _lokasiSaatIni!,
                      initialZoom: 13.0,),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          // Marker Lokasi Saat Ini
                          Marker(
                            point: _lokasiSaatIni!,
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                          // Marker Lokasi Gudang
                          Marker(
                            point: _lokasiGudang,
                            width: 80,
                            height: 80,
                            child: Icon(
                              Icons.store,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
    );
  }
}
