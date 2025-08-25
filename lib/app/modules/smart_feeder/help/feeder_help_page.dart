import 'package:accordion/controllers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:accordion/accordion.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';

class FeederHelpPage extends StatefulWidget {
  const FeederHelpPage({super.key});

  @override
  State<FeederHelpPage> createState() => _FeederHelpPageState();
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

class _StepGuide {
  final String title;
  final String imageAsset;
  final String description;

  const _StepGuide({
    required this.title,
    required this.imageAsset,
    required this.description,
  });
}

class _FeederHelpPageState extends State<FeederHelpPage> {
  // Dummy gambar alat feeder, silakan ganti sesuai asset projectmu
  final List<String> alatImages = [
    'assets/images/feeder_1.jpg',
    'assets/images/feeder_2.jpg',
    'assets/images/feeder_tank.jpg',
    'assets/images/feeder_control.jpg',
  ];

  // Step by step penggunaan alat (contoh, silakan sesuaikan dengan alat feeder)
  final List<_StepGuide> stepGuides = [
    _StepGuide(
      title: "1. Isi Tangki Air & Pakan",
      imageAsset: 'assets/images/step_feeder1.png',
      description:
          "Buka tutup tangki air dan pakan, lalu isi sesuai kapasitas maksimal.",
    ),
    _StepGuide(
      title: "2. Nyalakan Perangkat Feeder",
      imageAsset: 'assets/images/step_feeder2.png',
      description:
          "Pastikan perangkat feeder dalam kondisi menyala dan lampu indikator aktif.",
    ),
    _StepGuide(
      title: "3. Atur Jadwal Pengisian",
      imageAsset: 'assets/images/step_feeder3.png',
      description:
          "Masuk ke menu Kontrol Penjadwalan di aplikasi, pilih mode dan interval waktu pengisian otomatis, atau gunakan mode manual jika diperlukan.",
    ),
    _StepGuide(
      title: "4. Monitoring & Riwayat",
      imageAsset: 'assets/images/step_feeder4.png',
      description:
          "Pantau status air, pakan, dan riwayat pengisian setiap kandang melalui aplikasi.",
    ),
  ];

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

  int _currentCarousel = 0;

  @override
  Widget build(BuildContext context) {
    final double maxPageWidth = MediaQuery.of(context).size.width;
    final double rowChildWidth = maxPageWidth > 900 ? 600 : maxPageWidth - 64;
    final bool isWide = maxPageWidth > 900;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        withExpanded: false,
        title: 'Panduan Penggunaan Smart Feeder',
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
              const SizedBox(height: 28),
              // Row: Carousel di kiri, Accordion step di kanan
              Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carousel di kiri
                  SizedBox(
                    width: isWide ? rowChildWidth : double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Gambar Perangkat Smart Feeder",
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 400,
                              viewportFraction: 1.0,
                              enableInfiniteScroll: false,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 5),
                              enlargeCenterPage: true,
                              onPageChanged: (index, _) {
                                setState(() => _currentCarousel = index);
                              },
                            ),
                            items: alatImages.map((imgPath) {
                              return Container(
                                color: Colors.grey[100],
                                child: Image.asset(
                                  imgPath,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: alatImages.asMap().entries.map((entry) {
                            return Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentCarousel == entry.key
                                    ? AppColors.primary
                                    : AppColors.primary.withOpacity(0.25),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isWide ? 44 : 0, height: isWide ? 0 : 36),
                  // Accordion step di kanan
                  SizedBox(
                    width:
                        MediaQuery.of(context).size.width *
                        (isWide ? 0.44 : 1.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cara Menggunakan Smart Feeder",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Accordion(
                          paddingBetweenOpenSections: 14,
                          sectionOpeningHapticFeedback:
                              SectionHapticFeedback.heavy,
                          rightIcon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary,
                          ),
                          headerBackgroundColor: Colors.white,
                          headerBackgroundColorOpened: AppColors.primary
                              .withOpacity(0.08),
                          headerBorderColor: AppColors.primary.withOpacity(
                            0.11,
                          ),
                          headerBorderColorOpened: AppColors.primary
                              .withOpacity(0.18),
                          contentBackgroundColor: Colors.white,
                          contentBorderColor: AppColors.primary.withOpacity(
                            0.08,
                          ),
                          contentBorderWidth: 1.0,
                          paddingListHorizontal: 0,
                          paddingListTop: 0,
                          paddingListBottom: 0,
                          maxOpenSections: 1,
                          children: stepGuides
                              .map(
                                (step) => AccordionSection(
                                  isOpen: false,
                                  leftIcon: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(
                                        0.11,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                  ),
                                  header: Text(
                                    step.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  content: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.asset(
                                          step.imageAsset,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.image,
                                                  color: Colors.grey,
                                                  size: 40,
                                                ),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: Text(
                                          step.description,
                                          style: const TextStyle(
                                            fontSize: 16.5,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  headerPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 18,
                                  ),
                                  contentHorizontalPadding: 24,
                                  contentVerticalPadding: 14,
                                  contentBorderRadius: 15,
                                  headerBorderWidth: 1.1,
                                  headerBorderRadius: 18,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              // Accordion help utama seperti sebelumnya
              Text(
                "Panduan Fitur Aplikasi",
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Accordion(
                paddingBetweenOpenSections: 14,
                sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
                rightIcon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                ),
                headerBackgroundColor: Colors.white,
                headerBackgroundColorOpened: AppColors.primary.withOpacity(
                  0.08,
                ),
                headerBorderColor: AppColors.primary.withOpacity(0.11),
                headerBorderColorOpened: AppColors.primary.withOpacity(0.18),
                contentBackgroundColor: Colors.white,
                contentBorderColor: AppColors.primary.withOpacity(0.08),
                contentBorderWidth: 1.0,
                paddingListHorizontal: 0,
                paddingListTop: 0,
                paddingListBottom: 0,
                maxOpenSections: 1,
                children: sections
                    .map(
                      (section) => AccordionSection(
                        isOpen: false,
                        leftIcon: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.11),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(13),
                          child: Icon(
                            section.icon,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        header: Text(
                          section.title,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: section.content
                              .map(
                                (c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 7.5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "• ",
                                        style: TextStyle(fontSize: 16.5),
                                      ),
                                      Expanded(
                                        child: Text(
                                          c,
                                          style: const TextStyle(
                                            fontSize: 16.5,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        headerPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 18,
                        ),
                        contentHorizontalPadding: 28,
                        contentVerticalPadding: 10,
                        contentBorderRadius: 15,
                        headerBorderWidth: 1.1,
                        headerBorderRadius: 18,
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
