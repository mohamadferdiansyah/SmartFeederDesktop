import 'package:flutter/material.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';

class HalterHelpPage extends StatefulWidget {
  const HalterHelpPage({super.key});

  @override
  State<HalterHelpPage> createState() => _HalterHelpPageState();
}

class _HalterHelpPageState extends State<HalterHelpPage> {
  final List<_HelpSection> sections = [
    _HelpSection(
      icon: Icons.cable_rounded,
      title: "Daftar Halter Device",
      content: [
        "Menampilkan semua perangkat halter yang terdaftar di sistem.",
        "Kolom 'Kuda' menampilkan kuda yang terhubung (atau 'Tidak Digunakan' jika belum terpasang).",
        "Klik tombol aksi untuk melihat detail atau menghapus device.",
      ],
    ),
    _HelpSection(
      icon: Icons.videocam_rounded,
      title: "Data CCTV",
      content: [
        "Lihat daftar perangkat CCTV, alamat IP, port, dan kredensial.",
        "CCTV dapat dipasangkan ke ruangan untuk monitoring visual.",
        "Klik tombol aksi untuk melihat detail atau menghapus data CCTV.",
      ],
    ),
    _HelpSection(
      icon: Icons.home_rounded,
      title: "Data Kandang & Ruangan",
      content: [
        "Menampilkan daftar kandang beserta ruangan dan relasi perangkat.",
        "Kolom CCTV akan menampilkan kombinasi CCTV yang terpasang di ruangan tersebut.",
        "Kolom 'Sisa Air' dan 'Sisa Pakan' menampilkan stok real-time.",
        "Klik tombol aksi untuk detail ruangan atau penghapusan.",
      ],
    ),
    _HelpSection(
      icon: Icons.monitor_heart_rounded,
      title: "Monitoring Kesehatan Kuda",
      content: [
        "Pantau data sensor halter: detak jantung, suhu tubuh, respirasi, oksigen, dan postur.",
        "Status kesehatan akan otomatis muncul ('Sehat' atau 'Sakit') sesuai data sensor terakhir.",
        "Klik pada nama kuda untuk melihat detail kesehatan.",
      ],
    ),
    _HelpSection(
      icon: Icons.history_edu_rounded,
      title: "Riwayat Data & Pengisian",
      content: [
        "Lihat riwayat pengisian air/pakan, serta riwayat aktivitas halter.",
        "Gunakan fitur pencarian/filter untuk memudahkan pencarian data spesifik.",
        "Tombol 'Export Excel' untuk mengunduh data riwayat.",
      ],
    ),
    _HelpSection(
      icon: Icons.tips_and_updates_rounded,
      title: "Tips Penggunaan Smart Halter",
      content: [
        "Pastikan perangkat halter terpasang dan statusnya 'Aktif' untuk pemantauan real-time.",
        "Jika kuda berpindah ruangan, pastikan update relasi di data ruangan.",
        "Selalu cek daya baterai halter pada halaman monitoring kesehatan.",
        "Data postur dan kesehatan diambil otomatis berdasarkan sensor.",
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
        title: 'Panduan Penggunaan Smart Halter',
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Berikut adalah panduan fitur-fitur utama pada menu Smart Halter:",
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