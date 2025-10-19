import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                final e = entries[i];
                return Dismissible(
                  key: ValueKey(
                    e.id ?? e.datetime.toIso8601String(),
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
                    if (e.id != null) {
                      context.read<JournalBloc>().deleteEntry(
                        e.id!,
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
                    leading: CircleAvatar(
                      child: Text(
                        e.title.isNotEmpty ? e.title[0] : '?',
                      ),
                    ),
                    title: Text(e.title),
                    subtitle: Text(
                      '${e.kcal.round()} kcal • ${e.proteins} / ${e.fats} / ${e.carbs}',
                    ),
                    trailing: Text(
                      e.weightGrams != null
                          ? '${e.weightGrams?.round() ?? 0} g'
                          : '',
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
