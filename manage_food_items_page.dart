import 'package:flutter/material.dart';
import 'database_helper.dart';

class ManageFoodItemsPage extends StatefulWidget {
  const ManageFoodItemsPage({super.key});

  @override
  State<ManageFoodItemsPage> createState() => _ManageFoodItemsPageState();
}

class _ManageFoodItemsPageState extends State<ManageFoodItemsPage> {
  List<Map<String, dynamic>> _foodItems = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  Future<void> _fetchFoodItems() async {
    _foodItems = await DatabaseHelper.instance.getAllFoodItems();
    setState(() {});
  }

  Future<void> _addOrUpdateFoodItem() async {
    final name = _nameController.text;
    final cost = double.tryParse(_costController.text);

    if (name.isEmpty || cost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide valid inputs!')),
      );
      return;
    }

    if (_editingId == null) {
      await DatabaseHelper.instance.database.then((db) {
        db.insert('food_items', {'name': name, 'cost': cost});
      });
    } else {
      await DatabaseHelper.instance.database.then((db) {
        db.update(
          'food_items',
          {'name': name, 'cost': cost},
          where: 'id = ?',
          whereArgs: [_editingId],
        );
      });
    }

    _nameController.clear();
    _costController.clear();
    _editingId = null;
    _fetchFoodItems();
  }

  Future<void> _deleteFoodItem(int id) async {
    await DatabaseHelper.instance.database.then((db) {
      db.delete('food_items', where: 'id = ?', whereArgs: [id]);
    });
    _fetchFoodItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Food Items'),
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
          children: [
            // Food Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFF8F3F9),
                prefixIcon: const Icon(Icons.fastfood, color: Color(0xFFA67CBC)),
              ),
            ),
            const SizedBox(height: 16),

            // Cost Input
            TextField(
              controller: _costController,
              decoration: InputDecoration(
                labelText: 'Cost',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFF8F3F9),
                prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFA67CBC)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Add/Update Button
            ElevatedButton(
              onPressed: _addOrUpdateFoodItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA67CBC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 3,
              ),
              child: Text(
                _editingId == null ? 'Add Food Item' : 'Update Food Item',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // List of Food Items
            Expanded(
              child: ListView.builder(
                itemCount: _foodItems.length,
                itemBuilder: (context, index) {
                  final item = _foodItems[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFFE9DFF3),
                    child: ListTile(
                      title: Text(
                        item['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        'Cost: \$${item['cost']}',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF5E3F6B)),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit Button
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFFA67CBC)),
                            onPressed: () {
                              _nameController.text = item['name'];
                              _costController.text = item['cost'].toString();
                              _editingId = item['id'];
                            },
                          ),
                          // Delete Button
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFoodItem(item['id']),
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
      ),
    );
  }
}
