import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/core/utils/utils.dart';
import 'package:keto_calculator/features/tracking/bloc/tracking_state.dart';
import 'package:keto_calculator/features/tracking/data/journal_repository.dart';

class TrackingBloc extends Cubit<TrackingState> {
  TrackingBloc() : super(TrackingState.initial(DateChangeWatcher.today)) {
    _init();
  }
  late final DateChangeWatcher dateWatcher;

  Future<void> _init() async {
    dateWatcher = DateChangeWatcher((newDate) {
      newDate = DateUtils.dateOnly(newDate);
      if (!state.dates.contains(newDate)) {
        emit(
          state.copyWith(
            dates: [...state.dates, newDate],
            selectedDate: newDate,
          ),
        );
      }
    })..start();

    emit(state.copyWith(status: TrackingStatus.loadingDates));
    final journalDates = await JournalRepository.instance.dates;
    final dates = {
      ...journalDates.map(DateUtils.dateOnly),
      DateChangeWatcher.today,
    }.toSet().toList();
    emit(state.copyWith(dates: dates, status: TrackingStatus.datesReady));
  }

  void setDate(DateTime date) {
    final newDate = DateUtils.dateOnly(date);
    if (!DateUtils.isSameDay(state.selectedDate, newDate)) {
      emit(state.copyWith(selectedDate: newDate));
    }
  }

  @override
  Future<void> close() {
    dateWatcher.stop();
    return super.close();
  }
}
