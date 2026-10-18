// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveContactAdapter extends TypeAdapter<HiveContact> {
  @override
  final int typeId = 10;

  @override
  HiveContact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveContact(
      id: fields[0] as String,
      displayName: fields[1] as String,
      phones: (fields[2] as List?)?.cast<HivePhone>(),
      emails: (fields[3] as List?)?.cast<HiveEmail>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveContact obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.phones)
      ..writeByte(3)
      ..write(obj.emails);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HivePhoneAdapter extends TypeAdapter<HivePhone> {
  @override
  final int typeId = 11;

  @override
  HivePhone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HivePhone(
      number: fields[0] as String,
      label: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HivePhone obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivePhoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveEmailAdapter extends TypeAdapter<HiveEmail> {
  @override
  final int typeId = 12;

  @override
  HiveEmail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveEmail(
      address: fields[0] as String,
      label: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveEmail obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.address)
      ..writeByte(1)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveEmailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
