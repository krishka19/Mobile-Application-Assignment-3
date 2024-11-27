import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('food_ordering.db');
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create tables and insert sample data
  Future<void> _createDB(Database db, int version) async {
    // Create food items table
    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cost REAL NOT NULL
      )
    ''');

    // Create order plans table
    await db.execute('''
      CREATE TABLE order_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        selected_food_items TEXT NOT NULL
      )
    ''');

    //sample food items
    final sampleFoodItems = [
      {'name': 'Pizza', 'cost': 10.99},
      {'name': 'Burger', 'cost': 8.99},
      {'name': 'Pasta', 'cost': 12.50},
      {'name': 'Salad', 'cost': 6.50},
      {'name': 'Fries', 'cost': 4.99},
      {'name': 'Sandwich', 'cost': 5.99},
      {'name': 'Sushi', 'cost': 14.99},
      {'name': 'Taco', 'cost': 3.99},
      {'name': 'Steak', 'cost': 20.99},
      {'name': 'Chicken Wings', 'cost': 9.99},
      {'name': 'Ice Cream', 'cost': 3.50},
      {'name': 'Donut', 'cost': 1.99},
      {'name': 'Milkshake', 'cost': 4.50},
      {'name': 'Smoothie', 'cost': 6.00},
      {'name': 'Hot Dog', 'cost': 4.99},
      {'name': 'Nachos', 'cost': 7.99},
      {'name': 'Pancakes', 'cost': 8.50},
      {'name': 'Waffles', 'cost': 9.00},
      {'name': 'Soup', 'cost': 5.99},
      {'name': 'Pizza Slice', 'cost': 2.99},
    ];

    for (final item in sampleFoodItems) {
      await db.insert('food_items', item);
    }
  }

  // Fetch all food items
  Future<List<Map<String, dynamic>>> getAllFoodItems() async {
    final db = await database;
    return await db.query('food_items');
  }

  // Insert an order plan with selected food names
  Future<int> insertOrderPlan(String date, String selectedFoodNames) async {
    final db = await database;
    return await db.insert('order_plans', {
      'date': date,
      'selected_food_items': selectedFoodNames, // Save names as a string
    });
  }

  // Get an order plan by date
  Future<List<Map<String, dynamic>>> getOrderPlanByDate(String date) async {
    final db = await database;
    return await db.query(
      'order_plans',
      where: 'date = ?',
      whereArgs: [date],
    );
  }
}
