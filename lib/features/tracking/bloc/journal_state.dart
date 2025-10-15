import 'package:keto_calculator/core/models/journal_entry.dart';
import 'package:meta/meta.dart';

enum JournalStatus { initial, loading, ready, empty, saving, error }

@immutable
class JournalState {
  const JournalState({
    required this.entries,
    required this.status,
    this.error,
  });

  factory JournalState.initial() =>
      const JournalState(entries: [], status: JournalStatus.initial);

  final List<JournalEntry> entries;
  final JournalStatus status;
  final String? error;

  JournalState copyWith({
    List<JournalEntry>? entries,
    JournalStatus? status,
    String? error,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  bool get isEmpty => entries.isEmpty;
  int get count => entries.length;

  @override
  String toString() => 'JournalState(status=$status, count=${entries.length})';
}
