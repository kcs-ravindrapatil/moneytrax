import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/data_refresh_bus.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';
import '../../../settings/data/datasources/preferences_data_source.dart';
import '../../data/services/invoice_pdf_service.dart';
import '../../domain/usecases/get_report_summary_usecase.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc({
    required GetReportSummaryUseCase getReportSummary,
    required PreferencesDataSource preferences,
    required GetProfileUseCase getProfile,
    required InvoicePdfService invoicePdfService,
    required DataRefreshBus refreshBus,
  })  : _getReportSummary = getReportSummary,
        _preferences = preferences,
        _getProfile = getProfile,
        _invoicePdfService = invoicePdfService,
        _refreshBus = refreshBus,
        super(const ReportState()) {
    on<ReportStarted>(_onStarted);
    on<ReportPeriodChanged>(_onPeriodChanged);
    on<ReportDateRangeChanged>(_onDateRange);
    on<ReportInvoiceRequested>(_onInvoice);
    _subscription = _refreshBus.stream.listen((_) {
      if (!isClosed) add(const ReportStarted());
    });
  }

  final GetReportSummaryUseCase _getReportSummary;
  final PreferencesDataSource _preferences;
  final GetProfileUseCase _getProfile;
  final InvoicePdfService _invoicePdfService;
  final DataRefreshBus _refreshBus;
  StreamSubscription<void>? _subscription;

  Future<void> _onStarted(
    ReportStarted event,
    Emitter<ReportState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onPeriodChanged(
    ReportPeriodChanged event,
    Emitter<ReportState> emit,
  ) async {
    if (event.period == ReportPeriod.custom) {
      final now = DateTime.now();
      final from = state.customFrom ?? DateTime(now.year, now.month, 1);
      final to = state.customTo ?? DateTime(now.year, now.month, now.day);
      emit(
        state.copyWith(
          period: ReportPeriod.custom,
          customFrom: from,
          customTo: to,
        ),
      );
    } else {
      emit(
        state.copyWith(
          period: event.period,
          clearCustomRange: true,
        ),
      );
    }
    await _load(emit);
  }

  Future<void> _onDateRange(
    ReportDateRangeChanged event,
    Emitter<ReportState> emit,
  ) async {
    emit(
      state.copyWith(
        period: ReportPeriod.custom,
        customFrom: event.from,
        customTo: event.to,
      ),
    );
    await _load(emit);
  }

  Future<void> _load(Emitter<ReportState> emit) async {
    emit(state.copyWith(status: ReportStatus.loading));
    final currency = await _preferences.getCurrencyCode();
    final result = await _getReportSummary(
      period: state.period,
      fromOverride: state.customFrom,
      toOverride: state.customTo,
    );
    result.fold(
      onFailure: (f) => emit(
        state.copyWith(
          status: ReportStatus.failure,
          errorMessage: f.message,
        ),
      ),
      onSuccess: (summary) => emit(
        state.copyWith(
          status: ReportStatus.success,
          summary: summary,
          currencyCode: currency,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onInvoice(
    ReportInvoiceRequested event,
    Emitter<ReportState> emit,
  ) async {
    final summary = state.summary;
    if (summary == null) return;
    emit(state.copyWith(isExporting: true));
    final profile = await _getProfile();
    final name = profile.dataOrNull?.fullName ?? 'MoneyTrax user';
    try {
      await _invoicePdfService.shareStatement(
        summary: summary,
        currencyCode: state.currencyCode,
        userName: name,
        type: event.type,
      );
      emit(state.copyWith(isExporting: false));
    } catch (_) {
      emit(
        state.copyWith(
          isExporting: false,
          errorMessage: 'Could not generate statement PDF.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
