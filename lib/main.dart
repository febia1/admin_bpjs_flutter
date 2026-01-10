import 'package:flutter/material.dart';

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

// --- HALAMAN DASHBOARD (UTAMA) ---
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Ini adalah DATA SEMENTARA (List) yang akan tampil di layar
  List<Map<String, dynamic>> daftarPeserta = [
    {"nama": "Budi Santoso", "bpjs": "123456789", "status": "Aktif", "color": Colors.green},
    {"nama": "Siti Aminah", "bpjs": "987654321", "status": "Menunggak", "color": Colors.orange},
    {"nama": "Joko Anwar", "bpjs": "456123789", "status": "Aktif", "color": Colors.green},
  ];

  // Fungsi untuk menerima data baru dari Halaman Form
  void _tambahDataBaru() async {
    final dataBaru = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormPesertaPage()),
    );

    // Jika ada data yang dikirim balik (tidak tombol back), masukkan ke list
    if (dataBaru != null) {
      setState(() {
        daftarPeserta.insert(0, dataBaru); // Masukkan ke urutan paling atas
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek lebar layar (Responsif)
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin BPJS Kesehatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00A651),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // --- TOMBOL TAMBAH (Floating Action Button) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahDataBaru, // Saat diklik, panggil fungsi tambah
        label: const Text("Tambah Peserta", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF00A651),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Dashboard Overview", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // --- KARTU STATISTIK ---
              GridView.count(
                crossAxisCount: isDesktop ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isDesktop ? 1.6 : 1.3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _InfoCard(title: "Total Peserta", value: "${daftarPeserta.length + 254000}", icon: Icons.groups, color1: Colors.blue, color2: Colors.blueAccent),
                  const _InfoCard(title: "Iuran Lunas", value: "85%", icon: Icons.check_circle_outline, color1: Colors.green, color2: Colors.lightGreen),
                  const _InfoCard(title: "Menunggak", value: "Rp 450jt", icon: Icons.warning_amber_rounded, color1: Colors.orange, color2: Colors.deepOrange),
                  const _InfoCard(title: "Antrian Faskes", value: "1.205", icon: Icons.local_hospital_outlined, color1: Colors.purple, color2: Colors.deepPurple),
                ],
              ),

              const SizedBox(height: 30),
              const Text("Data Peserta Terbaru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // --- TABEL DATA PESERTA ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
                ),
                // ListView.builder membuat list otomatis berdasarkan jumlah data
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: daftarPeserta.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = daftarPeserta[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: Text(item['nama'][0], style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      title: Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("No. BPJS: ${item['bpjs']}"),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: item['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: item['color']),
                        ),
                        child: Text(item['status'], style: TextStyle(color: item['color'], fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80), // Ruang kosong agar tombol tidak menutupi list
            ],
          ),
        ),
      ),
    );
  }
}

// --- HALAMAN FORM INPUT (BARU) ---
class FormPesertaPage extends StatefulWidget {
  const FormPesertaPage({super.key});

  @override
  State<FormPesertaPage> createState() => _FormPesertaPageState();
}

class _FormPesertaPageState extends State<FormPesertaPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk mengambil teks yang diketik
  final TextEditingController namaController = TextEditingController();
  final TextEditingController bpjsController = TextEditingController();
  String statusTerpilih = "Aktif"; // Default pilihan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Input Peserta Baru"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Warna ikon back hitam
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Input Nama
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harap isi nama';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              
              // Input No BPJS
              TextFormField(
                controller: bpjsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Nomor BPJS",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.card_membership),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harap isi nomor BPJS';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Pilihan Status (Dropdown)
              DropdownButtonFormField<String>(
                value: statusTerpilih,
                decoration: const InputDecoration(
                  labelText: "Status Kepesertaan",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: const [
                  DropdownMenuItem(value: "Aktif", child: Text("Aktif")),
                  DropdownMenuItem(value: "Menunggak", child: Text("Menunggak")),
                  DropdownMenuItem(value: "Non-Aktif", child: Text("Non-Aktif")),
                ],
                onChanged: (value) {
                  setState(() {
                    statusTerpilih = value!;
                  });
                },
              ),
              const SizedBox(height: 30),

              // Tombol Simpan
              SizedBox(width: double.infinity, child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A651),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Tentukan warna berdasarkan status
                    Color warnaStatus = Colors.green;
                    if (statusTerpilih == "Menunggak") warnaStatus = Colors.orange;
                    if (statusTerpilih == "Non-Aktif") warnaStatus = Colors.red;

                    // Bungkus data dalam Map
                    Map<String, dynamic> dataBaru = {
                      "nama": namaController.text,
                      "bpjs": bpjsController.text,
                      "status": statusTerpilih,
                      "color": warnaStatus,
                    };

                    // Kirim data kembali ke Dashboard
                    Navigator.pop(context, dataBaru);
                  }
                },
                child: const Text("SIMPAN DATA", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Kartu (Hiasan)
class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color1;
  final Color color2;

  const _InfoCard({required this.title, required this.value, required this.icon, required this.color1, required this.color2});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color1.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}