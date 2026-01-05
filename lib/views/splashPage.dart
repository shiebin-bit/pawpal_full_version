import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/views/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class splashPage extends StatefulWidget {
  const splashPage({super.key});

  @override
  State<splashPage> createState() => _splashPageState();
}

class _splashPageState extends State<splashPage> {
  bool _hasNavigated = false;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Start Animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    autologin();
  }

  void autologin() async {
    Future<void> minimumDelay = Future.delayed(const Duration(seconds: 3));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;
    String email = prefs.getString('email') ?? '';
    String password = prefs.getString('password') ?? '';

    if (rememberMe && email.isNotEmpty && password.isNotEmpty) {
      http
          .post(
            Uri.parse('${MyConfig.baseUrl}/pawpal/server/api/login_user.php'),
            body: {'email': email, 'password': password},
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException("Connection timed out");
            },
          )
          .then((response) async {
            await minimumDelay;

            if (response.statusCode == 200) {
              var jsonResponse = jsonDecode(response.body);
              if (jsonResponse['status'] == 'success') {
                User user = User.fromJson(jsonResponse['data'][0]);
                _navigate(user);
              } else {
                _goAsGuest(delayed: false);
              }
            } else {
              _goAsGuest(delayed: false);
            }
          })
          .catchError((error) async {
            await minimumDelay;
            _goAsGuest(delayed: false);
          });
    } else {
      await minimumDelay;
      _goAsGuest(delayed: false);
    }
  }

  void _goAsGuest({bool delayed = true}) {
    User guestUser = User(
      userId: '0',
      userEmail: 'guest@email.com',
      userPassword: 'guest',
      userRegdate: '0000-00-00',
    );

    if (delayed) {
      Future.delayed(const Duration(seconds: 3), () => _navigate(guestUser));
    } else {
      _navigate(guestUser);
    }
  }

  void _navigate(User user) {
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage(user: user)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lecturer often uses MediaQuery size
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF448AFF), Color(0xFF1565C0)], // Your Blue Theme
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 1500),
            opacity: _opacity,
            curve: Curves.easeOut,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO CONTAINER
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/petLogo.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // APP NAME
                const Text(
                  'PawPal',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black26,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // TAGLINE
                const Text(
                  'Your Furry Friends Finder',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 50),

                // LOADING SPINNER
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),

                const SizedBox(height: 10),
                const Text(
                  'Loading...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
