// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'value_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ValueItemAdapter extends TypeAdapter<ValueItem> {
  @override
  final int typeId = 0;

  @override
  ValueItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final rawCategory = fields[4];
    List<String> categories;
    if (rawCategory is String) {
      categories = rawCategory.isEmpty ? <String>[] : <String>[rawCategory];
    } else if (rawCategory is Iterable) {
      categories = List<String>.from(rawCategory.whereType<String>());
    } else {
      categories = <String>[];
    }
    return ValueItem(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      name: fields[2] as String,
      value: fields[3] as double,
      categories: categories,
    );
  }

  @override
  void write(BinaryWriter writer, ValueItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.value)
      ..writeByte(4)
      ..write(obj.categories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
