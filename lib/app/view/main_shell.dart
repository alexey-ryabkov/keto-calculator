import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/app/bloc/navigation_bloc.dart';
import 'package:keto_calculator/app/models/models.dart';
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

class _MainShellState extends State<MainShell> {
  late final JournalBloc _journalBloc;
  late final TrackingBloc _trackingBloc;
  late final MenuBloc _menuBloc;
  late final ProductsBloc _productsBloc;

  @override
  void initState() {
    _journalBloc = JournalBloc();
    _trackingBloc = TrackingBloc();
    _menuBloc = MenuBloc();
    _productsBloc = ProductsBloc();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <AppPage, Widget>{
      AppPage.tracking: MultiBlocProvider(
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
        child: const MenuScreen(),
      ),
      // TODO provider for SpoonacularApi
      AppPage.products: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _journalBloc),
          BlocProvider.value(value: _productsBloc),
        ],
        child: const ProductsScreen(),
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

  @override
  void dispose() {
    _journalBloc.close();
    _trackingBloc.close();
    _menuBloc.close();
    _productsBloc.close();
    super.dispose();
  }
}
