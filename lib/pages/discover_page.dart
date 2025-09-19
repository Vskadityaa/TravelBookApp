import 'package:flutter/material.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String selectedCategory = 'All';
  String searchQuery = '';
  final List<String> categories = ['All', 'Beach', 'Mountain', 'City'];

  final List<Map<String, dynamic>> destinations = [
    {
      'name': 'Goa Beach',
      'category': 'Beach',
      'location': 'Goa, India',
      'rating': 4.8,
      'image': 'assets/goa.jpg',
    },
    {
      'name': 'Manali Hills',
      'category': 'Mountain',
      'location': 'Himachal, India',
      'rating': 4.6,
      'image': 'assets/manali.jpg',
    },
    {
      'name': 'Jaipur City',
      'category': 'City',
      'location': 'Rajasthan, India',
      'rating': 4.5,
      'image': 'assets/jaipur.jpg',
    },
    {
      'name': 'Pondicherry',
      'category': 'Beach',
      'location': 'Tamil Nadu, India',
      'rating': 4.7,
      'image': 'assets/pondicherry.jpg',
    },
    {
      'name': 'Shimla Hills',
      'category': 'Mountain',
      'location': 'Himachal, India',
      'rating': 4.4,
      'image': 'assets/shmila.jpg',
    },
  ];

  List<Map<String, dynamic>> get filteredDestinations {
    return destinations.where((d) {
      final matchesCategory =
          selectedCategory == 'All' || d['category'] == selectedCategory;
      final matchesSearch =
          d['name'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          d['location'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Discover Destinations'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Search & Filters
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search destinations...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
          ),

          // Category Filters
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    selectedColor: Colors.deepPurple,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Destination Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: filteredDestinations.length,
              itemBuilder: (context, index) {
                final dest = filteredDestinations[index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: () {
                      // Navigate to details page if needed
                    },
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.asset(
                            dest['image'], // ✅ Fixed here
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        ListTile(
                          title: Text(
                            dest['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(dest['location']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              Text(dest['rating'].toString()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
