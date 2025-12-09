// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matchplayer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MatchPlayerAdapter extends TypeAdapter<MatchPlayer> {
  @override
  final int typeId = 2;

  @override
  MatchPlayer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatchPlayer(
      fName: fields[0] as String,
      lName: fields[1] as String,
      lifes: fields[3] as int,
      isInMatch: fields[5] as bool,
      number: fields[6] as int,
    )
      ..id = fields[2] as int?
      ..rank = fields[7] as int?;
  }

  @override
  void write(BinaryWriter writer, MatchPlayer obj) {
    writer
      ..writeByte(7)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.isInMatch)
      ..writeByte(6)
      ..write(obj.number)
      ..writeByte(7)
      ..write(obj.rank)
      ..writeByte(0)
      ..write(obj.fName)
      ..writeByte(1)
      ..write(obj.lName)
      ..writeByte(3)
      ..write(obj.lifes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchPlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
