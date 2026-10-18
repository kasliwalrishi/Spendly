// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 3;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      phoneNumber: fields[3] as String,
      createdAt: fields[4] as DateTime,
      token: fields[5] as String,
      isLoggedIn: fields[6] as bool?,
      currency: fields[7] as String,
      age: fields[8] as int,
      occupation: fields[9] as String,
      monthlyIncome: fields[10] as double,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.token)
      ..writeByte(6)
      ..write(obj.isLoggedIn)
      ..writeByte(7)
      ..write(obj.currency)
      ..writeByte(8)
      ..write(obj.age)
      ..writeByte(9)
      ..write(obj.occupation)
      ..writeByte(10)
      ..write(obj.monthlyIncome);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      token: json['token'] as String,
      isLoggedIn: json['isLoggedIn'] as bool? ?? true,
      currency: json['currency'] as String,
      age: (json['age'] as num).toInt(),
      occupation: json['occupation'] as String,
      monthlyIncome: (json['monthly_income'] as num).toDouble(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'createdAt': instance.createdAt.toIso8601String(),
      'token': instance.token,
      'isLoggedIn': instance.isLoggedIn,
      'currency': instance.currency,
      'age': instance.age,
      'occupation': instance.occupation,
      'monthly_income': instance.monthlyIncome,
    };
