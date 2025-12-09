// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TournamentMatchAdapter extends TypeAdapter<TournamentMatch> {
  @override
  final int typeId = 1;

  @override
  TournamentMatch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TournamentMatch(
      player1: fields[0] as MatchPlayer,
      player2: fields[1] as MatchPlayer,
      place: fields[4] as String?,
      time: fields[5] as DateTime?,
      id: fields[6] as int?,
      matchNr: fields[7] as int,
    )
      ..winner = fields[2] as MatchPlayer?
      ..loser = fields[3] as MatchPlayer?;
  }

  @override
  void write(BinaryWriter writer, TournamentMatch obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.player1)
      ..writeByte(1)
      ..write(obj.player2)
      ..writeByte(2)
      ..write(obj.winner)
      ..writeByte(3)
      ..write(obj.loser)
      ..writeByte(4)
      ..write(obj.place)
      ..writeByte(5)
      ..write(obj.time)
      ..writeByte(6)
      ..write(obj.id)
      ..writeByte(7)
      ..write(obj.matchNr);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentMatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
