part of 'report_bloc.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object?> get props => [];
}

class ReportStarted extends ReportEvent {
  const ReportStarted();
}

class ReportPeriodChanged extends ReportEvent {
  const ReportPeriodChanged(this.period);
  final ReportPeriod period;
  @override
  List<Object?> get props => [period];
}

class ReportDateRangeChanged extends ReportEvent {
  const ReportDateRangeChanged({required this.from, required this.to});
  final DateTime from;
  final DateTime to;
  @override
  List<Object?> get props => [from, to];
}

class ReportInvoiceRequested extends ReportEvent {
  const ReportInvoiceRequested({this.type = StatementExportType.all});
  final StatementExportType type;
  @override
  List<Object?> get props => [type];
}
