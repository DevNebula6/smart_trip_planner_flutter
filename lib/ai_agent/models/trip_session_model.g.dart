// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_session_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTripPlanningSessionCollection on Isar {
  IsarCollection<TripPlanningSession> get tripPlanningSessions =>
      this.collection();
}

const TripPlanningSessionSchema = CollectionSchema(
  name: r'TripPlanningSession',
  id: -5354272340195553416,
  properties: {
    r'conversationHistoryJson': PropertySchema(
      id: 0,
      name: r'conversationHistoryJson',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'estimatedCostSavings': PropertySchema(
      id: 2,
      name: r'estimatedCostSavings',
      type: IsarType.double,
    ),
    r'isActive': PropertySchema(
      id: 3,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isValid': PropertySchema(
      id: 4,
      name: r'isValid',
      type: IsarType.bool,
    ),
    r'lastError': PropertySchema(
      id: 5,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'lastReset': PropertySchema(
      id: 6,
      name: r'lastReset',
      type: IsarType.dateTime,
    ),
    r'lastUsed': PropertySchema(
      id: 7,
      name: r'lastUsed',
      type: IsarType.dateTime,
    ),
    r'messagesInSession': PropertySchema(
      id: 8,
      name: r'messagesInSession',
      type: IsarType.long,
    ),
    r'needsCleanup': PropertySchema(
      id: 9,
      name: r'needsCleanup',
      type: IsarType.bool,
    ),
    r'refinementCount': PropertySchema(
      id: 10,
      name: r'refinementCount',
      type: IsarType.long,
    ),
    r'refinementPatternsJson': PropertySchema(
      id: 11,
      name: r'refinementPatternsJson',
      type: IsarType.string,
    ),
    r'sessionAgeHours': PropertySchema(
      id: 12,
      name: r'sessionAgeHours',
      type: IsarType.double,
    ),
    r'sessionId': PropertySchema(
      id: 13,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'tokenEfficiency': PropertySchema(
      id: 14,
      name: r'tokenEfficiency',
      type: IsarType.double,
    ),
    r'tokensSaved': PropertySchema(
      id: 15,
      name: r'tokensSaved',
      type: IsarType.long,
    ),
    r'tripContextJson': PropertySchema(
      id: 16,
      name: r'tripContextJson',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 17,
      name: r'userId',
      type: IsarType.string,
    ),
    r'userPreferencesJson': PropertySchema(
      id: 18,
      name: r'userPreferencesJson',
      type: IsarType.string,
    ),
    r'version': PropertySchema(
      id: 19,
      name: r'version',
      type: IsarType.string,
    )
  },
  estimateSize: _tripPlanningSessionEstimateSize,
  serialize: _tripPlanningSessionSerialize,
  deserialize: _tripPlanningSessionDeserialize,
  deserializeProp: _tripPlanningSessionDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _tripPlanningSessionGetId,
  getLinks: _tripPlanningSessionGetLinks,
  attach: _tripPlanningSessionAttach,
  version: '3.1.0+1',
);

int _tripPlanningSessionEstimateSize(
  TripPlanningSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.conversationHistoryJson.length * 3;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.refinementPatternsJson.length * 3;
  bytesCount += 3 + object.sessionId.length * 3;
  bytesCount += 3 + object.tripContextJson.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  bytesCount += 3 + object.userPreferencesJson.length * 3;
  bytesCount += 3 + object.version.length * 3;
  return bytesCount;
}

void _tripPlanningSessionSerialize(
  TripPlanningSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.conversationHistoryJson);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDouble(offsets[2], object.estimatedCostSavings);
  writer.writeBool(offsets[3], object.isActive);
  writer.writeBool(offsets[4], object.isValid);
  writer.writeString(offsets[5], object.lastError);
  writer.writeDateTime(offsets[6], object.lastReset);
  writer.writeDateTime(offsets[7], object.lastUsed);
  writer.writeLong(offsets[8], object.messagesInSession);
  writer.writeBool(offsets[9], object.needsCleanup);
  writer.writeLong(offsets[10], object.refinementCount);
  writer.writeString(offsets[11], object.refinementPatternsJson);
  writer.writeDouble(offsets[12], object.sessionAgeHours);
  writer.writeString(offsets[13], object.sessionId);
  writer.writeDouble(offsets[14], object.tokenEfficiency);
  writer.writeLong(offsets[15], object.tokensSaved);
  writer.writeString(offsets[16], object.tripContextJson);
  writer.writeString(offsets[17], object.userId);
  writer.writeString(offsets[18], object.userPreferencesJson);
  writer.writeString(offsets[19], object.version);
}

TripPlanningSession _tripPlanningSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TripPlanningSession();
  object.conversationHistoryJson = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.estimatedCostSavings = reader.readDouble(offsets[2]);
  object.isActive = reader.readBool(offsets[3]);
  object.isarId = id;
  object.lastError = reader.readStringOrNull(offsets[5]);
  object.lastReset = reader.readDateTimeOrNull(offsets[6]);
  object.lastUsed = reader.readDateTimeOrNull(offsets[7]);
  object.messagesInSession = reader.readLong(offsets[8]);
  object.refinementCount = reader.readLong(offsets[10]);
  object.refinementPatternsJson = reader.readString(offsets[11]);
  object.sessionId = reader.readString(offsets[13]);
  object.tokensSaved = reader.readLong(offsets[15]);
  object.tripContextJson = reader.readString(offsets[16]);
  object.userId = reader.readString(offsets[17]);
  object.userPreferencesJson = reader.readString(offsets[18]);
  object.version = reader.readString(offsets[19]);
  return object;
}

P _tripPlanningSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tripPlanningSessionGetId(TripPlanningSession object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _tripPlanningSessionGetLinks(
    TripPlanningSession object) {
  return [];
}

void _tripPlanningSessionAttach(
    IsarCollection<dynamic> col, Id id, TripPlanningSession object) {
  object.isarId = id;
}

extension TripPlanningSessionByIndex on IsarCollection<TripPlanningSession> {
  Future<TripPlanningSession?> getBySessionId(String sessionId) {
    return getByIndex(r'sessionId', [sessionId]);
  }

  TripPlanningSession? getBySessionIdSync(String sessionId) {
    return getByIndexSync(r'sessionId', [sessionId]);
  }

  Future<bool> deleteBySessionId(String sessionId) {
    return deleteByIndex(r'sessionId', [sessionId]);
  }

  bool deleteBySessionIdSync(String sessionId) {
    return deleteByIndexSync(r'sessionId', [sessionId]);
  }

  Future<List<TripPlanningSession?>> getAllBySessionId(
      List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'sessionId', values);
  }

  List<TripPlanningSession?> getAllBySessionIdSync(
      List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sessionId', values);
  }

  Future<int> deleteAllBySessionId(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sessionId', values);
  }

  int deleteAllBySessionIdSync(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sessionId', values);
  }

  Future<Id> putBySessionId(TripPlanningSession object) {
    return putByIndex(r'sessionId', object);
  }

  Id putBySessionIdSync(TripPlanningSession object, {bool saveLinks = true}) {
    return putByIndexSync(r'sessionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySessionId(List<TripPlanningSession> objects) {
    return putAllByIndex(r'sessionId', objects);
  }

  List<Id> putAllBySessionIdSync(List<TripPlanningSession> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'sessionId', objects, saveLinks: saveLinks);
  }
}

extension TripPlanningSessionQueryWhereSort
    on QueryBuilder<TripPlanningSession, TripPlanningSession, QWhere> {
  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TripPlanningSessionQueryWhere
    on QueryBuilder<TripPlanningSession, TripPlanningSession, QWhereClause> {
  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterWhereClause>
      sessionIdEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId',
        value: [sessionId],
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterWhereClause>
      sessionIdNotEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterWhereClause>
      userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TripPlanningSessionQueryFilter on QueryBuilder<TripPlanningSession,
    TripPlanningSession, QFilterCondition> {
  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      conversationHistoryJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationHistoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      conversationHistoryJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conversationHistoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      conversationHistoryJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conversationHistoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      conversationHistoryJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conversationHistoryJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      conversationHistoryJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'conversationHistoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      conversationHistoryJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'conversationHistoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      conversationHistoryJsonContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'conversationHistoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      conversationHistoryJsonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'conversationHistoryJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      conversationHistoryJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationHistoryJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      conversationHistoryJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'conversationHistoryJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      estimatedCostSavingsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estimatedCostSavings',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      estimatedCostSavingsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estimatedCostSavings',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      estimatedCostSavingsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estimatedCostSavings',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      estimatedCostSavingsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estimatedCostSavings',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      isValidEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isValid',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastResetIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastReset',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastResetIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastReset',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastResetEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReset',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastResetGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReset',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastResetLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReset',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastResetBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastUsedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUsed',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastUsedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUsed',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastUsedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastUsedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastUsedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      lastUsedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUsed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      messagesInSessionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messagesInSession',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      messagesInSessionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'messagesInSession',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      messagesInSessionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'messagesInSession',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      messagesInSessionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'messagesInSession',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      needsCleanupEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needsCleanup',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      refinementCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refinementCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      refinementCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'refinementCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      refinementCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'refinementCount',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      refinementCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'refinementCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      refinementPatternsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refinementPatternsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      refinementPatternsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'refinementPatternsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      refinementPatternsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'refinementPatternsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      refinementPatternsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'refinementPatternsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      refinementPatternsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'refinementPatternsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      refinementPatternsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'refinementPatternsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      refinementPatternsJsonContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'refinementPatternsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      refinementPatternsJsonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'refinementPatternsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      refinementPatternsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'refinementPatternsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      refinementPatternsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'refinementPatternsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      sessionAgeHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionAgeHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      sessionAgeHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionAgeHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      sessionAgeHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionAgeHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      sessionAgeHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionAgeHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      sessionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      sessionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      sessionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      sessionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      sessionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      sessionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sessionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tokenEfficiencyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tokenEfficiency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tokenEfficiencyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tokenEfficiency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tokenEfficiencyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tokenEfficiency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tokenEfficiencyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tokenEfficiency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tokensSavedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tokensSaved',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tokensSavedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tokensSaved',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tokensSavedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tokensSaved',
        value: value,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tokensSavedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tokensSaved',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tripContextJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tripContextJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tripContextJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tripContextJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tripContextJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tripContextJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tripContextJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tripContextJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tripContextJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tripContextJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tripContextJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tripContextJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tripContextJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tripContextJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tripContextJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tripContextJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tripContextJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tripContextJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      tripContextJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tripContextJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userPreferencesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userPreferencesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userPreferencesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userPreferencesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userPreferencesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userPreferencesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userPreferencesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userPreferencesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userPreferencesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userPreferencesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userPreferencesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userPreferencesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userPreferencesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userPreferencesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userPreferencesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userPreferencesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userPreferencesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userPreferencesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      userPreferencesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userPreferencesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      versionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      versionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      versionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      versionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      versionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      versionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      versionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      versionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'version',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      versionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: '',
      ));
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterFilterCondition>
      versionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'version',
        value: '',
      ));
    });
  }
}

extension TripPlanningSessionQueryObject on QueryBuilder<TripPlanningSession,
    TripPlanningSession, QFilterCondition> {}

extension TripPlanningSessionQueryLinks on QueryBuilder<TripPlanningSession,
    TripPlanningSession, QFilterCondition> {}

extension TripPlanningSessionQuerySortBy
    on QueryBuilder<TripPlanningSession, TripPlanningSession, QSortBy> {
  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByConversationHistoryJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationHistoryJson', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByConversationHistoryJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationHistoryJson', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByEstimatedCostSavings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedCostSavings', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByEstimatedCostSavingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedCostSavings', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByIsValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isValid', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByIsValidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isValid', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByLastReset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReset', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByLastResetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReset', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByLastUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByMessagesInSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messagesInSession', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByMessagesInSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messagesInSession', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByNeedsCleanup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsCleanup', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByNeedsCleanupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsCleanup', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByRefinementCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refinementCount', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByRefinementCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refinementCount', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByRefinementPatternsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refinementPatternsJson', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByRefinementPatternsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refinementPatternsJson', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortBySessionAgeHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionAgeHours', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortBySessionAgeHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionAgeHours', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByTokenEfficiency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenEfficiency', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByTokenEfficiencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenEfficiency', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByTokensSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokensSaved', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByTokensSavedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokensSaved', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByTripContextJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripContextJson', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByTripContextJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripContextJson', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByUserPreferencesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userPreferencesJson', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByUserPreferencesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userPreferencesJson', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension TripPlanningSessionQuerySortThenBy
    on QueryBuilder<TripPlanningSession, TripPlanningSession, QSortThenBy> {
  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByConversationHistoryJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationHistoryJson', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByConversationHistoryJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationHistoryJson', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByEstimatedCostSavings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedCostSavings', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByEstimatedCostSavingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedCostSavings', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByIsValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isValid', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByIsValidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isValid', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByLastReset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReset', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByLastResetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReset', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByLastUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsed', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByMessagesInSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messagesInSession', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByMessagesInSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messagesInSession', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByNeedsCleanup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsCleanup', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByNeedsCleanupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsCleanup', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByRefinementCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refinementCount', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByRefinementCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refinementCount', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByRefinementPatternsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refinementPatternsJson', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByRefinementPatternsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'refinementPatternsJson', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenBySessionAgeHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionAgeHours', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenBySessionAgeHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionAgeHours', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByTokenEfficiency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenEfficiency', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByTokenEfficiencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokenEfficiency', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByTokensSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokensSaved', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByTokensSavedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tokensSaved', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByTripContextJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripContextJson', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByTripContextJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tripContextJson', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByUserPreferencesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userPreferencesJson', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByUserPreferencesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userPreferencesJson', Sort.desc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QAfterSortBy>
      thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension TripPlanningSessionQueryWhereDistinct
    on QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct> {
  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByConversationHistoryJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conversationHistoryJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByEstimatedCostSavings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estimatedCostSavings');
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByIsValid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isValid');
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByLastError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByLastReset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReset');
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByLastUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUsed');
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByMessagesInSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messagesInSession');
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByNeedsCleanup() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needsCleanup');
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByRefinementCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'refinementCount');
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByRefinementPatternsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'refinementPatternsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctBySessionAgeHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionAgeHours');
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctBySessionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByTokenEfficiency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tokenEfficiency');
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByTokensSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tokensSaved');
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByTripContextJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tripContextJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByUserPreferencesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userPreferencesJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TripPlanningSession, TripPlanningSession, QDistinct>
      distinctByVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version', caseSensitive: caseSensitive);
    });
  }
}

extension TripPlanningSessionQueryProperty
    on QueryBuilder<TripPlanningSession, TripPlanningSession, QQueryProperty> {
  QueryBuilder<TripPlanningSession, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<TripPlanningSession, String, QQueryOperations>
      conversationHistoryJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conversationHistoryJson');
    });
  }

  QueryBuilder<TripPlanningSession, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TripPlanningSession, double, QQueryOperations>
      estimatedCostSavingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estimatedCostSavings');
    });
  }

  QueryBuilder<TripPlanningSession, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<TripPlanningSession, bool, QQueryOperations> isValidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isValid');
    });
  }

  QueryBuilder<TripPlanningSession, String?, QQueryOperations>
      lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<TripPlanningSession, DateTime?, QQueryOperations>
      lastResetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReset');
    });
  }

  QueryBuilder<TripPlanningSession, DateTime?, QQueryOperations>
      lastUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUsed');
    });
  }

  QueryBuilder<TripPlanningSession, int, QQueryOperations>
      messagesInSessionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messagesInSession');
    });
  }

  QueryBuilder<TripPlanningSession, bool, QQueryOperations>
      needsCleanupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needsCleanup');
    });
  }

  QueryBuilder<TripPlanningSession, int, QQueryOperations>
      refinementCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'refinementCount');
    });
  }

  QueryBuilder<TripPlanningSession, String, QQueryOperations>
      refinementPatternsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'refinementPatternsJson');
    });
  }

  QueryBuilder<TripPlanningSession, double, QQueryOperations>
      sessionAgeHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionAgeHours');
    });
  }

  QueryBuilder<TripPlanningSession, String, QQueryOperations>
      sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<TripPlanningSession, double, QQueryOperations>
      tokenEfficiencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tokenEfficiency');
    });
  }

  QueryBuilder<TripPlanningSession, int, QQueryOperations>
      tokensSavedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tokensSaved');
    });
  }

  QueryBuilder<TripPlanningSession, String, QQueryOperations>
      tripContextJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tripContextJson');
    });
  }

  QueryBuilder<TripPlanningSession, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<TripPlanningSession, String, QQueryOperations>
      userPreferencesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userPreferencesJson');
    });
  }

  QueryBuilder<TripPlanningSession, String, QQueryOperations>
      versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTripSessionMetadataCollection on Isar {
  IsarCollection<TripSessionMetadata> get tripSessionMetadatas =>
      this.collection();
}

const TripSessionMetadataSchema = CollectionSchema(
  name: r'TripSessionMetadata',
  id: -1788435992356349115,
  properties: {
    r'lastCleanup': PropertySchema(
      id: 0,
      name: r'lastCleanup',
      type: IsarType.dateTime,
    ),
    r'reuseEfficiency': PropertySchema(
      id: 1,
      name: r'reuseEfficiency',
      type: IsarType.double,
    ),
    r'totalCostSavings': PropertySchema(
      id: 2,
      name: r'totalCostSavings',
      type: IsarType.double,
    ),
    r'totalSessionsCreated': PropertySchema(
      id: 3,
      name: r'totalSessionsCreated',
      type: IsarType.long,
    ),
    r'totalSessionsReused': PropertySchema(
      id: 4,
      name: r'totalSessionsReused',
      type: IsarType.long,
    ),
    r'totalTokensSaved': PropertySchema(
      id: 5,
      name: r'totalTokensSaved',
      type: IsarType.double,
    ),
    r'userId': PropertySchema(
      id: 6,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _tripSessionMetadataEstimateSize,
  serialize: _tripSessionMetadataSerialize,
  deserialize: _tripSessionMetadataDeserialize,
  deserializeProp: _tripSessionMetadataDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _tripSessionMetadataGetId,
  getLinks: _tripSessionMetadataGetLinks,
  attach: _tripSessionMetadataAttach,
  version: '3.1.0+1',
);

int _tripSessionMetadataEstimateSize(
  TripSessionMetadata object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _tripSessionMetadataSerialize(
  TripSessionMetadata object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastCleanup);
  writer.writeDouble(offsets[1], object.reuseEfficiency);
  writer.writeDouble(offsets[2], object.totalCostSavings);
  writer.writeLong(offsets[3], object.totalSessionsCreated);
  writer.writeLong(offsets[4], object.totalSessionsReused);
  writer.writeDouble(offsets[5], object.totalTokensSaved);
  writer.writeString(offsets[6], object.userId);
}

TripSessionMetadata _tripSessionMetadataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TripSessionMetadata();
  object.isarId = id;
  object.lastCleanup = reader.readDateTime(offsets[0]);
  object.totalCostSavings = reader.readDouble(offsets[2]);
  object.totalSessionsCreated = reader.readLong(offsets[3]);
  object.totalSessionsReused = reader.readLong(offsets[4]);
  object.totalTokensSaved = reader.readDouble(offsets[5]);
  object.userId = reader.readString(offsets[6]);
  return object;
}

P _tripSessionMetadataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tripSessionMetadataGetId(TripSessionMetadata object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _tripSessionMetadataGetLinks(
    TripSessionMetadata object) {
  return [];
}

void _tripSessionMetadataAttach(
    IsarCollection<dynamic> col, Id id, TripSessionMetadata object) {
  object.isarId = id;
}

extension TripSessionMetadataQueryWhereSort
    on QueryBuilder<TripSessionMetadata, TripSessionMetadata, QWhere> {
  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TripSessionMetadataQueryWhere
    on QueryBuilder<TripSessionMetadata, TripSessionMetadata, QWhereClause> {
  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TripSessionMetadataQueryFilter on QueryBuilder<TripSessionMetadata,
    TripSessionMetadata, QFilterCondition> {
  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      lastCleanupEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCleanup',
        value: value,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      lastCleanupGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCleanup',
        value: value,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      lastCleanupLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCleanup',
        value: value,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      lastCleanupBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCleanup',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      reuseEfficiencyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reuseEfficiency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      reuseEfficiencyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reuseEfficiency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      reuseEfficiencyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reuseEfficiency',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      reuseEfficiencyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reuseEfficiency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalCostSavingsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCostSavings',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalCostSavingsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCostSavings',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalCostSavingsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCostSavings',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalCostSavingsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCostSavings',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalSessionsCreatedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSessionsCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalSessionsCreatedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSessionsCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalSessionsCreatedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSessionsCreated',
        value: value,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalSessionsCreatedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSessionsCreated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalSessionsReusedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalSessionsReused',
        value: value,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalSessionsReusedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalSessionsReused',
        value: value,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalSessionsReusedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalSessionsReused',
        value: value,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalSessionsReusedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalSessionsReused',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalTokensSavedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalTokensSaved',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalTokensSavedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalTokensSaved',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalTokensSavedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalTokensSaved',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      totalTokensSavedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalTokensSaved',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension TripSessionMetadataQueryObject on QueryBuilder<TripSessionMetadata,
    TripSessionMetadata, QFilterCondition> {}

extension TripSessionMetadataQueryLinks on QueryBuilder<TripSessionMetadata,
    TripSessionMetadata, QFilterCondition> {}

extension TripSessionMetadataQuerySortBy
    on QueryBuilder<TripSessionMetadata, TripSessionMetadata, QSortBy> {
  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      sortByLastCleanup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCleanup', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      sortByLastCleanupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCleanup', Sort.desc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      sortByReuseEfficiency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reuseEfficiency', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      sortByReuseEfficiencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reuseEfficiency', Sort.desc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      sortByTotalCostSavings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCostSavings', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      sortByTotalCostSavingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCostSavings', Sort.desc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      sortByTotalSessionsCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsCreated', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      sortByTotalSessionsCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsCreated', Sort.desc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      sortByTotalSessionsReused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsReused', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      sortByTotalSessionsReusedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsReused', Sort.desc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      sortByTotalTokensSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTokensSaved', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      sortByTotalTokensSavedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTokensSaved', Sort.desc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension TripSessionMetadataQuerySortThenBy
    on QueryBuilder<TripSessionMetadata, TripSessionMetadata, QSortThenBy> {
  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByLastCleanup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCleanup', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByLastCleanupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCleanup', Sort.desc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByReuseEfficiency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reuseEfficiency', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByReuseEfficiencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reuseEfficiency', Sort.desc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByTotalCostSavings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCostSavings', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByTotalCostSavingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCostSavings', Sort.desc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByTotalSessionsCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsCreated', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByTotalSessionsCreatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsCreated', Sort.desc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByTotalSessionsReused() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsReused', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByTotalSessionsReusedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalSessionsReused', Sort.desc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByTotalTokensSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTokensSaved', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByTotalTokensSavedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalTokensSaved', Sort.desc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension TripSessionMetadataQueryWhereDistinct
    on QueryBuilder<TripSessionMetadata, TripSessionMetadata, QDistinct> {
  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QDistinct>
      distinctByLastCleanup() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCleanup');
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QDistinct>
      distinctByReuseEfficiency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reuseEfficiency');
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QDistinct>
      distinctByTotalCostSavings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCostSavings');
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QDistinct>
      distinctByTotalSessionsCreated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSessionsCreated');
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QDistinct>
      distinctByTotalSessionsReused() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalSessionsReused');
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QDistinct>
      distinctByTotalTokensSaved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalTokensSaved');
    });
  }

  QueryBuilder<TripSessionMetadata, TripSessionMetadata, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension TripSessionMetadataQueryProperty
    on QueryBuilder<TripSessionMetadata, TripSessionMetadata, QQueryProperty> {
  QueryBuilder<TripSessionMetadata, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<TripSessionMetadata, DateTime, QQueryOperations>
      lastCleanupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCleanup');
    });
  }

  QueryBuilder<TripSessionMetadata, double, QQueryOperations>
      reuseEfficiencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reuseEfficiency');
    });
  }

  QueryBuilder<TripSessionMetadata, double, QQueryOperations>
      totalCostSavingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCostSavings');
    });
  }

  QueryBuilder<TripSessionMetadata, int, QQueryOperations>
      totalSessionsCreatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSessionsCreated');
    });
  }

  QueryBuilder<TripSessionMetadata, int, QQueryOperations>
      totalSessionsReusedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalSessionsReused');
    });
  }

  QueryBuilder<TripSessionMetadata, double, QQueryOperations>
      totalTokensSavedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalTokensSaved');
    });
  }

  QueryBuilder<TripSessionMetadata, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
