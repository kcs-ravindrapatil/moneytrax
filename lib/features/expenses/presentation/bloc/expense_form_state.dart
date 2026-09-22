part of 'expense_form_bloc.dart';

enum ExpenseFormStatus {
  initial,
  loading,
  editing,
  submitting,
  success,
  failure
}

class ExpenseFormState extends Equatable {
  const ExpenseFormState({
    this.status = ExpenseFormStatus.initial,
    this.amount = '',
    this.categoryId,
    this.date,
    this.paymentMethod,
    this.note = '',
    this.categories = const [],
    this.paymentMethods = const [],
    this.isValid = false,
    this.errorMessage,
    this.existingCreatedAt,
  });

  final ExpenseFormStatus status;
  final String amount;
  final String? categoryId;
  final DateTime? date;
  final String? paymentMethod;
  final String note;
  final List<Category> categories;
  final List<String> paymentMethods;
  final bool isValid;
  final String? errorMessage;
  final DateTime? existingCreatedAt;

  ExpenseFormState copyWith({
    ExpenseFormStatus? status,
    String? amount,
    String? categoryId,
    DateTime? date,
    String? paymentMethod,
    String? note,
    List<Category>? categories,
    List<String>? paymentMethods,
    bool? isValid,
    String? errorMessage,
    DateTime? existingCreatedAt,
  }) {
    return ExpenseFormState(
      status: status ?? this.status,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      categories: categories ?? this.categories,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
      existingCreatedAt: existingCreatedAt ?? this.existingCreatedAt,
    );
  }

  @override
  List<Object?> get props => [
        status,
        amount,
        categoryId,
        date,
        paymentMethod,
        note,
        categories,
        paymentMethods,
        isValid,
        errorMessage,
        existingCreatedAt,
      ];
}
