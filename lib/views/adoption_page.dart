import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/user.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/myconfig.dart';

class AdoptionScreen extends StatefulWidget {
  final Pet pet;
  final User user;

  const AdoptionScreen({super.key, required this.pet, required this.user});

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  TextEditingController motivationController = TextEditingController();
  late double screenWidth;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;

    List<String> imgList = [];
    if (widget.pet.imagePaths != null && widget.pet.imagePaths!.isNotEmpty) {
      imgList = widget.pet.imagePaths!.split(",");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Adoption Request"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      image: imgList.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(
                                "${MyConfig.baseUrl}/pawpal/server/${imgList[0]}",
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imgList.isEmpty
                        ? const Icon(Icons.pets, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Pet Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Table(
                    border: TableBorder.all(color: Colors.grey[300]!),
                    columnWidths: const {
                      0: FixedColumnWidth(120),
                      1: FlexColumnWidth(),
                    },
                    children: [
                      _buildTableRow("Name", widget.pet.petName.toString()),
                      _buildTableRow("Type", widget.pet.petType.toString()),
                      _buildTableRow("Gender", widget.pet.petGender ?? "N/A"),
                      _buildTableRow("Age", widget.pet.petAge ?? "N/A"),
                      _buildTableRow("Health", widget.pet.petHealth ?? "N/A"),
                      _buildTableRow(
                        "Posted By (ID)",
                        widget.pet.userId.toString(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.pet.description.toString(),
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                _showAdoptionPopup();
              },
              child: const Text(
                "Request to Adopt",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(value)),
      ],
    );
  }

  void _showAdoptionPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Adoption Request"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please tell the owner why you are the best fit:"),
              const SizedBox(height: 10),
              TextField(
                controller: motivationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Motivation Message",
                  hintText: "I love cats because...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitAdoption();
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void _submitAdoption() {
    String msg = motivationController.text;
    if (msg.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please write a message!")));
      return;
    }

    http
        .post(
          Uri.parse(
            "${MyConfig.baseUrl}/pawpal/server/api/submit_adoption.php",
          ),
          body: {
            "user_id": widget.user.userId,
            "pet_id": widget.pet.petId,
            "message": msg,
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            if (jsonResponse['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Request Submitted Successfully!"),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Failed to submit request"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
  }
}
