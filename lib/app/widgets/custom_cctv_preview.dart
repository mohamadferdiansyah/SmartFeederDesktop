import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:smart_feeder_desktop/app/models/halter/cctv_model.dart';
import 'package:smart_feeder_desktop/app/modules/smart_halter/monitoring_data/camera/halter_camera_controller.dart';
import 'package:smart_feeder_desktop/app/utils/toast_utils.dart';
import 'package:toastification/toastification.dart';

class CustomCctvPreview extends StatefulWidget {
  final String? cctvId;
  final String? label;

  const CustomCctvPreview({super.key, required this.cctvId, this.label});

  @override
  State<CustomCctvPreview> createState() => _CustomCctvPreviewState();
}

class _CustomCctvPreviewState extends State<CustomCctvPreview> {
  Player? _player;
  VideoController? _videoController;
  bool _hasError = false;
  bool _hasCctv = true;

  @override
  void initState() {
    super.initState();
    _initCctv();
  }

  Future<void> _initCctv() async {
    if (widget.cctvId == null) {
      setState(() {
        _hasCctv = false;
      });
      return;
    }
    final cctv = Get.find<HalterCameraController>().cctvList.firstWhereOrNull(
      (c) => c.cctvId == widget.cctvId,
    );
    if (cctv != null) {
      final rtspUrl = 'rtsp://${cctv.ipAddress}:${cctv.port}/h264_ulaw.sdp';
      _player = Player();
      await _player!.setVolume(100);
      _videoController = VideoController(_player!);
      _player!.stream.error.listen((error) {
        setState(() {
          _hasError = true;
        });
      });
      _player!.open(Media(rtspUrl));
      setState(() {});
    } else {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.label!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: borderRadius,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _hasCctv
                    ? _hasError
                          ? _buildNotConnected(theme)
                          : (_videoController == null
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Video(
                                    controller: _videoController!,
                                    controls: null,
                                    fit: BoxFit.cover,
                                  ))
                    : _buildNoCctv(theme),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: "Refresh",
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: theme.primaryColor,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _player?.dispose();
                      _player = null;
                      _videoController = null;
                      _hasError = false;
                      _hasCctv = true;
                    });
                    _initCctv();
                    showAppToast(
                      context: context,
                      type: ToastificationType.success,
                      title: 'Refresh CCTV',
                      description: 'Kamera CCTV Direfresh',
                    );
                  },
                ),
                IconButton(
                  tooltip: "Full Screen",
                  icon: Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.grey.shade600,
                    size: 22,
                  ),
                  onPressed: _videoController == null
                      ? null
                      : () {
                          final cctv = Get.find<HalterCameraController>()
                              .cctvList
                              .firstWhereOrNull(
                                (c) => c.cctvId == widget.cctvId,
                              );
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (ctx) {
                              return Dialog(
                                backgroundColor: Colors.black,
                                insetPadding: EdgeInsets.zero,
                                child: GestureDetector(
                                  onTap: () => Navigator.of(ctx).pop(),
                                  child: SizedBox.expand(
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Video(
                                            controller: _videoController!,
                                            controls: null,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        // Overlay kiri atas
                                        Positioned(
                                          top: 24,
                                          left: 24,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.6),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      cctv?.cctvId ?? "-",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Text(
                                                      'IP: ${cctv?.ipAddress ?? "-"}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Overlay kiri bawah (tanggal & jam realtime)
                                        Positioned(
                                          left: 24,
                                          bottom: 24,
                                          child: _DateTimeOverlay(),
                                        ),
                                        // Tombol close kanan atas
                                        Positioned(
                                          top: 24,
                                          right: 24,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotConnected(ThemeData theme) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_rounded, size: 44, color: Colors.grey[400]),
            const SizedBox(height: 4),
            Text(
              "Tidak Terhubung",
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCctv(ThemeData theme) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_rounded, size: 44, color: Colors.grey[300]),
            const SizedBox(height: 4),
            Text(
              "Tidak Memiliki CCTV",
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeOverlay extends StatefulWidget {
  @override
  State<_DateTimeOverlay> createState() => _DateTimeOverlayState();
}

class _DateTimeOverlayState extends State<_DateTimeOverlay> {
  late String _dateStr;
  late String _timeStr;
  late final ticker = Stream.periodic(const Duration(seconds: 1));

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    ticker.listen((_) {
      if (mounted) setState(_updateDateTime);
    });
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final hari = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ][now.weekday % 7];
    final bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ][now.month - 1];
    _dateStr = '$hari, ${now.day} $bulan ${now.year}';
    _timeStr =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _dateStr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _timeStr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
