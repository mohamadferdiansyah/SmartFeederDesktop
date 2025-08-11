import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/dashboard/feeder_dashboard_controller.dart';
import 'package:smart_feeder_desktop/app/modules/smart_feeder/setting/feeder_setting_controller.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';
import 'package:toastification/toastification.dart';

class FeederSettingPage extends StatefulWidget {
  const FeederSettingPage({super.key});

  @override
  State<FeederSettingPage> createState() => FeederSettingPageState();
}

class FeederSettingPageState extends State<FeederSettingPage> {
  final FeederDashboardController controller = Get.find();
  final FeederSettingController settingController = Get.find();

  // final TextEditingController _cloudUrlController = TextEditingController(
  //   text: 'https://smarthalter.ipb.ac.id',
  // );

  // String? _selectedLoraPort;
  // bool _loraConnected = false;

  // String? _selectedJenisPengiriman = 'LoRa';

  @override
  void initState() {
    super.initState();
    // _selectedLoraPort = settingController.setting.value.loraPort.isEmpty
    //     ? null
    //     : settingController.setting.value.loraPort;
    // _loraConnected = settingController.setting.value.loraPort.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Atur ukuran card agar tidak full height, dan grid agar responsif
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        title: 'Pengaturan Aplikasi Halter',
        withExpanded: false,
        content: Center(
          child: Column(
            children: [
              SingleChildScrollView(
                child: Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    // Card 1: Cloud Connection
                    // CustomCard(
                    //   withExpanded: false,
                    //   title: 'Cloud Connection',
                    //   headerColor: AppColors.primary,
                    //   headerHeight: 50,
                    //   titleFontSize: 18,
                    //   width: MediaQuery.of(context).size.width * 0.25,
                    //   height: MediaQuery.of(context).size.height * 0.27,
                    //   borderRadius: 16,
                    //   scrollable: false,
                    //   content: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.stretch,
                    //     children: [
                    //       const Text('Cloud URL'),
                    //       const SizedBox(height: 4),
                    //       TextField(
                    //         controller: _cloudUrlController,
                    //         decoration: const InputDecoration(
                    //           isDense: true,
                    //           border: OutlineInputBorder(),
                    //         ),
                    //       ),
                    //       const SizedBox(height: 12),
                    //       Row(
                    //         children: [
                    //           Expanded(
                    //             child: ElevatedButton(
                    //               style: ElevatedButton.styleFrom(
                    //                 backgroundColor: AppColors.primary,
                    //                 foregroundColor: Colors.white,
                    //                 shape: RoundedRectangleBorder(
                    //                   borderRadius: BorderRadius.circular(8),
                    //                 ),
                    //               ),
                    //               onPressed: () {},
                    //               child: const Text('Simpan'),
                    //             ),
                    //           ),
                    //           const SizedBox(width: 10),
                    //           Expanded(
                    //             child: ElevatedButton(
                    //               style: ElevatedButton.styleFrom(
                    //                 backgroundColor: Colors.blueGrey,
                    //                 foregroundColor: Colors.white,
                    //                 shape: RoundedRectangleBorder(
                    //                   borderRadius: BorderRadius.circular(8),
                    //                 ),
                    //               ),
                    //               onPressed: () {
                    //                 settingController.updateCloud(
                    //                   url: _cloudUrlController.text,
                    //                 );
                    //                 toastification.show(
                    //                   context: context,
                    //                   title: Text(
                    //                     'Koneksi Cloud Berhasil',
                    //                     style: const TextStyle(
                    //                       fontSize: 16,
                    //                       fontWeight: FontWeight.bold,
                    //                     ),
                    //                   ),
                    //                   type: ToastificationType.success,
                    //                   description: Text(
                    //                     'Cloud URL: ${_cloudUrlController.text}',
                    //                   ),
                    //                   boxShadow: const [
                    //                     BoxShadow(
                    //                       color: Colors.black26,
                    //                       blurRadius: 8,
                    //                       offset: Offset(0, 2),
                    //                     ),
                    //                   ],
                    //                   alignment: Alignment.topCenter,
                    //                   autoCloseDuration: const Duration(
                    //                     seconds: 2,
                    //                   ),
                    //                 );
                    //               },
                    //               child: const Text('Cek Koneksi'),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 12),
                    //       Obx(
                    //         () => LinearProgressIndicator(
                    //           value:
                    //               settingController
                    //                   .setting
                    //                   .value
                    //                   .cloudUrl
                    //                   .isNotEmpty
                    //               ? 1.0
                    //               : 0.2,
                    //           minHeight: 8,
                    //           color:
                    //               settingController
                    //                   .setting
                    //                   .value
                    //                   .cloudUrl
                    //                   .isNotEmpty
                    //               ? Colors.green
                    //               : Colors.orange,
                    //           backgroundColor: Colors.grey[300],
                    //         ),
                    //       ),
                    //       const SizedBox(height: 4),
                    //       Text(
                    //         settingController.setting.value.cloudUrl.isNotEmpty
                    //             ? 'Terhubung'
                    //             : 'Tidak Terhubung',
                    //         style: TextStyle(
                    //           color:
                    //               settingController
                    //                   .setting
                    //                   .value
                    //                   .cloudUrl
                    //                   .isNotEmpty
                    //               ? Colors.green
                    //               : Colors.orange,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //         textAlign: TextAlign.right,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Card 2: Lora Connection
                    // // CustomCard(
                    // //   title: 'Lora Connection',
                    // //   headerColor: AppColors.primary,
                    // //   withExpanded: false,

                    // //   headerHeight: 50,
                    // //   titleFontSize: 18,
                    // //   width: MediaQuery.of(context).size.width * 0.25,
                    // //   height: MediaQuery.of(context).size.height * 0.27,
                    // //   borderRadius: 16,
                    // //   scrollable: false,
                    // //   content: Column(
                    // //     crossAxisAlignment: CrossAxisAlignment.stretch,
                    // //     children: [
                    // //       const Text('Port'),
                    // //       const SizedBox(height: 4),
                    // //       DropdownButtonFormField<String>(
                    // //         value: _selectedLoraPort,
                    // //         decoration: const InputDecoration(
                    // //           border: OutlineInputBorder(),
                    // //           isDense: true,
                    // //         ),
                    // //         items: settingController.availablePorts
                    // //             .map(
                    // //               (port) => DropdownMenuItem(
                    // //                 value: port,
                    // //                 child: Text(port),
                    // //               ),
                    // //             )
                    // //             .toList(),
                    // //         onChanged: (val) {
                    // //           setState(() {
                    // //             _selectedLoraPort = val;
                    // //             _loraConnected = false;
                    // //             settingController.updateLora(
                    // //               port: _selectedLoraPort!,
                    // //             );
                    // //           });
                    // //         },
                    // //         hint: const Text('Pilih Port'),
                    // //       ),
                    // //       const SizedBox(height: 12),
                    // //       Row(
                    // //         children: [
                    // //           // Tombol Simpan Port (optional, bisa diisi logic simpan port ke controller)
                    // //           Expanded(
                    // //             child: ElevatedButton(
                    // //               style: ElevatedButton.styleFrom(
                    // //                 backgroundColor: AppColors.primary,
                    // //                 foregroundColor: Colors.white,
                    // //                 shape: RoundedRectangleBorder(
                    // //                   borderRadius: BorderRadius.circular(8),
                    // //                 ),
                    // //               ),
                    // //               onPressed: _selectedLoraPort == null
                    // //                   ? null
                    // //                   : () {
                    // //                       // Logic simpan port jika perlu
                    // //                     },
                    // //               child: const Text('Simpan Port'),
                    // //             ),
                    // //           ),
                    // //           const SizedBox(width: 10),
                    // //           // Tombol Connect/Disconnect
                    // //           Expanded(
                    // //             child: ElevatedButton(
                    // //               style: ElevatedButton.styleFrom(
                    // //                 backgroundColor: _selectedLoraPort == null
                    // //                     ? Colors.grey.shade400
                    // //                     : _loraConnected
                    // //                     ? Colors.red
                    // //                     : Colors.green,
                    // //                 foregroundColor: Colors.white,
                    // //                 shape: RoundedRectangleBorder(
                    // //                   borderRadius: BorderRadius.circular(8),
                    // //                 ),
                    // //               ),
                    // //               onPressed: _selectedLoraPort == null
                    // //                   ? null
                    // //                   : () {
                    // //                       setState(() {
                    // //                         _loraConnected = !_loraConnected;
                    // //                         settingController.updateLora(
                    // //                           port: _selectedLoraPort!,
                    // //                         );
                    // //                         if (_loraConnected) {
                    // //                           toastification.show(
                    // //                             context: context,
                    // //                             title: const Text(
                    // //                               'Koneksi Lora Berhasil',
                    // //                               style: TextStyle(
                    // //                                 fontSize: 16,
                    // //                                 fontWeight: FontWeight.bold,
                    // //                               ),
                    // //                             ),
                    // //                             type:
                    // //                                 ToastificationType.success,
                    // //                             description: Text(
                    // //                               'Port: $_selectedLoraPort',
                    // //                             ),
                    // //                             boxShadow: const [
                    // //                               BoxShadow(
                    // //                                 color: Colors.black26,
                    // //                                 blurRadius: 8,
                    // //                                 offset: Offset(0, 2),
                    // //                               ),
                    // //                             ],
                    // //                             alignment: Alignment.topCenter,
                    // //                             autoCloseDuration:
                    // //                                 const Duration(seconds: 2),
                    // //                           );
                    // //                         } else {
                    // //                           toastification.show(
                    // //                             context: context,
                    // //                             title: const Text(
                    // //                               'Koneksi Lora Terputus',
                    // //                               style: TextStyle(
                    // //                                 fontSize: 16,
                    // //                                 fontWeight: FontWeight.bold,
                    // //                               ),
                    // //                             ),
                    // //                             type: ToastificationType.error,
                    // //                             description: const Text(
                    // //                               'Lora telah terputus.',
                    // //                             ),
                    // //                             boxShadow: const [
                    // //                               BoxShadow(
                    // //                                 color: Colors.black26,
                    // //                                 blurRadius: 8,
                    // //                                 offset: Offset(0, 2),
                    // //                               ),
                    // //                             ],
                    // //                             alignment: Alignment.topCenter,
                    // //                             autoCloseDuration:
                    // //                                 const Duration(seconds: 2),
                    // //                           );
                    // //                         }
                    // //                       });
                    // //                     },
                    // //               child: Text(
                    // //                 _loraConnected ? 'Putuskan' : 'Hubungkan',
                    // //               ),
                    // //             ),
                    // //           ),
                    // //         ],
                    // //       ),
                    // //       const SizedBox(height: 12),
                    // //       // Status Bar
                    // //       LinearProgressIndicator(
                    // //         value: 1,
                    // //         minHeight: 8,
                    // //         color: _loraConnected ? Colors.green : Colors.red,
                    // //         backgroundColor: Colors.grey[300],
                    // //       ),
                    // //       const SizedBox(height: 4),
                    // //       Text(
                    // //         _loraConnected ? 'Terhubung' : 'Tidak Terhubung',
                    // //         style: TextStyle(
                    // //           color: _loraConnected ? Colors.green : Colors.red,
                    // //           fontWeight: FontWeight.bold,
                    // //         ),
                    // //         textAlign: TextAlign.right,
                    // //       ),
                    // //     ],
                    // //   ),
                    // // ),
                    // // Card 3: Pengiriman Data Halter
                    // CustomCard(
                    //   title: 'Pengiriman Data Halter',
                    //   headerColor: AppColors.primary,
                    //   withExpanded: false,

                    //   headerHeight: 50,
                    //   titleFontSize: 18,
                    //   width: MediaQuery.of(context).size.width * 0.25,
                    //   height: MediaQuery.of(context).size.height * 0.27,
                    //   borderRadius: 16,
                    //   scrollable: false,
                    //   content: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.stretch,
                    //     children: [
                    //       const Text('Jenis Pengiriman'),
                    //       const SizedBox(height: 4),
                    //       DropdownButtonFormField<String>(
                    //         value: _selectedJenisPengiriman,
                    //         decoration: const InputDecoration(
                    //           border: OutlineInputBorder(),
                    //           isDense: true,
                    //         ),
                    //         items: ['LoRa', 'Http', 'LoRa + Http']
                    //             .map(
                    //               (jenis) => DropdownMenuItem(
                    //                 value: jenis,
                    //                 child: Text(jenis),
                    //               ),
                    //             )
                    //             .toList(),
                    //         onChanged: (val) {
                    //           setState(() {
                    //             _selectedJenisPengiriman = val;
                    //           });
                    //         },
                    //       ),
                    //       const SizedBox(height: 16),
                    //       SizedBox(
                    //         width: double.infinity,
                    //         height: 40,
                    //         child: ElevatedButton(
                    //           style: ElevatedButton.styleFrom(
                    //             backgroundColor: AppColors.primary,
                    //             foregroundColor: Colors.white,
                    //             shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(8),
                    //             ),
                    //           ),
                    //           onPressed: () {
                    //             settingController.updateJenisPengiriman(
                    //               _selectedJenisPengiriman!,
                    //             );
                    //             toastification.show(
                    //               context: context,
                    //               title: const Text(
                    //                 'Pengaturan Jenis Pengiriman Berhasil',
                    //                 style: TextStyle(
                    //                   fontSize: 16,
                    //                   fontWeight: FontWeight.bold,
                    //                 ),
                    //               ),
                    //               type: ToastificationType.success,
                    //               description: Text(
                    //                 'Jenis Pengiriman: $_selectedJenisPengiriman',
                    //               ),
                    //               boxShadow: const [
                    //                 BoxShadow(
                    //                   color: Colors.black26,
                    //                   blurRadius: 8,
                    //                   offset: Offset(0, 2),
                    //                 ),
                    //               ],
                    //               alignment: Alignment.topCenter,
                    //               autoCloseDuration: const Duration(seconds: 2),
                    //             );
                    //           },
                    //           child: const Text(
                    //             'Simpan',
                    //             style: TextStyle(fontSize: 16),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    CustomCard(
                      title: 'Pilih Kandang',
                      headerColor: AppColors.primary,
                      withExpanded: false,

                      headerHeight: 50,
                      titleFontSize: 18,
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: MediaQuery.of(context).size.height * 0.27,
                      borderRadius: 16,
                      scrollable: false,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Kandang'),
                          const SizedBox(height: 4),
                          Obx(() {
                            final list = controller.stableList;
                            // Cari apakah selectedStableId ada di list, kalau tidak, set null
                            final selected =
                                list.any(
                                  (s) =>
                                      s.stableId ==
                                      controller.selectedStableId.value,
                                )
                                ? controller.selectedStableId.value
                                : null;

                            if (selected == null && list.isNotEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                controller.setSelectedStableId(
                                  list.first.stableId,
                                );
                              });
                            }
                            return DropdownButtonFormField<String>(
                              value: selected,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: list
                                  .map(
                                    (stable) => DropdownMenuItem(
                                      value: stable.stableId,
                                      child: Text(stable.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.setSelectedStableId(val);
                                }
                              },
                              hint: const Text('Pilih Kandang'),
                            );
                          }),
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
                              onPressed: () {
                                toastification.show(
                                  context: context,
                                  title: Text(
                                    'Pengaturan Kandang Berhasil',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  type: ToastificationType.success,
                                  description: Text(
                                    'Kandang: ${controller.selectedStableId.value}',
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  alignment: Alignment.topCenter,
                                  autoCloseDuration: const Duration(seconds: 2),
                                );
                              },
                              child: const Text(
                                'Simpan',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: 1, // contoh dummy
                            minHeight: 8,
                            color: Colors.green,
                            backgroundColor: Colors.grey[300],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Terhubung',
                            style: const TextStyle(
                              color: Colors.green,
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
      ),
    );
  }
}
