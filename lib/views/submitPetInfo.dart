import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pawpal/views/main_page.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/models/user.dart';

class submitPetInfo extends StatefulWidget {
  final User user;
  const submitPetInfo({super.key, required this.user});

  @override
  State<submitPetInfo> createState() => _submitPetInfoState();
}

class _submitPetInfoState extends State<submitPetInfo> {
  // Lists for Dropdowns
  List<String> petList = ['Cat', 'Dog', 'Bird', 'Rabbit', 'Hamster', 'Other'];
  List<String> genderList = ['Male', 'Female'];
  List<String> healthList = [
    'Healthy',
    'Minor Injury',
    'Serious Injury',
    'Chronic Disease',
  ];
  List<String> categoryList = ['Adoption', 'Donation Request', 'Help/Rescue'];

  // Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  // Selected Values (Default)
  String petType = 'Cat';
  String petGender = 'Male';
  String petHealth = 'Healthy';
  String selectedCategory = 'Adoption';

  Position? myPosition;
  String lat = "";
  String lng = "";

  // Images
  File? image1;
  File? image2;
  File? image3;
  final ImagePicker picker = ImagePicker();

  late double height, width;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    if (width > 600) width = 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Pet Information'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: width,
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        imageContainer(1, image1),
                        const SizedBox(width: 10),
                        imageContainer(2, image2),
                        const SizedBox(width: 10),
                        imageContainer(3, image3),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Pet Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pets),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: petType,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                          ),
                          items: petList.map((String val) {
                            return DropdownMenuItem(
                              value: val,
                              child: Text(val),
                            );
                          }).toList(),
                          onChanged: (newValue) =>
                              setState(() => petType = newValue!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: petGender,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
                          ),
                          items: genderList.map((String val) {
                            return DropdownMenuItem(
                              value: val,
                              child: Text(val),
                            );
                          }).toList(),
                          onChanged: (newValue) =>
                              setState(() => petGender = newValue!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Age
                  TextField(
                    controller: ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age (e.g., 2 months, 3 years)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    value: petHealth,
                    decoration: const InputDecoration(
                      labelText: 'Health Condition',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.favorite),
                    ),
                    items: healthList.map((String val) {
                      return DropdownMenuItem(value: val, child: Text(val));
                    }).toList(),
                    onChanged: (newValue) =>
                        setState(() => petHealth = newValue!),
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: categoryList.map((String val) {
                      return DropdownMenuItem(value: val, child: Text(val));
                    }).toList(),
                    onChanged: (newValue) =>
                        setState(() => selectedCategory = newValue!),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.location_on),
                        onPressed: () async {
                          try {
                            myPosition = await _determinePosition();
                            List<Placemark> placemarks =
                                await placemarkFromCoordinates(
                                  myPosition!.latitude,
                                  myPosition!.longitude,
                                );
                            Placemark place = placemarks[0];
                            setState(() {
                              addressController.text =
                                  "${place.name},\n${place.street},\n${place.postalCode},${place.locality},\n${place.administrativeArea},${place.country}";
                              lat = myPosition!.latitude.toString();
                              lng = myPosition!.longitude.toString();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Location captured!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Location error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: Size(width, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: showSummitDialog,
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget imageContainer(int slot, File? image) {
    return GestureDetector(
      onTap: () => pickImageDialog(slot),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent),
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12.0),
          image: image != null
              ? DecorationImage(image: FileImage(image), fit: BoxFit.cover)
              : null,
        ),
        child: image == null
            ? const Center(child: Icon(Icons.add_a_photo, color: Colors.grey))
            : null,
      ),
    );
  }

  void pickImageDialog(int slot) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick Image From'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  getImage(slot, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  getImage(slot, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getImage(int slot, ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        if (slot == 1) image1 = File(picked.path);
        if (slot == 2) image2 = File(picked.path);
        if (slot == 3) image3 = File(picked.path);
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    return await Geolocator.getCurrentPosition();
  }

  void showSummitDialog() {
    // Validation
    if (nameController.text.isEmpty || ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in Name and Age'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (descController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description must be at least 10 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide an address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (image1 == null && image2 == null && image3 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload at least one image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Confirmation'),
        content: const Text('Are you sure you want to submit this pet info?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              submitPetInfo();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void submitPetInfo() async {
    String base64Image1 = image1 != null
        ? base64Encode(image1!.readAsBytesSync())
        : "";
    String base64Image2 = image2 != null
        ? base64Encode(image2!.readAsBytesSync())
        : "";
    String base64Image3 = image3 != null
        ? base64Encode(image3!.readAsBytesSync())
        : "";

    http
        .post(
          Uri.parse("${MyConfig.baseUrl}/pawpal/server/api/submit_pet.php"),
          body: {
            "userid": widget.user.userId,
            "pet_name": nameController.text,
            "pet_type": petType,
            "pet_gender": petGender,
            "pet_age": ageController.text,
            "pet_health": petHealth,
            "category": selectedCategory,
            "description": descController.text,
            "latitude": lat.isEmpty ? "0" : lat,
            "longitude": lng.isEmpty ? "0" : lng,
            "image1": base64Image1,
            "image2": base64Image2,
            "image3": base64Image3,
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsondata = jsonDecode(response.body);
            if (jsondata['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pet submitted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainPage(user: widget.user),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Submission failed'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Server Error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }
}
