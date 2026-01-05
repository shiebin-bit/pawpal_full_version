import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/views/drawer.dart';

class DonationHistoryPage extends StatefulWidget {
  final User user;
  const DonationHistoryPage({super.key, required this.user});

  @override
  State<DonationHistoryPage> createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
  List donationList = [];
  String status = "Loading...";

  @override
  void initState() {
    super.initState();
    loadDonations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Donation History"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      drawer: MyDrawer(user: widget.user),
      body: donationList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_edu, size: 64, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    status,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: donationList.length,
              itemBuilder: (context, index) {
                final item = donationList[index];

                // Determine icon and color based on type
                IconData icon = Icons.volunteer_activism;
                Color color = Colors.blue;

                if (item['donation_type'] == 'Money') {
                  icon = Icons.attach_money;
                  color = Colors.green;
                } else if (item['donation_type'] == 'Food') {
                  icon = Icons.restaurant;
                  color = Colors.orange;
                } else {
                  icon = Icons.medical_services;
                  color = Colors.red;
                }

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.2),
                      child: Icon(icon, color: color),
                    ),
                    title: Text(
                      "Donated to: ${item['pet_name']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Date: ${item['donation_date']}"),
                        const SizedBox(height: 2),
                        Text(
                          item['donation_type'] == 'Money'
                              ? "Amount: RM ${item['amount']}"
                              : "Item: ${item['description']}",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void loadDonations() {
    http
        .get(
          Uri.parse(
            "${MyConfig.baseUrl}/pawpal/server/api/get_my_donations.php?user_id=${widget.user.userId}",
          ),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonData = jsonDecode(response.body);
            if (jsonData['status'] == 'success') {
              setState(() {
                donationList = jsonData['data'];
                status = "";
              });
            } else {
              setState(() {
                status = "No donation history found";
              });
            }
          } else {
            setState(() {
              status = "Server Error";
            });
          }
        });
  }
}
