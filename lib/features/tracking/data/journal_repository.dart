import 'package:flutter/material.dart';
import 'package:keto_calculator/core/data/repository.dart';
import 'package:keto_calculator/core/models/journal_entry.dart';

class JournalRepository extends MultiItemsRepository<JournalRepository> {
  JournalRepository._(super.source) : _source = source;
  final MultiItemsSource _source;
  static const _itemsOrder = [
    SourceItemsOrder('datetime', descending: true),
  ];

  static Future<JournalRepository> init(MultiItemsSource source) =>
      DataRepository.init<JournalRepository, MultiItemsSource>(
        JournalRepository._,
        source,
      );

  static JournalRepository get instance =>
      DataRepository.getInstance<JournalRepository, MultiItemsSource>();

  Future<List<DateTime>> get dates async {
    final list = await _source.getList(
      orderBy: _itemsOrder,
    );
    return list.items
        .map((item) => JournalEntry.fromJson(item).datetime)
        .map(DateUtils.dateOnly)
        .toSet()
        .toList();
  }

  Future<List<JournalEntry>> getForDate(DateTime dt) async {
    final from = DateUtils.dateOnly(dt);
    final to = DateUtils.dateOnly(from.add(const Duration(days: 1)));

    final dateFilter = [
      SourceItemsFilter(
        'datetime',
        isGreaterThanOrEqualTo: from,
      ),
      SourceItemsFilter(
        'datetime',
        isLessThan: to,
      ),
    ];

    final list = await _source.getList(
      filters: dateFilter,
      orderBy: _itemsOrder,
    );
    return list.items.map(JournalEntry.fromJson).toList();
  }

  Future<void> add(JournalEntry journalEntry) async {
    await _source.addItem(journalEntry.toJson());
  }

  Future<void> delete(String entryId) => _source.deleteItem(entryId);
}
