import 'package:flutter/material.dart';
import 'package:smart_feeder_desktop/app/widgets/custom_card.dart';
import 'package:smart_feeder_desktop/app/constants/app_colors.dart';

class HalterSyncPage extends StatefulWidget {
  const HalterSyncPage({super.key});

  @override
  State<HalterSyncPage> createState() => _HalterSyncPageState();
}

class _HalterSyncPageState extends State<HalterSyncPage> {
  final List<_SyncTable> tables = [
    _SyncTable(name: "Tipe Kuda"),
    _SyncTable(name: "IoT Node Halter"),
    _SyncTable(name: "Jenis Kuda"),
    _SyncTable(name: "Jenis Kelamin"),
    _SyncTable(name: "Pakan"),
    _SyncTable(name: "Pengguna"),
    _SyncTable(name: "Ruang"),
    _SyncTable(name: "Cctv"),
    _SyncTable(name: "Status Kuda"),
    _SyncTable(name: "Kuda"),
    _SyncTable(name: "Jadwal Petugas"),
    _SyncTable(name: "Kandang"),
  ];

  final String lastUpdate = "03-04-2023 13:44:32";

  @override
  Widget build(BuildContext context) {
    final double gridCardWidth = MediaQuery.of(context).size.width > 1200
        ? (MediaQuery.of(context).size.width - 120) / 4
        : (MediaQuery.of(context).size.width > 900
              ? (MediaQuery.of(context).size.width - 90) / 3
              : double.infinity);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomCard(
        title: 'Singkronisasi Data dengan Cloud',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                children: tables
                    .map(
                      (tbl) => SizedBox(
                        width: gridCardWidth > 400 ? 400 : gridCardWidth,
                        child: _SyncTableCard(
                          table: tbl,
                          lastUpdate: lastUpdate,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncTable {
  final String name;
  _SyncTable({required this.name});
}

class _SyncTableCard extends StatelessWidget {
  final _SyncTable table;
  final String lastUpdate;

  const _SyncTableCard({required this.table, required this.lastUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Nama Tabel",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const Spacer(),
                const Text(
                  "Terakhir Update",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  table.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
                const Spacer(),
                Text(
                  lastUpdate,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Status Sinkronisasi",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36),
                  ),
                  child: const Text('Sinkronisasi'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 14),
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'Tersinkronisasi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.5,
                        ),
                      ),
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
