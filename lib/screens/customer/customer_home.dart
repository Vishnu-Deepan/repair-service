import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_service/screens/customer/track_status_screen.dart';
import '../service/model.dart';
import 'submit_new_request.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({Key? key}) : super(key: key);

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Service> gadgets = [
    Service('Mobile Phone', 'https://img.icons8.com/nolan/96/iphone-x.png'),
    Service('Laptop', 'https://img.icons8.com/nolan/96/laptop.png'),
    Service('Tablet', 'https://img.icons8.com/nolan/96/ipad.png'),
    Service('Smartwatch',
        'https://img.icons8.com/nolan/96/1A6DFF/C822FF/watches-front-view--v2.png'),
    Service(
        'Camera', 'https://img.icons8.com/nolan/96/1A6DFF/C822FF/camera.png'),
    Service('Headphones', 'https://img.icons8.com/nolan/96/headphones.png'),
  ];

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade200,Colors.blue.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: 20.0, top: 50.0, right: 10.0), // Adjust top padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () async {
                        await _auth.signOut();
                        // Navigate to login screen
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      icon: Icon(Icons.logout_outlined, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Gadget to Repair',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 500,
                child: Center(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Display two gadgets in one row
                      childAspectRatio: deviceWidth /
                          (deviceWidth * 0.78), // Adjust aspect ratio
                      crossAxisSpacing:
                      (MediaQuery.of(context).size.width * 0.12) /
                          2, // Evenly distribute spacing
                      mainAxisSpacing: 20.0,
                    ),
                    itemCount: gadgets.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          // Navigate to repair details page and pass selected gadget
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewRequestPage(gadget: gadgets[index]),
                            ),
                          );
                        },
                        child: gadgetContainer(
                          gadgets[index].imageURL,
                          gadgets[index].name,
                          index,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  if (_auth.currentUser != null) {
                    // Navigate to track status screen
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const TrackStatusScreen() ,
                      ),
                    );
                  } else {
                    // User is not authenticated, handle accordingly
                    // For example, show a message or navigate to login screen
                    print("User null");
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width -
                      MediaQuery.of(context).padding.top,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),


                  ),
                  child: Center(
                    child: Text(
                      "Past Requests",
                      style: GoogleFonts.capriola(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  gadgetContainer(String imageUrl, String name, int index) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(
          color: Colors.transparent, // Updated border color to transparent
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(imageUrl, height: 45),
            SizedBox(
              height: 20,
            ),
            Text(
              name,
              style: TextStyle(fontSize: 15),
            )
          ]),
    );
  }
}
