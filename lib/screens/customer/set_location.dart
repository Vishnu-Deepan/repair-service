import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:repair_service/provider/weather_provider.dart';
import '../../provider/location_provider.dart';
import 'customer_home.dart';

class SetLocationPage extends StatefulWidget {
  var currentPosition;

  final String gadget;
  final String brand;
  final String model;
  final String desc;

  SetLocationPage({Key? key, required this.currentPosition, required this.gadget, required this.brand, required this.model, required this.desc}) : super(key: key);

  @override
  State<SetLocationPage> createState() => _SetLocationPageState();
}

class _SetLocationPageState extends State<SetLocationPage> {
  late Position currentPosition;
  static const double pointSize = 65;
  final mapController = MapController();
  LatLng tappedCoords = LatLng(0, 0);
  Point<double> tappedPoint = Point(0, 0);

  String gadget="";
  String brand="";
  String model="";
  String desc="";

  @override
  void initState() {
    super.initState();
    gadget = widget.gadget;
    brand = widget.brand;
    model = widget.model;
    desc = widget.desc;
    currentPosition = widget.currentPosition;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios_new_sharp,color: Colors.white,),
          ),
          title: const Text('Tap to Mark Location',style: TextStyle(
            fontSize: 17,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),)),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                        currentPosition.latitude, currentPosition.longitude),
                    initialZoom: 17,
                    interactionOptions: const InteractionOptions(
                      flags: ~InteractiveFlag.doubleTapZoom,
                    ),
                    onTap: (_, latLng) {
                      final point = mapController.camera
                          .latLngToScreenPoint(tappedCoords = latLng);
                      setState(() => tappedPoint = Point(point.x, point.y));
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: pointSize,
                          height: pointSize,
                          point: tappedCoords,
                          child: const Icon(
                            Icons.location_on_sharp,
                            size: 30,
                            color: Colors.red,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 80,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade600,Colors.blue.shade600], // Adjust colors as needed
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.zero, // Set border radius to zero
            ),
            child: TextButton(
              onPressed: _setLatLon,
              child: const Text(
                "Confirm Service Location",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white, // Text color to match gradient
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  void _setLatLon() {
    double latitude = tappedCoords.latitude;
    double longitude = tappedCoords.longitude;
    final locationProvider = Provider.of<LocationProvider>(context,listen: false);
    final weatherProvider = Provider.of<WeatherProvider>(context,listen: false);
    locationProvider.updateLocation(latitude,longitude);
    weatherProvider.updateWeather(context);
    _submitRequest();

  }
  void showCustomAlertDialog(BuildContext context) {
    // Use QuickAlert to display custom alert dialog
    QuickAlert.show(
      context: context,
      title: 'Success',
      text: 'Request submitted successfully',
      type: QuickAlertType.success,
      onConfirmBtnTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const CustomerHomePage(),
          ),
        );
      },
    );
  }

  void showCustomFailDialog(BuildContext context, Object error) {
    QuickAlert.show(
      context: context,
      title: 'Sorry Error Occured',
      text: error.toString(),
      type: QuickAlertType.error,
    );
  }

  void _submitRequest() async {
    try {
      // Check if _auth.currentUser is not null before accessing its properties
      if (_auth.currentUser != null) {
        String userId = _auth.currentUser!.uid;
        Timestamp timestamp = Timestamp.now();

        Map<String, dynamic> requestData = {
          'itemType': gadget,
          'brand': brand,
          'model': model,
          'issueDescription': desc,
          'assignedMechanic': null, // Default to null
          'onHoldReason': null, // Default to null
          'status': 'pending', // Default to "pending"
          'timestamp': timestamp,
          'userId': userId,
          'isRaining': Provider.of<WeatherProvider>(context, listen: false).isRaining == "" ? "Clear" : Provider.of<WeatherProvider>(context, listen: false).isRaining ,
        };

        // Add repair request to Firestore
        await _firestore.collection('repair_requests').add(requestData);
        showCustomAlertDialog(context);
      } else {
        // Handle the case when _auth.currentUser is null
        throw FirebaseAuthException(message: 'User not authenticated', code: '');
      }
    } catch (error) {
      // Handle errors
      print('Error submitting request: $error');
      // Show error message to user
      showCustomFailDialog(context, error);
    }
  }


}
