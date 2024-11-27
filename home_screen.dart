import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'query_order_page.dart';
import 'manage_food_items_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _targetCostController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  double _currentCost = 0.0;
  List<Map<String, dynamic>> _foodItems = [];
  Set<int> _selectedItemIds = {}; // Track IDs of selected (checked) items

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  Future<void> _fetchFoodItems() async {
    _foodItems = await DatabaseHelper.instance.getAllFoodItems();
    setState(() {});
  }

  void _toggleSelection(Map<String, dynamic> item) {
    final itemId = item['id'];
    final itemCost = item['cost'];

    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        _selectedItemIds.remove(itemId);
        _currentCost -= itemCost;
      } else if (_currentCost + itemCost <= double.parse(_targetCostController.text)) {
        _selectedItemIds.add(itemId);
        _currentCost += itemCost;
      }
    });
  }

  Future<void> _saveOrderPlan() async {
    if (_targetCostController.text.isEmpty || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')),
      );
      return;
    }

    final selectedFoodNames = _foodItems
        .where((item) => _selectedItemIds.contains(item['id']))
        .map((item) => item['name'])
        .join(', ');

    if (selectedFoodNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items selected!')),
      );
      return;
    }

    await DatabaseHelper.instance.insertOrderPlan(
      _dateController.text,
      selectedFoodNames,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order Plan Saved!')),
    );

    setState(() {
      _currentCost = 0.0;
      _selectedItemIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Ordering App'),
        backgroundColor: const Color(0xFFA67CBC),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _targetCostController,
              decoration: InputDecoration(
                labelText: 'Target Cost',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFA67CBC)),
                filled: true,
                fillColor: const Color(0xFFF0E6F6),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Select Date',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFA67CBC)),
                filled: true,
                fillColor: const Color(0xFFF0E6F6),
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
            Expanded(
              child: ListView.builder(
                itemCount: _foodItems.length,
                itemBuilder: (context, index) {
                  final item = _foodItems[index];
                  final isSelected = _selectedItemIds.contains(item['id']);
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFFE9DFF3),
                    child: ListTile(
                      title: Text(
                        item['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Cost: \$${item['cost']}'),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggleSelection(item),
                        activeColor: const Color(0xFFA67CBC),
                      ),
                    ),
                  );
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _saveOrderPlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA67CBC),
                    foregroundColor: Colors.white, // Text color
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Order Plan'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QueryOrderPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F6AA4),
                    foregroundColor: Colors.white, // Text color
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Query Order Plan'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ManageFoodItemsPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF806290),
                    foregroundColor: Colors.white, // Text color
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Manage Food Items'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

