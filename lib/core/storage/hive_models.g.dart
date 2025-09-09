// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveItineraryModelAdapter extends TypeAdapter<HiveItineraryModel> {
  @override
  final int typeId = 0;

  @override
  HiveItineraryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveItineraryModel(
      id: fields[0] as String,
      title: fields[1] as String,
      startDate: fields[2] as String,
      endDate: fields[3] as String,
      days: (fields[4] as List).cast<HiveDayPlanModel>(),
      originalPrompt: fields[5] as String?,
      createdAt: fields[6] as DateTime?,
      updatedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveItineraryModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.days)
      ..writeByte(5)
      ..write(obj.originalPrompt)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveItineraryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveDayPlanModelAdapter extends TypeAdapter<HiveDayPlanModel> {
  @override
  final int typeId = 1;

  @override
  HiveDayPlanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveDayPlanModel(
      date: fields[0] as String,
      summary: fields[1] as String,
      items: (fields[2] as List).cast<HiveActivityItemModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveDayPlanModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.summary)
      ..writeByte(2)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveDayPlanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveActivityItemModelAdapter extends TypeAdapter<HiveActivityItemModel> {
  @override
  final int typeId = 2;

  @override
  HiveActivityItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveActivityItemModel(
      time: fields[0] as String,
      activity: fields[1] as String,
      location: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveActivityItemModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.activity)
      ..writeByte(2)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveActivityItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveChatMessageModelAdapter extends TypeAdapter<HiveChatMessageModel> {
  @override
  final int typeId = 3;

  @override
  HiveChatMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveChatMessageModel(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      content: fields[2] as String,
      role: fields[3] as String,
      timestamp: fields[4] as DateTime,
      messageType: fields[7] as int,
      tokenCount: fields[5] as int?,
      itinerary: fields[6] as HiveItineraryModel?,
    );
  }

  @override
  void write(BinaryWriter writer, HiveChatMessageModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.tokenCount)
      ..writeByte(6)
      ..write(obj.itinerary)
      ..writeByte(7)
      ..write(obj.messageType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveChatMessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveSessionStateAdapter extends TypeAdapter<HiveSessionState> {
  @override
  final int typeId = 4;

  @override
  HiveSessionState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveSessionState(
      sessionId: fields[0] as String,
      userId: fields[1] as String,
      createdAt: fields[2] as DateTime,
      lastUsed: fields[3] as DateTime,
      conversationHistory: (fields[4] as List).cast<HiveContentModel>(),
      userPreferences: (fields[5] as Map).cast<String, dynamic>(),
      tripContext: (fields[6] as Map).cast<String, dynamic>(),
      tokensSaved: fields[7] as int,
      messagesInSession: fields[8] as int,
      estimatedCostSavings: fields[9] as double,
      refinementCount: fields[10] as int,
      isActive: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiveSessionState obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.lastUsed)
      ..writeByte(4)
      ..write(obj.conversationHistory)
      ..writeByte(5)
      ..write(obj.userPreferences)
      ..writeByte(6)
      ..write(obj.tripContext)
      ..writeByte(7)
      ..write(obj.tokensSaved)
      ..writeByte(8)
      ..write(obj.messagesInSession)
      ..writeByte(9)
      ..write(obj.estimatedCostSavings)
      ..writeByte(10)
      ..write(obj.refinementCount)
      ..writeByte(11)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveSessionStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveContentModelAdapter extends TypeAdapter<HiveContentModel> {
  @override
  final int typeId = 5;

  @override
  HiveContentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveContentModel(
      role: fields[0] as String,
      parts: (fields[1] as List).cast<HivePartModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveContentModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.role)
      ..writeByte(1)
      ..write(obj.parts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveContentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HivePartModelAdapter extends TypeAdapter<HivePartModel> {
  @override
  final int typeId = 6;

  @override
  HivePartModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HivePartModel(
      type: fields[0] as String,
      text: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HivePartModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HivePartModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
