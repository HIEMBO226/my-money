import '../../core/errors/result.dart';
import '../entities/attachment.dart';
import '../entities/transaction.dart';
import '../entities/transaction_filter.dart';

abstract interface class TransactionRepository {
  Stream<List<Transaction>> watchTransactions({
    TransactionFilter filter = const TransactionFilter(),
  });

  Future<Result<List<Transaction>>> getTransactions({
    TransactionFilter filter = const TransactionFilter(),
  });

  Future<Result<Transaction>> getTransactionById(String id);

  Future<Result<Transaction>> createTransaction(Transaction transaction);

  Future<Result<Transaction>> updateTransaction(Transaction transaction);

  Future<Result<void>> deleteTransaction(String id);

  Future<Result<List<Attachment>>> getAttachmentsForTransaction(
    String transactionId,
  );
}
