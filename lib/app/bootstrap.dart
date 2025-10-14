import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:keto_calculator/app/data/firestore.dart';
import 'package:keto_calculator/app/firebase_options.dart';
import 'package:keto_calculator/core/models/app_user.dart';
import 'package:keto_calculator/features/profile/data/profile_repository.dart';
import 'package:keto_calculator/features/tracking/data/journal_repository.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function(String env) builder,
  String env,
) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final fs = FirebaseFirestore.instance;

  await AppUser.init();

  await Future.wait([
    ProfileRepository.init(FirestoreProfile(fs)),
    JournalRepository.init(FirestoreJournal(fs)),
    // MealRepository.init(FirestoreMeal(fs)),
    // ProductRepository.init(FirestoreProduct(fs)),
  ]);

  runApp(await builder(env));
}
