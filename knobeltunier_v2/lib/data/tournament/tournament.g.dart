// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TournamentAdapter extends TypeAdapter<Tournament> {
  @override
  final int typeId = 3;

  @override
  Tournament read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tournament(
      name: fields[1] as String,
      ticketCount: fields[0] as int,
      matchLength: fields[3] as int,
    )
      .._players = (fields[4] as List).cast<Player>()
      .._matches = (fields[5] as List).cast<TournamentMatch>()
      .._places = (fields[6] as List).cast<MatchPlace>()
      .._matchPlayers = (fields[7] as List).cast<MatchPlayer>();
  }

  @override
  void write(BinaryWriter writer, Tournament obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.ticketCount)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.matchLength)
      ..writeByte(4)
      ..write(obj._players)
      ..writeByte(5)
      ..write(obj._matches)
      ..writeByte(6)
      ..write(obj._places)
      ..writeByte(7)
      ..write(obj._matchPlayers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
