import 'package:flutter/material.dart';

// --- BAGIAN 1: MAIN APP ---
void main() {
  runApp(const BpjsAdminApp());
}

class BpjsAdminApp extends StatelessWidget {
  const BpjsAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin BPJS',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A651)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const DashboardPage(),
    );
  }
}

// --- BAGIAN 2: MODEL DATA (Kode yang Anda kirim) ---
class Peserta {
  int? id;
  String nik;
  String nama;
  String alamat;
  String status;

  Peserta({
    this.id,
    required this.nik,
    required this.nama,
    required this.alamat,
    required this.status,
  });

  // Untuk mengubah data dari Map (Database/API) ke bentuk Peserta
  factory Peserta.fromMap(Map<String, dynamic> map) {
    return Peserta(
      id: map['id'],
      nik: map['nik'],
      nama: map['nama'],
      alamat: map['alamat'],
      status: map['status'],
    );
  }

  // Untuk mengubah data Peserta menjadi Map (simpan ke Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nik': nik,
      'nama': nama,
      'alamat': alamat,
      'status': status,
    };
  }
}

// --- BAGIAN 3: DASHBOARD ---
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // List sekarang menggunakan class 'Peserta', bukan Map biasa
  List<Peserta> daftarPeserta = [
    Peserta(nik: "32010123456789", nama: "Budi Santoso", alamat: "Jl. Merdeka No. 1", status: "Aktif"),
    Peserta(nik: "32010987654321", nama: "Siti Aminah", alamat: "Jl. Mawar Melati", status: "Menunggak"),
  ];

  // Fungsi untuk buka halaman Form
  void _tambahDataBaru() async {
    final Peserta? dataBaru = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormPesertaPage()),
    );

    if (dataBaru != null) {
      setState(() {
        daftarPeserta.insert(0, dataBaru); // Masukkan data object Peserta ke list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin BPJS Kesehatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00A651),
        actions: const [
           Padding(
             padding: EdgeInsets.only(right: 16.0),
             child: Icon(Icons.account_circle, color: Colors.white, size: 30),
           )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahDataBaru,
        label: const Text("Input Pasien", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF00A651),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Statistik Singkat ---
              const Text("Ringkasan Data", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              GridView.count(
                crossAxisCount: isDesktop ? 4 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.0, // Kartu lebih pendek
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _MiniCard(label: "Total Peserta", value: "${daftarPeserta.length}", color: Colors.blue),
                  const _MiniCard(label: "Perlu Verifikasi", value: "5", color: Colors.orange),
                ],
              ),
              
              const SizedBox(height: 30),
              const Text("Daftar Peserta Terbaru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // --- LIST DATA PESERTA ---
              daftarPeserta.isEmpty 
              ? const Center(child: Text("Belum ada data pasien"))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: daftarPeserta.length,
                  itemBuilder: (context, index) {
                    final peserta = daftarPeserta[index];
                    
                    // Menentukan warna badge status
                    Color statusColor = Colors.green;
                    if (peserta.status == 'Menunggak') statusColor = Colors.orange;
                    if (peserta.status == 'Non-Aktif') statusColor = Colors.red;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF00A651).withOpacity(0.2),
                          child: Text(peserta.nama[0], style: const TextStyle(color: Color(0xFF00A651), fontWeight: FontWeight.bold)),
                        ),
                        title: Text(peserta.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("NIK: ${peserta.nik}"),
                            Text("Alamat: ${peserta.alamat}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(peserta.status, style: const TextStyle(color: Colors.white, fontSize: 10)),
                          backgroundColor: statusColor,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// --- BAGIAN 4: FORM INPUT PASIEN ---
class FormPesertaPage extends StatefulWidget {
  const FormPesertaPage({super.key});

  @override
  State<FormPesertaPage> createState() => _FormPesertaPageState();
}

class _FormPesertaPageState extends State<FormPesertaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk menangkap inputan
  final TextEditingController nikController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  String statusTerpilih = "Aktif";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Input Pasien Baru"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView( // Agar bisa discroll saat keyboard muncul
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Input NIK
                TextFormField(
                  controller: nikController,
                  keyboardType: TextInputType.number,
                  maxLength: 16, // Batas NIK 16 digit
                  decoration: const InputDecoration(
                    labelText: "NIK (Nomor Induk Kependudukan)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'NIK wajib diisi';
                    if (value.length < 16) return 'NIK harus 16 digit';
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Input Nama
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: "Nama Lengkap Pasien",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 15),

                // Input Alamat
                TextFormField(
                  controller: alamatController,
                  maxLines: 3, // Kotak teks lebih besar
                  decoration: const InputDecoration(
                    labelText: "Alamat Lengkap",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                  ),
                  validator: (value) => value!.isEmpty ? 'Alamat wajib diisi' : null,
                ),
                const SizedBox(height: 15),

                // Pilihan Status
                DropdownButtonFormField<String>(
                  value: statusTerpilih,
                  decoration: const InputDecoration(
                    labelText: "Status Kepesertaan",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.verified_user),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Aktif", child: Text("Aktif")),
                    DropdownMenuItem(value: "Menunggak", child: Text("Menunggak")),
                    DropdownMenuItem(value: "Non-Aktif", child: Text("Non-Aktif")),
                  ],
                  onChanged: (val) => setState(() => statusTerpilih = val!),
                ),
                const SizedBox(height: 30),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A651)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Membuat Object Peserta dari Data Inputan
                        Peserta pasienBaru = Peserta(
                          nik: nikController.text,
                          nama: namaController.text,
                          alamat: alamatController.text,
                          status: statusTerpilih,
                        );

                        // Kirim balik data Peserta ke halaman Dashboard
                        Navigator.pop(context, pasienBaru);
                      }
                    },
                    child: const Text("SIMPAN DATA PASIEN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget Kecil untuk Statistik
class _MiniCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}