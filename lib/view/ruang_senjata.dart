import 'package:flutter/material.dart';
import 'package:latihan_vsga/helpers/db_helper.dart';
import 'package:latihan_vsga/models/senjata.dart';

class RuangSenjata extends StatefulWidget {
  const RuangSenjata({super.key});

  @override
  State<RuangSenjata> createState() => _RuangSenjataState();
}

class _RuangSenjataState extends State<RuangSenjata> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();

  List<Senjata> _senjata = [];
  Senjata? _editingWeapon;

  @override
  void initState() {
    super.initState();
    _loadWeapons();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadWeapons() async {
    final senjatas = await DbHelper.getSenjatas();
    setState(() => _senjata = senjatas);
  }

  Future<void> _saveWeapon() async {
    if (!_validateForm()) return;

    if (_editingWeapon != null) {
      // Update existing weapon
      await DbHelper.updateSenjata(
        Senjata(
          id: _editingWeapon!.id,
          nama: _nameController.text.trim(),
          jumlah: int.parse(_quantityController.text),
        ),
      );
      _editingWeapon = null;
    } else {
      await DbHelper.insertSenjata(
        Senjata(
          id: _editingWeapon?.id,
          nama: _nameController.text.trim(),
          jumlah: int.parse(_quantityController.text),
        ),
      );
    }
    _clearForm();
    _loadWeapons();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Data senjata berhasil disimpan')));
  }

  // Delete weapon (mirip _deleteTodo di referensi)
  Future<void> _deleteWeapon(int id) async {
    bool confirm = await _showDeleteConfirmDialog();
    if (confirm) {
      await DbHelper.deleteSenjata(id);
      _loadWeapons();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Data senjata berhasil dihapus')));
    }
  }

  // Edit weapon (mirip _editTodo di referensi)
  void _editWeapon(Senjata weapon) {
    setState(() {
      _nameController.text = weapon.nama;
      _quantityController.text = weapon.jumlah.toString();
      _editingWeapon = weapon;
    });
  }

  void _clearForm() {
    _nameController.clear();
    _quantityController.clear();
    setState(() {
      _editingWeapon = null;
    });
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Semua field harus diisi'), backgroundColor: Colors.red[700],));
      return false;
    }
    return true;
  }

  Future<bool> _showDeleteConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Konfirmasi Hapus'),
                content: Text('Apakah Anda yakin ingin menghapus data ini?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Hapus', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
        ) ??
        false;
  }

  

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingWeapon != null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        title: const Text(
          'Ruang Senjata',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Form Input Section
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Senjata' : 'Tambah Senjata Baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Senjata',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Jumlah',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _saveWeapon,
                          child: Text(isEditing ? "Update" : "Tambah"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                        if (isEditing) ...[
                          SizedBox(width: 8),
                          TextButton(
                            onPressed: _clearForm,
                            child: Text("Batal"),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child:
                  _senjata.isEmpty
                      ? Center(
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
                              'Tidak ada data senjata',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _senjata.length,
                        itemBuilder: (context, index) {
                          final weapon = _senjata[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                weapon.nama,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Jumlah: ${weapon.jumlah}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editWeapon(weapon),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteWeapon(weapon.id!),
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
