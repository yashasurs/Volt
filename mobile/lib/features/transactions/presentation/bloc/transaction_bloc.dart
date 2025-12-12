import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/delete_transaction_usecase.dart';
import '../../domain/usecases/extract_transaction_from_image_usecase.dart';
import '../../domain/usecases/get_transaction_usecase.dart';
import '../../domain/usecases/get_transactions_by_date_range_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/update_transaction_usecase.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final GetTransactionsByDateRangeUseCase getTransactionsByDateRangeUseCase;
  final GetTransactionUseCase getTransactionUseCase;
  final CreateTransactionUseCase createTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;
  final ExtractTransactionFromImageUseCase extractTransactionFromImageUseCase;

  TransactionBloc({
    required this.getTransactionsUseCase,
    required this.getTransactionsByDateRangeUseCase,
    required this.getTransactionUseCase,
    required this.createTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.extractTransactionFromImageUseCase,
  }) : super(TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<LoadTransactionsByDateRangeEvent>(_onLoadTransactionsByDateRange);
    on<RefreshTransactionsEvent>(_onRefreshTransactions);
    on<LoadTransactionEvent>(_onLoadTransaction);
    on<CreateTransactionEvent>(_onCreateTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<ExtractTransactionFromImageEvent>(_onExtractTransactionFromImage);
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await getTransactionsUseCase(
      GetTransactionsParams(
        skip: event.skip,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionsLoaded(transactions)),
    );
  }

  Future<void> _onLoadTransactionsByDateRange(
    LoadTransactionsByDateRangeEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await getTransactionsByDateRangeUseCase(
      GetTransactionsByDateRangeParams(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionsLoaded(transactions)),
    );
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await getTransactionsUseCase(
      GetTransactionsParams(),
    );

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionsLoaded(transactions)),
    );
  }

  Future<void> _onLoadTransaction(
    LoadTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await getTransactionUseCase(event.transactionId);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transaction) => emit(TransactionLoaded(transaction)),
    );
  }

  Future<void> _onCreateTransaction(
    CreateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await createTransactionUseCase(
      CreateTransactionParams(
        userId: event.userId,
        amount: event.amount,
        type: event.type,
        merchant: event.merchant,
        category: event.category,
        upiId: event.upiId,
        transactionId: event.transactionId,
        timestamp: event.timestamp,
        balance: event.balance,
        bankName: event.bankName,
        accountNumber: event.accountNumber,
        rawMessage: event.rawMessage,
      ),
    );

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transaction) {
        emit(TransactionCreated(transaction));
        // Reload transactions after creation
        add(const LoadTransactionsEvent());
      },
    );
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await updateTransactionUseCase(
      UpdateTransactionParams(
        transactionId: event.transactionId,
        userId: event.userId,
        amount: event.amount,
        type: event.type,
        merchant: event.merchant,
        category: event.category,
        upiId: event.upiId,
        transactionReferenceId: event.transactionReferenceId,
        timestamp: event.timestamp,
        balance: event.balance,
        bankName: event.bankName,
        accountNumber: event.accountNumber,
        rawMessage: event.rawMessage,
      ),
    );

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transaction) {
        emit(TransactionUpdated(transaction));
        // Reload transactions after update
        add(const LoadTransactionsEvent());
      },
    );
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await deleteTransactionUseCase(event.transactionId);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) {
        emit(TransactionDeleted(event.transactionId));
        // Reload transactions after deletion
        add(const LoadTransactionsEvent());
      },
    );
  }

  Future<void> _onExtractTransactionFromImage(
    ExtractTransactionFromImageEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await extractTransactionFromImageUseCase(event.imageFile);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transaction) => emit(TransactionExtractedFromImage(transaction)),
    );
  }
}

