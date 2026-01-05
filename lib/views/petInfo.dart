import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/user.dart';
import 'package:pawpal/models/pet.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/views/loginPage.dart';
import 'package:pawpal/views/drawer.dart';
import 'package:pawpal/views/submitPetInfo.dart';

class PetInfo extends StatefulWidget {
  final User user;
  const PetInfo({super.key, required this.user});

  @override
  State<PetInfo> createState() => _PetInfoState();
}

class _PetInfoState extends State<PetInfo> {
  List<Pet> petList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.user.userId != "0") {
      loadPets();
    } else {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pet List"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      drawer: MyDrawer(user: widget.user),

      body: widget.user.userId == "0" ? guestView() : loggedInView(),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          if (widget.user.userId == "0") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => submitPetInfo(user: widget.user),
              ),
            ).then((_) => loadPets());
          }
        },
      ),
    );
  }

  Widget guestView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text("Please login to manage your pets"),
          const SizedBox(height: 10),
          ElevatedButton(
            child: const Text("Login"),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget loggedInView() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (petList.isEmpty) {
      return const Center(child: Text("No pets found. Add one!"));
    }

    return RefreshIndicator(
      onRefresh: loadPets,
      child: ListView.builder(
        itemCount: petList.length,
        itemBuilder: (context, index) {
          Pet pet = petList[index];
          String firstImage = "";
          if (pet.imagePaths != null && pet.imagePaths!.isNotEmpty) {
            firstImage = pet.imagePaths!.split(",")[0];
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                  image: firstImage.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(
                            "${MyConfig.baseUrl}/pawpal/server/$firstImage",
                          ),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) =>
                              const Icon(Icons.broken_image),
                        )
                      : null,
                ),
                child: firstImage.isEmpty ? const Icon(Icons.pets) : null,
              ),
              title: Text(
                pet.petName.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${pet.petType} • ${pet.petGender}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _deletePetDialog(pet.petId.toString());
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> loadPets() async {
    setState(() => isLoading = true);
    String url =
        "${MyConfig.baseUrl}/pawpal/server/api/get_my_pets.php?user_id=${widget.user.userId}";

    http.get(Uri.parse(url)).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData["status"] == "success") {
          var data = jsonData["data"];
          if (data != null) {
            petList = (data as List).map((i) => Pet.fromJson(i)).toList();
          }
        }
      }
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  void _deletePetDialog(String petId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Pet"),
        content: const Text("Are you sure? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePet(petId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deletePet(String petId) {
    http
        .post(
          Uri.parse("${MyConfig.baseUrl}/pawpal/server/api/delete_pet.php"),
          body: {"pet_id": petId, "user_id": widget.user.userId},
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonData = jsonDecode(response.body);
            if (jsonData['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Pet deleted successfully"),
                  backgroundColor: Colors.green,
                ),
              );
              loadPets();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(jsonData['message']),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Server Error"),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }
}
