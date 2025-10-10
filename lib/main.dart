import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keto_calculator/app/app.dart';
import 'package:keto_calculator/features/profile/bloc/profile_bloc.dart';

void main() {
  bootstrap(
    (env) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProfileBloc()..init()),
      ],
      child: App(env),
    ),
    const String.fromEnvironment('FLAVOR', defaultValue: 'development'),
  );
}
