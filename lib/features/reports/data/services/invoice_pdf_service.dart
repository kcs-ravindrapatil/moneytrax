import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/formatters.dart';
import '../../../transactions/domain/entities/transaction_item.dart';
import '../../domain/usecases/get_report_summary_usecase.dart';

enum StatementExportType { all, expense, income }

class InvoicePdfService {
  Future<void> shareInvoice({
    required ReportSummary summary,
    required String currencyCode,
    required String userName,
  }) async {
    await shareStatement(
      summary: summary,
      currencyCode: currencyCode,
      userName: userName,
      type: StatementExportType.all,
      includeSummary: true,
    );
  }

  Future<void> shareStatement({
    required ReportSummary summary,
    required String currencyCode,
    required String userName,
    required StatementExportType type,
    bool includeSummary = true,
  }) async {
    final filtered = _filterTransactions(summary.transactions, type);
    final periodLabel =
        '${DateFormatter.dayMonthYear(summary.from)} – ${DateFormatter.dayMonthYear(summary.to)}';
    final title = switch (type) {
      StatementExportType.all => 'Account Statement',
      StatementExportType.expense => 'Expense Statement',
      StatementExportType.income => 'Income Statement',
    };

    final incomeTotal = filtered
        .where((t) => !t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expenseTotal = filtered
        .where((t) => t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'MoneyTrax',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.teal800,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.Text('Prepared for: $userName'),
          pw.Text('Period: $periodLabel'),
          pw.Text('Currency: $currencyCode'),
          pw.SizedBox(height: 16),
          if (includeSummary) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _summaryChip(
                    'Credits (Income)',
                    CurrencyFormatter.format(
                      incomeTotal,
                      currencyCode: currencyCode,
                    ),
                    PdfColors.green800,
                  ),
                  _summaryChip(
                    'Debits (Expense)',
                    CurrencyFormatter.format(
                      expenseTotal,
                      currencyCode: currencyCode,
                    ),
                    PdfColors.red800,
                  ),
                  _summaryChip(
                    'Net',
                    CurrencyFormatter.format(
                      incomeTotal - expenseTotal,
                      currencyCode: currencyCode,
                    ),
                    PdfColors.blueGrey800,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
          ],
          pw.Text(
            'Transactions',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
          pw.SizedBox(height: 8),
          if (filtered.isEmpty)
            pw.Text('No transactions in this period.')
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.4),
                1: const pw.FlexColumnWidth(2.4),
                2: const pw.FlexColumnWidth(1.2),
                3: const pw.FlexColumnWidth(1.2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _headerCell('Date'),
                    _headerCell('Description'),
                    _headerCell('Credit', alignRight: true),
                    _headerCell('Debit', alignRight: true),
                  ],
                ),
                ...filtered.map((tx) {
                  final credit = tx.isExpense
                      ? '—'
                      : CurrencyFormatter.format(
                          tx.amount,
                          currencyCode: currencyCode,
                        );
                  final debit = tx.isExpense
                      ? CurrencyFormatter.format(
                          tx.amount,
                          currencyCode: currencyCode,
                        )
                      : '—';
                  return pw.TableRow(
                    children: [
                      _bodyCell(DateFormatter.dayMonthYear(tx.date)),
                      _bodyCell(
                        [
                          tx.title,
                          if (tx.subtitle != null && tx.subtitle!.isNotEmpty)
                            tx.subtitle!,
                          if (tx.note != null && tx.note!.isNotEmpty) tx.note!,
                        ].join(' · '),
                      ),
                      _bodyCell(
                        credit,
                        alignRight: true,
                        color: tx.isExpense ? null : PdfColors.green800,
                      ),
                      _bodyCell(
                        debit,
                        alignRight: true,
                        color: tx.isExpense ? PdfColors.red800 : null,
                      ),
                    ],
                  );
                }),
              ],
            ),
          pw.SizedBox(height: 24),
          pw.Text(
            'This document is a personal spending statement generated by MoneyTrax. '
            'Amounts in green are income (credits); amounts in red are expenses (debits). '
            'It is not an official bank statement.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final suffix = type.name;
    final file = File(
      '${dir.path}/moneytrax_${suffix}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(Uint8List.fromList(bytes));
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'MoneyTrax $title',
      text: 'MoneyTrax $title for $periodLabel',
    );
  }

  List<TransactionItem> _filterTransactions(
    List<TransactionItem> items,
    StatementExportType type,
  ) {
    final sorted = [...items]
      ..sort((a, b) => a.date.compareTo(b.date));
    switch (type) {
      case StatementExportType.all:
        return sorted;
      case StatementExportType.expense:
        return sorted.where((t) => t.isExpense).toList();
      case StatementExportType.income:
        return sorted.where((t) => !t.isExpense).toList();
    }
  }

  pw.Widget _summaryChip(String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  pw.Widget _headerCell(String text, {bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      ),
    );
  }

  pw.Widget _bodyCell(
    String text, {
    bool alignRight = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(fontSize: 9, color: color),
      ),
    );
  }
}
