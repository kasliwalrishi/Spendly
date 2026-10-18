abstract class SignUpEvent {}

class SignUpSubmitted extends SignUpEvent {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;

  SignUpSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
  });
}
