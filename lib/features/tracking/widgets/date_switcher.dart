import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/core/utils/utils.dart';
import 'package:keto_calculator/features/tracking/bloc/journal_bloc.dart';
import 'package:keto_calculator/features/tracking/tracking.dart';

class DateSwitcher extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables cause widget rerendering by parent bloc bulder subscription
  DateSwitcher({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final trackingBloc = context.read<TrackingBloc>();
    // final journalBloc = context.read<JournalBloc>();

    final availableDates = trackingBloc.state.dates;
    if (availableDates.isEmpty) return const SizedBox.shrink();

    final selectedDate = trackingBloc.state.selectedDate;
    final (prevDate, nextDate) = _getNearestDates(selectedDate, availableDates);

    return Row(
      children: [
        if (prevDate != null)
          IconButton(
            onPressed: () {
              trackingBloc.setDate(prevDate);
              // journalBloc.loadForDate(prevDate);
            },
            icon: const Icon(Icons.arrow_back),
          )
        else
          const SizedBox(width: 48),
        Expanded(
          child: Text(
            formatDate(selectedDate),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (nextDate != null)
          IconButton(
            onPressed: () {
              trackingBloc.setDate(nextDate);
              // journalBloc.loadForDate(nextDate);
            },
            icon: const Icon(Icons.arrow_forward),
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }

  static (DateTime?, DateTime?) _getNearestDates(
    DateTime currentDate,
    List<DateTime> availableDates,
  ) {
    final curDateIndex = availableDates.indexWhere(
      (d) => DateUtils.isSameDay(d, currentDate),
    );
    return (
      (curDateIndex > 0) ? availableDates[curDateIndex - 1] : null,
      (curDateIndex >= 0 && curDateIndex < availableDates.length - 1)
          ? availableDates[curDateIndex + 1]
          : null,
    );
  }
}
