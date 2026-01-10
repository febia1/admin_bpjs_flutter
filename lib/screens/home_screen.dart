import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/peserta_model.dart';
import 'form_peserta_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Peserta> _dataPeserta = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Fungsi mengambil data dari database
  Future<void> _refreshData({String? keyword}) async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllPeserta(keyword: keyword);
    setState(() {
      _dataPeserta = data;
      _isLoading = false;
    });
  }

  // Navigasi ke Form (Tambah/Edit)
  void _bukaForm({Peserta? peserta}) async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormPesertaScreen(peserta: peserta)),
    );
    // Jika kembali setelah simpan data, refresh list
    if (hasil == true) {
      _refreshData();
    }
  }

  // Fungsi Hapus
  void _hapusData(int id) async {
    await DatabaseHelper.instance.delete(id);
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Peserta BPJS'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Kolom Pencarian
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari NIK atau Nama...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => _refreshData(keyword: value),
            ),
          ),
          // Daftar List Peserta
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _dataPeserta.isEmpty
                    ? const Center(child: Text('Belum ada data'))
                    : ListView.builder(
                        itemCount: _dataPeserta.length,
                        itemBuilder: (context, index) {
                          final item = _dataPeserta[index];
                          final isAktif = item.status == 'Aktif';
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isAktif ? Colors.green : Colors.red,
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('NIK: ${item.nik}\n${item.status}'),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _bukaForm(peserta: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _hapusData(item.id!),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bukaForm(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}