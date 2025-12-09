// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_place.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MatchPlaceAdapter extends TypeAdapter<MatchPlace> {
  @override
  final int typeId = 4;

  @override
  MatchPlace read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatchPlace(
      startime: fields[0] as DateTime,
      matchLength: fields[1] as int,
      name: fields[2] as String,
      id: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, MatchPlace obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.startime)
      ..writeByte(1)
      ..write(obj.matchLength)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchPlaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
