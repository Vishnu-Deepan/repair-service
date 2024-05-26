import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:repair_service/screens/customer/customer_home.dart';
import '../../provider/location_provider.dart';
import '../../models/service_model.dart';
import 'set_location.dart';

class NewRequestPage extends StatelessWidget {
  final Service gadget;

  NewRequestPage({super.key, required this.gadget});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepairForm(gadget: gadget),
    );
  }
}

class RepairForm extends StatefulWidget {
  final Service gadget;

  const RepairForm({
    super.key,
    required this.gadget,
  });

  @override
  _RepairFormState createState() => _RepairFormState();
}

class _RepairFormState extends State<RepairForm> {
  LocationProvider? locationProvider;

  @override
  void initState() {
    super.initState();
    locationProvider = Provider.of<LocationProvider>(context, listen: false);
  }

  late Position currentPosition;
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _issueDescriptionController =
      TextEditingController();


  Future<void> _openMap() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
      }
    } else if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return;
    }

    _getCurrentLocation();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            SetLocationPage(currentPosition: currentPosition,gadget: widget.gadget.name,brand: _brandController.text,model:_modelController.text,desc:_issueDescriptionController.text)));
  }



  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocationProvider>(
      create: (_) => LocationProvider(),
      child: Consumer<LocationProvider>(
          builder: (context, locationProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade200,
                Colors.blue.shade200,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back_ios_outlined,
                              color: Colors.white),
                        ),
                        Text(
                          'Repair ${widget.gadget.name}',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Device Information:',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _brandController,
                      decoration: InputDecoration(
                        labelText: 'Brand',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Enter brand name...',
                        hintStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        labelText: 'Model',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Enter model name...',
                        hintStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Problem Description:',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _issueDescriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter problem description...',
                        hintStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          // Add border to provide a clear visual indication of the text field
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(
                              8), // You can adjust the border radius as needed
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: _openMap,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Provider.of<LocationProvider>(context)
                                    .location
                                    .latitude ==
                                0
                            ? Center(
                                child: Text(
                                  "Set Service Location",
                                  style: GoogleFonts.capriola(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.done_outline_sharp,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Location Set",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text("Change Location ?",
                                      style: GoogleFonts.capriola(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      )),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // GestureDetector(
                    //   onTap: _submitRequest, // Call submit function when tapped
                    //   child: Container(
                    //     width: MediaQuery.of(context).size.width,
                    //     height: 70,
                    //     decoration: BoxDecoration(
                    //       gradient: const LinearGradient(
                    //         colors: [Colors.blue, Colors.purple],
                    //         begin: Alignment.centerLeft,
                    //         end: Alignment.centerRight,
                    //       ),
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //     child: Center(
                    //       child: Text(
                    //         "Submit Request",
                    //         style: GoogleFonts.capriola(
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _brandController.dispose();
    _modelController.dispose();
    _issueDescriptionController.dispose();
    super.dispose();
  }


  Future<Position?> _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
    return currentPosition;
  }
}
