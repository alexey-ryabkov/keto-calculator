import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/app/bloc/navigation_bloc.dart';
import 'package:keto_calculator/app/models/models.dart';
import 'package:keto_calculator/features/profile/bloc/profile_bloc.dart';
import 'package:keto_calculator/features/tracking/bloc/journal_bloc.dart';
import 'package:keto_calculator/features/tracking/bloc/tracking_bloc.dart';
import 'package:keto_calculator/features/tracking/bloc/tracking_state.dart';
import 'package:keto_calculator/features/tracking/widgets/date_switcher.dart';
import 'package:keto_calculator/features/tracking/widgets/journal_entries_list.dart';
import 'package:keto_calculator/features/tracking/widgets/journal_entry_form.dart';
import 'package:keto_calculator/features/tracking/widgets/nutrition_analytics.dart';

void showAddEntryModal(BuildContext context, DateTime selectedDate) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return JournalEntryForm(
        onSubmit: (entry) {
          context.read<JournalBloc>().addEntry(entry, reloadDate: selectedDate);
          Navigator.of(ctx).pop();
        },
      );
    },
  );
}

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isProfileDefined = context.select(
      (ProfileBloc profileBloc) => profileBloc.isProfileDefined,
    );
    final isProfileNotEmpty = context.select(
      (ProfileBloc profileBloc) => profileBloc.isProfileNotEmpty,
    );

    if (!isProfileDefined) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocBuilder<TrackingBloc, TrackingState>(
      builder: (context, state) {
        final JournalBloc(:hasEntries) = context.read<JournalBloc>();
        final TrackingState(:selectedDate) = state;
        return SafeArea(
          child: isProfileNotEmpty
              ? Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DateSwitcher(),
                        if (hasEntries) const SizedBox(height: 8),
                        const NutritionAnalytics(),
                        const SizedBox(height: 20),
                        Align(
                          child: Text(
                            'Food Journal',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(child: JournalEntriesList(selectedDate)),
                      ],
                    ),
                  ),
                  floatingActionButton: state.isSelectedDateToday
                      ? FloatingActionButton.extended(
                          onPressed: () =>
                              showAddEntryModal(context, selectedDate),
                          label: const Text('Add entry'),
                          icon: const Icon(Icons.add),
                        )
                      : null,
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () =>
                              context.read<NavigationBloc>().setPage(
                                AppPage.profile,
                              ),
                          icon: const Icon(Icons.person),
                          label: const Text('Complete your profile'),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'You need a completed profile to start tracking '
                          'your nutritions',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
