import 'package:flutter/material.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_button.dart';
import 'package:smart_feeder_desktop/app/data/dummy_data.dart';
import 'package:smart_feeder_desktop/app/models/stable_model.dart';

class ControlSchedulePage extends StatefulWidget {
  const ControlSchedulePage({super.key});

  @override
  State<ControlSchedulePage> createState() => _ControlSchedulePageState();
}

class _ControlSchedulePageState extends State<ControlSchedulePage> {
  int _selectedTab = 0; // 0: Air, 1: Pakan

  StableModel selectedStable = stableList[0];
  String selectedMode = "Penjadwalan";
  int intervalJam = 2; // default 2 jam

  @override
  Widget build(BuildContext context) {
    final isAir = _selectedTab == 0;
    final tabTitle = isAir ? "Air" : "Pakan";
    final colorMain = isAir ? Colors.blue : Colors.deepOrange;
    final satuan = isAir ? "Liter" : "Gram";
    final sisaKandang = isAir
        ? selectedStable.remainingWater
        : selectedStable.remainingFeed;
    final maxKandang = isAir ? 5 : 50;
    final kurangIsi = isAir
        ? maxKandang - selectedStable.remainingWater.value
        : maxKandang - selectedStable.remainingFeed.value;

    Color airBg = isAir ? Colors.blue : Colors.blue.withOpacity(0.1);
    Color airText = isAir ? Colors.white : Colors.blue;
    Color airBorder = isAir ? Colors.transparent : Colors.blue;
    Color pakanBg = !isAir
        ? Colors.deepOrange
        : Colors.deepOrange.withOpacity(0.1);
    Color pakanText = !isAir ? Colors.white : Colors.deepOrange;
    Color pakanBorder = !isAir ? Colors.transparent : Colors.deepOrange;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        title: 'Kontrol Penjadwalan',
        content: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Kandang dan Menu Untuk Mengatur Jadwal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                // Dropdown Pilih Kandang di atas
                SizedBox(
                  width: 350,
                  child: DropdownButtonFormField<StableModel>(
                    value: selectedStable,
                    items: stableList
                        .map(
                          (kandang) => DropdownMenuItem(
                            value: kandang,
                            child: Text(kandang.stableName),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() => selectedStable = val!);
                    },
                    decoration: InputDecoration(
                      labelText: "Pilih Kandang",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: AppColors.primary.withOpacity(0.08),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Air',
                        onPressed: () {
                          setState(() => _selectedTab = 0);
                        },
                        backgroundColor: airBg,
                        textColor: airText,
                        borderColor: airBorder,
                        fontSize: 32,
                        height: 80,
                        borderRadius: 12,
                        hasShadow: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Pakan',
                        onPressed: () {
                          setState(() => _selectedTab = 1);
                        },
                        backgroundColor: pakanBg,
                        textColor: pakanText,
                        fontSize: 32,
                        height: 80,
                        borderRadius: 12,
                        hasShadow: false,
                        borderColor: pakanBorder,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.63,
                  child: CustomCard(
                    title: 'Atur Jadwal',
                    scrollable: false,
                    titleFontSize: 20,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informasi Kandang & Sisa
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Container Kandang Info
                            SizedBox(
                              width: 280,
                              height: 210,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.25),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        selectedStable.imageAsset,
                                        width: double.infinity,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          selectedStable.stableName,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: selectedStable.isActive
                                                ? Colors.green
                                                : Colors.grey,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            selectedStable.isActive
                                                ? 'Aktif'
                                                : 'Nonaktif',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Terakhir: ',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          selectedStable.lastFeedText,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Container Sisa Air/Pakan di Kandang & Kebutuhan Isi Tempat
                            Expanded(
                              child: SizedBox(
                                height: 210,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colorMain.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: colorMain),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/fill_tank.png',
                                        width: 90,
                                        height: 90,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Sisa $tabTitle di Kandang:',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '$sisaKandang $satuan',
                                              style: TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                                color: colorMain,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Kebutuhan Isi Tempat:',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${kurangIsi.clamp(0, maxKandang).toStringAsFixed(1)} $satuan',
                                              style: TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                                color: colorMain,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // Mode Penjadwalan
                        Text(
                          'Mode Penjadwalan:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedMode,
                          items: [
                            DropdownMenuItem(
                              value: "Penjadwalan",
                              child: Text("Penjadwalan"),
                            ),
                            DropdownMenuItem(
                              value: "Otomatis",
                              child: Text("Otomatis"),
                            ),
                            DropdownMenuItem(
                              value: "Manual",
                              child: Text("Manual"),
                            ),
                          ],
                          onChanged: (val) => setState(
                            () => selectedMode = val ?? "Penjadwalan",
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: colorMain.withOpacity(0.07),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Input interval: dropdown angka 1-24
                        if (selectedMode == "Penjadwalan")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Interval Penjadwalan (berapa jam sekali):',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 250,
                                child: DropdownButtonFormField<int>(
                                  value: intervalJam,
                                  items: List.generate(
                                    24,
                                    (index) => DropdownMenuItem(
                                      value: index + 1,
                                      child: Text('${index + 1} jam'),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() => intervalJam = val ?? 2);
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: colorMain.withOpacity(0.07),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        Spacer(),
                        CustomButton(
                          text: 'Simpan Jadwal',
                          onPressed: () {},
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 20,
                          height: 80,
                          borderRadius: 8,
                          icon: Icons.save,
                          iconSize: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
