import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../auth/auth_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final User? user = AuthService().currentUser;
  List<Map<String, dynamic>> recentTrips = [];
  List<Map<String, dynamic>> upcomingTrips = [];

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    if (user == null) return;

    final today = DateTime.now();
    final tripSnapshot = await FirebaseFirestore.instance
        .collection('trips')
        .where('userId', isEqualTo: user!.uid)
        .get();

    final trips = tripSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'title': data['title'],
        'date': (data['date'] as Timestamp).toDate(),
      };
    }).toList();

    final List<Map<String, dynamic>> recent = [];
    final List<Map<String, dynamic>> upcoming = [];

    for (var trip in trips) {
      if (trip['date'].isBefore(today)) {
        recent.add(trip);
      } else {
        upcoming.add(trip);
      }
    }

    setState(() {
      recentTrips = recent;
      upcomingTrips = upcoming;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Colors.deepPurple.shade50,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.indigo],
                  ),
                ),
                accountName: const Text("Welcome!"),
                accountEmail: Text(user?.email ?? "Guest"),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.deepPurple, size: 35),
                ),
              ),
              _buildDrawerItem(Icons.explore, 'Discover', '/discover'),
              _buildDrawerItem(Icons.event, 'Plan Trip', '/plan'),

              _buildDrawerItem(Icons.book, 'Journal', '/journal'),
              _buildDrawerItem(Icons.photo_album, 'Gallery', '/gallery'),
              _buildDrawerItem(Icons.attach_money, 'Budget', '/budget'),
              _buildDrawerItem(Icons.settings, 'Settings', '/settings'),
              _buildDrawerItem(Icons.person, 'Profile', '/profile'),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  try {
                    await AuthService().logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchTrips, // Manual refresh
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(3.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(user?.email),
              const SizedBox(height: 20),
              _buildDashboardGrid(context),
              const SizedBox(height: 30),
              Text("Recent Trips", style: _sectionTitleStyle()),
              const SizedBox(height: 10),
              _buildTripList(recentTrips),
              const SizedBox(height: 30),
              Text("Upcoming Trips", style: _sectionTitleStyle()),
              const SizedBox(height: 10),
              _buildTripList(upcomingTrips),
            ],
          ),
        ),
      ),
    );
  }

  // --- Reusable Widgets ---

  ListTile _buildDrawerItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 15.0,
      mainAxisSpacing: 15.0,
      children: [
        _buildDashboardCard(context, Icons.explore, 'Discover', '/discover'),
        _buildDashboardCard(context, Icons.event, 'Plan Trip', '/plan'),

        _buildDashboardCard(context, Icons.book, 'Journal', '/journal'),
        _buildDashboardCard(context, Icons.photo, 'Gallery', '/gallery'),
        _buildDashboardCard(context, Icons.attach_money, 'Budget', '/budget'),
      ],
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.deepPurple.shade400,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(String? email) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      color: Colors.deepPurple.shade700,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.deepPurple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Hello, ${email ?? 'Traveler'}!',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const Icon(Icons.waving_hand, color: Colors.amberAccent, size: 28),
          ],
        ),
      ),
    );
  }

  TextStyle _sectionTitleStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    );
  }

  Widget _buildTripList(List<Map<String, dynamic>> tripList) {
    if (tripList.isEmpty) {
      return const Text(
        'No trips available.',
        style: TextStyle(color: Colors.white70),
      );
    }

    return Column(
      children: tripList.map((trip) {
        String formattedDate = DateFormat('MMM dd, yyyy').format(trip['date']);
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.deepPurple.shade300,
          elevation: 5,
          child: ListTile(
            leading: const Icon(Icons.location_on, color: Colors.white),
            title: Text(
              trip['title'],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              formattedDate,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        );
      }).toList(),
    );
  }
}
