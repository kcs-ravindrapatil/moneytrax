import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/utils/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.debug('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.error('${bloc.runtimeType} error', error, stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
