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
      title: 'Sistem RS & BPJS',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A651)),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF00A651)),
        ),
      ),
      home: const MainLayout(),
    );
  }
}

// =======================================================
// 1. MAIN LAYOUT
// =======================================================
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    const DaftarDokterView(),
    const DataPasienView(),
    const DataObatView(),
  ];

  final List<String> _titles = [
    "", // Title kosong untuk Dashboard karena custom header
    "Jadwal Dokter",
    "Data Peserta BPJS",
    "Farmasi & Obat"
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: _selectedIndex == 0,
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(""))
          : AppBar(
              title: Text(_titles[_selectedIndex],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF00A651), Color(0xFF00CD65)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
              accountName: const Text("Admin Rumah Sakit",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: const Text("admin@rs-sehat.co.id"),
              currentAccountPicture: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.local_hospital_rounded,
                    size: 40, color: Color(0xFF00A651)),
              ),
            ),
            _buildDrawerItem(0, Icons.grid_view_rounded, "Dashboard"),
            _buildDrawerItem(1, Icons.medical_services_rounded, "Jadwal Dokter"),
            _buildDrawerItem(2, Icons.people_alt_rounded, "Data Pasien"),
            _buildDrawerItem(3, Icons.medication_rounded, "Stok Obat"),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16), child: Divider()),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text("Keluar Sistem",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon,
          color: isSelected ? const Color(0xFF00A651) : Colors.grey[600]),
      title: Text(title,
          style: TextStyle(
              color: isSelected ? const Color(0xFF00A651) : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
      selected: isSelected,
      selectedTileColor: const Color(0xFF00A651).withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: () => _onItemTapped(index),
    );
  }
}

// =======================================================
// 2. VIEW: DASHBOARD (COMPACT & INTERACTIVE)
// =======================================================
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  // Data Dummy untuk Pasien per Kelas
  final List<Map<String, String>> _pasienKelas1 = const [
    {"nama": "Bpk. Hartono", "diagnosa": "Demam Berdarah"},
    {"nama": "Ibu Sulastri", "diagnosa": "Pasca Operasi"},
    {"nama": "Sdr. Kevin", "diagnosa": "Tifus"},
  ];

  final List<Map<String, String>> _pasienKelas2 = const [
    {"nama": "Bpk. Jojo", "diagnosa": "Fraktur Ringan"},
    {"nama": "Adik Bayu", "diagnosa": "ISPA"},
  ];

  final List<Map<String, String>> _pasienKelas3 = const [
    {"nama": "Ibu Minah", "diagnosa": "Diabetes Melitus"},
    {"nama": "Bpk. Asep", "diagnosa": "Hipertensi"},
    {"nama": "Sdr. Tono", "diagnosa": "Asma"},
    {"nama": "Ibu Rina", "diagnosa": "Maag Akut"},
  ];

  final List<Map<String, String>> _pasienVIP = const [
    {"nama": "Bpk. Direktur", "diagnosa": "Checkup Jantung"},
  ];

  // Fungsi untuk menampilkan BottomSheet daftar pasien
  void _showPatientList(BuildContext context, String title, List<Map<String, String>> data, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.bed_rounded, color: color),
                  ),
                  const SizedBox(width: 12),
                  Text("Pasien $title", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              if (data.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text("Tidak ada pasien saat ini.")),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade100,
                          child: Text("${index + 1}"),
                        ),
                        title: Text(data[index]['nama']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Diagnosa: ${data[index]['diagnosa']}"),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER LEBIH KECIL (COMPACT) ---
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20), // Padding dikurangi
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00A651), Color(0xFF008E45)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Halo, Admin", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text("RS Sehat Sentosa", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                )
              ],
            ),
          ),

          // --- KONTEN BODY ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. GRID STATISTIK (DIPERKECIL)
                GridView.count(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8, // Aspect ratio lebih besar agar kartu lebih pendek
                  children: const [
                    _CompactStatCard(title: "Total Dokter", value: "32", icon: Icons.medical_services, color: Colors.blue),
                    _CompactStatCard(title: "Pasien Rawat", value: "142", icon: Icons.bed, color: Colors.orange),
                    _CompactStatCard(title: "Kamar Kosong", value: "8", icon: Icons.meeting_room, color: Colors.green),
                    _CompactStatCard(title: "Antrian", value: "56", icon: Icons.people_outline, color: Colors.purple),
                  ],
                ),

                const SizedBox(height: 20),
                const Text("Status Rawat Inap (Klik untuk Detail)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 10),

                // 2. BAGIAN KLASIFIKASI KELAS (DAPAT DIKLIK)
                Row(
                  children: [
                    Expanded(child: _ClassCard(title: "VIP", count: _pasienVIP.length, color: Colors.purple, onTap: () => _showPatientList(context, "VIP", _pasienVIP, Colors.purple))),
                    const SizedBox(width: 10),
                    Expanded(child: _ClassCard(title: "Kelas 1", count: _pasienKelas1.length, color: Colors.blue, onTap: () => _showPatientList(context, "Kelas 1", _pasienKelas1, Colors.blue))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _ClassCard(title: "Kelas 2", count: _pasienKelas2.length, color: Colors.orange, onTap: () => _showPatientList(context, "Kelas 2", _pasienKelas2, Colors.orange))),
                    const SizedBox(width: 10),
                    Expanded(child: _ClassCard(title: "Kelas 3", count: _pasienKelas3.length, color: Colors.green, onTap: () => _showPatientList(context, "Kelas 3", _pasienKelas3, Colors.green))),
                  ],
                ),

                const SizedBox(height: 20),
                // 3. ANTRIAN COMPACT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Antrian Terkini", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    TextButton(onPressed: () {}, child: const Text("Lihat Semua", style: TextStyle(fontSize: 12)))
                  ],
                ),
                Column(
                  children: [
                    _QueueItemCompact(nama: "Bpk. Rahmad", poli: "Poli Jantung", no: "A-01", status: "Periksa"),
                    _QueueItemCompact(nama: "Ibu Susi", poli: "Poli Gigi", no: "B-12", status: "Menunggu"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Kartu Statistik Kecil
class _CompactStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _CompactStatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600], overflow: TextOverflow.ellipsis)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Widget Kartu Kelas (Clickable)
class _ClassCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _ClassCard({required this.title, required this.count, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text("$count Pasien", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[400])
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Antrian Compact
class _QueueItemCompact extends StatelessWidget {
  final String nama;
  final String poli;
  final String no;
  final String status;

  const _QueueItemCompact({required this.nama, required this.poli, required this.no, required this.status});

  @override
  Widget build(BuildContext context) {
    bool isActive = status == "Periksa";
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: isActive ? Border.all(color: const Color(0xFF00A651).withOpacity(0.5)) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
            child: Text(no, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(poli, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF00A651) : Colors.orange)),
        ],
      ),
    );
  }
}

// =======================================================
// 3. VIEW: DOKTER (LEBIH BANYAK DATA)
// =======================================================
class DaftarDokterView extends StatelessWidget {
  const DaftarDokterView({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Dokter diperbanyak
    final List<Map<String, dynamic>> doctors = [
      {"name": "Dr. Budi Santoso, Sp.PD", "specialist": "Penyakit Dalam", "time": "08:00 - 14:00", "status": "Praktek"},
      {"name": "Dr. Siti Aminah, Sp.A", "specialist": "Spesialis Anak", "time": "09:00 - 15:00", "status": "Istirahat"},
      {"name": "Dr. Andi Wijaya, Sp.JP", "specialist": "Jantung & Pembuluh", "time": "13:00 - 18:00", "status": "Praktek"},
      {"name": "Dr. Sarah Larasati, Sp.KK", "specialist": "Kulit & Kelamin", "time": "10:00 - 16:00", "status": "Praktek"},
      {"name": "Dr. Robertus, Sp.B", "specialist": "Bedah Umum", "time": "07:00 - 12:00", "status": "Pulang"},
      {"name": "Dr. Linda Kurnia, Sp.M", "specialist": "Spesialis Mata", "time": "14:00 - 20:00", "status": "Praktek"},
      {"name": "Dr. Handoko, Sp.OG", "specialist": "Kandungan", "time": "08:00 - 14:00", "status": "Operasi"},
      {"name": "Dr. Feri Irawan, Sp.S", "specialist": "Saraf", "time": "15:00 - 21:00", "status": "Menunggu"},
      {"name": "Dr. Citra Kirana, Sp.KJ", "specialist": "Kesehatan Jiwa", "time": "09:00 - 15:00", "status": "Praktek"},
      {"name": "Drg. Doni Pratama", "specialist": "Gigi & Mulut", "time": "08:00 - 16:00", "status": "Praktek"},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doc = doctors[index];
        String status = doc['status'];
        Color statusColor;
        Color bgStatusColor;

        if (status == "Praktek") {
          statusColor = const Color(0xFF2E7D32);
          bgStatusColor = const Color(0xFFE8F5E9);
        } else if (status == "Istirahat" || status == "Menunggu") {
          statusColor = Colors.orange[800]!;
          bgStatusColor = Colors.orange[50]!;
        } else if (status == "Operasi") {
          statusColor = Colors.red[800]!;
          bgStatusColor = Colors.red[50]!;
        } else {
          statusColor = Colors.grey;
          bgStatusColor = Colors.grey[200]!;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                height: 50, width: 50,
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.person_rounded, color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(doc['specialist'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.schedule_rounded, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(doc['time'], style: TextStyle(color: Colors.grey[700], fontSize: 11)),
                    ]),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bgStatusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
              )
            ],
          ),
        );
      },
    );
  }
}

// =======================================================
// 4. VIEW: DATA PASIEN (TETAP)
// =======================================================
class DataPasienView extends StatefulWidget {
  const DataPasienView({super.key});

  @override
  State<DataPasienView> createState() => _DataPasienViewState();
}

class _DataPasienViewState extends State<DataPasienView> {
  List<Map<String, dynamic>> patients = [
    {"nama": "Budi Santoso", "nik": "320112345678", "status": "Aktif", "kelas": "Kelas 1"},
    {"nama": "Rina Wati", "nik": "320198765432", "status": "Menunggak", "kelas": "Kelas 2"},
    {"nama": "Ahmad Dani", "nik": "320444555666", "status": "Aktif", "kelas": "VIP"},
    {"nama": "Siti Nurhaliza", "nik": "320777888999", "status": "Aktif", "kelas": "Kelas 3"},
  ];

  void _showAddPatientDialog() {
    // ... Logika tambah pasien sama seperti sebelumnya ...
    // Disingkat untuk fokus ke perubahan utama
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPatientDialog,
        backgroundColor: const Color(0xFF00A651),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Tambah", style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final p = patients[index];
          Color statusColor = p['status'] == "Aktif" ? Colors.green : Colors.orange;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: const Color(0xFF00A651).withOpacity(0.1), child: Text(p['nama'][0], style: const TextStyle(color: Color(0xFF00A651), fontWeight: FontWeight.bold))),
              title: Text(p['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("NIK: ${p['nik']} • ${p['kelas']}", style: const TextStyle(fontSize: 12)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(p['status'], style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =======================================================
// 5. VIEW: DATA OBAT (TETAP)
// =======================================================
class DataObatView extends StatefulWidget {
  const DataObatView({super.key});

  @override
  State<DataObatView> createState() => _DataObatViewState();
}

class _DataObatViewState extends State<DataObatView> {
  // Data obat ...
  List<Map<String, dynamic>> medicines = [
    {"nama": "Paracetamol 500mg", "stok": 150, "jenis": "Tablet", "harga": "Rp 5.000"},
    {"nama": "Amoxicillin", "stok": 45, "jenis": "Kapsul", "harga": "Rp 12.000"},
    {"nama": "Betadine Cair", "stok": 20, "jenis": "Botol", "harga": "Rp 25.000"},
  ];

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: medicines.length,
        separatorBuilder: (c, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final med = medicines[index];
          Color stockColor = (med['stok'] < 50) ? Colors.red : Colors.green;

          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.vaccines_rounded, color: Colors.blue.shade700),
              ),
              title: Text(med['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${med['jenis']} • ${med['harga']}"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${med['stok']}", style: TextStyle(color: stockColor, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("Stok", style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}