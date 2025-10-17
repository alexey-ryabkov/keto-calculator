import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/app/bloc/navigation_bloc.dart';
import 'package:keto_calculator/app/models/models.dart';
import 'package:keto_calculator/core/models/meal_mock.dart';
import 'package:keto_calculator/core/models/product.dart';
import 'package:keto_calculator/core/utils/utils.dart';
import 'package:keto_calculator/features/menu/menu.dart';
import 'package:keto_calculator/features/products/products.dart';
import 'package:keto_calculator/features/profile/profile.dart';
import 'package:keto_calculator/features/tracking/bloc/journal_bloc.dart';
import 'package:keto_calculator/features/tracking/bloc/tracking_state.dart';
import 'package:keto_calculator/features/tracking/tracking.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

// TODO get rid of dummy data n methods
class _MainShellState extends State<MainShell> {
  late final JournalBloc _journalBloc;
  late final TrackingBloc _trackingBloc;
  late final MenuBloc _menuBloc;
  late DateTime _selectedDate;

  @override
  void initState() {
    _journalBloc = JournalBloc();
    _trackingBloc = TrackingBloc();
    _menuBloc = MenuBloc();

    super.initState();

    _selectedDate = DateChangeWatcher.today;
    // _selectedDate = _trackingBloc.state.selectedDate;
    final todayKey = _dateKey(_selectedDate);
    _mealsByDate.putIfAbsent(
      todayKey,
      () => [
        MealMock(product: _localProducts[1], weightGrams: 150), // курица 150g
        MealMock(product: _localProducts[0], weightGrams: 100), // авокадо 100g
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <AppPage, Widget>{
      AppPage.tracking: MultiBlocProvider(
        // AppPage.tracking: BlocProvider.value(
        // value: _journalBloc,
        providers: [
          BlocProvider.value(value: _journalBloc),
          BlocProvider.value(value: _trackingBloc),
        ],
        child: BlocListener<TrackingBloc, TrackingState>(
          // when selected date changed or availiable dates list loaded ...
          listenWhen: (previous, current) =>
              !DateUtils.isSameDay(
                previous.selectedDate,
                current.selectedDate,
              ) ||
              (previous.status != TrackingStatus.datesReady &&
                  current.status == TrackingStatus.datesReady),
          // ... load journal entries for selected date
          listener: (context, state) {
            final date = DateUtils.dateOnly(state.selectedDate);
            context.read<JournalBloc>().loadForDate(date);
          },
          child: const TrackingScreen(),
        ),
      ),
      AppPage.menu: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _journalBloc),
          BlocProvider.value(value: _menuBloc),
        ],
        child: MenuScreen(),
      ),
      AppPage.products: ProductsScreen(
        localProducts: _localProducts,
        catalog: _catalog,
        onAddToLocal: _addProductToLocal,
        onAddToMenu: (p) => _addMealToDate(
          MealMock(product: p, weightGrams: 100),
          _selectedDate,
        ),
      ),
      AppPage.profile: const ProfileScreen(),
    };

    final currentPage = context.watch<NavigationBloc>().state;
    return Scaffold(
      body: pages[currentPage],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPage.index,
        onDestinationSelected: (i) =>
            context.read<NavigationBloc>().setPage(AppPage.values[i]),
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

  final Map<String, List<MealMock>> _mealsByDate = {
    // today's date will be filled in initState
  };

  final List<ProductData> _localProducts = [
    ProductData(
      name: 'Авокадо',
      kcalPer100g: 160,
      protein: 2,
      fat: 15,
      carbs: 9,
      keto: true,
    ),
    ProductData(
      name: 'Куриная грудка',
      kcalPer100g: 165,
      protein: 31,
      fat: 3.6,
      carbs: 0,
      keto: true,
    ),
    ProductData(
      name: 'Овсянка',
      kcalPer100g: 389,
      protein: 13,
      fat: 7,
      carbs: 67,
      keto: false,
    ),
  ];

  final List<ProductData> _catalog = [
    ProductData(
      name: 'Лосось',
      kcalPer100g: 208,
      protein: 20,
      fat: 13,
      carbs: 0,
      keto: true,
    ),
    ProductData(
      name: 'Творог',
      kcalPer100g: 98,
      protein: 11,
      fat: 4.3,
      carbs: 3.4,
      keto: false,
    ),
    ProductData(
      name: 'Яйцо',
      kcalPer100g: 155,
      protein: 13,
      fat: 11,
      carbs: 1.1,
      keto: true,
    ),
    ProductData(
      name: 'Огурец',
      kcalPer100g: 16,
      protein: 0.7,
      fat: 0.1,
      carbs: 3.6,
      keto: false,
    ),
  ];

  String _dateKey(DateTime dt) => formatDate(dt);

  void _addMealToDate(MealMock meal, DateTime date) {
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

  void _addProductToLocal(ProductData p) {
    setState(() {
      if (!_localProducts.any((x) => x.name == p.name)) {
        _localProducts.insert(0, p);
      }
    });
  }

  @override
  void dispose() {
    _journalBloc.close();
    _trackingBloc.close();
    _menuBloc.close();
    super.dispose();
  }
}
