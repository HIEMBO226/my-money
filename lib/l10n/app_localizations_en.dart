// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'My money';

  @override
  String get navDashboard => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navBudgets => 'Budgets';

  @override
  String get navStatistics => 'Statistics';

  @override
  String get navSettings => 'Settings';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get loading => 'Loading';

  @override
  String get transactionTypeExpense => 'Expense';

  @override
  String get transactionTypeIncome => 'Income';

  @override
  String get transactionTypeTransfer => 'Transfer';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get accountTypeMobileMoney => 'Mobile Money';

  @override
  String get accountTypeSavings => 'Savings';

  @override
  String get frequencyDaily => 'Daily';

  @override
  String get frequencyWeekly => 'Weekly';

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get frequencyYearly => 'Yearly';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryTransport => 'Transportation';

  @override
  String get categoryHousing => 'Housing';

  @override
  String get categoryBills => 'Bills';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryLeisure => 'Leisure';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryOtherExpense => 'Other expenses';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categoryFreelance => 'Freelance';

  @override
  String get categoryInvestment => 'Investments';

  @override
  String get categoryGifts => 'Gifts';

  @override
  String get categoryOtherIncome => 'Other income';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get monthlyIncome => 'Monthly income';

  @override
  String get monthlyExpenses => 'Monthly expenses';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get category => 'Category';

  @override
  String get account => 'Account';

  @override
  String get note => 'Note';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get selectAccount => 'Select an account';

  @override
  String get budgetTitle => 'Budgets';

  @override
  String get budgetProgress => 'Progress';

  @override
  String get budgetWarning => 'Warning: 80% of budget reached';

  @override
  String get budgetExceeded => 'Budget exceeded';

  @override
  String get noBudgets => 'No budgets defined';

  @override
  String get savingsGoals => 'Savings goals';

  @override
  String get targetAmount => 'Target amount';

  @override
  String get currentAmount => 'Current amount';

  @override
  String get deadline => 'Deadline';

  @override
  String get noGoals => 'No savings goals';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get noAccounts => 'No accounts';

  @override
  String get noCategories => 'No categories';

  @override
  String get currency => 'Currency';

  @override
  String get dateFormat => 'Date format';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Language';

  @override
  String get pin => 'PIN code';

  @override
  String get biometrics => 'Biometrics';

  @override
  String get exportData => 'Export data';

  @override
  String get importData => 'Import data';

  @override
  String get currencyXof => 'CFA Franc (XOF)';

  @override
  String get currencyEur => 'Euro (EUR)';

  @override
  String get currencyUsd => 'US Dollar (USD)';

  @override
  String get currencyGbp => 'British Pound (GBP)';

  @override
  String get currencyCad => 'Canadian Dollar (CAD)';

  @override
  String get currencyChf => 'Swiss Franc (CHF)';

  @override
  String get currencyMad => 'Moroccan Dirham (MAD)';

  @override
  String get currencyTnd => 'Tunisian Dinar (TND)';

  @override
  String get currencyXaf => 'CFA Franc (XAF)';

  @override
  String get currencyGnf => 'Guinean Franc (GNF)';

  @override
  String get errorGeneric => 'An unexpected error occurred.';

  @override
  String get errorDatabase => 'Error accessing local data.';

  @override
  String get errorValidation => 'Please check your input fields.';

  @override
  String get errorExport => 'Error exporting data.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get confirmDelete => 'Confirm deletion';

  @override
  String get deleteConfirmMessage =>
      'This action cannot be undone. Do you want to continue?';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get addAccount => 'Add account';

  @override
  String get editAccount => 'Edit account';

  @override
  String get accountName => 'Account name';

  @override
  String get accountNameHint => 'e.g. Checking, Mobile Money...';

  @override
  String get accountType => 'Account type';

  @override
  String get initialBalance => 'Initial balance';

  @override
  String get initialBalanceNote => 'Initial balance';

  @override
  String get noAccountsSubtitle =>
      'Add your accounts (cash, bank, mobile money, savings) to track balances.';

  @override
  String get accountCreated => 'Account created successfully';

  @override
  String get accountUpdated => 'Account updated';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get accountDeleteLinkedError =>
      'Cannot delete an account with linked transactions.';

  @override
  String get transfer => 'Transfer';

  @override
  String get transferTitle => 'Transfer between accounts';

  @override
  String get fromAccount => 'Source account';

  @override
  String get toAccount => 'Destination account';

  @override
  String get transferSuccess => 'Transfer completed successfully';

  @override
  String get transferSameAccountError =>
      'Source and destination accounts must be different.';

  @override
  String get invalidAmountError =>
      'Please enter a valid amount greater than zero.';

  @override
  String get requiredFieldError => 'This field is required.';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryNameHint => 'e.g. Coffee, Subscriptions...';

  @override
  String get categoryType => 'Type';

  @override
  String get expensesTab => 'Expenses';

  @override
  String get incomesTab => 'Income';

  @override
  String get defaultBadge => 'Default';

  @override
  String get noCategoriesSubtitle =>
      'Create categories to organize your income and expenses.';

  @override
  String get categoryCreated => 'Category created successfully';

  @override
  String get categoryUpdated => 'Category updated';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get categoryDeleteDefaultError =>
      'Default categories cannot be deleted.';

  @override
  String get categoryDeleteUsedError =>
      'Cannot delete a category linked to transactions or budgets.';

  @override
  String get selectIcon => 'Icon';

  @override
  String get selectColor => 'Color';

  @override
  String get settingsManagementSection => 'Management';

  @override
  String get manageAccountsSubtitle =>
      'Manage your accounts and transfer funds';

  @override
  String get manageCategoriesSubtitle =>
      'Customize your income and expense categories';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get transactionCreated => 'Transaction saved';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get searchTransactionsHint => 'Search by note, category or account...';

  @override
  String get noTransactionsSubtitle =>
      'Tap + to record your first expense or income.';

  @override
  String get noMatchingTransactions => 'No matching transactions';

  @override
  String get noMatchingTransactionsSubtitle =>
      'Try adjusting or resetting your filters.';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String get applyFilters => 'Apply';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get period => 'Period';

  @override
  String get allPeriods => 'All dates';

  @override
  String get thisMonth => 'This month';

  @override
  String get lastMonth => 'Last month';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get customPeriod => 'Custom';

  @override
  String get allTypes => 'All';

  @override
  String get allAccounts => 'All accounts';

  @override
  String get allCategories => 'All categories';

  @override
  String get amountRange => 'Amount range';

  @override
  String get minAmount => 'Min. amount';

  @override
  String get maxAmount => 'Max. amount';

  @override
  String get loadMore => 'Load more';

  @override
  String get attachment => 'Attachment';

  @override
  String get addAttachment => 'Add receipt';

  @override
  String get removeAttachment => 'Remove attachment';

  @override
  String get cameraOption => 'Take photo';

  @override
  String get galleryOption => 'Choose from gallery';

  @override
  String get noteHint => 'Add a note (optional)...';

  @override
  String get noAccountsPrompt =>
      'Create an account first to record transactions.';

  @override
  String get clearAmount => 'Clear amount';

  @override
  String get backspace => 'Delete last digit';

  @override
  String get selectType => 'Transaction type';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get monthlyNet => 'Monthly net';

  @override
  String get expensesByCategory => 'Expenses by category';

  @override
  String get incomesByCategory => 'Income by category';

  @override
  String get sixMonthTrend => '6-month trend';

  @override
  String get seeAll => 'See all';

  @override
  String get noExpensesThisMonth => 'No expenses this month';

  @override
  String get noDataForPeriod => 'No data for this period';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String accountsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
      zero: 'No accounts',
    );
    return '$_temp0';
  }

  @override
  String get period3Months => '3 months';

  @override
  String get period6Months => '6 months';

  @override
  String get periodThisYear => 'This year';

  @override
  String get netSavings => 'Net balance';

  @override
  String get savingsRate => 'Savings rate';

  @override
  String get incomeVsExpense => 'Income vs Expenses';

  @override
  String get categoryDetails => 'Category breakdown';

  @override
  String get welcomeDashboardSubtitle =>
      'Create your first account or record a transaction to view your financial overview.';

  @override
  String get addBudget => 'Add budget';

  @override
  String get editBudget => 'Edit budget';

  @override
  String get budgetLimit => 'Monthly limit';

  @override
  String get budgetSpent => 'Spent';

  @override
  String get budgetRemaining => 'Remaining';

  @override
  String budgetOverBy(String amount) {
    return 'Over by $amount';
  }

  @override
  String get budgetTotalMonthly => 'Total monthly budget';

  @override
  String get noBudgetsSubtitle =>
      'Set a monthly limit per category to stay on track and get alerts at 80% and 100%.';

  @override
  String get budgetSaved => 'Budget saved';

  @override
  String get budgetDeleted => 'Budget deleted';

  @override
  String get budgetAlertWarningTitle => 'Budget warning (80%)';

  @override
  String get budgetAlertExceededTitle => 'Budget exceeded (100%)';

  @override
  String budgetAlertBody(
    String category,
    int percentage,
    String spent,
    String limit,
  ) {
    return '$category: $percentage% used ($spent / $limit)';
  }

  @override
  String get allCategoriesBudgeted =>
      'All your expense categories already have a budget for this month.';

  @override
  String get recurringTitle => 'Recurring transactions';

  @override
  String get manageRecurringSubtitle =>
      'Rent, subscriptions, salary auto-generated on launch';

  @override
  String get addRecurring => 'Add recurring';

  @override
  String get editRecurring => 'Edit recurring';

  @override
  String get noRecurring => 'No recurring transactions';

  @override
  String get noRecurringSubtitle =>
      'Schedule your rent, subscriptions or salary to generate them automatically when you open the app.';

  @override
  String get frequency => 'Frequency';

  @override
  String get nextDueDate => 'Next due date';

  @override
  String get endDateOptional => 'End date (optional)';

  @override
  String get noEndDate => 'No end date';

  @override
  String get recurringCreated => 'Recurring transaction saved';

  @override
  String get recurringUpdated => 'Recurring transaction updated';

  @override
  String get recurringDeleted => 'Recurring transaction deleted';

  @override
  String recurringActiveLabel(String name) {
    return 'Toggle $name';
  }

  @override
  String get recurringPaused => 'Paused';

  @override
  String get runDueNow => 'Generate due transactions';

  @override
  String recurringGeneratedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions generated',
      one: '1 transaction generated',
      zero: 'No due transactions to generate',
    );
    return '$_temp0';
  }

  @override
  String get manageGoalsSubtitle => 'Track your savings towards your projects';

  @override
  String get addGoal => 'New goal';

  @override
  String get editGoal => 'Edit goal';

  @override
  String get goalName => 'Goal name';

  @override
  String get goalNameHint => 'e.g. Emergency fund, Vacation, Car...';

  @override
  String get noGoalsSubtitle =>
      'Create savings goals with a target amount and deadline to track your progress.';

  @override
  String get goalCreated => 'Goal created successfully';

  @override
  String get goalUpdated => 'Goal updated';

  @override
  String get goalDeleted => 'Goal deleted';

  @override
  String get contribute => 'Contribute';

  @override
  String get contributeTitle => 'Add contribution';

  @override
  String get contributionAdded => 'Contribution added';

  @override
  String get goalCompleted => 'Goal reached!';

  @override
  String get deadlineOptional => 'Deadline (optional)';

  @override
  String get noDeadline => 'No deadline';

  @override
  String get linkedAccountOptional => 'Linked savings account (optional)';

  @override
  String get noLinkedAccount => 'No linked account';

  @override
  String daysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
      zero: 'Due today',
    );
    return '$_temp0';
  }

  @override
  String get deadlinePassed => 'Deadline passed';

  @override
  String get totalSaved => 'Total saved';

  @override
  String get settingsPreferencesSection => 'Preferences';

  @override
  String get settingsDataSection => 'Data';

  @override
  String get exportImportTitle => 'Export & Backup';

  @override
  String get exportImportSubtitle =>
      'CSV, PDF report and encrypted JSON backup';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get exportCsvTitle => 'Export to CSV';

  @override
  String get exportCsvSubtitle =>
      'Excel-compatible spreadsheet of all transactions';

  @override
  String get exportPdfTitle => 'Export PDF report';

  @override
  String get exportPdfSubtitle =>
      'Formatted accounts summary and transaction history';

  @override
  String get encryptedBackupSection => 'Encrypted local backup (AES-256)';

  @override
  String get backupJsonTitle => 'Create encrypted backup';

  @override
  String get backupJsonSubtitle =>
      'Exports all data into a password-protected JSON file';

  @override
  String get restoreJsonTitle => 'Restore backup';

  @override
  String get restoreJsonSubtitle =>
      'Replaces local data from an encrypted backup file';

  @override
  String get backupPasswordTitle => 'Encryption password';

  @override
  String get restorePasswordTitle => 'Backup password';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordMinLengthError =>
      'Password must be at least 6 characters.';

  @override
  String get passwordMismatchError => 'Passwords do not match.';

  @override
  String get exportSuccess => 'Export ready to share';

  @override
  String get restoreConfirmTitle => 'Restore backup?';

  @override
  String get restoreConfirmMessage =>
      'All current local data will be replaced by the backup contents.';

  @override
  String restoreSuccess(int transactions, int accounts) {
    return 'Backup restored ($transactions transactions, $accounts accounts)';
  }

  @override
  String get invalidBackupError => 'Wrong password or corrupted backup file.';

  @override
  String get settingsSecuritySection => 'Security';

  @override
  String get securityTitle => 'Security & privacy';

  @override
  String get securitySubtitle => 'PIN code, biometrics, auto-lock';

  @override
  String get pinEnabledStatus => 'PIN enabled';

  @override
  String get pinDisabledStatus => 'Disabled';

  @override
  String get enablePin => 'Enable PIN code';

  @override
  String get changePin => 'Change PIN code';

  @override
  String get disablePin => 'Disable PIN code';

  @override
  String get enterCurrentPin => 'Enter your current PIN code';

  @override
  String get enterNewPin => 'Choose a 4-digit PIN code';

  @override
  String get confirmNewPin => 'Confirm your PIN code';

  @override
  String get enterPinToUnlock => 'Enter your PIN code to unlock My money';

  @override
  String get wrongPinError => 'Incorrect PIN code. Please try again.';

  @override
  String get pinMismatchError => 'PIN codes do not match.';

  @override
  String get pinSavedSuccess => 'PIN code saved';

  @override
  String get pinRemovedSuccess => 'PIN code disabled';

  @override
  String get biometricsReason => 'Authenticate to unlock My money';

  @override
  String get biometricsSubtitle => 'Use fingerprint or Face ID';

  @override
  String get biometricsUnavailable => 'Not available on this device';

  @override
  String get useBiometrics => 'Unlock with biometrics';

  @override
  String get autoLockTimeout => 'Auto-lock timeout';

  @override
  String get autoLockImmediate => 'Immediately in background';

  @override
  String autoLockMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'After $minutes minutes',
      one: 'After 1 minute',
    );
    return '$_temp0';
  }

  @override
  String get hideInAppSwitcher => 'Hide in recent apps';

  @override
  String get hideInAppSwitcherSubtitle =>
      'Shows a privacy screen in the app switcher preview';

  @override
  String get lockNow => 'Lock now';

  @override
  String pinDigitEntered(int count, int total) {
    return '$count of $total digits entered';
  }

  @override
  String get settingsDeveloperSection => 'Developer tools (Debug)';

  @override
  String get loadDemoData => 'Load demo dataset';

  @override
  String get loadDemoDataSubtitle =>
      'Populates sample accounts, transactions, budgets, recurring rules and goals';

  @override
  String get loadDemoDataConfirmTitle => 'Load demo dataset?';

  @override
  String get loadDemoDataConfirmBody =>
      'This inserts a realistic 6-month demo dataset into the local database (debug mode only).';

  @override
  String demoDataLoaded(int accounts, int transactions) {
    return 'Demo data loaded ($accounts accounts, $transactions transactions)';
  }

  @override
  String get resetAllData => 'Reset all local data';

  @override
  String get resetAllDataSubtitle =>
      'Deletes all local records and restores default categories';

  @override
  String get resetAllDataConfirmTitle => 'Reset everything?';

  @override
  String get resetAllDataConfirmBody =>
      'All accounts, transactions, budgets, recurring items and savings goals will be permanently deleted.';

  @override
  String get allDataReset => 'All local data has been reset';

  @override
  String get aboutAppSubtitle =>
      '100% offline • Your data stays on your device';
}
