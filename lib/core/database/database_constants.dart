class DatabaseConstants {
  DatabaseConstants._();

  static const String databaseName = 'moneytrax.db';
  static const int databaseVersion = 2;

  static const String tableUsers = 'users';
  static const String tableExpenses = 'expenses';
  static const String tableIncomes = 'incomes';
  static const String tableCategories = 'categories';
  static const String tableBudgets = 'budgets';

  static const String colId = 'id';
  static const String colFullName = 'full_name';
  static const String colEmail = 'email';
  static const String colMobileNumber = 'mobile_number';
  static const String colPasswordHash = 'password_hash';
  static const String colPasswordSalt = 'password_salt';
  static const String colAmount = 'amount';
  static const String colCategoryId = 'category_id';
  static const String colDate = 'date';
  static const String colPaymentMethod = 'payment_method';
  static const String colNote = 'note';
  static const String colSource = 'source';
  static const String colName = 'name';
  static const String colIcon = 'icon';
  static const String colIsDefault = 'is_default';
  static const String colMonth = 'month';
  static const String colYear = 'year';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
}
