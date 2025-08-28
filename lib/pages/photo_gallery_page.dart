import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoGalleryPage extends StatefulWidget {
  const PhotoGalleryPage({super.key});

  @override
  State<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  // ✅ Replace these with YOUR values
  static const String cloudName = 'dpqr8lawp'; // e.g. dpqr8lawp
  static const String uploadPreset = 'imagedata'; // the preset you created
  static const String folder = 'gallery'; // optional folder

  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  // Persisted items: [{url, desc, uploadedAt}]
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cloudinary_gallery') ?? '[]';
    final List decoded = json.decode(raw);
    _items = decoded.cast<Map<String, dynamic>>();
    _items.sort(
      (a, b) => DateTime.parse(
        b['uploadedAt'],
      ).compareTo(DateTime.parse(a['uploadedAt'])),
    );
    setState(() {});
  }

  Future<void> _saveGallery() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cloudinary_gallery', json.encode(_items));
  }

  Future<String?> _promptDescription() async {
    String text = '';
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Description'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Optional description...',
          ),
          onChanged: (v) => text = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final desc = await _promptDescription() ?? '';
    await _uploadToCloudinary(File(picked.path), description: desc);
  }

  Future<void> _uploadToCloudinary(
    File file, {
    required String description,
  }) async {
    setState(() => _uploading = true);
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final url = data['secure_url'] as String?;
        if (url != null) {
          _items.insert(0, {
            'url': url,
            'desc': description,
            'uploadedAt': DateTime.now().toIso8601String(),
          });
          await _saveGallery();
          setState(() {});
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploaded to Cloudinary ✅')),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed (${response.statusCode})')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _preview(String url, String desc, DateTime date) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: InteractiveViewer(
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${desc.isEmpty ? '—' : desc}\n${DateFormat.yMMMd().format(date)}',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group by date string
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final it in _items) {
      final d = DateTime.parse(it['uploadedAt']);
      final key = DateFormat.yMMMMd().format(d);
      grouped.putIfAbsent(key, () => []).add(it);
    }
    final dateKeys = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Gallery'),
        actions: [
          IconButton(
            onPressed: _pickAndUploadImage,
            icon: const Icon(Icons.add_photo_alternate),
          ),
        ],
      ),
      body: _uploading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text('No memories added yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: dateKeys.length,
              itemBuilder: (ctx, idx) {
                final dateKey = dateKeys[idx];
                final items = grouped[dateKey]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        dateKey,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemBuilder: (ctx, i) {
                        final it = items[i];
                        final url = it['url'] as String;
                        final desc = it['desc'] as String;
                        final dt = DateTime.parse(it['uploadedAt']);
                        return GestureDetector(
                          onTap: () => _preview(url, desc, dt),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  url,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    desc.isEmpty
                                        ? DateFormat.jm().format(dt)
                                        : desc,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
    );
  }
}
