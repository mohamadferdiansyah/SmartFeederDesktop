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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FOTO KUDA
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          // FOTO PREVIEW (TINGGI DIBATASI)
                          SizedBox(
                            height: 500,
                            child: photos.isNotEmpty
                                ? CarouselSlider(
                                    carouselController: _carouselController,
                                    options: CarouselOptions(
                                      height: 500,
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
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(path),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    }).toList(),
                                  )
                                : Container(
                                    height: 500,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey[200],
                                    ),
                                    width: double.infinity,
                                    child: const Icon(
                                      Icons.image,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 10),

                          // THUMBNAIL LIST
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: photos.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    _carouselController.animateToPage(index);
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _currentIndex == index
                                            ? AppColors.primary
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.file(
                                        File(photos[index]),
                                        width: 100,
                                        height: 100,
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

                    const SizedBox(width: 24),

                    // DETAIL INFORMASI KUDA
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _detailRow("Id Kuda", widget.horse.horseId),
                            _detailRow("Nama Kuda", widget.horse.name),
                            _detailRow(
                              "Jenis",
                              widget.horse.type == "local"
                                  ? "Lokal"
                                  : "Crossbred",
                            ),
                            _detailRow("Tipe", widget.horse.category ?? "-"),
                            _detailRow("Jenis Kelamin", widget.horse.gender),
                            _detailRow(
                              "Tempat Lahir",
                              widget.horse.birthPlace ?? "-",
                            ),
                            _detailRow(
                              "Tanggal Lahir",
                              widget.horse.birthDate != null
                                  ? widget.horse.birthDate!
                                        .toIso8601String()
                                        .split('T')
                                        .first
                                  : "-",
                            ),
                            _detailRow(
                              "Kandang",
                              _controller
                                      .getStableByRoomId(
                                        widget.horse.roomId ?? '',
                                      )
                                      ?.name ??
                                  "-",
                            ),
                            _detailRow(
                              "Kode Kamar",
                              widget.horse.roomId ?? "-",
                            ),
                            _detailRow(
                              "Tanggal Menetap",
                              widget.horse.settleDate != null
                                  ? widget.horse.settleDate!
                                        .toIso8601String()
                                        .split('T')
                                        .first
                                  : "-",
                            ),
                            _detailRow(
                              "Panjang",
                              widget.horse.length != null
                                  ? "${widget.horse.length} cm"
                                  : "-",
                            ),
                            _detailRow(
                              "Berat",
                              widget.horse.weight != null
                                  ? "${widget.horse.weight} kg"
                                  : "-",
                            ),
                            _detailRow(
                              "Tinggi",
                              widget.horse.height != null
                                  ? "${widget.horse.height} cm"
                                  : "-",
                            ),
                            _detailRow(
                              "Lingkar Dada",
                              widget.horse.chestCircum != null
                                  ? "${widget.horse.chestCircum} cm"
                                  : "-",
                            ),
                            _detailRow(
                              "Warna Kulit",
                              widget.horse.skinColor ?? "-",
                            ),
                            _detailRow(
                              "Deskripsi Tanda",
                              widget.horse.markDesc ?? "-",
                            ),
                          ],
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

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 200,
          child: Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Flexible(child: Text(value, style: const TextStyle(fontSize: 18))),
      ],
    ),
  );
}
