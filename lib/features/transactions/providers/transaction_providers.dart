import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/result.dart';
import '../../../data/database/database_provider.dart';
import '../../../data/repositories/transaction_repository_impl.dart';
import '../../../domain/entities/attachment.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/transaction_filter.dart';
import '../../../domain/enums/transaction_type.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/use_cases/transactions/create_transaction.dart';
import '../../../domain/use_cases/transactions/delete_transaction.dart';
import '../../../domain/use_cases/transactions/filter_transactions.dart';
import '../../../domain/use_cases/transactions/get_transactions.dart';
import '../../../domain/use_cases/transactions/update_transaction.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TransactionRepositoryImpl(db);
});

final getTransactionsUseCaseProvider = Provider<GetTransactions>((ref) {
  return GetTransactions(ref.watch(transactionRepositoryProvider));
});

final createTransactionUseCaseProvider = Provider<CreateTransaction>((ref) {
  return CreateTransaction(ref.watch(transactionRepositoryProvider));
});

final updateTransactionUseCaseProvider = Provider<UpdateTransaction>((ref) {
  return UpdateTransaction(ref.watch(transactionRepositoryProvider));
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransaction>((ref) {
  return DeleteTransaction(ref.watch(transactionRepositoryProvider));
});

final filterTransactionsUseCaseProvider = Provider<FilterTransactions>((ref) {
  return FilterTransactions(ref.watch(transactionRepositoryProvider));
});

class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query.trim().isEmpty ? null : query,
      clearSearchQuery: query.trim().isEmpty,
      limit: AppConstants.pageSize,
    );
  }

  void applyFilter(TransactionFilter next) {
    state = next.copyWith(limit: AppConstants.pageSize, offset: 0);
  }

  void loadMore() {
    state = state.copyWith(limit: state.limit + AppConstants.pageSize);
  }

  void reset() {
    state = const TransactionFilter();
  }
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilter>(
  TransactionFilterNotifier.new,
);

final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final filter = ref.watch(transactionFilterProvider);
  return ref.watch(getTransactionsUseCaseProvider).watch(filter: filter);
});

final transactionControllerProvider = Provider<TransactionController>((ref) {
  return TransactionController(
    ref.watch(createTransactionUseCaseProvider),
    ref.watch(updateTransactionUseCaseProvider),
    ref.watch(deleteTransactionUseCaseProvider),
  );
});

class TransactionController {
  const TransactionController(
    this._createTransaction,
    this._updateTransaction,
    this._deleteTransaction,
  );

  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;

  Future<Result<Transaction>> create({
    required TransactionType type,
    required int amount,
    required DateTime date,
    required String accountId,
    String? categoryId,
    String? toAccountId,
    String? note,
    List<Attachment> attachments = const [],
  }) {
    return _createTransaction(
      type: type,
      amount: amount,
      date: date,
      accountId: accountId,
      categoryId: categoryId,
      toAccountId: toAccountId,
      note: note,
      attachments: attachments,
    );
  }

  Future<Result<Transaction>> update(Transaction transaction) =>
      _updateTransaction(transaction);

  Future<Result<void>> delete(String id) => _deleteTransaction(id);
}
