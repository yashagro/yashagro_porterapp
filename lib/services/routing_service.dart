import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class RoutingService {
  static final Dio _dio = Dio();

  /// Launches Google Maps to navigate/view the specified LatLng route points
  static Future<void> launchGoogleMapsRoute(List<LatLng> points) async {
    if (points.isEmpty) return;

    String url;
    if (points.length == 1) {
      url = "https://www.google.com/maps/search/?api=1&query=${points.first.latitude},${points.first.longitude}";
    } else {
      final origin = "${points.first.latitude},${points.first.longitude}";
      final destination = "${points.last.latitude},${points.last.longitude}";
      
      String waypoints = "";
      if (points.length > 2) {
        final List<LatLng> intermediates = [];
        final step = (points.length - 2) / 8.0;
        for (int i = 0; i < 8 && i * step < points.length - 2; i++) {
          final index = 1 + (i * step).toInt();
          if (index < points.length - 1) {
            intermediates.add(points[index]);
          }
        }
        waypoints = intermediates.map((p) => "${p.latitude},${p.longitude}").join('|');
      }

      url = "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination" +
          (waypoints.isNotEmpty ? "&waypoints=$waypoints" : "") +
          "&travelmode=driving";
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      log("Could not launch Google Maps URL: $url", name: 'routing_service');
    }
  }

  /// Fetches a road route (snapped to roads) connecting the input LatLng points from OSRM
  static Future<List<LatLng>> getRoadRoute(List<LatLng> points) async {
    if (points.length < 2) return points;

    try {
      // OSRM expects: longitude,latitude separated by semicolons
      // Limit coordinates list size to 100 points to prevent URL length limits
      List<LatLng> queryPoints = [];
      if (points.length <= 100) {
        queryPoints = points;
      } else {
        // Downsample to 100 points
        final step = points.length / 100.0;
        for (int i = 0; i < 100; i++) {
          queryPoints.add(points[(i * step).toInt()]);
        }
        if (queryPoints.last != points.last) {
          queryPoints.add(points.last);
        }
      }

      final coordsStr = queryPoints
          .map((p) => "${p.longitude},${p.latitude}")
          .join(';');

      final url = "https://router.project-osrm.org/route/v1/driving/$coordsStr?overview=full&geometries=geojson";
      
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['code'] == 'Ok' && data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          if (geometry != null && geometry['coordinates'] != null) {
            final coordsList = geometry['coordinates'] as List<dynamic>;
            final List<LatLng> roadPoints = [];
            for (var c in coordsList) {
              if (c is List && c.length == 2) {
                final lon = double.tryParse(c[0].toString());
                final lat = double.tryParse(c[1].toString());
                if (lat != null && lon != null) {
                  roadPoints.add(LatLng(lat, lon));
                }
              }
            }
            if (roadPoints.isNotEmpty) {
              return roadPoints;
            }
          }
        }
      }
    } catch (e) {
      log("❌ Error fetching road route from OSRM: $e", name: 'routing_service');
    }

    return points;
  }
}

class RoadPolylineLayer extends StatefulWidget {
  final List<LatLng> rawPoints;
  final Color color;
  final double strokeWidth;

  const RoadPolylineLayer({
    super.key,
    required this.rawPoints,
    required this.color,
    required this.strokeWidth,
  });

  @override
  State<RoadPolylineLayer> createState() => _RoadPolylineLayerState();
}

class _RoadPolylineLayerState extends State<RoadPolylineLayer> {
  List<LatLng> _roadPoints = [];
  List<LatLng>? _lastRawPoints;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRoadPoints();
  }

  @override
  void didUpdateWidget(covariant RoadPolylineLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_arePointsEqual(widget.rawPoints, _lastRawPoints)) {
      _fetchRoadPoints();
    }
  }

  bool _arePointsEqual(List<LatLng> a, List<LatLng>? b) {
    if (b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].latitude != b[i].latitude || a[i].longitude != b[i].longitude) {
        return false;
      }
    }
    return true;
  }

  Future<void> _fetchRoadPoints() async {
    _lastRawPoints = List<LatLng>.from(widget.rawPoints);
    if (widget.rawPoints.length < 2) {
      setState(() {
        _roadPoints = widget.rawPoints;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final fetchedRoadPoints = await RoutingService.getRoadRoute(widget.rawPoints);
    
    if (mounted) {
      setState(() {
        _roadPoints = fetchedRoadPoints;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pointsToDraw = _roadPoints.isNotEmpty ? _roadPoints : widget.rawPoints;
    return PolylineLayer(
      polylines: [
        Polyline(
          points: pointsToDraw,
          color: widget.color,
          strokeWidth: widget.strokeWidth,
        ),
      ],
    );
  }
}
