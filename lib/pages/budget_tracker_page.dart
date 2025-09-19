import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetTrackerPage extends StatefulWidget {
  const BudgetTrackerPage({super.key});

  @override
  State<BudgetTrackerPage> createState() => _BudgetTrackerPageState();
}

class _BudgetTrackerPageState extends State<BudgetTrackerPage> {
  double totalBudget = 0;
  double totalExpenses = 0;
  final List<Map<String, dynamic>> expenses = [];

  final TextEditingController budgetController = TextEditingController();
  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController expenseAmountController = TextEditingController();

  void setBudget() {
    setState(() {
      totalBudget = double.tryParse(budgetController.text) ?? 0;
    });
    budgetController.clear();
  }

  void addExpense() {
    double amount = double.tryParse(expenseAmountController.text) ?? 0;
    if (expenseNameController.text.isNotEmpty && amount > 0) {
      setState(() {
        expenses.add({
          'name': expenseNameController.text,
          'amount': amount,
          'date': DateTime.now(),
        });
        totalExpenses += amount;
      });
      expenseNameController.clear();
      expenseAmountController.clear();
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      border: const OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double remainingBudget = totalBudget - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget Tracker"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Set Budget Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "Set Your Budget",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: budgetController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.black),
                        decoration: _inputDecoration("Enter total budget"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: setBudget,
                        child: const Text("Save Budget"),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Budget Summary
              Card(
                color: Colors.black87,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Total Budget: ₹${totalBudget.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Total Expenses: ₹${totalExpenses.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Remaining: ₹${remainingBudget.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: remainingBudget >= 0
                              ? Colors.greenAccent
                              : const Color.fromARGB(255, 209, 195, 195),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Add Expense Section
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "Add Expense",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: expenseNameController,
                        style: const TextStyle(color: Colors.black),
                        decoration: _inputDecoration("Expense Name"),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: expenseAmountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.black),
                        decoration: _inputDecoration("Amount"),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            107,
                            188,
                            121,
                          ),
                        ),
                        onPressed: addExpense,
                        child: const Text("Add Expense"),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Expenses List
              const Text(
                "Expenses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  var expense = expenses[index];
                  return ListTile(
                    title: Text(expense['name']),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy').format(expense['date']),
                    ),
                    trailing: Text("₹${expense['amount'].toStringAsFixed(2)}"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
