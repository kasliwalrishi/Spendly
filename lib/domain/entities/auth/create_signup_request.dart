class SignUpRequest {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;

  SignUpRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
      };
}
