import 'package:fingenie/data/auth/auth_repository.dart';
import 'package:fingenie/domain/entities/auth/create_signup_request.dart';
import 'package:fingenie/presentation/auth/bloc/signup_bloc/signup_event.dart';
import 'package:fingenie/presentation/auth/bloc/signup_bloc/signup_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository _authRepository;

  SignUpBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(SignUpInitial()) {
    on<SignUpSubmitted>(_onSignUpSubmitted);
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());

    try {
      final request = SignUpRequest(
        name: event.name,
        email: event.email,
        password: event.password,
        phoneNumber: event.phoneNumber,
      );

      final user = await _authRepository.signUp(request);
      emit(SignUpSuccess(user));
    } catch (error) {
      emit(SignUpFailure(error.toString()));
    }
  }
}
