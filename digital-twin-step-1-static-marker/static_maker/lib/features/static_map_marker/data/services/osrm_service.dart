import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/route_result.dart';

class OsrmService {
  Future<RouteResult> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      '${AppConstants.osrmBaseUrl}/route/v1/driving/'
      '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("OSRM error");
    }

    final data = jsonDecode(response.body);
    final route = data['routes'][0];

    final coords = route['geometry']['coordinates'];

    List<LatLng> points = coords.map<LatLng>((c) {
      return LatLng(c[1], c[0]);
    }).toList();

    return RouteResult(
      points: points,
      distanceMeters: route['distance'],
      durationSeconds: route['duration'],
    );
  }
}
