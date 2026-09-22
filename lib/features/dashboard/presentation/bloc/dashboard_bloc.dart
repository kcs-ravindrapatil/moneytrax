import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/data_refresh_bus.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(
    this._getDashboardData,
    this._refreshBus,
  ) : super(const DashboardState()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardRefreshed>(_onStarted);
    _subscription = _refreshBus.stream.listen((_) {
      if (!isClosed) add(const DashboardRefreshed());
    });
  }

  final GetDashboardDataUseCase _getDashboardData;
  final DataRefreshBus _refreshBus;
  StreamSubscription<void>? _subscription;

  Future<void> _onStarted(
    DashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    final result = await _getDashboardData();
    result.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (data) => emit(
        state.copyWith(
          status: DashboardStatus.success,
          data: data,
          errorMessage: null,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
