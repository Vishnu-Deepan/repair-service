import 'package:flutter/material.dart';
import '../models/location_model.dart';
class LocationProvider extends ChangeNotifier {
  LocationData _locationData = LocationData(0.0, 0.0);

  LocationData get location => _locationData;

  void updateLocation(double latitude , double longitude) {
    _locationData = LocationData(latitude, longitude);
    notifyListeners();
  }


}