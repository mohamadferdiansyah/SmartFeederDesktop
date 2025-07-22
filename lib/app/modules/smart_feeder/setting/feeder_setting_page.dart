import 'package:flutter/material.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';

class FeederSettingPage extends StatefulWidget {
  const FeederSettingPage({super.key});

  @override
  State<FeederSettingPage> createState() => FeederSettingPageState();
}

class FeederSettingPageState extends State<FeederSettingPage> {
  // Dummy controllers
  final TextEditingController _cloudUrlController = TextEditingController(
    text: 'https://smarthalter.ipb.ac.id',
  );
  final TextEditingController _loraPortController = TextEditingController(
    text: 'COM3',
  );
  String? _selectedJenisPengiriman = 'Realtime';
  bool _cloudConnected = true;
  bool _loraConnected = false;

  @override
  Widget build(BuildContext context) {
    // Atur ukuran card agar tidak full height, dan grid agar responsif
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        title: 'Pengaturan Perangkat',
        content: Column(
          children: [
            SingleChildScrollView(
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  // Card 1: Cloud Connection
                  CustomCard(
                    title: 'Cloud Connection',
                    headerColor: AppColors.primary,
                    headerHeight: 50,
                    titleFontSize: 18,
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.height * 0.27,
                    borderRadius: 16,
                    scrollable: false,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Cloud URL'),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _cloudUrlController,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text('Simpan'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text('Check Connection'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: _cloudConnected ? 1.0 : 0.2,
                          minHeight: 8,
                          color: _cloudConnected ? Colors.green : Colors.orange,
                          backgroundColor: Colors.grey[300],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _cloudConnected ? 'Terhubung' : 'Tidak Terhubung',
                          style: TextStyle(
                            color: _cloudConnected
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  // Card 2: Lora Connection
                  CustomCard(
                    title: 'Lora Connection',
                    headerColor: AppColors.primary,
                    headerHeight: 50,
                    titleFontSize: 18,
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.height * 0.27,
                    borderRadius: 16,
                    scrollable: false,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Port'),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: _loraPortController.text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: ['COM1', 'COM2', 'COM3', 'COM4']
                              .map(
                                (port) => DropdownMenuItem(
                                  value: port,
                                  child: Text(port),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _loraPortController.text = val ?? '';
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text('Simpan Port'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text('Disconnect'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: _loraConnected ? 1.0 : 0.2,
                          minHeight: 8,
                          color: _loraConnected ? Colors.green : Colors.red,
                          backgroundColor: Colors.grey[300],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _loraConnected ? 'Terhubung' : 'Not Connected',
                          style: TextStyle(
                            color: _loraConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  // Card 3: Pengiriman Data Halter
                  CustomCard(
                    title: 'Pengiriman Data Halter',
                    headerColor: AppColors.primary,
                    headerHeight: 50,
                    titleFontSize: 18,
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.height * 0.27,
                    borderRadius: 16,
                    scrollable: false,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Jenis Pengiriman'),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: _selectedJenisPengiriman,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: ['Realtime', 'Batch', 'Manual']
                              .map(
                                (jenis) => DropdownMenuItem(
                                  value: jenis,
                                  child: Text(jenis),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedJenisPengiriman = val;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              'Simpan',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: 0.2, // contoh dummy
                          minHeight: 8,
                          color: Colors.orange,
                          backgroundColor: Colors.grey[300],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Not Connected',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
