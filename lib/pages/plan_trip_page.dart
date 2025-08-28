import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlanTripPage extends StatefulWidget {
  const PlanTripPage({super.key});

  @override
  State<PlanTripPage> createState() => _PlanTripPageState();
}

class _PlanTripPageState extends State<PlanTripPage> {
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;

  bool _isSaving = false;

  void _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.purple,
              onPrimary: Colors.white,
              surface: Color(0xFF1B1A2D),
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF1B1A2D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveTrip() async {
    final destination = _destinationController.text.trim();
    final notes = _notesController.text.trim();

    if (destination.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter destination and date.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('trips').add({
        'title': destination,
        'notes': notes,
        'date': _selectedDate,
        'userId': user.uid,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Trip saved successfully!')));

      _destinationController.clear();
      _notesController.clear();
      setState(() {
        _selectedDate = null;
      });

      // Optionally: pop back to dashboard
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save trip: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _selectedDate != null
        ? DateFormat('MMM d, yyyy').format(_selectedDate!)
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Plan a Trip',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Destination',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _destinationController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Departure Date',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 12,
                ),
                decoration: _inputBoxDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate.isNotEmpty ? formattedDate : 'Pick a date',
                      style: TextStyle(
                        color: formattedDate.isNotEmpty
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Notes',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: _inputDecoration(hint: 'e.g. Visit the Eiffel Tower'),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF5F72BE), Color(0xFF9921E8)],
                ),
              ),
              child: TextButton(
                onPressed: _isSaving ? null : _saveTrip,
                child: _isSaving
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Save Trip',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint ?? '',
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.transparent,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  BoxDecoration _inputBoxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.blueAccent),
      borderRadius: BorderRadius.circular(14),
    );
  }
}
