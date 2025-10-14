import 'package:bloc/bloc.dart';
import 'package:keto_calculator/app/models/models.dart';

class NavigationBloc extends Cubit<AppPage> {
  NavigationBloc([super.initial = AppPage.tracking]);
  void setPage(AppPage i) => emit(i);
}
