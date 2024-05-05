import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customer/customer_home.dart';
import 'mechanic/mechanic_home.dart';
import 'owner/owner_home.dart';
import 'service/firebase_services.dart';

enum UserRole { Customer, Owner, Mechanic }

class LoginSignupPage extends StatefulWidget {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  const LoginSignupPage({super.key});

  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.Customer; // Default role is Customer

  bool _isLoginForm = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _isLoginForm ? "LOGIN" : "REGISTER",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2661FA),
                    fontSize: 36,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              // Dropdown for selecting user role
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  items: [
                    DropdownMenuItem(
                      value: UserRole.Customer,
                      child: Text('Customer'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.Owner,
                      child: Text('Owner'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.Mechanic,
                      child: Text('Mechanic'),
                    ),
                  ],
                  onChanged: (UserRole? value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
                    padding: EdgeInsets.zero,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80.0),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 255, 136, 34),
                          Color.fromARGB(255, 255, 177, 41)
                        ],
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      height: 50.0,
                      width: size.width * 0.5,
                      child: Text(
                        _isLoginForm ? "LOGIN" : "SIGN UP",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLoginForm = !_isLoginForm;
                    });
                  },
                  child: Text(
                    _isLoginForm ? "Don't Have an Account? Sign up" : "Already Have an Account? Sign in",
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2661FA)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_isLoginForm) {
        // Login with email/password
        await LoginSignupPage._auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        // Create new user with email/password
        await LoginSignupPage._auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Automatically add mechanic to Firestore if selected role is Mechanic
        if (_selectedRole == UserRole.Mechanic) {
          await FirestoreService.addMechanic(
            _emailController.text.split('@')[0], // Use email prefix as name
            _emailController.text,
            // Add other details as needed
          );
        }
      }

      // Navigate to the respective home page based on selected role
      switch (_selectedRole) {
        case UserRole.Customer:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CustomerHomePage()),
          );
          break;
        case UserRole.Owner:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OwnerHomePage()),
          );
          break;
        case UserRole.Mechanic:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MechanicHomePage(mechanicEmail: _emailController.text)),
          );
          break;
      }
    } catch (e) {
      print('Error: $e');
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class Background extends StatelessWidget {
  final Widget child;

  const Background({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              "assets/images/top1.png",
              width: size.width,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              "assets/images/top2.png",
              width: size.width,
            ),
          ),
          Positioned(
            top: 50,
            right: 30,
            child: Image.asset(
              "assets/images/main.png",
              width: size.width * 0.35,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              "assets/images/bottom1.png",
              width: size.width,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              "assets/images/bottom2.png",
              width: size.width,
            ),
          ),
          child,
        ],
      ),
    );
  }
}