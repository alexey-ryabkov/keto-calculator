import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:keto_calculator/app/utils/utils.dart';
import 'package:keto_calculator/features/tracking/bloc/journal_bloc.dart';
import 'package:keto_calculator/features/tracking/bloc/journal_state.dart';

class JournalEntriesList extends StatelessWidget {
  const JournalEntriesList(this._date, {super.key});
  final DateTime _date;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        final JournalState(:entries, :status) = state;

        switch (status) {
          case JournalStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case JournalStatus.empty:
            return const Center(
              child: Text(
                'No entries for this day',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          case JournalStatus.ready:
          case JournalStatus.saving:
            return ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final entry = entries[i];
                final (formatedNutrients, formatedKcal) = formatNutrients(
                  entry,
                );
                return Dismissible(
                  key: ValueKey(
                    entry.id ?? entry.datetime.toIso8601String(),
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
                  onDismissed: (_) {
                    if (entry.id != null) {
                      context.read<JournalBloc>().deleteEntry(
                        entry.id!,
                        _date,
                      );
                    } else {
                      // FIXME loadForDate already in called in deleteEntry
                      context.read<JournalBloc>().loadForDate(
                        _date,
                      );
                    }
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat('HH:mm').format(entry.datetime),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    title: Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(formatedNutrients),
                    trailing: Text(
                      '${entry.kcal.round()} kcal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            );
          case JournalStatus.error:
            return Center(
              child: Text('Error: ${state.error ?? 'unknown'}'),
            );
          case JournalStatus.initial:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
