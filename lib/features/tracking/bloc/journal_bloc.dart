import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:keto_calculator/core/models/journal_entry.dart';
import 'package:keto_calculator/features/tracking/bloc/journal_state.dart';
import 'package:keto_calculator/features/tracking/data/journal_repository.dart';

class JournalBloc extends Cubit<JournalState> {
  JournalBloc() : super(JournalState.initial());

  Map<String, double> get totals => Map.fromIterable(
    ['kcal', 'proteins', 'fats', 'carbs'],
    value: (k) => state.entries.fold(
      0.0,
      (sum, entry) => sum + (entry.toJson()[k] as num).toDouble(),
    ),
  );

  Future<void> loadForDate(DateTime date) async {
    emit(state.copyWith(status: JournalStatus.loading));
    try {
      final entries = await JournalRepository.instance.getForDate(date);
      if (entries.isEmpty) {
        emit(state.copyWith(entries: [], status: JournalStatus.empty));
      } else {
        emit(state.copyWith(entries: entries, status: JournalStatus.ready));
      }
    } catch (e) {
      debugPrint('JournalBloc.loadForDate error: $e');
      emit(state.copyWith(status: JournalStatus.error, error: e.toString()));
    }
  }

  Future<void> addEntry(JournalEntry entry, {DateTime? reloadDate}) async {
    // TODO mb opt out of saving at all
    emit(state.copyWith(status: JournalStatus.saving));
    try {
      await JournalRepository.instance.add(entry);
      if (reloadDate != null) {
        await loadForDate(reloadDate);
      } else {
        final newList = List<JournalEntry>.from(state.entries)
          ..insert(0, entry);
        emit(state.copyWith(entries: newList, status: JournalStatus.ready));
      }
    } catch (e) {
      emit(state.copyWith(status: JournalStatus.error, error: e.toString()));
    }
  }

  Future<void> deleteEntry(String id, DateTime reloadDate) async {
    // TODO mb opt out of saving at all
    // emit(state.copyWith(status: JournalStatus.saving));
    try {
      await JournalRepository.instance.delete(id);
      await loadForDate(reloadDate);
    } catch (e) {
      emit(state.copyWith(status: JournalStatus.error, error: e.toString()));
    }
  }

  /* 
  // TODO optimistic UI opt
  Future<void> deleteEntry(String id, DateTime reloadDate) async {
    final before = state.entries;
    final after = before.where((e) => e.id != id).toList();
    emit(
      state.copyWith(
        status: JournalStatus.saving,
        entries: after,
      ),
    );
    try {
      await JournalRepository.instance.delete(id);
      await loadForDate(reloadDate);
    } catch (e) {
      emit(
        state.copyWith(
          status: JournalStatus.error,
          entries: before,
          error: e.toString(),
        ),
      );
    }
  } */
}
