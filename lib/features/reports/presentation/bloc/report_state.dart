part of 'report_bloc.dart';

enum ReportStatus { initial, loading, success, failure }

class ReportState extends Equatable {
  const ReportState({
    this.status = ReportStatus.initial,
    this.period = ReportPeriod.monthly,
    this.customFrom,
    this.customTo,
    this.summary,
    this.currencyCode = 'INR',
    this.isExporting = false,
    this.errorMessage,
  });

  final ReportStatus status;
  final ReportPeriod period;
  final DateTime? customFrom;
  final DateTime? customTo;
  final ReportSummary? summary;
  final String currencyCode;
  final bool isExporting;
  final String? errorMessage;

  ReportState copyWith({
    ReportStatus? status,
    ReportPeriod? period,
    DateTime? customFrom,
    DateTime? customTo,
    bool clearCustomRange = false,
    ReportSummary? summary,
    String? currencyCode,
    bool? isExporting,
    String? errorMessage,
  }) {
    return ReportState(
      status: status ?? this.status,
      period: period ?? this.period,
      customFrom: clearCustomRange ? null : (customFrom ?? this.customFrom),
      customTo: clearCustomRange ? null : (customTo ?? this.customTo),
      summary: summary ?? this.summary,
      currencyCode: currencyCode ?? this.currencyCode,
      isExporting: isExporting ?? this.isExporting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        period,
        customFrom,
        customTo,
        summary,
        currencyCode,
        isExporting,
        errorMessage,
      ];
}
