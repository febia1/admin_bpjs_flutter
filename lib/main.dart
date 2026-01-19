import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Getter pages agar Dashboard selalu direfresh saat dibuka
  List<Widget> get _pages => [
    DashboardView(onTabChange: _changeTab),
    const DaftarDokterView(),
    const DataPasienView(),
    const DataObatView(),
    const DataAntrianView(),
  ];

  final List<String> _titles = [
    "", 
    "Jadwal Dokter",
    "Data Peserta BPJS",
    "Farmasi & Obat",
    "Antrian Pasien"
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
            _buildDrawerItem(4, Icons.people_outline_rounded, "Data Antrian"),
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
// 2. VIEW: DASHBOARD (REAL-TIME DATA PER KELAS)
// =======================================================
class DashboardView extends StatefulWidget {
  final Function(int) onTabChange;
  const DashboardView({super.key, required this.onTabChange});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Variabel Global
  int totalDokter = 0;
  int totalPasien = 0;
  int totalObat = 0;
  int totalAntrian = 0;

  // Variabel Per Kelas
  int countVIP = 0;
  int countKelas1 = 0;
  int countKelas2 = 0;
  int countKelas3 = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final prefs = await SharedPreferences.getInstance();
    
    List d = jsonDecode(prefs.getString('data_dokter') ?? "[]");
    List p = jsonDecode(prefs.getString('data_pasien') ?? "[]");
    List a = jsonDecode(prefs.getString('data_antrian') ?? "[]");
    List o = jsonDecode(prefs.getString('data_obat') ?? "[]");

    // Hitung Pasien per Kelas
    int v = 0, k1 = 0, k2 = 0, k3 = 0;
    
    // Jika data pasien kosong, kita pakai dummy count default biar tampilan tidak nol semua di awal
    if (p.isEmpty) {
       k1 = 1; // Default dummy
    } else {
      for (var patient in p) {
        String kelas = patient['kelas'] ?? "";
        if (kelas == "VIP") v++;
        else if (kelas == "Kelas 1") k1++;
        else if (kelas == "Kelas 2") k2++;
        else if (kelas == "Kelas 3") k3++;
      }
    }

    setState(() {
      totalDokter = d.isEmpty ? 10 : d.length; 
      totalPasien = p.isEmpty ? 1 : p.length;
      totalAntrian = a.isEmpty ? 2 : a.length;
      totalObat = o.isEmpty ? 15 : o.length;
      
      countVIP = v;
      countKelas1 = k1;
      countKelas2 = k2;
      countKelas3 = k3;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int gridCount = screenWidth > 900 ? 4 : 2;
    double childRatio = screenWidth > 900 ? 2.5 : 1.5;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF00A651), Color(0xFF008E45)]),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Selamat Datang,", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text("Admin RS Sehat", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  onPressed: _loadCounts,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: "Refresh Data",
                )
              ],
            ),
          ),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- GRID STATISTIK UTAMA ---
                    GridView.count(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: gridCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: childRatio,
                      children: [
                        _CompactStatCard(
                          title: "Total Dokter", value: "$totalDokter Orang", icon: Icons.medical_services, color: Colors.blue, 
                          onTap: () => widget.onTabChange(1)), 
                        _CompactStatCard(
                          title: "Total Pasien", value: "$totalPasien Orang", icon: Icons.people_alt, color: Colors.orange, 
                          onTap: () => widget.onTabChange(2)), 
                        _CompactStatCard(
                          title: "Jenis Obat", value: "$totalObat Item", icon: Icons.medication, color: Colors.green, 
                          onTap: () => widget.onTabChange(3)), 
                        _CompactStatCard(
                          title: "Antrian", value: "$totalAntrian", icon: Icons.people_outline, color: Colors.purple, 
                          onTap: () => widget.onTabChange(4)), 
                      ],
                    ),

                    const SizedBox(height: 25),
                    const Text("Status Rawat Inap per Kelas", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 10),

                    // --- BAGIAN BARU: GRID KELAS BPJS/VIP ---
                    GridView.count(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: gridCount, // Responsif mengikuti lebar layar
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: childRatio, // Rasio kotak
                      children: [
                        _ClassStatCard(title: "VIP", count: countVIP, color: Colors.purple, onTap: () => widget.onTabChange(2)),
                        _ClassStatCard(title: "Kelas 1", count: countKelas1, color: Colors.indigo, onTap: () => widget.onTabChange(2)),
                        _ClassStatCard(title: "Kelas 2", count: countKelas2, color: Colors.teal, onTap: () => widget.onTabChange(2)),
                        _ClassStatCard(title: "Kelas 3", count: countKelas3, color: Colors.blueGrey, onTap: () => widget.onTabChange(2)),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100)
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(child: Text("Data kelas di atas dihitung otomatis berdasarkan data 'Peserta BPJS' yang Anda input.", style: TextStyle(color: Colors.blue.shade900))),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Kartu Statistik Biasa
class _CompactStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CompactStatCard({required this.title, required this.value, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))), Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600], overflow: TextOverflow.ellipsis))]))
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Kartu Khusus Kelas
class _ClassStatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _ClassStatCard({required this.title, required this.count, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
            color: color.withOpacity(0.05), // Sedikit warna background
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
                  Icon(Icons.bed_outlined, color: color, size: 20),
                ],
              ),
              const Spacer(),
              Text("$count Pasien", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              const Text("Terisi saat ini", style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================
// 3. VIEW: DATA ANTRIAN (POLI LENGKAP)
// =======================================================
class DataAntrianView extends StatefulWidget {
  const DataAntrianView({super.key});
  @override
  State<DataAntrianView> createState() => _DataAntrianViewState();
}
class _DataAntrianViewState extends State<DataAntrianView> {
  List<Map<String, dynamic>> queues = [];
  String _searchQuery = "";

  final List<String> daftarPoli = [
    "Poli Umum", "Poli Gigi & Mulut", "Poli Penyakit Dalam", "Poli Anak (Pediatri)",
    "Poli Kandungan (Obgyn)", "Poli Bedah Umum", "Poli Mata", "Poli THT",
    "Poli Saraf (Neurologi)", "Poli Jantung & Pembuluh", "Poli Kulit & Kelamin",
    "Poli Paru", "Poli Orthopedi (Tulang)", "Poli Rehabilitasi Medik", "IGD (Gawat Darurat)"
  ];

  @override
  void initState() { super.initState(); _loadData(); }
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('data_antrian');
    if (dataString != null) { setState(() { queues = List<Map<String, dynamic>>.from(jsonDecode(dataString)); }); } 
    else { setState(() { queues = [{"nama": "Bpk. Rahmad", "poli": "Poli Jantung & Pembuluh", "no": "A-001", "status": "Periksa"}, {"nama": "Ibu Susi", "poli": "Poli Gigi & Mulut", "no": "B-005", "status": "Menunggu"}]; }); }
  }
  Future<void> _saveData() async { final prefs = await SharedPreferences.getInstance(); await prefs.setString('data_antrian', jsonEncode(queues)); }
  
  void _showQueueDialog({Map<String, dynamic>? item, int? index}) {
    String nama = item?['nama'] ?? "";
    String poli = item?['poli'] ?? "Poli Umum";
    String no = item?['no'] ?? "";
    if (!daftarPoli.contains(poli)) poli = "Poli Umum";

    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text(index == null ? "Tambah Antrian" : "Edit Antrian"), 
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: TextEditingController(text: nama), decoration: const InputDecoration(labelText: "Nama Pasien"), onChanged: (v) => nama = v), 
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: poli, isExpanded: true, decoration: const InputDecoration(labelText: "Tujuan Poli", border: OutlineInputBorder()),
            items: daftarPoli.map((e)=>DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(), 
            onChanged: (v)=>poli=v!
          ), 
          const SizedBox(height: 10),
          TextField(controller: TextEditingController(text: no), decoration: const InputDecoration(labelText: "Nomor Antrian"), onChanged: (v) => no = v)
        ]),
      ), 
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(c), child: const Text("Batal")), 
        ElevatedButton(onPressed: (){ if(nama.isNotEmpty){ setState(() { if(index==null) { queues.add({"nama": nama, "poli": poli, "no": no, "status": "Menunggu"}); } else { queues[index] = {"nama": nama, "poli": poli, "no": no, "status": item?['status']}; } }); _saveData(); Navigator.pop(c); }}, child: const Text("Simpan"))
      ]
    ));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = queues.where((e) => e['nama'].toLowerCase().contains(_searchQuery.toLowerCase()) || e['no'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _showQueueDialog(), backgroundColor: Colors.purple, icon: const Icon(Icons.add, color: Colors.white), label: const Text("Antrian")),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: "Cari nomor atau nama...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)), onChanged: (v) => setState(() => _searchQuery = v))),
          Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: filtered.length, itemBuilder: (context, index) {
            final realIndex = queues.indexOf(filtered[index]);
            final q = filtered[index];
            bool isChecking = q['status'] == "Periksa";
            return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: isChecking ? Border.all(color: Colors.green, width: 2) : null), child: ListTile(leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: Text(q['no'], style: const TextStyle(fontWeight: FontWeight.bold))), title: Text(q['nama'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(q['poli']), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showQueueDialog(item: q, index: realIndex)),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: (){ setState(() { queues.removeAt(realIndex); }); _saveData(); })
            ])));
          }))
        ],
      ),
    );
  }
}

// =======================================================
// 4. VIEW: DATA DOKTER (DATA BANYAK & LENGKAP)
// =======================================================
class DaftarDokterView extends StatefulWidget {
  const DaftarDokterView({super.key});
  @override
  State<DaftarDokterView> createState() => _DaftarDokterViewState();
}
class _DaftarDokterViewState extends State<DaftarDokterView> {
  List<Map<String, dynamic>> doctors = [];
  String _searchQuery = "";
  
  @override void initState() { super.initState(); _loadData(); }
  
  Future<void> _loadData() async { 
    final prefs = await SharedPreferences.getInstance(); 
    final d = prefs.getString('data_dokter');
    
    if (d == null || (jsonDecode(d) as List).length <= 1) {
      List<Map<String, dynamic>> dataLengkap = [
        {"name": "Dr. Budi Santoso, Sp.PD", "specialist": "Penyakit Dalam", "time": "08:00 - 14:00", "status": "Praktek"},
        {"name": "Dr. Siti Aminah, Sp.A", "specialist": "Spesialis Anak", "time": "09:00 - 15:00", "status": "Istirahat"},
        {"name": "Dr. Andi Wijaya, Sp.JP", "specialist": "Jantung", "time": "10:00 - 16:00", "status": "Praktek"},
        {"name": "Dr. Citra Kirana, Sp.OG", "specialist": "Kandungan", "time": "08:00 - 13:00", "status": "Selesai"},
        {"name": "Drg. Doni Pratama", "specialist": "Gigi & Mulut", "time": "14:00 - 20:00", "status": "Praktek"},
        {"name": "Dr. Eka Saputra, Sp.B", "specialist": "Bedah Umum", "time": "13:00 - 18:00", "status": "Operasi"},
        {"name": "Dr. Feri Irawan, Sp.S", "specialist": "Saraf", "time": "09:00 - 15:00", "status": "Praktek"},
        {"name": "Dr. Gina Lestari, Sp.M", "specialist": "Mata", "time": "15:00 - 19:00", "status": "Menunggu"},
        {"name": "Dr. Hadi Sucipto, Sp.THT", "specialist": "THT", "time": "08:00 - 12:00", "status": "Cuti"},
        {"name": "Dr. Indah Permata", "specialist": "Umum", "time": "24 Jam", "status": "Praktek"},
      ];
      setState(() { doctors = dataLengkap; });
      await prefs.setString('data_dokter', jsonEncode(dataLengkap));
    } else {
      setState(() { doctors = List<Map<String, dynamic>>.from(jsonDecode(d)); }); 
    }
  }

  Future<void> _saveData() async { final prefs = await SharedPreferences.getInstance(); await prefs.setString('data_dokter', jsonEncode(doctors)); }
  
  void _showDialog({Map<String, dynamic>? item, int? index}) {
    String name=item?['name']??"", specialist=item?['specialist']??"", time=item?['time']??"";
    showDialog(context: context, builder: (c) => AlertDialog(title: Text(index==null?"Tambah":"Edit"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: TextEditingController(text: name), decoration: const InputDecoration(labelText: "Nama"), onChanged: (v)=>name=v), TextField(controller: TextEditingController(text: specialist), decoration: const InputDecoration(labelText: "Spesialis"), onChanged: (v)=>specialist=v), TextField(controller: TextEditingController(text: time), decoration: const InputDecoration(labelText: "Jam"), onChanged: (v)=>time=v)]), actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: const Text("Batal")), ElevatedButton(onPressed: (){ if(name.isNotEmpty){ setState(() { if(index==null) doctors.add({"name": name, "specialist": specialist, "time": time, "status": "Praktek"}); else doctors[index] = {"name": name, "specialist": specialist, "time": time, "status": item?['status']}; }); _saveData(); Navigator.pop(c); }}, child: const Text("Simpan"))]));
  }

  @override Widget build(BuildContext context) {
    final filtered = doctors.where((e) => e['name'].toLowerCase().contains(_searchQuery.toLowerCase()) || e['specialist'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    return Scaffold(backgroundColor: Colors.transparent, floatingActionButton: FloatingActionButton.extended(onPressed: () => _showDialog(), backgroundColor: Colors.blue, icon: const Icon(Icons.add, color: Colors.white), label: const Text("Dokter")), body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: "Cari dokter atau spesialis...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)), onChanged: (v) => setState(() => _searchQuery = v))),
      Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: filtered.length, itemBuilder: (c, i){ final realIndex = doctors.indexOf(filtered[i]); final d = filtered[i]; return Card(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: ListTile(leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.person, color: Colors.blue)), title: Text(d['name'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("${d['specialist']}\n${d['time']}"), isThreeLine: true, trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showDialog(item: d, index: realIndex)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: (){ setState(() { doctors.removeAt(realIndex); }); _saveData(); })]))); }))
    ]));
  }
}

// =======================================================
// 5. VIEW: DATA PASIEN
// =======================================================
class DataPasienView extends StatefulWidget {
  const DataPasienView({super.key});
  @override State<DataPasienView> createState() => _DataPasienViewState();
}
class _DataPasienViewState extends State<DataPasienView> {
  List<Map<String, dynamic>> patients = [];
  String _searchQuery = "";
  @override void initState() { super.initState(); _loadData(); }
  Future<void> _loadData() async { final prefs = await SharedPreferences.getInstance(); final d = prefs.getString('data_pasien'); setState(() { patients = d!=null ? List<Map<String, dynamic>>.from(jsonDecode(d)) : [{"nama": "Budi Santoso", "nik": "12345", "status": "Aktif", "kelas": "Kelas 1"}]; }); }
  Future<void> _saveData() async { final prefs = await SharedPreferences.getInstance(); await prefs.setString('data_pasien', jsonEncode(patients)); }
  void _showDialog({Map<String, dynamic>? item, int? index}) {
    String nama=item?['nama']??"", nik=item?['nik']??"", kelas=item?['kelas']??"Kelas 3";
    showDialog(context: context, builder: (c) => AlertDialog(title: Text(index==null?"Tambah":"Edit"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: TextEditingController(text: nama), decoration: const InputDecoration(labelText: "Nama"), onChanged: (v)=>nama=v), TextField(controller: TextEditingController(text: nik), decoration: const InputDecoration(labelText: "NIK"), onChanged: (v)=>nik=v), DropdownButtonFormField(value: kelas, items: ["Kelas 1", "Kelas 2", "Kelas 3", "VIP"].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v)=>kelas=v!)]), actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: const Text("Batal")), ElevatedButton(onPressed: (){ if(nama.isNotEmpty){ setState(() { if(index==null) patients.add({"nama": nama, "nik": nik, "status": "Aktif", "kelas": kelas}); else patients[index] = {"nama": nama, "nik": nik, "status": item?['status'], "kelas": kelas}; }); _saveData(); Navigator.pop(c); }}, child: const Text("Simpan"))]));
  }
  @override Widget build(BuildContext context) {
    final filtered = patients.where((e) => e['nama'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    return Scaffold(backgroundColor: Colors.transparent, floatingActionButton: FloatingActionButton.extended(onPressed: () => _showDialog(), backgroundColor: const Color(0xFF00A651), icon: const Icon(Icons.add, color: Colors.white), label: const Text("Peserta")), body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: "Cari peserta...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)), onChanged: (v) => setState(() => _searchQuery = v))),
      Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: filtered.length, itemBuilder: (c, i) { final realIndex = patients.indexOf(filtered[i]); final p = filtered[i]; return Card(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: ListTile(leading: CircleAvatar(child: Text(p['nama'][0])), title: Text(p['nama'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("${p['nik']} - ${p['kelas']}"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showDialog(item: p, index: realIndex)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: (){ setState(() { patients.removeAt(realIndex); }); _saveData(); })]))); }))
    ]));
  }
}

// =======================================================
// 6. VIEW: DATA OBAT (DATA LENGKAP & STOK)
// =======================================================
class DataObatView extends StatefulWidget {
  const DataObatView({super.key});
  @override State<DataObatView> createState() => _DataObatViewState();
}
class _DataObatViewState extends State<DataObatView> {
  List<Map<String, dynamic>> medicines = [];
  String _searchQuery = "";
  
  @override void initState() { super.initState(); _loadData(); }
  
  Future<void> _loadData() async { 
    final prefs = await SharedPreferences.getInstance(); 
    final d = prefs.getString('data_obat');
    
    if (d == null || (jsonDecode(d) as List).length <= 1) {
      List<Map<String, dynamic>> obatLengkap = [
          {"nama": "Paracetamol 500mg", "stok": 150, "jenis": "Tablet", "harga": "Rp 5.000"},
          {"nama": "Amoxicillin 500mg", "stok": 45, "jenis": "Kapsul", "harga": "Rp 12.000"},
          {"nama": "Betadine Cair 30ml", "stok": 20, "jenis": "Botol", "harga": "Rp 25.000"},
          {"nama": "Vitamin C IPI", "stok": 200, "jenis": "Botol", "harga": "Rp 8.000"},
          {"nama": "Omeprazole 20mg", "stok": 30, "jenis": "Kapsul", "harga": "Rp 15.000"},
          {"nama": "Ibuprofen 400mg", "stok": 80, "jenis": "Tablet", "harga": "Rp 6.000"},
          {"nama": "OBH Combi Anak", "stok": 15, "jenis": "Sirup", "harga": "Rp 18.000"},
          {"nama": "Mylanta Cair", "stok": 25, "jenis": "Sirup", "harga": "Rp 22.000"},
          {"nama": "Amlodipine 5mg", "stok": 100, "jenis": "Tablet", "harga": "Rp 7.500"},
          {"nama": "Metformin 500mg", "stok": 120, "jenis": "Tablet", "harga": "Rp 5.000"},
          {"nama": "Masker Medis (Box)", "stok": 50, "jenis": "Box", "harga": "Rp 35.000"},
          {"nama": "Hand Sanitizer 100ml", "stok": 10, "jenis": "Botol", "harga": "Rp 15.000"},
          {"nama": "Salonpas Koyo", "stok": 150, "jenis": "Sachet", "harga": "Rp 12.000"},
          {"nama": "Minyak Kayu Putih", "stok": 40, "jenis": "Botol", "harga": "Rp 28.000"},
          {"nama": "Antibiotik Salep", "stok": 18, "jenis": "Tube", "harga": "Rp 20.000"},
      ];
      setState(() { medicines = obatLengkap; });
      await prefs.setString('data_obat', jsonEncode(obatLengkap));
    } else {
      setState(() { medicines = List<Map<String, dynamic>>.from(jsonDecode(d)); }); 
    }
  }

  Future<void> _saveData() async { final prefs = await SharedPreferences.getInstance(); await prefs.setString('data_obat', jsonEncode(medicines)); }
  void _updateStock(int index, int amount) {
    setState(() {
      int newStock = medicines[index]['stok'] + amount;
      if (newStock >= 0) medicines[index]['stok'] = newStock;
    });
    _saveData();
  }
  void _showDialog({Map<String, dynamic>? item, int? index}) {
    String nama=item?['nama']??"", jenis=item?['jenis']??"Tablet", harga=item?['harga']??"", stok=item?['stok'].toString()??"0";
    showDialog(context: context, builder: (c) => AlertDialog(title: Text(index==null?"Tambah":"Edit"), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: TextEditingController(text: nama), decoration: const InputDecoration(labelText: "Nama"), onChanged: (v)=>nama=v), TextField(controller: TextEditingController(text: jenis), decoration: const InputDecoration(labelText: "Jenis"), onChanged: (v)=>jenis=v), TextField(controller: TextEditingController(text: harga), decoration: const InputDecoration(labelText: "Harga"), onChanged: (v)=>harga=v), TextField(controller: TextEditingController(text: stok), decoration: const InputDecoration(labelText: "Stok"), keyboardType: TextInputType.number, onChanged: (v)=>stok=v)]), actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: const Text("Batal")), ElevatedButton(onPressed: (){ if(nama.isNotEmpty){ setState(() { if(index==null) medicines.add({"nama": nama, "stok": int.tryParse(stok)??0, "jenis": jenis, "harga": harga}); else medicines[index] = {"nama": nama, "stok": int.tryParse(stok)??0, "jenis": jenis, "harga": harga}; }); _saveData(); Navigator.pop(c); }}, child: const Text("Simpan"))]));
  }
  @override Widget build(BuildContext context) {
    final filtered = medicines.where((e) => e['nama'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    return Scaffold(backgroundColor: Colors.transparent, floatingActionButton: FloatingActionButton(onPressed: () => _showDialog(), backgroundColor: Colors.blue, child: const Icon(Icons.add, color: Colors.white)), body: Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: "Cari obat...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)), onChanged: (v) => setState(() => _searchQuery = v))),
      Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: filtered.length, itemBuilder: (c, i) { final realIndex = medicines.indexOf(filtered[i]); final m = filtered[i]; return Card(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: ListTile(leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.medication, color: Colors.orange)), title: Text(m['nama'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("${m['jenis']} - ${m['harga']}"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.grey), onPressed: () => _updateStock(realIndex, -1)),
        Text("${m['stok']}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: (m['stok'] as int) < 20 ? Colors.red : Colors.green)),
        IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.blue), onPressed: () => _updateStock(realIndex, 1)),
        PopupMenuButton(onSelected: (v) { if(v=='edit') _showDialog(item: m, index: realIndex); else { setState(() { medicines.removeAt(realIndex); }); _saveData(); } }, itemBuilder: (c) => [const PopupMenuItem(value: 'edit', child: Text("Edit")), const PopupMenuItem(value: 'del', child: Text("Hapus", style: TextStyle(color: Colors.red)))])
      ]))); }))
    ]));
  }
}
// PERUBAHAN TES GIT
