import 'package:schedule_app/app/bootstrap.dart';
import 'package:schedule_app/core/env/app_config.dart';

Future<void> main() async {
  await bootstrap(AppConfig.dev());
}

