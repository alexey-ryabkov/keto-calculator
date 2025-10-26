// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/app/widgets/product_tile.dart';
import 'package:keto_calculator/core/models/journal_entry.dart';
import 'package:keto_calculator/core/utils/utils.dart';
// import 'package:keto_calculator/core/models/meal.dart';
import 'package:keto_calculator/features/menu/bloc/menu_state.dart';
import 'package:keto_calculator/features/menu/menu.dart';
import 'package:keto_calculator/features/tracking/bloc/journal_bloc.dart';

class MenuList extends StatelessWidget {
  const MenuList({super.key});

  @override
  Widget build(BuildContext context) {
    final jounalBloc = context.read<JournalBloc>();
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        final MenuState(:menu, :status) = state;
        switch (status) {
          case MenuStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case MenuStatus.empty:
            return const Center(
              child: Text(
                'No any meals yet',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          case MenuStatus.ready:
          case MenuStatus.saving:
            return ListView.separated(
              itemCount: menu.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final meal = menu[i];
                return Dismissible(
                  key: ValueKey(
                    meal.id!,
                    // ?? meal.created.toIso8601String(),
                  ),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) =>
                      context.read<MenuBloc>().deleteMeal(meal.id!),
                  child: ProductTile(
                    details: meal,
                    trailing: TextButton.icon(
                      icon: const Icon(Icons.local_dining_outlined),
                      iconAlignment: IconAlignment.end,
                      label: const Text('Eat'),
                      onPressed: () {
                        jounalBloc.addEntry(
                          JournalEntry.fromConsumable(
                            meal,
                            title:
                                '${formatNumber(meal.weight)}g of ${meal.name}',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Journal entry added')),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          case MenuStatus.error:
            return Center(
              child: Text('Error: ${state.error ?? 'unknown'}'),
            );
          case MenuStatus.initial:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
