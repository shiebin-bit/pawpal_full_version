import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/user.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/views/payment_page.dart';

class DonationPage extends StatefulWidget {
  final Pet pet;
  final User user;

  const DonationPage({super.key, required this.pet, required this.user});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  String selectedType = "Food";
  List<String> donationTypes = ["Food", "Medical", "Money"];
  TextEditingController textController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Donate to ${widget.pet.petName}"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Donation Type:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: selectedType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: donationTypes.map((String type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),

              if (selectedType == "Money") ...[
                const Text(
                  "Enter Amount (RM):",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: "RM ",
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else ...[
                Text(
                  "Description of $selectedType items:",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: textController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: selectedType == "Food"
                        ? "e.g., 2 bags of Dry Food"
                        : "e.g., Bandages and Medicine",
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: _validateAndConfirm,
                  child: const Text(
                    "Proceed to Donate",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateAndConfirm() {
    if (selectedType == "Money" && amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter an amount")));
      return;
    }
    if (selectedType != "Money" && textController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter a description")));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Donation"),
        content: Text(
          "Are you sure you want to donate $selectedType for ${widget.pet.petName}?",
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(context);
              _processDonation();
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processDonation() {
    String rawAmount = amountController.text;
    String cleanAmount = rawAmount.replaceAll(RegExp(r'[^0-9.]'), '');
    String description = selectedType == "Money"
        ? "Cash Donation"
        : textController.text;

    if (selectedType == "Money") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            user: widget.user,
            petId: widget.pet.petId!,
            amount: cleanAmount,
          ),
        ),
      ).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please check your donation history for status."),
          ),
        );
        Navigator.pop(context);
      });
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    String url =
        "${MyConfig.baseUrl}/pawpal/server/api/submit_donation.php?"
        "userid=${widget.user.userId}&"
        "petid=${widget.pet.petId}&"
        "email=${widget.user.userEmail}&"
        "phone=${widget.user.userPhone}&"
        "name=${widget.user.userName}&"
        "amount=0&"
        "type=$selectedType&"
        "description=$description";

    http
        .get(Uri.parse(url))
        .then((response) {
          Navigator.pop(context);
          if (response.statusCode == 200) {
            // Success!
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Thank you! Your donation request has been recorded.",
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Server Error: ${response.statusCode}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        })
        .catchError((e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Connection Failed"),
              backgroundColor: Colors.red,
            ),
          );
        });
  }
}
