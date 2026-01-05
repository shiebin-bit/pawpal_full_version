import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/views/donation_history.dart';
import 'package:pawpal/views/loginPage.dart';
import 'package:pawpal/views/main_page.dart';
import 'package:pawpal/views/petInfo.dart';
import 'package:pawpal/views/profile_page.dart';

class MyDrawer extends StatefulWidget {
  final User user;

  const MyDrawer({super.key, required this.user});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 250,
            decoration: const BoxDecoration(color: Colors.blueAccent),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.pets, color: Colors.white, size: 28),
                        const SizedBox(width: 10),
                        const Text(
                          "PawPal",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: widget.user.userId != "0"
                          ? NetworkImage(
                              "${MyConfig.baseUrl}/pawpal/server/assets/profiles/user_${widget.user.userId}.png?v=${DateTime.now().millisecondsSinceEpoch}",
                            )
                          : null,
                      onBackgroundImageError: widget.user.userId != "0"
                          ? (_, __) {}
                          : null,
                      child: widget.user.userId == "0"
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.user.userName ?? "Guest",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.user.userEmail ?? "Please Login",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Public Pets (Home)"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainPage(user: widget.user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text("My Pets"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PetInfo(user: widget.user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.volunteer_activism),
            title: const Text("My Donations"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DonationHistoryPage(user: widget.user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: widget.user),
                ),
              );
            },
          ),
          const Divider(color: Colors.grey),

          ListTile(
            leading: Icon(
              widget.user.userId == "0" ? Icons.login : Icons.logout,
            ),
            title: Text(widget.user.userId == "0" ? "Login" : "Log out"),
            onTap: () {
              Navigator.pop(context);

              if (widget.user.userId == "0") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
