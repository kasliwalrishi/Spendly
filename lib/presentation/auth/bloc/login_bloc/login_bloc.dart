import 'package:fingenie/data/auth/auth_repository.dart';
import 'package:fingenie/domain/entities/auth/create_login_request.dart';
import 'package:fingenie/presentation/auth/bloc/login_bloc/login_event.dart';
import 'package:fingenie/presentation/auth/bloc/login_bloc/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc({
    required AuthRepository authRepository,
    required dio,
  })  : _authRepository = authRepository,
        super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      final request = LoginRequest(
        email: event.email,
        password: event.password,
      );

      final user = await _authRepository.login(request);
      emit(LoginSuccess(user));
    } catch (error) {
      emit(LoginFailure(error.toString()));
    }
  }
}
