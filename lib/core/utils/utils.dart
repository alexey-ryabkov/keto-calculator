import 'package:intl/intl.dart';

export 'compute_daily_nutrition_targets.dart';
export 'date_change_watcher.dart';

String formatDate(DateTime dt) => DateFormat('dd.MM.yyyy').format(dt);
