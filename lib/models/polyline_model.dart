import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:the_carbon_conscious_traveller/constants.dart';

class PolylineModel extends ChangeNotifier {
  final PolylinePoints _polylinePoints = PolylinePoints();
  final Map<PolylineId, Polyline> _polylines = {};
  final List<LatLng> _polylineCoordinates = [];
  TravelMode _transportMode = TravelMode.driving;
  String _mode = 'driving';

  PolylinePoints get polylinePoints => _polylinePoints;
  Map<PolylineId, Polyline> get polylines => _polylines;
  List<LatLng> get polylineCoordinates => _polylineCoordinates;
  String get mode => _mode;

  static const Map<String, TravelMode> _modeMap = {
    'driving': TravelMode.driving,
    'motorcycling': TravelMode.driving, // This should be motorcycling
    'transit': TravelMode.transit,
    'flying': TravelMode.walking, // This should be flying
  };

  set transportMode(String mode) {
    _transportMode = _modeMap[mode]!;
    _mode = mode;
    print("Transport mode in model: $_transportMode");
    resetPolyline();
    notifyListeners();
  }

  void resetPolyline() {
    print("Resetting polyline");
    _polylineCoordinates.clear();
    _polylines.clear();
    notifyListeners();
  }

  void drawPolyline() {
    print("Drawing polyline");
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: const Color.fromARGB(255, 45, 61, 245),
        points: polylineCoordinates,
        width: 4);
    polylines[id] = polyline;
    notifyListeners();
  }

  void getPolyline(List<LatLng> coordinates) async {
    print("Getting polyline...");
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: Constants.googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(coordinates[0].latitude, coordinates[0].longitude),
        destination:
            PointLatLng(coordinates[1].latitude, coordinates[1].longitude),
        mode: _transportMode,
      ),
    );
    if (result.points.isNotEmpty) {
      for (PointLatLng point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    drawPolyline();
    notifyListeners();
  }
}
