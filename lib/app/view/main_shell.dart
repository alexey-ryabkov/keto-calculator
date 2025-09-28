import 'package:flutter/material.dart';
import 'package:keto_calculator/core/models/meal.dart';
import 'package:keto_calculator/core/models/product.dart';
import 'package:keto_calculator/features/menu/menu.dart';
import 'package:keto_calculator/features/products/products.dart';
import 'package:keto_calculator/features/profile/profile.dart';
import 'package:keto_calculator/features/tracking/tracking.dart';
import 'package:keto_calculator/l10n/l10n.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Simple in-memory demo data
  final Map<String, List<Meal>> _mealsByDate = {
    // today's date will be filled in initState
  };

  final List<Product> _localProducts = [
    Product(
      name: 'Авокадо',
      kcalPer100g: 160,
      protein: 2.0,
      fat: 15.0,
      carbs: 9.0,
      keto: true,
    ),
    Product(
      name: 'Куриная грудка',
      kcalPer100g: 165,
      protein: 31.0,
      fat: 3.6,
      carbs: 0.0,
      keto: true,
    ),
    Product(
      name: 'Овсянка',
      kcalPer100g: 389,
      protein: 13.0,
      fat: 7.0,
      carbs: 67.0,
      keto: false,
    ),
  ];

  // remote / catalog products (demo)
  final List<Product> _catalog = [
    Product(
      name: 'Лосось',
      kcalPer100g: 208,
      protein: 20.0,
      fat: 13.0,
      carbs: 0.0,
      keto: true,
    ),
    Product(
      name: 'Творог',
      kcalPer100g: 98,
      protein: 11.0,
      fat: 4.3,
      carbs: 3.4,
      keto: false,
    ),
    Product(
      name: 'Яйцо',
      kcalPer100g: 155,
      protein: 13.0,
      fat: 11.0,
      carbs: 1.1,
      keto: true,
    ),
    Product(
      name: 'Огурец',
      kcalPer100g: 16,
      protein: 0.7,
      fat: 0.1,
      carbs: 3.6,
      keto: false,
    ),
  ];

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    final todayKey = _dateKey(_selectedDate);
    _mealsByDate.putIfAbsent(
      todayKey,
      () => [
        Meal(product: _localProducts[1], weightGrams: 150), // курица 150g
        Meal(product: _localProducts[0], weightGrams: 100), // авокадо 100g
      ],
    );
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _addMealToDate(Meal meal, DateTime date) {
    setState(() {
      final key = _dateKey(date);
      _mealsByDate.putIfAbsent(key, () => []);
      _mealsByDate[key]!.add(meal);
    });
  }

  void _removeMealFromDate(int index, DateTime date) {
    setState(() {
      final key = _dateKey(date);
      _mealsByDate[key]!.removeAt(index);
    });
  }

  void _addProductToLocal(Product p) {
    setState(() {
      if (!_localProducts.any((x) => x.name == p.name)) {
        _localProducts.insert(0, p);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      TrackingScreen(
        selectedDate: _selectedDate,
        meals: _mealsByDate[_dateKey(_selectedDate)] ?? [],
        onPrevDay: () => setState(
          () => _selectedDate = _selectedDate.subtract(const Duration(days: 1)),
        ),
        onNextDay: () => setState(
          () => _selectedDate = _selectedDate.add(const Duration(days: 1)),
        ),
        onRemoveMeal: (index) => _removeMealFromDate(index, _selectedDate),
      ),
      MenuScreen(
        localMeals: _mealsByDate[_dateKey(_selectedDate)] ?? [],
        localProducts: _localProducts,
        onConsumeFromLocal: (product) {
          _addMealToDate(
            Meal(product: product, weightGrams: 100),
            _selectedDate,
          );
        },
        onDeleteMealAt: (index) => _removeMealFromDate(index, _selectedDate),
        onAddMealPressed: () {
          // For UI demo simply add first local product as eaten
          if (_localProducts.isNotEmpty) {
            _addMealToDate(
              Meal(product: _localProducts.first, weightGrams: 100),
              _selectedDate,
            );
          }
        },
      ),
      ProductsScreen(
        localProducts: _localProducts,
        catalog: _catalog,
        onAddToLocal: (p) => _addProductToLocal(p),
        onAddToMenu: (p) =>
            _addMealToDate(Meal(product: p, weightGrams: 100), _selectedDate),
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.track_changes),
            label: 'Tracking',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          NavigationDestination(icon: Icon(Icons.list), label: 'Products'),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
