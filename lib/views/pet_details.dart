import 'package:flutter/material.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/views/adoption_page.dart';
import 'package:pawpal/views/donation_page.dart';
import 'package:pawpal/views/loginPage.dart';

class PetDetailsPage extends StatefulWidget {
  final Pet pet;
  final User user;

  const PetDetailsPage({super.key, required this.pet, required this.user});

  @override
  State<PetDetailsPage> createState() => _PetDetailsPageState();
}

class _PetDetailsPageState extends State<PetDetailsPage> {
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
        title: Text(widget.pet.petName.toString()),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 400,
                    child: imgList.isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.pets,
                              size: 64,
                              color: Colors.grey,
                            ),
                          )
                        : PageView.builder(
                            itemCount: imgList.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                "${MyConfig.baseUrl}/pawpal/server/${imgList[index]}",
                                fit: BoxFit.cover,
                                width: screenWidth,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 50),
                              );
                            },
                          ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.pet.petName.toString(),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Posted by Owner ID: ${widget.pet.userId}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 15),

                        Table(
                          columnWidths: const {
                            0: FixedColumnWidth(100),
                            1: FlexColumnWidth(),
                          },
                          children: [
                            _buildTableRow(
                              "Category",
                              widget.pet.category ?? "N/A",
                            ),
                            _buildTableRow(
                              "Type",
                              widget.pet.petType.toString(),
                            ),
                            _buildTableRow(
                              "Gender",
                              widget.pet.petGender ?? "N/A",
                            ),
                            _buildTableRow("Age", widget.pet.petAge ?? "N/A"),
                            _buildTableRow(
                              "Health",
                              widget.pet.petHealth ?? "N/A",
                            ),
                            _buildTableRow(
                              "Date",
                              widget.pet.createdAt.toString().substring(0, 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.pet.description.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: _buildDynamicActionButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicActionButton() {
    if (widget.user.userId == widget.pet.userId) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
        ),
        onPressed: null,
        child: const Text("This is your post"),
      );
    }

    String category = widget.pet.category ?? "Adoption";
    if (category == "Help/Rescue") {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
        ),
        onPressed: null,
        child: const Text("Rescue Only (No Action Required)"),
      );
    } else if (category == "Donation Request") {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        onPressed: () => _checkLoginAndNavigate("donate"),
        child: const Text("Donate Now"),
      );
    } else {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        onPressed: () => _checkLoginAndNavigate("adopt"),
        child: const Text("Adopt Me"),
      );
    }
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(padding: const EdgeInsets.all(4), child: Text(value)),
      ],
    );
  }

  void _checkLoginAndNavigate(String action) {
    if (widget.user.userId == "0") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first!")));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      if (action == "donate") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DonationPage(pet: widget.pet, user: widget.user),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AdoptionScreen(pet: widget.pet, user: widget.user),
          ),
        );
      }
    }
  }
}
