import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_feeder_desktop/app/data/storage/halter/data_team_halter.dart';

class CustomMapPicker extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final double? initialAlt;
  final void Function(double lat, double lng, double? alt) onChanged;

  const CustomMapPicker({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialAlt,
    required this.onChanged,
  });

  @override
  State<CustomMapPicker> createState() => CustomMapPickerState();
}

class CustomMapPickerState extends State<CustomMapPicker> {
  LatLng? _selected;
  late TextEditingController _altCtrl;

  @override
  void initState() {
    super.initState();
    final team = DataTeamHalter.getTeam();
    final lat = team?.latitude;
    final lng = team?.longitude;
    final alt = team?.altitude;

    if (lat != null && lng != null) {
      _selected = LatLng(lat, lng);
    } else if (widget.initialLat != null && widget.initialLng != null) {
      _selected = LatLng(widget.initialLat!, widget.initialLng!);
    } else {
      _selected = LatLng(-6.798891746891438, 107.57122769373423);
    }
    _altCtrl = TextEditingController(
      text: (alt ?? widget.initialAlt)?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lokasi Pengujian (klik pada peta)'),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: FlutterMap(
            options: MapOptions(
              initialCenter:
                  _selected ?? LatLng(-6.798891746891438, 107.57122769373423),
              // minZoom: 15,
              onTap: (tapPos, latlng) {
                setState(() {
                  _selected = latlng;
                });
                widget.onChanged(
                  latlng.latitude,
                  latlng.longitude,
                  double.tryParse(_altCtrl.text),
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=Fcw1tDADwUeUJwoQLqIN',
                userAgentPackageName: 'com.example.app',
              ),
              if (_selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: _selected!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                _selected == null
                    ? 'Belum dipilih'
                    : 'Lat: ${_selected!.latitude.toStringAsFixed(6)}, Lng: ${_selected!.longitude.toStringAsFixed(6)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _altCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Alt (m)',
                  isDense: true,
                ),
                onChanged: (v) {
                  if (_selected != null) {
                    widget.onChanged(
                      _selected!.latitude,
                      _selected!.longitude,
                      double.tryParse(v),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
