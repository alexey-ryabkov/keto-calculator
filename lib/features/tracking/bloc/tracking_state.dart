import 'package:flutter/material.dart';
import 'package:keto_calculator/core/utils/utils.dart';

enum TrackingStatus { initial, loadingDates, datesReady, error }

@immutable
class TrackingState {
  const TrackingState({
    required this.selectedDate,
    required this.dates,
    required this.status,
    this.error,
  });

  factory TrackingState.initial(DateTime selectedDate) => TrackingState(
    selectedDate: selectedDate,
    dates: [selectedDate],
    status: TrackingStatus.initial,
  );

  final DateTime selectedDate;
  final List<DateTime> dates;
  final TrackingStatus status;
  final String? error;

  bool get isSelectedDateToday =>
      DateUtils.isSameDay(selectedDate, DateChangeWatcher.today);

  TrackingState copyWith({
    DateTime? selectedDate,
    List<DateTime>? dates,
    TrackingStatus? status,
    String? error,
  }) {
    return TrackingState(
      selectedDate: selectedDate ?? this.selectedDate,
      dates: dates ?? this.dates,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  static const _maxStrOutputDatesCnt = 10;
  @override
  String toString() {
    final datesCnt = dates.length;
    return 'TrackingState(status $status, '
        'selectedDate ${formatDate(selectedDate)}, dates count $datesCnt, '
        'dates: ${dates.map(formatDate).take(_maxStrOutputDatesCnt).join(', ')}'
        '${datesCnt > _maxStrOutputDatesCnt ? ', ... and '
                  '${datesCnt - _maxStrOutputDatesCnt} more' : ''}';
  }
}
