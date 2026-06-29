import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class VisitPlotMapScreen extends StatefulWidget {
  final String plotName;
  final String? farmerName;
  final String? village;
  final double latitude;
  final double longitude;
  final Map<String, dynamic>? plotDetails;

  const VisitPlotMapScreen({
    super.key,
    required this.plotName,
    required this.latitude,
    required this.longitude,
    this.farmerName,
    this.village,
    this.plotDetails,
  });

  @override
  State<VisitPlotMapScreen> createState() => _VisitPlotMapScreenState();
}

class _VisitPlotMapScreenState extends State<VisitPlotMapScreen> {
  bool _isLaunchingDirections = false;
  bool _showPlotDetails = true;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text(
          'Plot Map',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: const Color(0xFFFAF9F6),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.plotName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if ((widget.farmerName ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      widget.farmerName!,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                  if ((widget.village ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.village!,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Lat: ${widget.latitude.toStringAsFixed(6)}, Lng: ${widget.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: FlutterMap(
                  options: MapOptions(initialCenter: point, initialZoom: 16),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.yashagro.partner',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 56,
                          height: 56,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showPlotDetails = true;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green.shade700,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.shade700.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_showPlotDetails) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Plot Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showPlotDetails = false;
                            });
                          },
                          icon: const Icon(Icons.close, size: 20),
                          splashRadius: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._buildPlotDetails(),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLaunchingDirections
                            ? null
                            : _openDirectionsInGoogleMaps,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.directions),
                        label: Text(
                          _isLaunchingDirections
                              ? 'Opening...'
                              : 'Open in Google Maps',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPlotDetails() {
    final details = widget.plotDetails ?? <String, dynamic>{};

    final rows = <Widget?>[
      _buildDetailRow('Plot Name', details['plot_name'] ?? widget.plotName),
      _buildDetailRow('Crop', details['crops_id']),
      _buildDetailRow('Variety', details['variety']),
      _buildDetailRow('Pruning Type', details['pruning_type']),
      _buildDetailRow('Pruning Date', details['prunning_date']),
      _buildDetailRow('Planting Date', details['planting_date']),
      _buildDetailRow(
        'Area',
        _combineArea(details['area'], details['area_unit']),
      ),
      _buildDetailRow('Soil Type', details['soil_type']),
      _buildDetailRow('Irrigation Type', details['irrigation_type']),
      _buildDetailRow('Structure', details['structure']),
      _buildDetailRow('Water Resource', details['water_resource']),
      _buildDetailRow('Location', details['location']),
    ];

    return rows.whereType<Widget>().toList();
  }

  Widget? _buildDetailRow(String label, dynamic value) {
    final text = _safeText(value);
    if (text == 'N/A') {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _combineArea(dynamic area, dynamic areaUnit) {
    final areaText = _safeText(area);
    final unitText = _safeText(areaUnit);
    if (areaText == 'N/A' && unitText == 'N/A') {
      return 'N/A';
    }
    if (unitText == 'N/A') {
      return areaText;
    }
    if (areaText == 'N/A') {
      return unitText;
    }
    return '$areaText $unitText';
  }

  String _safeText(dynamic value) {
    if (value == null) {
      return 'N/A';
    }

    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return 'N/A';
    }

    return text;
  }

  Future<void> _openDirectionsInGoogleMaps() async {
    setState(() {
      _isLaunchingDirections = true;
    });

    try {
      final currentPosition = await _getCurrentPosition();
      final destination =
          '${widget.latitude.toStringAsFixed(6)},${widget.longitude.toStringAsFixed(6)}';

      final directionsUrl = currentPosition == null
          ? Uri.parse(
              'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving',
            )
          : Uri.parse(
              'https://www.google.com/maps/dir/?api=1&origin=${currentPosition.latitude},${currentPosition.longitude}&destination=$destination&travelmode=driving',
            );

      if (await canLaunchUrl(directionsUrl)) {
        await launchUrl(directionsUrl, mode: LaunchMode.externalApplication);
        return;
      }

      Get.snackbar(
        'Error',
        'Could not open Google Maps',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLaunchingDirections = false;
        });
      }
    }
  }

  Future<Position?> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Location Off',
        'Enable location services to start directions from your current location.',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      Get.snackbar(
        'Permission Needed',
        'Location permission was denied. Opening directions without your current location.',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission Needed',
        'Location permission is permanently denied. Opening directions without your current location.',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      Get.snackbar(
        'Location Error',
        'Could not fetch your current location. Opening directions without it.',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return null;
    }
  }
}
