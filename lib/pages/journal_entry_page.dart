import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JournalEntryPage extends StatefulWidget {
  const JournalEntryPage({super.key});

  @override
  _JournalEntryPageState createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends State<JournalEntryPage> {
  final TextEditingController _noteController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _historyNotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotesHistory();
  }

  Future<void> _loadNotesHistory() async {
    final user = _auth.currentUser;
    if (user != null) {
      final querySnapshot = await _firestore
          .collection('journals')
          .doc(user.uid)
          .collection('entries')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _historyNotes = querySnapshot.docs
            .map(
              (doc) => {
                'note': doc['note'],
                'createdAt': (doc['createdAt'] as Timestamp).toDate(),
              },
            )
            .toList();
        isLoading = false;
      });
    }
  }

  Future<void> _saveNote() async {
    final user = _auth.currentUser;
    if (user != null && _noteController.text.trim().isNotEmpty) {
      await _firestore
          .collection('journals')
          .doc(user.uid)
          .collection('entries')
          .add({
            'note': _noteController.text.trim(),
            'createdAt': Timestamp.now(),
          });
      _noteController.clear();
      _loadNotesHistory(); // Reload history
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note saved successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal Entry')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Write new note
                  TextField(
                    controller: _noteController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Write a new journal entry...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _saveNote,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Note'),
                  ),
                  const SizedBox(height: 20),

                  // Journal History
                  Expanded(
                    child: _historyNotes.isEmpty
                        ? const Text('No previous entries yet.')
                        : ListView.builder(
                            itemCount: _historyNotes.length,
                            itemBuilder: (context, index) {
                              final note = _historyNotes[index];
                              return Card(
                                color: Colors.grey[100],
                                child: ListTile(
                                  title: Text(note['note']),
                                  subtitle: Text(
                                    'Saved on ${note['createdAt'].toString().substring(0, 16)}',
                                    style: const TextStyle(fontSize: 12),
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
}
