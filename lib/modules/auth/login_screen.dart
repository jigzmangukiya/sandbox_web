import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sandbox_demo/modules/auth/signup_screen.dart';
import 'package:sandbox_demo/modules/dashboard/admin/admin_main_screen.dart';
import 'package:sandbox_demo/modules/dashboard/user/user_main_screen.dart';
import 'package:sandbox_demo/services/global_data.dart';
import 'package:sandbox_demo/services/http_service.dart';
import 'package:sandbox_demo/services/navigation_service.dart';
import 'package:sandbox_demo/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Import the http package

class LoginScreen extends StatefulWidget {
  static final route = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine the layout properties based on screen width
    double containerWidth = screenWidth * 0.8;
    double padding = 24.0;
    double titleFontSize = 24.0;

    if (screenWidth > 1200) {
      containerWidth = 600;
      padding = 48.0;
      titleFontSize = 32.0;
    } else if (screenWidth > 800) {
      containerWidth = 500;
      padding = 36.0;
      titleFontSize = 28.0;
    }

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(padding),
          width: containerWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                if (_isLoading)
                  Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _login,
                    child: Center(
                      child: Text('Login'),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.0),
                    ),
                  ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        final navService = locator<NavigationService>();
                        if (navService != null) {
                          print('Navigating to: ${SignUpScreen.route}');
                          navService.navigateTO(SignUpScreen.route);
                        } else {
                          print('NavigationService is null');
                        }
                      },
                      child: Text('Sign Up'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return; // Exit if form is not valid
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String email = _usernameController.text;
    String password = _passwordController.text;

    final httpService = HttpService();
    try {
      final response = await httpService.post('/login', body: {
        'email': email,
        'password': password,
      });

      if (response is Map<String, dynamic> && response.containsKey('access_token')) {
        final token = response['access_token'];
        final role = response['role']; // Use 'user_role' if that's the field in your response

        // Store token in GlobalData and SharedPreferences
        final globalData = Provider.of<GlobalData>(context, listen: false);
        globalData.setUserToken(authToken: token);

        // Save token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);

        // Navigate based on role
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, AdminMainScreen.route);
        } else if (role == 'normal') {
          Navigator.pushReplacementNamed(context, UserMainScreen.route);
        }
      } else {
        // Handle unexpected response format
        setState(() {
          _errorMessage = 'Invalid response from server.';
        });
      }
    } catch (e) {
      // Handle different exceptions
      if (e is FetchDataException) {
        setState(() {
          _errorMessage = e.message;
        });
      } else {
        setState(() {
          _errorMessage = 'An unexpected error occurred.';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
