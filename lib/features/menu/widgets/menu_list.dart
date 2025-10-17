import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/core/models/journal_entry.dart';
import 'package:keto_calculator/core/models/meal.dart';
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
                final Meal(:id, :name, :photo, :weight) = meal;
                return Dismissible(
                  key: ValueKey(
                    id!,
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
                  onDismissed: (_) => context.read<MenuBloc>().deleteMeal(id),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 40,
                      backgroundImage: photo != null
                          ? NetworkImage(photo)
                          : null,
                      child: photo == null
                          ? Icon(
                              Icons.restaurant_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.surface,
                              size: 60,
                            )
                          : null,
                    ),
                    title: Text(name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${meal.kcal} kcal on $weight'),
                        if (meal.isKetoFriendly())
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  // Icons.eco,
                                  // Icons.local_florist,
                                  Icons.thumb_up_alt_outlined,
                                  size: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onTertiaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'keto',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onTertiaryContainer,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    trailing: TextButton.icon(
                      icon: const Icon(Icons.local_dining_outlined),
                      iconAlignment: IconAlignment.end,
                      label: const Text('Consume'),
                      onPressed: () async {
                        // TODO
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
