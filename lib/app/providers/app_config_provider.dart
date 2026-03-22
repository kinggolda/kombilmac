import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedule_app/core/env/app_config.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError(
    'AppConfig must be overridden in bootstrap.',
  ),
);

