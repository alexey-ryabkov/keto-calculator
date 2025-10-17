import 'package:keto_calculator/core/models/meal.dart';
import 'package:meta/meta.dart';

enum MenuStatus { initial, loading, ready, empty, saving, error }

@immutable
class MenuState {
  const MenuState({
    required this.menu,
    required this.status,
    this.error,
  });

  factory MenuState.initial() =>
      const MenuState(menu: [], status: MenuStatus.initial);

  final List<Meal> menu;
  final MenuStatus status;
  final String? error;

  MenuState copyWith({
    List<Meal>? menu,
    MenuStatus? status,
    String? error,
  }) {
    return MenuState(
      menu: menu ?? this.menu,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  bool get isEmpty => menu.isEmpty;
  int get count => menu.length;

  @override
  String toString() => 'MenuState(status=$status, count=${menu.length})';
}
