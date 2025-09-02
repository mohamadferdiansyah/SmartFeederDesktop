import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/models/horse_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/dashboard/halter_dashboard_controller.dart';

class HalterHorseDetailWidget extends StatefulWidget {
  final HorseModel horse;
  final VoidCallback onBack;

  const HalterHorseDetailWidget({
    required this.horse,
    required this.onBack,
    Key? key,
  }) : super(key: key);

  @override
  State<HalterHorseDetailWidget> createState() =>
      _HalterHorseDetailWidgetState();
}

class _HalterHorseDetailWidgetState extends State<HalterHorseDetailWidget> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final HalterDashboardController _controller =
      Get.find<HalterDashboardController>();

  @override
  Widget build(BuildContext context) {
    final photos = (widget.horse.photos ?? [])
        .where((p) => p.isNotEmpty)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: widget.onBack,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Detail ${widget.horse.name}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // === KONTEN ===
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                color: Colors.grey[50],
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FOTO KUDA
                    Expanded(
                      flex: 1,
                      child: Card(
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white, Colors.grey[50]!],
                            ),
                          ),
                          child: Column(
                            children: [
                              // Header untuk section foto
                              Container(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.photo_library,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Galeri Foto',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // FOTO PREVIEW
                              Container(
                                height: 400,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: photos.isNotEmpty
                                    ? CarouselSlider(
                                        carouselController: _carouselController,
                                        options: CarouselOptions(
                                          height: 400,
                                          viewportFraction: 1.0,
                                          enlargeCenterPage: true,
                                          onPageChanged: (index, reason) {
                                            setState(() {
                                              _currentIndex = index;
                                            });
                                          },
                                        ),
                                        items: photos.map((path) {
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    spreadRadius: 1,
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Image.file(
                                                File(path),
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      )
                                    : Container(
                                        height: 400,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.grey[100],
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 2,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              size: 80,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Tidak ada foto',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),

                              const SizedBox(height: 16),

                              // THUMBNAIL LIST
                              if (photos.isNotEmpty)
                                Container(
                                  height: 80,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: photos.length,
                                    itemBuilder: (context, index) {
                                      final isSelected = _currentIndex == index;
                                      return GestureDetector(
                                        onTap: () {
                                          _carouselController.animateToPage(
                                            index,
                                          );
                                          setState(() {
                                            _currentIndex = index;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          margin: const EdgeInsets.only(
                                            right: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : Colors.grey[300]!,
                                              width: isSelected ? 3 : 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors.primary
                                                          .withOpacity(0.3),
                                                      spreadRadius: 1,
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: Image.file(
                                              File(photos[index]),
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 24),

                    // DETAIL INFORMASI KUDA
                    Expanded(
                      flex: 1,
                      child: Card(
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white, Colors.grey[50]!],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header untuk detail informasi
                              Container(
                                padding: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.pets,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Informasi Detail',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Detail informasi dalam scrollable area
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _modernDetailCard(
                                        "Id Kuda",
                                        widget.horse.horseId,
                                        Icons.tag,
                                      ),
                                      _modernDetailCard(
                                        "Nama Kuda",
                                        widget.horse.name,
                                        Icons.pets,
                                      ),
                                      _modernDetailCard(
                                        "Jenis",
                                        widget.horse.type == "local"
                                            ? "Lokal"
                                            : "Crossbred",
                                        Icons.category,
                                      ),
                                      _modernDetailCard(
                                        "Tipe",
                                        widget.horse.category ?? "-",
                                        Icons.type_specimen,
                                      ),
                                      _modernDetailCard(
                                        "Jenis Kelamin",
                                        widget.horse.gender,
                                        Icons.wc,
                                      ),
                                      _modernDetailCard(
                                        "Tempat Lahir",
                                        widget.horse.birthPlace ?? "-",
                                        Icons.location_on,
                                      ),
                                      _modernDetailCard(
                                        "Tanggal Lahir",
                                        widget.horse.birthDate != null
                                            ? widget.horse.birthDate!
                                                  .toIso8601String()
                                                  .split('T')
                                                  .first
                                            : "-",
                                        Icons.cake,
                                      ),
                                      _modernDetailCard(
                                        "Kandang",
                                        _controller
                                                .getStableByRoomId(
                                                  widget.horse.roomId ?? '',
                                                )
                                                ?.name ??
                                            "-",
                                        Icons.home,
                                      ),
                                      _modernDetailCard(
                                        "Kode Kamar",
                                        widget.horse.roomId ?? "-",
                                        Icons.room,
                                      ),
                                      _modernDetailCard(
                                        "Tanggal Menetap",
                                        widget.horse.settleDate != null
                                            ? widget.horse.settleDate!
                                                  .toIso8601String()
                                                  .split('T')
                                                  .first
                                            : "-",
                                        Icons.event,
                                      ),
                                      _modernDetailCard(
                                        "Panjang",
                                        widget.horse.length != null
                                            ? "${widget.horse.length} cm"
                                            : "-",
                                        Icons.straighten,
                                      ),
                                      _modernDetailCard(
                                        "Berat",
                                        widget.horse.weight != null
                                            ? "${widget.horse.weight} kg"
                                            : "-",
                                        Icons.monitor_weight,
                                      ),
                                      _modernDetailCard(
                                        "Tinggi",
                                        widget.horse.height != null
                                            ? "${widget.horse.height} cm"
                                            : "-",
                                        Icons.height,
                                      ),
                                      _modernDetailCard(
                                        "Lingkar Dada",
                                        widget.horse.chestCircum != null
                                            ? "${widget.horse.chestCircum} cm"
                                            : "-",
                                        Icons.timeline,
                                      ),
                                      _modernDetailCard(
                                        "Warna Kulit",
                                        widget.horse.skinColor ?? "-",
                                        Icons.palette,
                                      ),
                                      _modernDetailCard(
                                        "Deskripsi Tanda",
                                        widget.horse.markDesc ?? "-",
                                        Icons.description,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernDetailCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
