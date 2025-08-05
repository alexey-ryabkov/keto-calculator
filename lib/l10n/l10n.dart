import 'package:flutter/widgets.dart';
import 'package:keto_calculator/l10n/gen/app_localizations.dart';

export 'package:keto_calculator/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
