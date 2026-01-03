// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CashAdapter extends TypeAdapter<Cash> {
  @override
  final int typeId = 1;

  @override
  Cash read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cash(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      name: fields[2] as String,
      value: fields[3] as double,
      currency: fields[4] as String,
      isIncome: fields[5] as bool,
      itemsList: (fields[6] as List).cast<ValueItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, Cash obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.value)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.isIncome)
      ..writeByte(6)
      ..write(obj.itemsList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
