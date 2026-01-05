import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/user.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/views/drawer.dart';
import 'package:pawpal/views/submitPetInfo.dart';
import 'package:pawpal/views/pet_details.dart';

class MainPage extends StatefulWidget {
  final User user;
  const MainPage({super.key, required this.user});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Pet> petList = [];
  String status = "Loading...";
  late double screenWidth, screenHeight;

  TextEditingController searchController = TextEditingController();
  String selectedType = "All";
  List<String> typeList = [
    "All",
    "Cat",
    "Dog",
    "Bird",
    "Rabbit",
    "Hamster",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    loadAllPets();
  }

  Future<void> _refresh() async {
    loadAllPets();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PawPal Listings'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      drawer: MyDrawer(user: widget.user),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          if (widget.user.userId == "0") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please login to submit a pet!"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => submitPetInfo(user: widget.user),
              ),
            ).then((_) => loadAllPets());
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Flexible(
                    flex: 7,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onSubmitted: (value) => loadAllPets(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 48,
                    width: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedType,
                        isExpanded: true,
                        items: typeList.map((String type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() => selectedType = newValue!);
                          loadAllPets();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: petList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            status == "Connection Failed"
                                ? Icons.wifi_off
                                : Icons.pets,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            status,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          if (status == "Connection Failed")
                            ElevatedButton(
                              onPressed: loadAllPets,
                              child: const Text("Retry"),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: petList.length,
                      itemBuilder: (context, index) {
                        Pet pet = petList[index];
                        String firstImage = "";
                        if (pet.imagePaths != null &&
                            pet.imagePaths!.isNotEmpty) {
                          firstImage = pet.imagePaths!.split(",")[0];
                        }
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PetDetailsPage(
                                    pet: pet,
                                    user: widget.user,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      color: Colors.grey[300],
                                      child: firstImage.isEmpty
                                          ? const Icon(
                                              Icons.pets,
                                              size: 40,
                                              color: Colors.grey,
                                            )
                                          : Image.network(
                                              "${MyConfig.baseUrl}/pawpal/server/$firstImage",
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, stack) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                  ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pet.petName.toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            // Pet Type Label
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                pet.petType.toString(),
                                                style: TextStyle(
                                                  color: Colors.blue[800],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange[50],
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.orange
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Text(
                                                pet.category ?? "Adoption",
                                                style: TextStyle(
                                                  color: Colors.orange[900],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              pet.petAge ?? "N/A",
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void loadAllPets() {
    String search = searchController.text;
    String url =
        "${MyConfig.baseUrl}/pawpal/server/api/load_all_pets.php?type=$selectedType";

    if (search.isNotEmpty) {
      url += "&search=$search";
    }

    setState(() {
      petList.clear();
      status = "Loading...";
    });

    http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 5))
        .then((response) {
          if (!mounted) return;

          if (response.statusCode == 200) {
            var jsonData = jsonDecode(response.body);
            if (jsonData['status'] == 'success') {
              var data = jsonData['data'];
              if (data != null && (data as List).isNotEmpty) {
                petList = data.map((i) => Pet.fromJson(i)).toList();
                status = "";
              } else {
                status = "No pets found";
              }
              setState(() {});
            } else {
              setState(() {
                status = "No pets found";
              });
            }
          } else {
            setState(() {
              status = "Server Error (${response.statusCode})";
            });
          }
        })
        .catchError((error) {
          if (!mounted) return;
          setState(() {
            status = "Connection Failed";
          });
          print("Error: $error");
        });
  }
}
