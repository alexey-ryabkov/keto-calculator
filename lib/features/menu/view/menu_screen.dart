import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/features/menu/bloc/menu_state.dart';
import 'package:keto_calculator/features/menu/menu.dart';
import 'package:keto_calculator/features/menu/widgets/add_meal_form.dart';
import 'package:keto_calculator/features/menu/widgets/menu_list.dart';

void showAddMealModal(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return AddMealForm(
        onAdd: (meal) {
          context.read<MenuBloc>().addMeal(meal);
          Navigator.of(ctx).pop();
        },
      );
    },
  );
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuBloc = context.read<MenuBloc>();
      if (mounted && menuBloc.state.status == MenuStatus.initial) {
        menuBloc.init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Align(
                    child: Text(
                      'Meals menu',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Expanded(child: MenuList()),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => showAddMealModal(context),
              label: const Text('Add meal'),
              icon: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}
