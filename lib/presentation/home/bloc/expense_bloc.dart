// expense_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<SettleExpense>(_onSettleExpense);
  }

  Future<void> _onLoadExpenses(
      LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      // final expenses = await repository.getExpenses();
      // final expenses = await repository.getExpenses();
      final expenses = <int>[]; // Replace with actual data fetching logic
      emit(ExpenseLoaded(expenses));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onAddExpense(
      AddExpense event, Emitter<ExpenseState> emit) async {
    // Implementation
  }

  Future<void> _onSettleExpense(
      SettleExpense event, Emitter<ExpenseState> emit) async {
    // Implementation
  }
}

// expense_event.dart
abstract class ExpenseEvent {}

class LoadExpenses extends ExpenseEvent {}

class AddExpense extends ExpenseEvent {
  // final Expense expense;
  // AddExpense(this.expense);
}

class SettleExpense extends ExpenseEvent {
  final String expenseId;
  SettleExpense(this.expenseId);
}

// expense_state.dart
abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<int> expenses;
  ExpenseLoaded(this.expenses);
}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}
