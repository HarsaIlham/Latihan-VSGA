import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

import 'package:latihan_vsga/helpers/db_helper.dart';
import 'package:latihan_vsga/models/roti.dart';
import 'package:latihan_vsga/models/transaksi.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<Roti> _rotiList = [];
  List<Map<String, dynamic>> _keranjang = [];
  bool _isLoading = true;
  LatLng? _lokasiSaatIni;
  String? _errorMessage;

  final TextEditingController _namaController = TextEditingController();
  String _lokasiPembeli = '';
  bool _isLoadingLocation = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadRoti();
    _getLokasiSaatIni();
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _getLokasiSaatIni() async {
    setState(() {
      _isLoadingLocation = true;
      _lokasiPembeli = '';
    });

    try {
      // Cek izin lokasi
      PermissionStatus status = await Permission.location.request();
      if (!status.isGranted) {
        setState(() {
          _errorMessage = 'Izin lokasi ditolak';
          _lokasiPembeli = 'Izin lokasi ditolak';
          _isLoading = false;
          _isLoadingLocation = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Izin lokasi ditolak'),
              backgroundColor: Colors.red[700],
            ),
          );
        }
        return;
      }

      // Cek apakah GPS aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _lokasiPembeli = 'GPS tidak aktif';
          _isLoadingLocation = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Harap aktifkan GPS'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Dapatkan posisi saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      setState(() {
        _lokasiSaatIni = LatLng(position.latitude, position.longitude);
        _currentPosition = position;
        _lokasiPembeli = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
        _isLoading = false;
        _isLoadingLocation = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mendapatkan lokasi: $e';
        _lokasiPembeli = 'Gagal mendapatkan lokasi';
        _isLoading = false;
        _isLoadingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan lokasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  Future<void> _loadRoti() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rotiList = await DbHelper.getRotis();
      setState(() {
        _rotiList = rotiList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading produk: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addToKeranjang(Roti roti, int jumlah) {
    setState(() {
      // Cek apakah produk sudah ada di keranjang
      int existingIndex = _keranjang.indexWhere(
        (item) => item['roti'].id == roti.id,
      );

      if (existingIndex != -1) {
        // Update jumlah jika produk sudah ada
        _keranjang[existingIndex]['jumlah'] += jumlah;
      } else {
        // Tambah produk baru ke keranjang
        _keranjang.add({
          'roti': roti,
          'jumlah': jumlah,
          'total': roti.harga * jumlah,
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${roti.nama} ditambahkan ke keranjang'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeFromKeranjang(int index) {
    setState(() {
      _keranjang.removeAt(index);
    });
  }

  void _updateJumlahKeranjang(int index, int newJumlah) {
    if (newJumlah <= 0) {
      _removeFromKeranjang(index);
      return;
    }

    setState(() {
      _keranjang[index]['jumlah'] = newJumlah;
      _keranjang[index]['total'] = _keranjang[index]['roti'].harga * newJumlah;
    });
  }

  double _getTotalKeranjang() {
    return _keranjang.fold(0, (total, item) => total + item['total']);
  }

  void _showAddToCartDialog(Roti roti) {
    int jumlah = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Tambah ${roti.nama}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatCurrency(roti.harga.toDouble()),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed:
                            jumlah > 1
                                ? () {
                                  setDialogState(() {
                                    jumlah--;
                                  });
                                }
                                : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          jumlah.toString(),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setDialogState(() {
                            jumlah++;
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total: ${_formatCurrency((roti.harga * jumlah).toDouble())}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addToKeranjang(roti, jumlah);
                  },
                  child: const Text('Tambah ke Keranjang'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _prosesTransaksi() async {
    if (_keranjang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang masih kosong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama pembeli harus diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_lokasiPembeli.isEmpty ||
        _lokasiPembeli.contains('Gagal') ||
        _lokasiPembeli.contains('ditolak') ||
        _lokasiPembeli.contains('tidak aktif')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi pembeli belum tersedia'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Simpan setiap item dalam keranjang sebagai transaksi terpisah
      for (var item in _keranjang) {
        Transaksi transaksi = Transaksi(
          produkId: item['roti'].id,
          jumlah: item['jumlah'],
          namaPembeli: _namaController.text.trim(),
          lokasiPembeli: _lokasiPembeli,
        );
        await DbHelper.insertTransaksi(transaksi);
      }

      // Kosongkan keranjang dan form
      setState(() {
        _keranjang.clear();
        _namaController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving transaksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showKeranjang() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Keranjang Belanja',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
              
                    if (_keranjang.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Keranjang kosong',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: _keranjang.length,
                          itemBuilder: (context, index) {
                            final item = _keranjang[index];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['roti'].nama,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _formatCurrency(
                                              item['roti'].harga.toDouble(),
                                            ),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            _updateJumlahKeranjang(
                                              index,
                                              item['jumlah'] - 1,
                                            );
                                            setBottomSheetState(() {});
                                          },
                                          icon: const Icon(Icons.remove),
                                        ),
                                        Text(item['jumlah'].toString()),
                                        IconButton(
                                          onPressed: () {
                                            _updateJumlahKeranjang(
                                              index,
                                              item['jumlah'] + 1,
                                            );
                                            setBottomSheetState(() {});
                                          },
                                          icon: const Icon(Icons.add),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _formatCurrency(item['total'].toDouble()),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              
                    if (_keranjang.isNotEmpty) ...[
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatCurrency(_getTotalKeranjang()),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _prosesTransaksi();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Proses Transaksi',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Page",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _showKeranjang,
              ),
              if (_keranjang.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _keranjang.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _rotiList.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bakery_dining, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada produk tersedia',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Header info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue[50],
                    child: const Text(
                      'Pilih produk yang ingin dibeli',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Product grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 140, // Extra space for bottom form
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _rotiList.length,
                      itemBuilder: (context, index) {
                        final roti = _rotiList[index];

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        roti.nama,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatCurrency(roti.harga.toDouble()),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const Spacer(),

                                      // Add button
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed:
                                              () => _showAddToCartDialog(roti),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue[700],
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            'Tambah',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pembeli',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),

            // Nama Pembeli
            TextFormField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama Pembeli',
                hintText: 'Masukkan nama lengkap',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Lokasi Pembeli
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lokasi Pembeli',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        _isLoadingLocation
                            ? const Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Mendapatkan lokasi...'),
                              ],
                            )
                            : Text(
                              _lokasiPembeli.isEmpty
                                  ? 'Lokasi tidak tersedia'
                                  : _lokasiPembeli,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    _lokasiPembeli.contains('Gagal') ||
                                            _lokasiPembeli.contains('ditolak') ||
                                            _lokasiPembeli.contains('tidak aktif')
                                        ? Colors.red
                                        : Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _isLoadingLocation ? null : _getLokasiSaatIni,
                    tooltip: 'Refresh lokasi',
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