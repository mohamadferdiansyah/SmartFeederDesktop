import 'package:flutter/material.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<_HelpSection> sections = [
    _HelpSection(
      icon: Icons.dashboard_rounded,
      title: "Dashboard",
      content: [
        "Menampilkan ringkasan status tanki air & pakan utama.",
        "Menampilkan daftar kandang beserta status air, pakan, dan informasi kuda.",
        "Klik pada 'Pilih Kandang' untuk melihat detail kandang.",
      ],
    ),
    _HelpSection(
      icon: Icons.settings_suggest_rounded,
      title: "Kontrol Penjadwalan",
      content: [
        "Atur mode penjadwalan pemberian air & pakan:",
        "  - Penjadwalan: Atur interval waktu pengisian otomatis.",
        "  - Otomatis: Sistem akan mengisi sesuai kebutuhan sensor.",
        "  - Manual: Isi air/pakan secara langsung sesuai kebutuhan.",
        "Klik 'Ubah Jadwal' untuk mengatur mode dan interval.",
      ],
    ),
    _HelpSection(
      icon: Icons.monitor_heart,
      title: "Monitoring Data",
      content: [
        "Pantau data real-time & riwayat perangkat, air, pakan, dan pengisian kandang.",
        "  - Data Perangkat: Daftar semua perangkat feeder dan statusnya.",
        "  - Data Air: Lihat riwayat dan status air di kandang.",
        "  - Data Pakan: Lihat riwayat dan status pakan di kandang.",
        "  - Data Riwayat Pengisian: Pantau riwayat pengisian air & pakan tiap kandang.",
      ],
    ),
    _HelpSection(
      icon: Icons.list_alt_rounded,
      title: "Riwayat Pengisian",
      content: [
        "Tabel riwayat pengisian untuk setiap kandang.",
        "Gunakan pencarian untuk filter data berdasarkan tanggal, kandang, mode, dll.",
        "Klik tombol aksi untuk melihat detail atau menghapus data.",
      ],
    ),
    _HelpSection(
      icon: Icons.settings,
      title: "Pengaturan Perangkat",
      content: [
        "Kelola data perangkat feeder.",
        "Tambah, edit, atau hapus perangkat sesuai kebutuhan.",
      ],
    ),
    _HelpSection(
      icon: Icons.info_outline_rounded,
      title: "Tips Umum",
      content: [
        "Warna biru/oranye menandakan informasi air/pakan.",
        "Tombol hijau: aktif, merah: tidak aktif/mati.",
        "Selalu cek status sensor dan pastikan perangkat terhubung.",
        "Gunakan fitur 'Export Excel' untuk menyimpan data riwayat.",
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    double gridCardWidth = MediaQuery.of(context).size.width > 900
        ? (MediaQuery.of(context).size.width - 120) / 2
        : double.infinity;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        title: 'Panduan Penggunaan Aplikasi',
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selamat datang di aplikasi Smart Feeder! Berikut panduan penggunaan fitur-fitur utama:",
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 32,
                runSpacing: 32,
                children: sections
                    .map(
                      (section) => SizedBox(
                        width: gridCardWidth > 450 ? 450 : gridCardWidth,
                        child: _HelpSectionWidget(section: section),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpSection {
  final IconData icon;
  final String title;
  final List<String> content;

  const _HelpSection({
    required this.icon,
    required this.title,
    required this.content,
  });
}

class _HelpSectionWidget extends StatelessWidget {
  final _HelpSection section;
  const _HelpSectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: EdgeInsets.zero,
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.13)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(16),
            child: Icon(section.icon, color: AppColors.primary, size: 34),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: TextStyle(
                    fontSize: 21,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: section.content
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            c,
                            style: TextStyle(
                              fontSize: 16.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
