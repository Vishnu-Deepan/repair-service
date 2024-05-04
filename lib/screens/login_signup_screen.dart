import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'customer/customer_home.dart';
import 'mechanic/mechanic_home.dart';
import 'owner/owner_home.dart';
import 'service/firebase_services.dart';

enum UserRole { Customer, Owner, Mechanic }

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.Customer; // Default role is Customer

  bool _isLoginForm = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginForm ? 'Login' : 'Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DropdownButtonFormField<UserRole>(
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
            SizedBox(height: 8.0),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 8.0),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16.0),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: Text(_isLoginForm ? 'Login' : 'Sign Up'),
            ),
            SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoginForm = !_isLoginForm;
                });
              },
              child: Text(_isLoginForm
                  ? 'Create an account'
                  : 'Have an account? Sign in'),
            ),
          ],
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
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        // Create new user with email/password
        await _auth.createUserWithEmailAndPassword(
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
            MaterialPageRoute(builder: (context) => MechanicHomePage(mechanicEmail: _emailController.text,)),
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