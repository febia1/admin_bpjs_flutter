import 'package:flutter/material.dart';
import '/models/peserta_model.dart';
import '/db/database_helper.dart';

class FormPesertaScreen extends StatefulWidget {
  final Peserta? peserta;
  const FormPesertaScreen({super.key, this.peserta});

  @override
  State<FormPesertaScreen> createState() => _FormPesertaScreenState();
}

class _FormPesertaScreenState extends State<FormPesertaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nik;
  late TextEditingController _nama;
  late TextEditingController _alamat;
  String? _status;

  @override
  void initState() {
    super.initState();
    _nik = TextEditingController(text: widget.peserta?.nik ?? '');
    _nama = TextEditingController(text: widget.peserta?.nama ?? '');
    _alamat = TextEditingController(text: widget.peserta?.alamat ?? '');
    _status = widget.peserta?.status;
  }

  Future<void> _simpan() async {
    if (_formKey.currentState!.validate()) {
      final data = Peserta(
        id: widget.peserta?.id,
        nik: _nik.text,
        nama: _nama.text,
        alamat: _alamat.text,
        status: _status ?? 'Tidak Aktif',
      );
      if (widget.peserta == null) {
        await DatabaseHelper.instance.create(data);
      } else {
        await DatabaseHelper.instance.update(data);
      }
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peserta == null ? 'Tambah' : 'Edit'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nik,
                decoration: const InputDecoration(labelText: 'NIK', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _alamat,
                decoration: const InputDecoration(labelText: 'Alamat', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Aktif', 'Tidak Aktif']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v),
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                validator: (v) => v == null ? 'Pilih status' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('SIMPAN', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}