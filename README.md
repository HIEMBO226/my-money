# My money

**Smart, Private & 100% Offline Personal Finance Management**

My money is a modern, privacy-first personal finance application built with Flutter. Designed with an offline-first philosophy, all your financial records stay strictly on your device. There are no remote servers, no user accounts to create, no ads, and zero telemetry or tracking.

## Screenshots

<p align="center">
  <img src="screenshots/dashboard.png" width="220" alt="Dashboard" />
  <img src="screenshots/transactions.png" width="220" alt="Transactions" />
  <img src="screenshots/budgets.png" width="220" alt="Budgets" />
  <img src="screenshots/statistics.png" width="220" alt="Statistics" />
</p>

## Key Highlights

- **100% Offline & Private**: your financial data never leaves your smartphone.
- **Modern Material 3 Interface**: clean, premium aesthetic with smooth transitions, responsive layouts, and native Dark & Light modes.
- **Accessible (WCAG 2.1 AA)**: high-contrast palettes, comfortable tap targets (at least 48x48 dp), full screen reader support, and dynamic system text scaling.
- **Zero floating-point inaccuracies**: all monetary figures are stored in the smallest currency unit (cents/integers) for total mathematical precision.

## Core Features

### 1. Consolidated Dashboard & Financial Overview
- **Instant net worth**: prominent total balance card showing your consolidated funds across all accounts.
- **Monthly breakdown**: quick-glance summary of total income, total expenses, and net cash flow.
- **Visual charts**:
  - Expense breakdown (pie chart) by category.
  - 6-month trend (bar/line chart) of monthly cash flow.
- **Month-by-month navigation**: jump between past, present, and future periods.

### 2. Comprehensive Transaction Tracking
- **Three transaction types**: expenses, incomes, and transfers between accounts.
- **Optimized input**: built-in specialized numpad for swift amount entry.
- **Receipts & attachments**: attach photos of receipts or invoices stored locally.
- **Smart search & deep filtering**: search by keyword or filter by date range, account, category, type, or amount range.
- **Daily grouping**: transactions organized chronologically by day with daily net totals.

### 3. Multi-Account Management
- **Multiple account types**: Cash, Bank accounts, Mobile Money wallets, and Savings accounts.
- **Dynamic balances**: calculated automatically through verified local SQL aggregations.
- **Inter-account transfers**: move funds with a single recorded transaction that updates both balances simultaneously.

### 4. Custom Categories
- **Default set**: 15 pre-configured categories (10 expense and 5 income).
- **Fully customizable**: create, edit, and delete custom categories with tailored icons and colors.

### 5. Monthly Budgets & Smart Alerts
- **Category limits**: set monthly spending caps for individual categories.
- **Visual progress indicators**: progress bars with color shifts (green below 80%, amber from 80%, red from 100%).
- **Local notifications**: automatic alerts when reaching 80% or exceeding 100% of a budget.

### 6. In-Depth Financial Statistics & KPIs
- **Multiple time horizons**: current month, last 3 months, 6 months, or entire year.
- **Key performance indicators**: total income, total expenses, net savings balance, and savings rate.
- **Interactive comparison charts**: smooth curved graphs showing income vs. expense.

### 7. Automated Recurring Transactions
- **Flexible schedules**: daily, weekly, monthly, or yearly incomes and bills.
- **Smart edge-case handling**: supports leap years and end-of-month adjustments (e.g. billing on the 28th/29th of February).
- **Auto-generation**: recurring items are generated when the app launches, with an option to trigger them manually.

### 8. Savings Goals
- **Target-driven savings**: set target amounts, optional deadlines, and link goals to dedicated savings accounts.
- **Progress tracking**: clear progress percentages and remaining amounts.
- **Quick contributions**: add deposits toward your goals with a single tap.

### 9. Bank-Grade Security & Privacy
- **PIN protection**: 4 to 6-digit PIN hashed with a random salt and HMAC-SHA256 (10,000 iterations), stored in the platform's secure storage (Android Keystore / iOS Keychain).
- **Biometric unlock**: Fingerprint, Touch ID, or Face ID.
- **Auto-lock timer**: configurable delay (Immediate, 1 min, 5 min, 15 min) or instant manual lock.
- **App switcher privacy shield**: hides screen contents in the recent apps switcher (FLAG_SECURE on Android).

### 10. Data Portability, Backup & Restore
- **Encrypted JSON backups**: full backup and restore protected by a user-defined password (AES-256-CBC + HMAC-SHA256).
- **CSV export**: clean spreadsheet export (UTF-8 BOM for direct Microsoft Excel compatibility).
- **PDF financial reports**: formatted statements with embedded Unicode typography (NotoSans), full currency symbol support (EUR, USD, FCFA), and system share sheet integration.

### 11. Personalization & Settings
- **Multi-currency support**: configurable symbols and formatting (EUR, USD, XOF, XAF, GBP, CAD, CHF, MAD, TND, GNF, and more).
- **Custom date formats**: DD/MM/YYYY, MM/DD/YYYY, or YYYY-MM-DD.
- **Theme options**: Light, Dark, or Follow System.
- **Multilingual**: native English and French support.

## Getting Started

Prerequisite: [Flutter](https://docs.flutter.dev/get-started/install) installed.

```bash
git clone https://github.com/HIEMBO226/my-money.git
cd my-money
flutter pub get
flutter run
```

## Built With

- [Flutter](https://flutter.dev) / Dart
- Local SQL database (offline-first)

## License and Credits

This project is licensed under the MIT License (see the [LICENSE](LICENSE) file).

If you use or adapt this code, please keep the copyright notice and credit the author: [HIEMBO226](https://github.com/HIEMBO226)
