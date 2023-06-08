// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $ThreadsTable extends Threads with TableInfo<$ThreadsTable, Thread> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThreadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelsMeta = const VerificationMeta('labels');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> labels =
      GeneratedColumn<String>('labels', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<String>>($ThreadsTable.$converterlabels);
  static const VerificationMeta _developerMeta =
      const VerificationMeta('developer');
  @override
  late final GeneratedColumn<String> developer = GeneratedColumn<String>(
      'developer', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prevVersionMeta =
      const VerificationMeta('prevVersion');
  @override
  late final GeneratedColumn<String> prevVersion = GeneratedColumn<String>(
      'prev_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currVersionMeta =
      const VerificationMeta('currVersion');
  @override
  late final GeneratedColumn<String> currVersion = GeneratedColumn<String>(
      'curr_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bannerMeta = const VerificationMeta('banner');
  @override
  late final GeneratedColumn<Uint8List> banner = GeneratedColumn<Uint8List>(
      'banner', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> tags =
      GeneratedColumn<String>('tags', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant(''))
          .withConverter<List<String>>($ThreadsTable.$convertertags);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<String> lastUpdated = GeneratedColumn<String>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        labels,
        developer,
        prevVersion,
        currVersion,
        banner,
        tags,
        description,
        lastUpdated
      ];
  @override
  String get aliasedName => _alias ?? 'threads';
  @override
  String get actualTableName => 'threads';
  @override
  VerificationContext validateIntegrity(Insertable<Thread> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    context.handle(_labelsMeta, const VerificationResult.success());
    if (data.containsKey('developer')) {
      context.handle(_developerMeta,
          developer.isAcceptableOrUnknown(data['developer']!, _developerMeta));
    } else if (isInserting) {
      context.missing(_developerMeta);
    }
    if (data.containsKey('prev_version')) {
      context.handle(
          _prevVersionMeta,
          prevVersion.isAcceptableOrUnknown(
              data['prev_version']!, _prevVersionMeta));
    } else if (isInserting) {
      context.missing(_prevVersionMeta);
    }
    if (data.containsKey('curr_version')) {
      context.handle(
          _currVersionMeta,
          currVersion.isAcceptableOrUnknown(
              data['curr_version']!, _currVersionMeta));
    } else if (isInserting) {
      context.missing(_currVersionMeta);
    }
    if (data.containsKey('banner')) {
      context.handle(_bannerMeta,
          banner.isAcceptableOrUnknown(data['banner']!, _bannerMeta));
    } else if (isInserting) {
      context.missing(_bannerMeta);
    }
    context.handle(_tagsMeta, const VerificationResult.success());
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Thread map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Thread(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      labels: $ThreadsTable.$converterlabels.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}labels'])!),
      developer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}developer'])!,
      prevVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prev_version'])!,
      currVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}curr_version'])!,
      banner: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}banner'])!,
      tags: $ThreadsTable.$convertertags.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_updated'])!,
    );
  }

  @override
  $ThreadsTable createAlias(String alias) {
    return $ThreadsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterlabels =
      const ListConverter();
  static TypeConverter<List<String>, String> $convertertags =
      const ListConverter();
}

class Thread extends DataClass implements Insertable<Thread> {
  final int id;
  final String name;
  final List<String> labels;
  final String developer;
  final String prevVersion;
  final String currVersion;
  final Uint8List banner;
  final List<String> tags;
  final String description;
  final String lastUpdated;
  const Thread(
      {required this.id,
      required this.name,
      required this.labels,
      required this.developer,
      required this.prevVersion,
      required this.currVersion,
      required this.banner,
      required this.tags,
      required this.description,
      required this.lastUpdated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      final converter = $ThreadsTable.$converterlabels;
      map['labels'] = Variable<String>(converter.toSql(labels));
    }
    map['developer'] = Variable<String>(developer);
    map['prev_version'] = Variable<String>(prevVersion);
    map['curr_version'] = Variable<String>(currVersion);
    map['banner'] = Variable<Uint8List>(banner);
    {
      final converter = $ThreadsTable.$convertertags;
      map['tags'] = Variable<String>(converter.toSql(tags));
    }
    map['description'] = Variable<String>(description);
    map['last_updated'] = Variable<String>(lastUpdated);
    return map;
  }

  ThreadsCompanion toCompanion(bool nullToAbsent) {
    return ThreadsCompanion(
      id: Value(id),
      name: Value(name),
      labels: Value(labels),
      developer: Value(developer),
      prevVersion: Value(prevVersion),
      currVersion: Value(currVersion),
      banner: Value(banner),
      tags: Value(tags),
      description: Value(description),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory Thread.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Thread(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      labels: serializer.fromJson<List<String>>(json['labels']),
      developer: serializer.fromJson<String>(json['developer']),
      prevVersion: serializer.fromJson<String>(json['prevVersion']),
      currVersion: serializer.fromJson<String>(json['currVersion']),
      banner: serializer.fromJson<Uint8List>(json['banner']),
      tags: serializer.fromJson<List<String>>(json['tags']),
      description: serializer.fromJson<String>(json['description']),
      lastUpdated: serializer.fromJson<String>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'labels': serializer.toJson<List<String>>(labels),
      'developer': serializer.toJson<String>(developer),
      'prevVersion': serializer.toJson<String>(prevVersion),
      'currVersion': serializer.toJson<String>(currVersion),
      'banner': serializer.toJson<Uint8List>(banner),
      'tags': serializer.toJson<List<String>>(tags),
      'description': serializer.toJson<String>(description),
      'lastUpdated': serializer.toJson<String>(lastUpdated),
    };
  }

  Thread copyWith(
          {int? id,
          String? name,
          List<String>? labels,
          String? developer,
          String? prevVersion,
          String? currVersion,
          Uint8List? banner,
          List<String>? tags,
          String? description,
          String? lastUpdated}) =>
      Thread(
        id: id ?? this.id,
        name: name ?? this.name,
        labels: labels ?? this.labels,
        developer: developer ?? this.developer,
        prevVersion: prevVersion ?? this.prevVersion,
        currVersion: currVersion ?? this.currVersion,
        banner: banner ?? this.banner,
        tags: tags ?? this.tags,
        description: description ?? this.description,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
  @override
  String toString() {
    return (StringBuffer('Thread(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('labels: $labels, ')
          ..write('developer: $developer, ')
          ..write('prevVersion: $prevVersion, ')
          ..write('currVersion: $currVersion, ')
          ..write('banner: $banner, ')
          ..write('tags: $tags, ')
          ..write('description: $description, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      labels,
      developer,
      prevVersion,
      currVersion,
      $driftBlobEquality.hash(banner),
      tags,
      description,
      lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Thread &&
          other.id == this.id &&
          other.name == this.name &&
          other.labels == this.labels &&
          other.developer == this.developer &&
          other.prevVersion == this.prevVersion &&
          other.currVersion == this.currVersion &&
          $driftBlobEquality.equals(other.banner, this.banner) &&
          other.tags == this.tags &&
          other.description == this.description &&
          other.lastUpdated == this.lastUpdated);
}

class ThreadsCompanion extends UpdateCompanion<Thread> {
  final Value<int> id;
  final Value<String> name;
  final Value<List<String>> labels;
  final Value<String> developer;
  final Value<String> prevVersion;
  final Value<String> currVersion;
  final Value<Uint8List> banner;
  final Value<List<String>> tags;
  final Value<String> description;
  final Value<String> lastUpdated;
  const ThreadsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.labels = const Value.absent(),
    this.developer = const Value.absent(),
    this.prevVersion = const Value.absent(),
    this.currVersion = const Value.absent(),
    this.banner = const Value.absent(),
    this.tags = const Value.absent(),
    this.description = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  ThreadsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required List<String> labels,
    required String developer,
    required String prevVersion,
    required String currVersion,
    required Uint8List banner,
    this.tags = const Value.absent(),
    this.description = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  })  : name = Value(name),
        labels = Value(labels),
        developer = Value(developer),
        prevVersion = Value(prevVersion),
        currVersion = Value(currVersion),
        banner = Value(banner);
  static Insertable<Thread> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? labels,
    Expression<String>? developer,
    Expression<String>? prevVersion,
    Expression<String>? currVersion,
    Expression<Uint8List>? banner,
    Expression<String>? tags,
    Expression<String>? description,
    Expression<String>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (labels != null) 'labels': labels,
      if (developer != null) 'developer': developer,
      if (prevVersion != null) 'prev_version': prevVersion,
      if (currVersion != null) 'curr_version': currVersion,
      if (banner != null) 'banner': banner,
      if (tags != null) 'tags': tags,
      if (description != null) 'description': description,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  ThreadsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<List<String>>? labels,
      Value<String>? developer,
      Value<String>? prevVersion,
      Value<String>? currVersion,
      Value<Uint8List>? banner,
      Value<List<String>>? tags,
      Value<String>? description,
      Value<String>? lastUpdated}) {
    return ThreadsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      labels: labels ?? this.labels,
      developer: developer ?? this.developer,
      prevVersion: prevVersion ?? this.prevVersion,
      currVersion: currVersion ?? this.currVersion,
      banner: banner ?? this.banner,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (labels.present) {
      final converter = $ThreadsTable.$converterlabels;
      map['labels'] = Variable<String>(converter.toSql(labels.value));
    }
    if (developer.present) {
      map['developer'] = Variable<String>(developer.value);
    }
    if (prevVersion.present) {
      map['prev_version'] = Variable<String>(prevVersion.value);
    }
    if (currVersion.present) {
      map['curr_version'] = Variable<String>(currVersion.value);
    }
    if (banner.present) {
      map['banner'] = Variable<Uint8List>(banner.value);
    }
    if (tags.present) {
      final converter = $ThreadsTable.$convertertags;
      map['tags'] = Variable<String>(converter.toSql(tags.value));
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<String>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThreadsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('labels: $labels, ')
          ..write('developer: $developer, ')
          ..write('prevVersion: $prevVersion, ')
          ..write('currVersion: $currVersion, ')
          ..write('banner: $banner, ')
          ..write('tags: $tags, ')
          ..write('description: $description, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $ThreadsTable threads = $ThreadsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [threads];
}
