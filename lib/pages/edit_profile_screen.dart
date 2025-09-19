import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  String selectedAvatar = "assets/avatar1.png"; // default avatar

  final Color primaryColor = const Color(0xFF00796B);
  final user = FirebaseAuth.instance.currentUser;

  final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );
  final RegExp phoneRegex = RegExp(r"^[0-9]{10}$");

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    final data = doc.data();
    setState(() {
      nameController = TextEditingController(text: data?["name"] ?? "");
      emailController = TextEditingController(text: data?["email"] ?? "");
      phoneController = TextEditingController(text: data?["phone"] ?? "");
      selectedAvatar = data?["avatarPath"] ?? "assets/avatar1.png";
      loading = false;
    });
  }

  Future<void> _saveChanges() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if ([name, email, phone].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid email format")));
      return;
    }
    if (!phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Phone must be 10 digits")));
      return;
    }

    try {
      if (user == null) return;

      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "name": name,
        "email": email,
        "phone": phone,
        "avatarPath": selectedAvatar,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE5F9F6),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 👇 Avatar Preview
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(selectedAvatar),
            ),
            const SizedBox(height: 20),

            const Text(
              "Select Avatar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Avatar options
            Wrap(
              spacing: 10,
              children: [
                _buildAvatarOption("assets/img1.jpg"),
                _buildAvatarOption("assets/img2.jpg"),
                _buildAvatarOption("assets/img3.jpg"),
                _buildAvatarOption("assets/img4.jpg"),
              ],
            ),

            const SizedBox(height: 20),
            _buildTextField("Full Name", nameController),
            const SizedBox(height: 10),
            _buildTextField(
              "Email",
              emailController,
              inputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              "Phone Number",
              phoneController,
              inputType: TextInputType.phone,
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Save Changes",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAvatarOption(String assetPath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAvatar = assetPath;
        });
      },
      child: CircleAvatar(
        radius: 30,
        backgroundImage: AssetImage(assetPath),
        child: selectedAvatar == assetPath
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white),
              )
            : null,
      ),
    );
  }
}
