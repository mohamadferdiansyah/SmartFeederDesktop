import 'package:accordion/controllers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:accordion/accordion.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';

class HalterHelpPage extends StatefulWidget {
  const HalterHelpPage({super.key});

  @override
  State<HalterHelpPage> createState() => _HalterHelpPageState();
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

class _HalterHelpPageState extends State<HalterHelpPage> {
  // Dummy gambar alat, ganti path asset sesuai kebutuhanmu
  final List<String> alatImages = [
    'assets/images/halter_2.jpg',
    'assets/images/halter_1.jpg',
    'assets/images/lora.jpg',
    'assets/images/noderoom.jpg',
  ];

  // Step by step penggunaan alat
  final List<_StepGuide> stepGuides = [
    _StepGuide(
      title: "1. Pasang Halter ke Kuda",
      imageAsset: 'assets/images/step1.png',
      description:
          "Tempatkan perangkat halter dengan benar di leher kuda. Pastikan posisi sensor menghadap bagian bawah leher.",
    ),
    _StepGuide(
      title: "2. Nyalakan Perangkat",
      imageAsset: 'assets/images/step2.png',
      description:
          "Tekan tombol power hingga lampu indikator menyala hijau, menandakan perangkat aktif.",
    ),
    _StepGuide(
      title: "3. Hubungkan ke Sistem",
      imageAsset: 'assets/images/step3.png',
      description:
          "Pastikan perangkat terkoneksi dengan baik ke sistem aplikasi dan status di dashboard menjadi 'Aktif'.",
    ),
    _StepGuide(
      title: "4. Monitoring",
      imageAsset: 'assets/images/step4.png',
      description:
          "Pantau data kesehatan kuda secara real-time melalui aplikasi pada menu Monitoring Kesehatan.",
    ),
  ];

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

  int _currentCarousel = 0;

  @override
  Widget build(BuildContext context) {
    final double maxPageWidth = MediaQuery.of(context).size.width;
    final double rowChildWidth = maxPageWidth > 900
        ? 600
        : maxPageWidth -
              64; // 500px lebar max carousel/accordion, atau penuh jika mobile
    final bool isWide = maxPageWidth > 900;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        withExpanded: false,
        title: 'Panduan Penggunaan Smart Halter',
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            "Gambar Perangkat Smart Halter",
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
                          "Cara Menggunakan Smart Halter",
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
