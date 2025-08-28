import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../auth/auth_service.dart'; // adjust path as per your project

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Example user data (replace with Firebase/Auth later)
  String profileImage =
      "https://www.w3schools.com/howto/img_avatar.png"; // Default avatar
  final String userName = "John Doe";
  final String userEmail = "johndoe@example.com";
  final String userPhone = "+91 9876543210";
  final String userLocation = "Mumbai, India";
  final String memberSince = "Jan 2024";

  File? _pickedImage;

  // Pick image (Gallery or Camera)
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() => _pickedImage = File(picked.path));
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a Photo"),
                onTap: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) {
                    setState(() => _pickedImage = File(picked.path));
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),

            // Avatar with Edit Option
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.grey.shade300,
                  child: ClipOval(
                    child: _pickedImage != null
                        ? Image.file(
                            _pickedImage!,
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            profileImage,
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.white,
                              );
                            },
                          ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Name & Email
            Text(
              userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              userEmail,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 30),

            // Info Cards
            _buildInfoCard(Icons.phone, "Phone", userPhone),
            _buildInfoCard(Icons.location_on, "Location", userLocation),
            _buildInfoCard(Icons.calendar_today, "Member Since", memberSince),

            const SizedBox(height: 25),

            // Edit Profile Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/editProfile');
                },
              ),
            ),

            const SizedBox(height: 12),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirm Logout"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text("Logout"),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await AuthService().logout();
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacementNamed(context, '/login');
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Info Card Widget
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        subtitle: Text(value, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
