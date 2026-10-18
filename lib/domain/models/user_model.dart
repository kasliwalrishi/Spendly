import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 3)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String phoneNumber;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String token;

  @HiveField(6)
  final bool? isLoggedIn;

  @HiveField(7)
  final String currency;

  @HiveField(8)
  final int age;

  @HiveField(9)
  final String occupation;

  @HiveField(10)
  @JsonKey(name: 'monthly_income')
  final double monthlyIncome;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.createdAt,
    required this.token,
    this.isLoggedIn = true,
    required this.currency,
    required this.age,
    required this.occupation,
    required this.monthlyIncome,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
