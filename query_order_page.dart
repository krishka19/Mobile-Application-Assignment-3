import 'package:flutter/material.dart';
import 'database_helper.dart';

class QueryOrderPage extends StatefulWidget {
  const QueryOrderPage({super.key});

  @override
  State<QueryOrderPage> createState() => _QueryOrderPageState();
}

class _QueryOrderPageState extends State<QueryOrderPage> {
  final TextEditingController _dateController = TextEditingController();
  String _result = '';

  Future<void> _queryOrderPlan() async {
    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a date!')),
      );
      return;
    }

    final result = await DatabaseHelper.instance.getOrderPlanByDate(_dateController.text);
    if (result.isEmpty) {
      setState(() {
        _result = 'No order plan found for this date.';
      });
    } else {
      final selectedItems = result[0]['selected_food_items'];
      setState(() {
        _result = 'Order Plan:\n$selectedItems';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Query Order Plan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFA67CBC),
        elevation: 5,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5EBFA), Color(0xFFEDE1F4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Field for Date
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Enter Date (YYYY-MM-DD)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFA67CBC)),
                filled: true,
                fillColor: const Color(0xFFF8F3F9),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  _dateController.text = date.toIso8601String().split('T')[0];
                }
              },
            ),
            const SizedBox(height: 16),

            // Query Button
            ElevatedButton(
              onPressed: _queryOrderPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA67CBC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 5,
              ),
              child: const Text(
                'Query Order Plan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // Results Display
            Expanded(
              child: Card(
                elevation: 3,
                color: const Color(0xFFF8F3F9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _result,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF5E3F6B)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
