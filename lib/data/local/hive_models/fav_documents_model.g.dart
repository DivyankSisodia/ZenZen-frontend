// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fav_documents_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavDocumentAdapter extends TypeAdapter<FavDocument> {
  @override
  final int typeId = 1;

  @override
  FavDocument read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavDocument(
      title: fields[0] as String,
      projectId: fields[1] as String,
      id: fields[2] as String,
      description: fields[3] as String?,
      createdAt: fields[5] as DateTime,
      admin: fields[6] as LocalUser?,
    );
  }

  @override
  void write(BinaryWriter writer, FavDocument obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.admin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavDocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
