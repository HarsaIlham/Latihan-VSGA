import 'package:flutter/material.dart';
import 'package:latihan_vsga/helpers/db_helper.dart';
import 'package:latihan_vsga/models/roti.dart';

class Produk extends StatefulWidget {
  const Produk({super.key});

  @override
  State<Produk> createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  final _nameController = TextEditingController();
  final _hargaController = TextEditingController();

  List<Roti> _roti = [];
  Roti? _editingRoti;

  @override
  void initState() {
    super.initState();
    _loadRoti();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  Future<void> _loadRoti() async {
    final rotis = await DbHelper.getRotis();
    setState(() => _roti = rotis);
  }

  Future<void> _saveRoti() async {
    if (!_validateForm()) return;

    if (_editingRoti != null) {
      await DbHelper.updateRoti(
        Roti(
          id: _editingRoti!.id,
          nama: _nameController.text.trim(),
          harga: int.parse(_hargaController.text),
        ),
      );
      _editingRoti = null;
    } else {
      await DbHelper.insertRoti(
        Roti(
          id: _editingRoti?.id,
          nama: _nameController.text.trim(),
          harga: int.parse(_hargaController.text),
        ),
      );
    }
    _clearForm();
    _loadRoti();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data produk berhasil disimpan')));
  }

  Future<void> _deleteRoti(int id) async {
    bool confirm = await _showDeleteConfirmDialog();
    if (confirm) {
      await DbHelper.deleteRoti(id);
      _loadRoti();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data produk berhasil dihapus')));
    }
  }

  void _editRoti(Roti roti) {
    setState(() {
      _nameController.text = roti.nama;
      _hargaController.text = roti.harga.toString();
      _editingRoti = roti;
    });
  }

  void _clearForm() {
    _nameController.clear();
    _hargaController.clear();
    setState(() {
      _editingRoti = null;
    });
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty || _hargaController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
        content: const Text('Semua field harus diisi'), 
        backgroundColor: Colors.red[700],
      ));
      return false;
    }
    return true;
  }

  Future<bool> _showDeleteConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Konfirmasi Hapus'),
                content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingRoti != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Produk Page',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        automaticallyImplyLeading: false, // Hilangkan tombol back
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Produk' : 'Tambah Produk Roti Baru',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _hargaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Harga',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _saveRoti,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                          ),
                          child: Text(isEditing ? "Update" : "Tambah"),
                        ),
                        if (isEditing) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _clearForm,
                            child: const Text("Batal"),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _roti.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada data produk',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _roti.length,
                      itemBuilder: (context, index) {
                        final weapon = _roti[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              weapon.nama,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Harga: Rp ${weapon.harga}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editRoti(weapon),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteRoti(weapon.id!),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}