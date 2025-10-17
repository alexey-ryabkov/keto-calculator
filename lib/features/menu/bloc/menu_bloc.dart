import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:keto_calculator/core/models/meal.dart';
import 'package:keto_calculator/features/menu/bloc/menu_state.dart';
import 'package:keto_calculator/features/menu/data/menu_repository.dart';

class MenuBloc extends Cubit<MenuState> {
  MenuBloc() : super(MenuState.initial());

  Future<void> init() => loadMeals();

  // TODO paging
  Future<void> loadMeals() async {
    emit(state.copyWith(status: MenuStatus.loading));
    try {
      final menu = await MenuRepository.instance.getList();
      if (menu.isEmpty) {
        emit(state.copyWith(menu: [], status: MenuStatus.empty));
      } else {
        emit(state.copyWith(menu: menu, status: MenuStatus.ready));
      }
    } catch (e) {
      debugPrint('MenuBloc.load error: $e');
      emit(state.copyWith(status: MenuStatus.error, error: e.toString()));
    }
  }

  Future<void> addMeal(Meal meal) async {
    emit(state.copyWith(status: MenuStatus.saving));
    try {
      await MenuRepository.instance.add(meal);
      await loadMeals();
      // } else {
      //   final newList = List<Meal>.from(state.menu)..insert(0, entry);
      //   emit(state.copyWith(menu: newList, status: MenuStatus.ready));
      // }
    } catch (e) {
      emit(state.copyWith(status: MenuStatus.error, error: e.toString()));
    }
  }

  Future<void> consumeMeal(Meal meal, {bool withAdding = false}) async {
    emit(state.copyWith(status: MenuStatus.saving));
    if (withAdding) {
      await addMeal(meal.copyWith(consumedCnt: 1));
    } else {
      try {
        await MenuRepository.instance.consume(meal);
      } catch (e) {
        emit(state.copyWith(status: MenuStatus.error, error: e.toString()));
      }
    }
  }

  Future<void> deleteMeal(String id) async {
    try {
      await MenuRepository.instance.delete(id);
      await loadMeals();
    } catch (e) {
      emit(state.copyWith(status: MenuStatus.error, error: e.toString()));
    }
  }
}
