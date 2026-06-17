// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<int> isArchived = GeneratedColumn<int>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, type, notes, isArchived, createdAt, updatedAt, syncStatus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String name;
  final String type;
  final String? notes;
  final int isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const Account(
      {required this.id,
      required this.name,
      required this.type,
      this.notes,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_archived'] = Variable<int>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      notes: serializer.fromJson<String?>(json['notes']),
      isArchived: serializer.fromJson<int>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'notes': serializer.toJson<String?>(notes),
      'isArchived': serializer.toJson<int>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Account copyWith(
          {String? id,
          String? name,
          String? type,
          Value<String?> notes = const Value.absent(),
          int? isArchived,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus}) =>
      Account(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        notes: notes.present ? notes.value : this.notes,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      notes: data.notes.present ? data.notes.value : this.notes,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, type, notes, isArchived, createdAt, updatedAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.notes == this.notes &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> notes;
  final Value<int> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? notes,
    Expression<int>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (notes != null) 'notes': notes,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? type,
      Value<String?>? notes,
      Value<int>? isArchived,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<int>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeopleTable extends People with TableInfo<$PeopleTable, PeopleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<int> isArchived = GeneratedColumn<int>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, phone, notes, isArchived, createdAt, updatedAt, syncStatus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'people';
  @override
  VerificationContext validateIntegrity(Insertable<PeopleData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeopleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeopleData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $PeopleTable createAlias(String alias) {
    return $PeopleTable(attachedDatabase, alias);
  }
}

class PeopleData extends DataClass implements Insertable<PeopleData> {
  final String id;
  final String name;
  final String? phone;
  final String? notes;
  final int isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const PeopleData(
      {required this.id,
      required this.name,
      this.phone,
      this.notes,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_archived'] = Variable<int>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  PeopleCompanion toCompanion(bool nullToAbsent) {
    return PeopleCompanion(
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory PeopleData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeopleData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      notes: serializer.fromJson<String?>(json['notes']),
      isArchived: serializer.fromJson<int>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'notes': serializer.toJson<String?>(notes),
      'isArchived': serializer.toJson<int>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  PeopleData copyWith(
          {String? id,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          int? isArchived,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus}) =>
      PeopleData(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        notes: notes.present ? notes.value : this.notes,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  PeopleData copyWithCompanion(PeopleCompanion data) {
    return PeopleData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      notes: data.notes.present ? data.notes.value : this.notes,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeopleData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, phone, notes, isArchived, createdAt, updatedAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeopleData &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.notes == this.notes &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class PeopleCompanion extends UpdateCompanion<PeopleData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> notes;
  final Value<int> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const PeopleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeopleCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PeopleData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? notes,
    Expression<int>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (notes != null) 'notes': notes,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeopleCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? notes,
      Value<int>? isArchived,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return PeopleCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<int>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeopleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentsTable extends Investments
    with TableInfo<$InvestmentsTable, Investment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _marketValueMeta =
      const VerificationMeta('marketValue');
  @override
  late final GeneratedColumn<double> marketValue = GeneratedColumn<double>(
      'market_value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _marketValueUpdatedAtMeta =
      const VerificationMeta('marketValueUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> marketValueUpdatedAt =
      GeneratedColumn<DateTime>('market_value_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<int> isArchived = GeneratedColumn<int>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        type,
        symbol,
        marketValue,
        marketValueUpdatedAt,
        isArchived,
        notes,
        createdAt,
        updatedAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investments';
  @override
  VerificationContext validateIntegrity(Insertable<Investment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    }
    if (data.containsKey('market_value')) {
      context.handle(
          _marketValueMeta,
          marketValue.isAcceptableOrUnknown(
              data['market_value']!, _marketValueMeta));
    }
    if (data.containsKey('market_value_updated_at')) {
      context.handle(
          _marketValueUpdatedAtMeta,
          marketValueUpdatedAt.isAcceptableOrUnknown(
              data['market_value_updated_at']!, _marketValueUpdatedAtMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Investment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Investment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol']),
      marketValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}market_value']),
      marketValueUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}market_value_updated_at']),
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_archived'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $InvestmentsTable createAlias(String alias) {
    return $InvestmentsTable(attachedDatabase, alias);
  }
}

class Investment extends DataClass implements Insertable<Investment> {
  final String id;
  final String name;
  final String type;
  final String? symbol;
  final double? marketValue;
  final DateTime? marketValueUpdatedAt;
  final int isArchived;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const Investment(
      {required this.id,
      required this.name,
      required this.type,
      this.symbol,
      this.marketValue,
      this.marketValueUpdatedAt,
      required this.isArchived,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || symbol != null) {
      map['symbol'] = Variable<String>(symbol);
    }
    if (!nullToAbsent || marketValue != null) {
      map['market_value'] = Variable<double>(marketValue);
    }
    if (!nullToAbsent || marketValueUpdatedAt != null) {
      map['market_value_updated_at'] = Variable<DateTime>(marketValueUpdatedAt);
    }
    map['is_archived'] = Variable<int>(isArchived);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  InvestmentsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      symbol:
          symbol == null && nullToAbsent ? const Value.absent() : Value(symbol),
      marketValue: marketValue == null && nullToAbsent
          ? const Value.absent()
          : Value(marketValue),
      marketValueUpdatedAt: marketValueUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(marketValueUpdatedAt),
      isArchived: Value(isArchived),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Investment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Investment(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      symbol: serializer.fromJson<String?>(json['symbol']),
      marketValue: serializer.fromJson<double?>(json['marketValue']),
      marketValueUpdatedAt:
          serializer.fromJson<DateTime?>(json['marketValueUpdatedAt']),
      isArchived: serializer.fromJson<int>(json['isArchived']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'symbol': serializer.toJson<String?>(symbol),
      'marketValue': serializer.toJson<double?>(marketValue),
      'marketValueUpdatedAt':
          serializer.toJson<DateTime?>(marketValueUpdatedAt),
      'isArchived': serializer.toJson<int>(isArchived),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Investment copyWith(
          {String? id,
          String? name,
          String? type,
          Value<String?> symbol = const Value.absent(),
          Value<double?> marketValue = const Value.absent(),
          Value<DateTime?> marketValueUpdatedAt = const Value.absent(),
          int? isArchived,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus}) =>
      Investment(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        symbol: symbol.present ? symbol.value : this.symbol,
        marketValue: marketValue.present ? marketValue.value : this.marketValue,
        marketValueUpdatedAt: marketValueUpdatedAt.present
            ? marketValueUpdatedAt.value
            : this.marketValueUpdatedAt,
        isArchived: isArchived ?? this.isArchived,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Investment copyWithCompanion(InvestmentsCompanion data) {
    return Investment(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      marketValue:
          data.marketValue.present ? data.marketValue.value : this.marketValue,
      marketValueUpdatedAt: data.marketValueUpdatedAt.present
          ? data.marketValueUpdatedAt.value
          : this.marketValueUpdatedAt,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Investment(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('symbol: $symbol, ')
          ..write('marketValue: $marketValue, ')
          ..write('marketValueUpdatedAt: $marketValueUpdatedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      type,
      symbol,
      marketValue,
      marketValueUpdatedAt,
      isArchived,
      notes,
      createdAt,
      updatedAt,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Investment &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.symbol == this.symbol &&
          other.marketValue == this.marketValue &&
          other.marketValueUpdatedAt == this.marketValueUpdatedAt &&
          other.isArchived == this.isArchived &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class InvestmentsCompanion extends UpdateCompanion<Investment> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> symbol;
  final Value<double?> marketValue;
  final Value<DateTime?> marketValueUpdatedAt;
  final Value<int> isArchived;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const InvestmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.symbol = const Value.absent(),
    this.marketValue = const Value.absent(),
    this.marketValueUpdatedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentsCompanion.insert({
    required String id,
    required String name,
    required String type,
    this.symbol = const Value.absent(),
    this.marketValue = const Value.absent(),
    this.marketValueUpdatedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Investment> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? symbol,
    Expression<double>? marketValue,
    Expression<DateTime>? marketValueUpdatedAt,
    Expression<int>? isArchived,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (symbol != null) 'symbol': symbol,
      if (marketValue != null) 'market_value': marketValue,
      if (marketValueUpdatedAt != null)
        'market_value_updated_at': marketValueUpdatedAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? type,
      Value<String?>? symbol,
      Value<double?>? marketValue,
      Value<DateTime?>? marketValueUpdatedAt,
      Value<int>? isArchived,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return InvestmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      symbol: symbol ?? this.symbol,
      marketValue: marketValue ?? this.marketValue,
      marketValueUpdatedAt: marketValueUpdatedAt ?? this.marketValueUpdatedAt,
      isArchived: isArchived ?? this.isArchived,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (marketValue.present) {
      map['market_value'] = Variable<double>(marketValue.value);
    }
    if (marketValueUpdatedAt.present) {
      map['market_value_updated_at'] =
          Variable<DateTime>(marketValueUpdatedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<int>(isArchived.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('symbol: $symbol, ')
          ..write('marketValue: $marketValue, ')
          ..write('marketValueUpdatedAt: $marketValueUpdatedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentLotsTable extends InvestmentLots
    with TableInfo<$InvestmentLotsTable, InvestmentLot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentLotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _investmentIdMeta =
      const VerificationMeta('investmentId');
  @override
  late final GeneratedColumn<String> investmentId = GeneratedColumn<String>(
      'investment_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES investments(id)');
  static const VerificationMeta _buyTransactionIdMeta =
      const VerificationMeta('buyTransactionId');
  @override
  late final GeneratedColumn<String> buyTransactionId = GeneratedColumn<String>(
      'buy_transaction_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES transactions(id)');
  static const VerificationMeta _unitsPurchasedMeta =
      const VerificationMeta('unitsPurchased');
  @override
  late final GeneratedColumn<double> unitsPurchased = GeneratedColumn<double>(
      'units_purchased', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitsRemainingMeta =
      const VerificationMeta('unitsRemaining');
  @override
  late final GeneratedColumn<double> unitsRemaining = GeneratedColumn<double>(
      'units_remaining', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _costPerUnitMeta =
      const VerificationMeta('costPerUnit');
  @override
  late final GeneratedColumn<double> costPerUnit = GeneratedColumn<double>(
      'cost_per_unit', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _purchaseDateMeta =
      const VerificationMeta('purchaseDate');
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
      'purchase_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        investmentId,
        buyTransactionId,
        unitsPurchased,
        unitsRemaining,
        costPerUnit,
        purchaseDate,
        createdAt,
        updatedAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investment_lots';
  @override
  VerificationContext validateIntegrity(Insertable<InvestmentLot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('investment_id')) {
      context.handle(
          _investmentIdMeta,
          investmentId.isAcceptableOrUnknown(
              data['investment_id']!, _investmentIdMeta));
    } else if (isInserting) {
      context.missing(_investmentIdMeta);
    }
    if (data.containsKey('buy_transaction_id')) {
      context.handle(
          _buyTransactionIdMeta,
          buyTransactionId.isAcceptableOrUnknown(
              data['buy_transaction_id']!, _buyTransactionIdMeta));
    } else if (isInserting) {
      context.missing(_buyTransactionIdMeta);
    }
    if (data.containsKey('units_purchased')) {
      context.handle(
          _unitsPurchasedMeta,
          unitsPurchased.isAcceptableOrUnknown(
              data['units_purchased']!, _unitsPurchasedMeta));
    } else if (isInserting) {
      context.missing(_unitsPurchasedMeta);
    }
    if (data.containsKey('units_remaining')) {
      context.handle(
          _unitsRemainingMeta,
          unitsRemaining.isAcceptableOrUnknown(
              data['units_remaining']!, _unitsRemainingMeta));
    } else if (isInserting) {
      context.missing(_unitsRemainingMeta);
    }
    if (data.containsKey('cost_per_unit')) {
      context.handle(
          _costPerUnitMeta,
          costPerUnit.isAcceptableOrUnknown(
              data['cost_per_unit']!, _costPerUnitMeta));
    } else if (isInserting) {
      context.missing(_costPerUnitMeta);
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
          _purchaseDateMeta,
          purchaseDate.isAcceptableOrUnknown(
              data['purchase_date']!, _purchaseDateMeta));
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvestmentLot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentLot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      investmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}investment_id'])!,
      buyTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}buy_transaction_id'])!,
      unitsPurchased: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}units_purchased'])!,
      unitsRemaining: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}units_remaining'])!,
      costPerUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_per_unit'])!,
      purchaseDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}purchase_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $InvestmentLotsTable createAlias(String alias) {
    return $InvestmentLotsTable(attachedDatabase, alias);
  }
}

class InvestmentLot extends DataClass implements Insertable<InvestmentLot> {
  final String id;
  final String investmentId;
  final String buyTransactionId;
  final double unitsPurchased;
  final double unitsRemaining;
  final double costPerUnit;
  final DateTime purchaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const InvestmentLot(
      {required this.id,
      required this.investmentId,
      required this.buyTransactionId,
      required this.unitsPurchased,
      required this.unitsRemaining,
      required this.costPerUnit,
      required this.purchaseDate,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['investment_id'] = Variable<String>(investmentId);
    map['buy_transaction_id'] = Variable<String>(buyTransactionId);
    map['units_purchased'] = Variable<double>(unitsPurchased);
    map['units_remaining'] = Variable<double>(unitsRemaining);
    map['cost_per_unit'] = Variable<double>(costPerUnit);
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  InvestmentLotsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentLotsCompanion(
      id: Value(id),
      investmentId: Value(investmentId),
      buyTransactionId: Value(buyTransactionId),
      unitsPurchased: Value(unitsPurchased),
      unitsRemaining: Value(unitsRemaining),
      costPerUnit: Value(costPerUnit),
      purchaseDate: Value(purchaseDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory InvestmentLot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentLot(
      id: serializer.fromJson<String>(json['id']),
      investmentId: serializer.fromJson<String>(json['investmentId']),
      buyTransactionId: serializer.fromJson<String>(json['buyTransactionId']),
      unitsPurchased: serializer.fromJson<double>(json['unitsPurchased']),
      unitsRemaining: serializer.fromJson<double>(json['unitsRemaining']),
      costPerUnit: serializer.fromJson<double>(json['costPerUnit']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'investmentId': serializer.toJson<String>(investmentId),
      'buyTransactionId': serializer.toJson<String>(buyTransactionId),
      'unitsPurchased': serializer.toJson<double>(unitsPurchased),
      'unitsRemaining': serializer.toJson<double>(unitsRemaining),
      'costPerUnit': serializer.toJson<double>(costPerUnit),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  InvestmentLot copyWith(
          {String? id,
          String? investmentId,
          String? buyTransactionId,
          double? unitsPurchased,
          double? unitsRemaining,
          double? costPerUnit,
          DateTime? purchaseDate,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus}) =>
      InvestmentLot(
        id: id ?? this.id,
        investmentId: investmentId ?? this.investmentId,
        buyTransactionId: buyTransactionId ?? this.buyTransactionId,
        unitsPurchased: unitsPurchased ?? this.unitsPurchased,
        unitsRemaining: unitsRemaining ?? this.unitsRemaining,
        costPerUnit: costPerUnit ?? this.costPerUnit,
        purchaseDate: purchaseDate ?? this.purchaseDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  InvestmentLot copyWithCompanion(InvestmentLotsCompanion data) {
    return InvestmentLot(
      id: data.id.present ? data.id.value : this.id,
      investmentId: data.investmentId.present
          ? data.investmentId.value
          : this.investmentId,
      buyTransactionId: data.buyTransactionId.present
          ? data.buyTransactionId.value
          : this.buyTransactionId,
      unitsPurchased: data.unitsPurchased.present
          ? data.unitsPurchased.value
          : this.unitsPurchased,
      unitsRemaining: data.unitsRemaining.present
          ? data.unitsRemaining.value
          : this.unitsRemaining,
      costPerUnit:
          data.costPerUnit.present ? data.costPerUnit.value : this.costPerUnit,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentLot(')
          ..write('id: $id, ')
          ..write('investmentId: $investmentId, ')
          ..write('buyTransactionId: $buyTransactionId, ')
          ..write('unitsPurchased: $unitsPurchased, ')
          ..write('unitsRemaining: $unitsRemaining, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      investmentId,
      buyTransactionId,
      unitsPurchased,
      unitsRemaining,
      costPerUnit,
      purchaseDate,
      createdAt,
      updatedAt,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentLot &&
          other.id == this.id &&
          other.investmentId == this.investmentId &&
          other.buyTransactionId == this.buyTransactionId &&
          other.unitsPurchased == this.unitsPurchased &&
          other.unitsRemaining == this.unitsRemaining &&
          other.costPerUnit == this.costPerUnit &&
          other.purchaseDate == this.purchaseDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class InvestmentLotsCompanion extends UpdateCompanion<InvestmentLot> {
  final Value<String> id;
  final Value<String> investmentId;
  final Value<String> buyTransactionId;
  final Value<double> unitsPurchased;
  final Value<double> unitsRemaining;
  final Value<double> costPerUnit;
  final Value<DateTime> purchaseDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const InvestmentLotsCompanion({
    this.id = const Value.absent(),
    this.investmentId = const Value.absent(),
    this.buyTransactionId = const Value.absent(),
    this.unitsPurchased = const Value.absent(),
    this.unitsRemaining = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentLotsCompanion.insert({
    required String id,
    required String investmentId,
    required String buyTransactionId,
    required double unitsPurchased,
    required double unitsRemaining,
    required double costPerUnit,
    required DateTime purchaseDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        investmentId = Value(investmentId),
        buyTransactionId = Value(buyTransactionId),
        unitsPurchased = Value(unitsPurchased),
        unitsRemaining = Value(unitsRemaining),
        costPerUnit = Value(costPerUnit),
        purchaseDate = Value(purchaseDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<InvestmentLot> custom({
    Expression<String>? id,
    Expression<String>? investmentId,
    Expression<String>? buyTransactionId,
    Expression<double>? unitsPurchased,
    Expression<double>? unitsRemaining,
    Expression<double>? costPerUnit,
    Expression<DateTime>? purchaseDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (investmentId != null) 'investment_id': investmentId,
      if (buyTransactionId != null) 'buy_transaction_id': buyTransactionId,
      if (unitsPurchased != null) 'units_purchased': unitsPurchased,
      if (unitsRemaining != null) 'units_remaining': unitsRemaining,
      if (costPerUnit != null) 'cost_per_unit': costPerUnit,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentLotsCompanion copyWith(
      {Value<String>? id,
      Value<String>? investmentId,
      Value<String>? buyTransactionId,
      Value<double>? unitsPurchased,
      Value<double>? unitsRemaining,
      Value<double>? costPerUnit,
      Value<DateTime>? purchaseDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return InvestmentLotsCompanion(
      id: id ?? this.id,
      investmentId: investmentId ?? this.investmentId,
      buyTransactionId: buyTransactionId ?? this.buyTransactionId,
      unitsPurchased: unitsPurchased ?? this.unitsPurchased,
      unitsRemaining: unitsRemaining ?? this.unitsRemaining,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (investmentId.present) {
      map['investment_id'] = Variable<String>(investmentId.value);
    }
    if (buyTransactionId.present) {
      map['buy_transaction_id'] = Variable<String>(buyTransactionId.value);
    }
    if (unitsPurchased.present) {
      map['units_purchased'] = Variable<double>(unitsPurchased.value);
    }
    if (unitsRemaining.present) {
      map['units_remaining'] = Variable<double>(unitsRemaining.value);
    }
    if (costPerUnit.present) {
      map['cost_per_unit'] = Variable<double>(costPerUnit.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentLotsCompanion(')
          ..write('id: $id, ')
          ..write('investmentId: $investmentId, ')
          ..write('buyTransactionId: $buyTransactionId, ')
          ..write('unitsPurchased: $unitsPurchased, ')
          ..write('unitsRemaining: $unitsRemaining, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentLotConsumptionsTable extends InvestmentLotConsumptions
    with TableInfo<$InvestmentLotConsumptionsTable, InvestmentLotConsumption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentLotConsumptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sellTransactionIdMeta =
      const VerificationMeta('sellTransactionId');
  @override
  late final GeneratedColumn<String> sellTransactionId =
      GeneratedColumn<String>('sell_transaction_id', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          $customConstraints: 'NOT NULL REFERENCES transactions(id)');
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
      'lot_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES investment_lots(id)');
  static const VerificationMeta _unitsConsumedMeta =
      const VerificationMeta('unitsConsumed');
  @override
  late final GeneratedColumn<double> unitsConsumed = GeneratedColumn<double>(
      'units_consumed', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _costBasisMeta =
      const VerificationMeta('costBasis');
  @override
  late final GeneratedColumn<double> costBasis = GeneratedColumn<double>(
      'cost_basis', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _proceedsAllocatedMeta =
      const VerificationMeta('proceedsAllocated');
  @override
  late final GeneratedColumn<double> proceedsAllocated =
      GeneratedColumn<double>('proceeds_allocated', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _realizedGainLossMeta =
      const VerificationMeta('realizedGainLoss');
  @override
  late final GeneratedColumn<double> realizedGainLoss = GeneratedColumn<double>(
      'realized_gain_loss', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sellTransactionId,
        lotId,
        unitsConsumed,
        costBasis,
        proceedsAllocated,
        realizedGainLoss,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investment_lot_consumptions';
  @override
  VerificationContext validateIntegrity(
      Insertable<InvestmentLotConsumption> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sell_transaction_id')) {
      context.handle(
          _sellTransactionIdMeta,
          sellTransactionId.isAcceptableOrUnknown(
              data['sell_transaction_id']!, _sellTransactionIdMeta));
    } else if (isInserting) {
      context.missing(_sellTransactionIdMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(
          _lotIdMeta, lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta));
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('units_consumed')) {
      context.handle(
          _unitsConsumedMeta,
          unitsConsumed.isAcceptableOrUnknown(
              data['units_consumed']!, _unitsConsumedMeta));
    } else if (isInserting) {
      context.missing(_unitsConsumedMeta);
    }
    if (data.containsKey('cost_basis')) {
      context.handle(_costBasisMeta,
          costBasis.isAcceptableOrUnknown(data['cost_basis']!, _costBasisMeta));
    } else if (isInserting) {
      context.missing(_costBasisMeta);
    }
    if (data.containsKey('proceeds_allocated')) {
      context.handle(
          _proceedsAllocatedMeta,
          proceedsAllocated.isAcceptableOrUnknown(
              data['proceeds_allocated']!, _proceedsAllocatedMeta));
    } else if (isInserting) {
      context.missing(_proceedsAllocatedMeta);
    }
    if (data.containsKey('realized_gain_loss')) {
      context.handle(
          _realizedGainLossMeta,
          realizedGainLoss.isAcceptableOrUnknown(
              data['realized_gain_loss']!, _realizedGainLossMeta));
    } else if (isInserting) {
      context.missing(_realizedGainLossMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvestmentLotConsumption map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentLotConsumption(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sellTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}sell_transaction_id'])!,
      lotId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lot_id'])!,
      unitsConsumed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}units_consumed'])!,
      costBasis: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_basis'])!,
      proceedsAllocated: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}proceeds_allocated'])!,
      realizedGainLoss: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}realized_gain_loss'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InvestmentLotConsumptionsTable createAlias(String alias) {
    return $InvestmentLotConsumptionsTable(attachedDatabase, alias);
  }
}

class InvestmentLotConsumption extends DataClass
    implements Insertable<InvestmentLotConsumption> {
  final String id;
  final String sellTransactionId;
  final String lotId;
  final double unitsConsumed;
  final double costBasis;
  final double proceedsAllocated;
  final double realizedGainLoss;
  final DateTime createdAt;
  const InvestmentLotConsumption(
      {required this.id,
      required this.sellTransactionId,
      required this.lotId,
      required this.unitsConsumed,
      required this.costBasis,
      required this.proceedsAllocated,
      required this.realizedGainLoss,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sell_transaction_id'] = Variable<String>(sellTransactionId);
    map['lot_id'] = Variable<String>(lotId);
    map['units_consumed'] = Variable<double>(unitsConsumed);
    map['cost_basis'] = Variable<double>(costBasis);
    map['proceeds_allocated'] = Variable<double>(proceedsAllocated);
    map['realized_gain_loss'] = Variable<double>(realizedGainLoss);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InvestmentLotConsumptionsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentLotConsumptionsCompanion(
      id: Value(id),
      sellTransactionId: Value(sellTransactionId),
      lotId: Value(lotId),
      unitsConsumed: Value(unitsConsumed),
      costBasis: Value(costBasis),
      proceedsAllocated: Value(proceedsAllocated),
      realizedGainLoss: Value(realizedGainLoss),
      createdAt: Value(createdAt),
    );
  }

  factory InvestmentLotConsumption.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentLotConsumption(
      id: serializer.fromJson<String>(json['id']),
      sellTransactionId: serializer.fromJson<String>(json['sellTransactionId']),
      lotId: serializer.fromJson<String>(json['lotId']),
      unitsConsumed: serializer.fromJson<double>(json['unitsConsumed']),
      costBasis: serializer.fromJson<double>(json['costBasis']),
      proceedsAllocated: serializer.fromJson<double>(json['proceedsAllocated']),
      realizedGainLoss: serializer.fromJson<double>(json['realizedGainLoss']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sellTransactionId': serializer.toJson<String>(sellTransactionId),
      'lotId': serializer.toJson<String>(lotId),
      'unitsConsumed': serializer.toJson<double>(unitsConsumed),
      'costBasis': serializer.toJson<double>(costBasis),
      'proceedsAllocated': serializer.toJson<double>(proceedsAllocated),
      'realizedGainLoss': serializer.toJson<double>(realizedGainLoss),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InvestmentLotConsumption copyWith(
          {String? id,
          String? sellTransactionId,
          String? lotId,
          double? unitsConsumed,
          double? costBasis,
          double? proceedsAllocated,
          double? realizedGainLoss,
          DateTime? createdAt}) =>
      InvestmentLotConsumption(
        id: id ?? this.id,
        sellTransactionId: sellTransactionId ?? this.sellTransactionId,
        lotId: lotId ?? this.lotId,
        unitsConsumed: unitsConsumed ?? this.unitsConsumed,
        costBasis: costBasis ?? this.costBasis,
        proceedsAllocated: proceedsAllocated ?? this.proceedsAllocated,
        realizedGainLoss: realizedGainLoss ?? this.realizedGainLoss,
        createdAt: createdAt ?? this.createdAt,
      );
  InvestmentLotConsumption copyWithCompanion(
      InvestmentLotConsumptionsCompanion data) {
    return InvestmentLotConsumption(
      id: data.id.present ? data.id.value : this.id,
      sellTransactionId: data.sellTransactionId.present
          ? data.sellTransactionId.value
          : this.sellTransactionId,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      unitsConsumed: data.unitsConsumed.present
          ? data.unitsConsumed.value
          : this.unitsConsumed,
      costBasis: data.costBasis.present ? data.costBasis.value : this.costBasis,
      proceedsAllocated: data.proceedsAllocated.present
          ? data.proceedsAllocated.value
          : this.proceedsAllocated,
      realizedGainLoss: data.realizedGainLoss.present
          ? data.realizedGainLoss.value
          : this.realizedGainLoss,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentLotConsumption(')
          ..write('id: $id, ')
          ..write('sellTransactionId: $sellTransactionId, ')
          ..write('lotId: $lotId, ')
          ..write('unitsConsumed: $unitsConsumed, ')
          ..write('costBasis: $costBasis, ')
          ..write('proceedsAllocated: $proceedsAllocated, ')
          ..write('realizedGainLoss: $realizedGainLoss, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sellTransactionId, lotId, unitsConsumed,
      costBasis, proceedsAllocated, realizedGainLoss, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentLotConsumption &&
          other.id == this.id &&
          other.sellTransactionId == this.sellTransactionId &&
          other.lotId == this.lotId &&
          other.unitsConsumed == this.unitsConsumed &&
          other.costBasis == this.costBasis &&
          other.proceedsAllocated == this.proceedsAllocated &&
          other.realizedGainLoss == this.realizedGainLoss &&
          other.createdAt == this.createdAt);
}

class InvestmentLotConsumptionsCompanion
    extends UpdateCompanion<InvestmentLotConsumption> {
  final Value<String> id;
  final Value<String> sellTransactionId;
  final Value<String> lotId;
  final Value<double> unitsConsumed;
  final Value<double> costBasis;
  final Value<double> proceedsAllocated;
  final Value<double> realizedGainLoss;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InvestmentLotConsumptionsCompanion({
    this.id = const Value.absent(),
    this.sellTransactionId = const Value.absent(),
    this.lotId = const Value.absent(),
    this.unitsConsumed = const Value.absent(),
    this.costBasis = const Value.absent(),
    this.proceedsAllocated = const Value.absent(),
    this.realizedGainLoss = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentLotConsumptionsCompanion.insert({
    required String id,
    required String sellTransactionId,
    required String lotId,
    required double unitsConsumed,
    required double costBasis,
    required double proceedsAllocated,
    required double realizedGainLoss,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sellTransactionId = Value(sellTransactionId),
        lotId = Value(lotId),
        unitsConsumed = Value(unitsConsumed),
        costBasis = Value(costBasis),
        proceedsAllocated = Value(proceedsAllocated),
        realizedGainLoss = Value(realizedGainLoss),
        createdAt = Value(createdAt);
  static Insertable<InvestmentLotConsumption> custom({
    Expression<String>? id,
    Expression<String>? sellTransactionId,
    Expression<String>? lotId,
    Expression<double>? unitsConsumed,
    Expression<double>? costBasis,
    Expression<double>? proceedsAllocated,
    Expression<double>? realizedGainLoss,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sellTransactionId != null) 'sell_transaction_id': sellTransactionId,
      if (lotId != null) 'lot_id': lotId,
      if (unitsConsumed != null) 'units_consumed': unitsConsumed,
      if (costBasis != null) 'cost_basis': costBasis,
      if (proceedsAllocated != null) 'proceeds_allocated': proceedsAllocated,
      if (realizedGainLoss != null) 'realized_gain_loss': realizedGainLoss,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentLotConsumptionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sellTransactionId,
      Value<String>? lotId,
      Value<double>? unitsConsumed,
      Value<double>? costBasis,
      Value<double>? proceedsAllocated,
      Value<double>? realizedGainLoss,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return InvestmentLotConsumptionsCompanion(
      id: id ?? this.id,
      sellTransactionId: sellTransactionId ?? this.sellTransactionId,
      lotId: lotId ?? this.lotId,
      unitsConsumed: unitsConsumed ?? this.unitsConsumed,
      costBasis: costBasis ?? this.costBasis,
      proceedsAllocated: proceedsAllocated ?? this.proceedsAllocated,
      realizedGainLoss: realizedGainLoss ?? this.realizedGainLoss,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sellTransactionId.present) {
      map['sell_transaction_id'] = Variable<String>(sellTransactionId.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (unitsConsumed.present) {
      map['units_consumed'] = Variable<double>(unitsConsumed.value);
    }
    if (costBasis.present) {
      map['cost_basis'] = Variable<double>(costBasis.value);
    }
    if (proceedsAllocated.present) {
      map['proceeds_allocated'] = Variable<double>(proceedsAllocated.value);
    }
    if (realizedGainLoss.present) {
      map['realized_gain_loss'] = Variable<double>(realizedGainLoss.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentLotConsumptionsCompanion(')
          ..write('id: $id, ')
          ..write('sellTransactionId: $sellTransactionId, ')
          ..write('lotId: $lotId, ')
          ..write('unitsConsumed: $unitsConsumed, ')
          ..write('costBasis: $costBasis, ')
          ..write('proceedsAllocated: $proceedsAllocated, ')
          ..write('realizedGainLoss: $realizedGainLoss, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fromAccountIdMeta =
      const VerificationMeta('fromAccountId');
  @override
  late final GeneratedColumn<String> fromAccountId = GeneratedColumn<String>(
      'from_account_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES accounts(id)');
  static const VerificationMeta _toAccountIdMeta =
      const VerificationMeta('toAccountId');
  @override
  late final GeneratedColumn<String> toAccountId = GeneratedColumn<String>(
      'to_account_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES accounts(id)');
  static const VerificationMeta _personIdMeta =
      const VerificationMeta('personId');
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
      'person_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES people(id)');
  static const VerificationMeta _investmentIdMeta =
      const VerificationMeta('investmentId');
  @override
  late final GeneratedColumn<String> investmentId = GeneratedColumn<String>(
      'investment_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES investments(id)');
  static const VerificationMeta _voidedTransactionIdMeta =
      const VerificationMeta('voidedTransactionId');
  @override
  late final GeneratedColumn<String> voidedTransactionId =
      GeneratedColumn<String>('voided_transaction_id', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: 'REFERENCES transactions(id)');
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pricePerUnitMeta =
      const VerificationMeta('pricePerUnit');
  @override
  late final GeneratedColumn<double> pricePerUnit = GeneratedColumn<double>(
      'price_per_unit', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _unitsMeta = const VerificationMeta('units');
  @override
  late final GeneratedColumn<double> units = GeneratedColumn<double>(
      'units', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _transactionDateMeta =
      const VerificationMeta('transactionDate');
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>('transaction_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        amount,
        category,
        fromAccountId,
        toAccountId,
        personId,
        investmentId,
        voidedTransactionId,
        notes,
        pricePerUnit,
        units,
        transactionDate,
        createdAt,
        updatedAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('from_account_id')) {
      context.handle(
          _fromAccountIdMeta,
          fromAccountId.isAcceptableOrUnknown(
              data['from_account_id']!, _fromAccountIdMeta));
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
          _toAccountIdMeta,
          toAccountId.isAcceptableOrUnknown(
              data['to_account_id']!, _toAccountIdMeta));
    }
    if (data.containsKey('person_id')) {
      context.handle(_personIdMeta,
          personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta));
    }
    if (data.containsKey('investment_id')) {
      context.handle(
          _investmentIdMeta,
          investmentId.isAcceptableOrUnknown(
              data['investment_id']!, _investmentIdMeta));
    }
    if (data.containsKey('voided_transaction_id')) {
      context.handle(
          _voidedTransactionIdMeta,
          voidedTransactionId.isAcceptableOrUnknown(
              data['voided_transaction_id']!, _voidedTransactionIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('price_per_unit')) {
      context.handle(
          _pricePerUnitMeta,
          pricePerUnit.isAcceptableOrUnknown(
              data['price_per_unit']!, _pricePerUnitMeta));
    }
    if (data.containsKey('units')) {
      context.handle(
          _unitsMeta, units.isAcceptableOrUnknown(data['units']!, _unitsMeta));
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
          _transactionDateMeta,
          transactionDate.isAcceptableOrUnknown(
              data['transaction_date']!, _transactionDateMeta));
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      fromAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_account_id']),
      toAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_account_id']),
      personId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_id']),
      investmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}investment_id']),
      voidedTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}voided_transaction_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      pricePerUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price_per_unit']),
      units: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}units']),
      transactionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}transaction_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final String type;
  final double amount;
  final String? category;
  final String? fromAccountId;
  final String? toAccountId;
  final String? personId;
  final String? investmentId;
  final String? voidedTransactionId;
  final String? notes;
  final double? pricePerUnit;
  final double? units;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const Transaction(
      {required this.id,
      required this.type,
      required this.amount,
      this.category,
      this.fromAccountId,
      this.toAccountId,
      this.personId,
      this.investmentId,
      this.voidedTransactionId,
      this.notes,
      this.pricePerUnit,
      this.units,
      required this.transactionDate,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || fromAccountId != null) {
      map['from_account_id'] = Variable<String>(fromAccountId);
    }
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<String>(toAccountId);
    }
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    if (!nullToAbsent || investmentId != null) {
      map['investment_id'] = Variable<String>(investmentId);
    }
    if (!nullToAbsent || voidedTransactionId != null) {
      map['voided_transaction_id'] = Variable<String>(voidedTransactionId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || pricePerUnit != null) {
      map['price_per_unit'] = Variable<double>(pricePerUnit);
    }
    if (!nullToAbsent || units != null) {
      map['units'] = Variable<double>(units);
    }
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      fromAccountId: fromAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromAccountId),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      investmentId: investmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(investmentId),
      voidedTransactionId: voidedTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedTransactionId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      pricePerUnit: pricePerUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePerUnit),
      units:
          units == null && nullToAbsent ? const Value.absent() : Value(units),
      transactionDate: Value(transactionDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String?>(json['category']),
      fromAccountId: serializer.fromJson<String?>(json['fromAccountId']),
      toAccountId: serializer.fromJson<String?>(json['toAccountId']),
      personId: serializer.fromJson<String?>(json['personId']),
      investmentId: serializer.fromJson<String?>(json['investmentId']),
      voidedTransactionId:
          serializer.fromJson<String?>(json['voidedTransactionId']),
      notes: serializer.fromJson<String?>(json['notes']),
      pricePerUnit: serializer.fromJson<double?>(json['pricePerUnit']),
      units: serializer.fromJson<double?>(json['units']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String?>(category),
      'fromAccountId': serializer.toJson<String?>(fromAccountId),
      'toAccountId': serializer.toJson<String?>(toAccountId),
      'personId': serializer.toJson<String?>(personId),
      'investmentId': serializer.toJson<String?>(investmentId),
      'voidedTransactionId': serializer.toJson<String?>(voidedTransactionId),
      'notes': serializer.toJson<String?>(notes),
      'pricePerUnit': serializer.toJson<double?>(pricePerUnit),
      'units': serializer.toJson<double?>(units),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Transaction copyWith(
          {String? id,
          String? type,
          double? amount,
          Value<String?> category = const Value.absent(),
          Value<String?> fromAccountId = const Value.absent(),
          Value<String?> toAccountId = const Value.absent(),
          Value<String?> personId = const Value.absent(),
          Value<String?> investmentId = const Value.absent(),
          Value<String?> voidedTransactionId = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<double?> pricePerUnit = const Value.absent(),
          Value<double?> units = const Value.absent(),
          DateTime? transactionDate,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus}) =>
      Transaction(
        id: id ?? this.id,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        category: category.present ? category.value : this.category,
        fromAccountId:
            fromAccountId.present ? fromAccountId.value : this.fromAccountId,
        toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
        personId: personId.present ? personId.value : this.personId,
        investmentId:
            investmentId.present ? investmentId.value : this.investmentId,
        voidedTransactionId: voidedTransactionId.present
            ? voidedTransactionId.value
            : this.voidedTransactionId,
        notes: notes.present ? notes.value : this.notes,
        pricePerUnit:
            pricePerUnit.present ? pricePerUnit.value : this.pricePerUnit,
        units: units.present ? units.value : this.units,
        transactionDate: transactionDate ?? this.transactionDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      fromAccountId: data.fromAccountId.present
          ? data.fromAccountId.value
          : this.fromAccountId,
      toAccountId:
          data.toAccountId.present ? data.toAccountId.value : this.toAccountId,
      personId: data.personId.present ? data.personId.value : this.personId,
      investmentId: data.investmentId.present
          ? data.investmentId.value
          : this.investmentId,
      voidedTransactionId: data.voidedTransactionId.present
          ? data.voidedTransactionId.value
          : this.voidedTransactionId,
      notes: data.notes.present ? data.notes.value : this.notes,
      pricePerUnit: data.pricePerUnit.present
          ? data.pricePerUnit.value
          : this.pricePerUnit,
      units: data.units.present ? data.units.value : this.units,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('fromAccountId: $fromAccountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('personId: $personId, ')
          ..write('investmentId: $investmentId, ')
          ..write('voidedTransactionId: $voidedTransactionId, ')
          ..write('notes: $notes, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('units: $units, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      type,
      amount,
      category,
      fromAccountId,
      toAccountId,
      personId,
      investmentId,
      voidedTransactionId,
      notes,
      pricePerUnit,
      units,
      transactionDate,
      createdAt,
      updatedAt,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.fromAccountId == this.fromAccountId &&
          other.toAccountId == this.toAccountId &&
          other.personId == this.personId &&
          other.investmentId == this.investmentId &&
          other.voidedTransactionId == this.voidedTransactionId &&
          other.notes == this.notes &&
          other.pricePerUnit == this.pricePerUnit &&
          other.units == this.units &&
          other.transactionDate == this.transactionDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> type;
  final Value<double> amount;
  final Value<String?> category;
  final Value<String?> fromAccountId;
  final Value<String?> toAccountId;
  final Value<String?> personId;
  final Value<String?> investmentId;
  final Value<String?> voidedTransactionId;
  final Value<String?> notes;
  final Value<double?> pricePerUnit;
  final Value<double?> units;
  final Value<DateTime> transactionDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.fromAccountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.personId = const Value.absent(),
    this.investmentId = const Value.absent(),
    this.voidedTransactionId = const Value.absent(),
    this.notes = const Value.absent(),
    this.pricePerUnit = const Value.absent(),
    this.units = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String type,
    required double amount,
    this.category = const Value.absent(),
    this.fromAccountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.personId = const Value.absent(),
    this.investmentId = const Value.absent(),
    this.voidedTransactionId = const Value.absent(),
    this.notes = const Value.absent(),
    this.pricePerUnit = const Value.absent(),
    this.units = const Value.absent(),
    required DateTime transactionDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        amount = Value(amount),
        transactionDate = Value(transactionDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<String>? fromAccountId,
    Expression<String>? toAccountId,
    Expression<String>? personId,
    Expression<String>? investmentId,
    Expression<String>? voidedTransactionId,
    Expression<String>? notes,
    Expression<double>? pricePerUnit,
    Expression<double>? units,
    Expression<DateTime>? transactionDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (fromAccountId != null) 'from_account_id': fromAccountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (personId != null) 'person_id': personId,
      if (investmentId != null) 'investment_id': investmentId,
      if (voidedTransactionId != null)
        'voided_transaction_id': voidedTransactionId,
      if (notes != null) 'notes': notes,
      if (pricePerUnit != null) 'price_per_unit': pricePerUnit,
      if (units != null) 'units': units,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<double>? amount,
      Value<String?>? category,
      Value<String?>? fromAccountId,
      Value<String?>? toAccountId,
      Value<String?>? personId,
      Value<String?>? investmentId,
      Value<String?>? voidedTransactionId,
      Value<String?>? notes,
      Value<double?>? pricePerUnit,
      Value<double?>? units,
      Value<DateTime>? transactionDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      personId: personId ?? this.personId,
      investmentId: investmentId ?? this.investmentId,
      voidedTransactionId: voidedTransactionId ?? this.voidedTransactionId,
      notes: notes ?? this.notes,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      units: units ?? this.units,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (fromAccountId.present) {
      map['from_account_id'] = Variable<String>(fromAccountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<String>(toAccountId.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (investmentId.present) {
      map['investment_id'] = Variable<String>(investmentId.value);
    }
    if (voidedTransactionId.present) {
      map['voided_transaction_id'] =
          Variable<String>(voidedTransactionId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (pricePerUnit.present) {
      map['price_per_unit'] = Variable<double>(pricePerUnit.value);
    }
    if (units.present) {
      map['units'] = Variable<double>(units.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('fromAccountId: $fromAccountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('personId: $personId, ')
          ..write('investmentId: $investmentId, ')
          ..write('voidedTransactionId: $voidedTransactionId, ')
          ..write('notes: $notes, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('units: $units, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpectedIncomesTable extends ExpectedIncomes
    with TableInfo<$ExpectedIncomesTable, ExpectedIncome> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpectedIncomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expectedDateMeta =
      const VerificationMeta('expectedDate');
  @override
  late final GeneratedColumn<DateTime> expectedDate = GeneratedColumn<DateTime>(
      'expected_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _receivedTransactionIdMeta =
      const VerificationMeta('receivedTransactionId');
  @override
  late final GeneratedColumn<String> receivedTransactionId =
      GeneratedColumn<String>('received_transaction_id', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: 'REFERENCES transactions(id)');
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        source,
        amount,
        status,
        expectedDate,
        receivedTransactionId,
        notes,
        createdAt,
        updatedAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expected_incomes';
  @override
  VerificationContext validateIntegrity(Insertable<ExpectedIncome> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('expected_date')) {
      context.handle(
          _expectedDateMeta,
          expectedDate.isAcceptableOrUnknown(
              data['expected_date']!, _expectedDateMeta));
    }
    if (data.containsKey('received_transaction_id')) {
      context.handle(
          _receivedTransactionIdMeta,
          receivedTransactionId.isAcceptableOrUnknown(
              data['received_transaction_id']!, _receivedTransactionIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpectedIncome map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpectedIncome(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      expectedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expected_date']),
      receivedTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}received_transaction_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $ExpectedIncomesTable createAlias(String alias) {
    return $ExpectedIncomesTable(attachedDatabase, alias);
  }
}

class ExpectedIncome extends DataClass implements Insertable<ExpectedIncome> {
  final String id;
  final String source;
  final double amount;
  final String status;
  final DateTime? expectedDate;
  final String? receivedTransactionId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const ExpectedIncome(
      {required this.id,
      required this.source,
      required this.amount,
      required this.status,
      this.expectedDate,
      this.receivedTransactionId,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source'] = Variable<String>(source);
    map['amount'] = Variable<double>(amount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || expectedDate != null) {
      map['expected_date'] = Variable<DateTime>(expectedDate);
    }
    if (!nullToAbsent || receivedTransactionId != null) {
      map['received_transaction_id'] = Variable<String>(receivedTransactionId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ExpectedIncomesCompanion toCompanion(bool nullToAbsent) {
    return ExpectedIncomesCompanion(
      id: Value(id),
      source: Value(source),
      amount: Value(amount),
      status: Value(status),
      expectedDate: expectedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedDate),
      receivedTransactionId: receivedTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(receivedTransactionId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ExpectedIncome.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpectedIncome(
      id: serializer.fromJson<String>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      amount: serializer.fromJson<double>(json['amount']),
      status: serializer.fromJson<String>(json['status']),
      expectedDate: serializer.fromJson<DateTime?>(json['expectedDate']),
      receivedTransactionId:
          serializer.fromJson<String?>(json['receivedTransactionId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'source': serializer.toJson<String>(source),
      'amount': serializer.toJson<double>(amount),
      'status': serializer.toJson<String>(status),
      'expectedDate': serializer.toJson<DateTime?>(expectedDate),
      'receivedTransactionId':
          serializer.toJson<String?>(receivedTransactionId),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ExpectedIncome copyWith(
          {String? id,
          String? source,
          double? amount,
          String? status,
          Value<DateTime?> expectedDate = const Value.absent(),
          Value<String?> receivedTransactionId = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus}) =>
      ExpectedIncome(
        id: id ?? this.id,
        source: source ?? this.source,
        amount: amount ?? this.amount,
        status: status ?? this.status,
        expectedDate:
            expectedDate.present ? expectedDate.value : this.expectedDate,
        receivedTransactionId: receivedTransactionId.present
            ? receivedTransactionId.value
            : this.receivedTransactionId,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  ExpectedIncome copyWithCompanion(ExpectedIncomesCompanion data) {
    return ExpectedIncome(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      amount: data.amount.present ? data.amount.value : this.amount,
      status: data.status.present ? data.status.value : this.status,
      expectedDate: data.expectedDate.present
          ? data.expectedDate.value
          : this.expectedDate,
      receivedTransactionId: data.receivedTransactionId.present
          ? data.receivedTransactionId.value
          : this.receivedTransactionId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpectedIncome(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('amount: $amount, ')
          ..write('status: $status, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('receivedTransactionId: $receivedTransactionId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, source, amount, status, expectedDate,
      receivedTransactionId, notes, createdAt, updatedAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpectedIncome &&
          other.id == this.id &&
          other.source == this.source &&
          other.amount == this.amount &&
          other.status == this.status &&
          other.expectedDate == this.expectedDate &&
          other.receivedTransactionId == this.receivedTransactionId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class ExpectedIncomesCompanion extends UpdateCompanion<ExpectedIncome> {
  final Value<String> id;
  final Value<String> source;
  final Value<double> amount;
  final Value<String> status;
  final Value<DateTime?> expectedDate;
  final Value<String?> receivedTransactionId;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ExpectedIncomesCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.amount = const Value.absent(),
    this.status = const Value.absent(),
    this.expectedDate = const Value.absent(),
    this.receivedTransactionId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpectedIncomesCompanion.insert({
    required String id,
    required String source,
    required double amount,
    required String status,
    this.expectedDate = const Value.absent(),
    this.receivedTransactionId = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        source = Value(source),
        amount = Value(amount),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ExpectedIncome> custom({
    Expression<String>? id,
    Expression<String>? source,
    Expression<double>? amount,
    Expression<String>? status,
    Expression<DateTime>? expectedDate,
    Expression<String>? receivedTransactionId,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (amount != null) 'amount': amount,
      if (status != null) 'status': status,
      if (expectedDate != null) 'expected_date': expectedDate,
      if (receivedTransactionId != null)
        'received_transaction_id': receivedTransactionId,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpectedIncomesCompanion copyWith(
      {Value<String>? id,
      Value<String>? source,
      Value<double>? amount,
      Value<String>? status,
      Value<DateTime?>? expectedDate,
      Value<String?>? receivedTransactionId,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return ExpectedIncomesCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      expectedDate: expectedDate ?? this.expectedDate,
      receivedTransactionId:
          receivedTransactionId ?? this.receivedTransactionId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (expectedDate.present) {
      map['expected_date'] = Variable<DateTime>(expectedDate.value);
    }
    if (receivedTransactionId.present) {
      map['received_transaction_id'] =
          Variable<String>(receivedTransactionId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpectedIncomesCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('amount: $amount, ')
          ..write('status: $status, ')
          ..write('expectedDate: $expectedDate, ')
          ..write('receivedTransactionId: $receivedTransactionId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
      'target_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currentAmountMeta =
      const VerificationMeta('currentAmount');
  @override
  late final GeneratedColumn<double> currentAmount = GeneratedColumn<double>(
      'current_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
      'deadline', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<int> isArchived = GeneratedColumn<int>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        targetAmount,
        currentAmount,
        deadline,
        notes,
        isArchived,
        createdAt,
        updatedAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(Insertable<Goal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('current_amount')) {
      context.handle(
          _currentAmountMeta,
          currentAmount.isAcceptableOrUnknown(
              data['current_amount']!, _currentAmountMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_amount'])!,
      currentAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_amount'])!,
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String? notes;
  final int isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const Goal(
      {required this.id,
      required this.name,
      required this.targetAmount,
      required this.currentAmount,
      this.deadline,
      this.notes,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['target_amount'] = Variable<double>(targetAmount);
    map['current_amount'] = Variable<double>(currentAmount);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_archived'] = Variable<int>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      name: Value(name),
      targetAmount: Value(targetAmount),
      currentAmount: Value(currentAmount),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Goal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      currentAmount: serializer.fromJson<double>(json['currentAmount']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      notes: serializer.fromJson<String?>(json['notes']),
      isArchived: serializer.fromJson<int>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'currentAmount': serializer.toJson<double>(currentAmount),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'notes': serializer.toJson<String?>(notes),
      'isArchived': serializer.toJson<int>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Goal copyWith(
          {String? id,
          String? name,
          double? targetAmount,
          double? currentAmount,
          Value<DateTime?> deadline = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          int? isArchived,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus}) =>
      Goal(
        id: id ?? this.id,
        name: name ?? this.name,
        targetAmount: targetAmount ?? this.targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
        deadline: deadline.present ? deadline.value : this.deadline,
        notes: notes.present ? notes.value : this.notes,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      notes: data.notes.present ? data.notes.value : this.notes,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('deadline: $deadline, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, targetAmount, currentAmount,
      deadline, notes, isArchived, createdAt, updatedAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetAmount == this.targetAmount &&
          other.currentAmount == this.currentAmount &&
          other.deadline == this.deadline &&
          other.notes == this.notes &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> targetAmount;
  final Value<double> currentAmount;
  final Value<DateTime?> deadline;
  final Value<String?> notes;
  final Value<int> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.deadline = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String name,
    required double targetAmount,
    this.currentAmount = const Value.absent(),
    this.deadline = const Value.absent(),
    this.notes = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        targetAmount = Value(targetAmount),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Goal> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? targetAmount,
    Expression<double>? currentAmount,
    Expression<DateTime>? deadline,
    Expression<String>? notes,
    Expression<int>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (deadline != null) 'deadline': deadline,
      if (notes != null) 'notes': notes,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<double>? targetAmount,
      Value<double>? currentAmount,
      Value<DateTime?>? deadline,
      Value<String?>? notes,
      Value<int>? isArchived,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return GoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<double>(currentAmount.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<int>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('deadline: $deadline, ')
          ..write('notes: $notes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalMilestonesTable extends GoalMilestones
    with TableInfo<$GoalMilestonesTable, GoalMilestone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalMilestonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
      'goal_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES goals(id) ON DELETE CASCADE');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
      'target_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _reachedAtMeta =
      const VerificationMeta('reachedAt');
  @override
  late final GeneratedColumn<DateTime> reachedAt = GeneratedColumn<DateTime>(
      'reached_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<int> isArchived = GeneratedColumn<int>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        goalId,
        name,
        targetAmount,
        reachedAt,
        isArchived,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_milestones';
  @override
  VerificationContext validateIntegrity(Insertable<GoalMilestone> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta,
          goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('reached_at')) {
      context.handle(_reachedAtMeta,
          reachedAt.isAcceptableOrUnknown(data['reached_at']!, _reachedAtMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalMilestone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalMilestone(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      goalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_amount'])!,
      reachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}reached_at']),
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GoalMilestonesTable createAlias(String alias) {
    return $GoalMilestonesTable(attachedDatabase, alias);
  }
}

class GoalMilestone extends DataClass implements Insertable<GoalMilestone> {
  final String id;
  final String goalId;
  final String name;
  final double targetAmount;
  final DateTime? reachedAt;
  final int isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const GoalMilestone(
      {required this.id,
      required this.goalId,
      required this.name,
      required this.targetAmount,
      this.reachedAt,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['goal_id'] = Variable<String>(goalId);
    map['name'] = Variable<String>(name);
    map['target_amount'] = Variable<double>(targetAmount);
    if (!nullToAbsent || reachedAt != null) {
      map['reached_at'] = Variable<DateTime>(reachedAt);
    }
    map['is_archived'] = Variable<int>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GoalMilestonesCompanion toCompanion(bool nullToAbsent) {
    return GoalMilestonesCompanion(
      id: Value(id),
      goalId: Value(goalId),
      name: Value(name),
      targetAmount: Value(targetAmount),
      reachedAt: reachedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reachedAt),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GoalMilestone.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalMilestone(
      id: serializer.fromJson<String>(json['id']),
      goalId: serializer.fromJson<String>(json['goalId']),
      name: serializer.fromJson<String>(json['name']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      reachedAt: serializer.fromJson<DateTime?>(json['reachedAt']),
      isArchived: serializer.fromJson<int>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'goalId': serializer.toJson<String>(goalId),
      'name': serializer.toJson<String>(name),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'reachedAt': serializer.toJson<DateTime?>(reachedAt),
      'isArchived': serializer.toJson<int>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GoalMilestone copyWith(
          {String? id,
          String? goalId,
          String? name,
          double? targetAmount,
          Value<DateTime?> reachedAt = const Value.absent(),
          int? isArchived,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      GoalMilestone(
        id: id ?? this.id,
        goalId: goalId ?? this.goalId,
        name: name ?? this.name,
        targetAmount: targetAmount ?? this.targetAmount,
        reachedAt: reachedAt.present ? reachedAt.value : this.reachedAt,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GoalMilestone copyWithCompanion(GoalMilestonesCompanion data) {
    return GoalMilestone(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      name: data.name.present ? data.name.value : this.name,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      reachedAt: data.reachedAt.present ? data.reachedAt.value : this.reachedAt,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalMilestone(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('reachedAt: $reachedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, goalId, name, targetAmount, reachedAt,
      isArchived, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalMilestone &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.name == this.name &&
          other.targetAmount == this.targetAmount &&
          other.reachedAt == this.reachedAt &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GoalMilestonesCompanion extends UpdateCompanion<GoalMilestone> {
  final Value<String> id;
  final Value<String> goalId;
  final Value<String> name;
  final Value<double> targetAmount;
  final Value<DateTime?> reachedAt;
  final Value<int> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GoalMilestonesCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.reachedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalMilestonesCompanion.insert({
    required String id,
    required String goalId,
    required String name,
    required double targetAmount,
    this.reachedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        goalId = Value(goalId),
        name = Value(name),
        targetAmount = Value(targetAmount),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<GoalMilestone> custom({
    Expression<String>? id,
    Expression<String>? goalId,
    Expression<String>? name,
    Expression<double>? targetAmount,
    Expression<DateTime>? reachedAt,
    Expression<int>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (name != null) 'name': name,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (reachedAt != null) 'reached_at': reachedAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalMilestonesCompanion copyWith(
      {Value<String>? id,
      Value<String>? goalId,
      Value<String>? name,
      Value<double>? targetAmount,
      Value<DateTime?>? reachedAt,
      Value<int>? isArchived,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return GoalMilestonesCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      reachedAt: reachedAt ?? this.reachedAt,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (reachedAt.present) {
      map['reached_at'] = Variable<DateTime>(reachedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<int>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalMilestonesCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('reachedAt: $reachedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SnapshotsTable extends Snapshots
    with TableInfo<$SnapshotsTable, Snapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _snapshotDateMeta =
      const VerificationMeta('snapshotDate');
  @override
  late final GeneratedColumn<DateTime> snapshotDate = GeneratedColumn<DateTime>(
      'snapshot_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _netWorthMeta =
      const VerificationMeta('netWorth');
  @override
  late final GeneratedColumn<double> netWorth = GeneratedColumn<double>(
      'net_worth', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _assetsMeta = const VerificationMeta('assets');
  @override
  late final GeneratedColumn<double> assets = GeneratedColumn<double>(
      'assets', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _liabilitiesMeta =
      const VerificationMeta('liabilities');
  @override
  late final GeneratedColumn<double> liabilities = GeneratedColumn<double>(
      'liabilities', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _receivablesMeta =
      const VerificationMeta('receivables');
  @override
  late final GeneratedColumn<double> receivables = GeneratedColumn<double>(
      'receivables', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _investedCapitalMeta =
      const VerificationMeta('investedCapital');
  @override
  late final GeneratedColumn<double> investedCapital = GeneratedColumn<double>(
      'invested_capital', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _expectedIncomeMeta =
      const VerificationMeta('expectedIncome');
  @override
  late final GeneratedColumn<double> expectedIncome = GeneratedColumn<double>(
      'expected_income', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        snapshotDate,
        netWorth,
        assets,
        liabilities,
        receivables,
        investedCapital,
        expectedIncome,
        createdAt,
        updatedAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snapshots';
  @override
  VerificationContext validateIntegrity(Insertable<Snapshot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('snapshot_date')) {
      context.handle(
          _snapshotDateMeta,
          snapshotDate.isAcceptableOrUnknown(
              data['snapshot_date']!, _snapshotDateMeta));
    } else if (isInserting) {
      context.missing(_snapshotDateMeta);
    }
    if (data.containsKey('net_worth')) {
      context.handle(_netWorthMeta,
          netWorth.isAcceptableOrUnknown(data['net_worth']!, _netWorthMeta));
    } else if (isInserting) {
      context.missing(_netWorthMeta);
    }
    if (data.containsKey('assets')) {
      context.handle(_assetsMeta,
          assets.isAcceptableOrUnknown(data['assets']!, _assetsMeta));
    } else if (isInserting) {
      context.missing(_assetsMeta);
    }
    if (data.containsKey('liabilities')) {
      context.handle(
          _liabilitiesMeta,
          liabilities.isAcceptableOrUnknown(
              data['liabilities']!, _liabilitiesMeta));
    } else if (isInserting) {
      context.missing(_liabilitiesMeta);
    }
    if (data.containsKey('receivables')) {
      context.handle(
          _receivablesMeta,
          receivables.isAcceptableOrUnknown(
              data['receivables']!, _receivablesMeta));
    }
    if (data.containsKey('invested_capital')) {
      context.handle(
          _investedCapitalMeta,
          investedCapital.isAcceptableOrUnknown(
              data['invested_capital']!, _investedCapitalMeta));
    } else if (isInserting) {
      context.missing(_investedCapitalMeta);
    }
    if (data.containsKey('expected_income')) {
      context.handle(
          _expectedIncomeMeta,
          expectedIncome.isAcceptableOrUnknown(
              data['expected_income']!, _expectedIncomeMeta));
    } else if (isInserting) {
      context.missing(_expectedIncomeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Snapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Snapshot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      snapshotDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}snapshot_date'])!,
      netWorth: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}net_worth'])!,
      assets: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}assets'])!,
      liabilities: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}liabilities'])!,
      receivables: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}receivables'])!,
      investedCapital: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}invested_capital'])!,
      expectedIncome: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}expected_income'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $SnapshotsTable createAlias(String alias) {
    return $SnapshotsTable(attachedDatabase, alias);
  }
}

class Snapshot extends DataClass implements Insertable<Snapshot> {
  final String id;
  final DateTime snapshotDate;
  final double netWorth;
  final double assets;
  final double liabilities;
  final double receivables;
  final double investedCapital;
  final double expectedIncome;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const Snapshot(
      {required this.id,
      required this.snapshotDate,
      required this.netWorth,
      required this.assets,
      required this.liabilities,
      required this.receivables,
      required this.investedCapital,
      required this.expectedIncome,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['snapshot_date'] = Variable<DateTime>(snapshotDate);
    map['net_worth'] = Variable<double>(netWorth);
    map['assets'] = Variable<double>(assets);
    map['liabilities'] = Variable<double>(liabilities);
    map['receivables'] = Variable<double>(receivables);
    map['invested_capital'] = Variable<double>(investedCapital);
    map['expected_income'] = Variable<double>(expectedIncome);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  SnapshotsCompanion toCompanion(bool nullToAbsent) {
    return SnapshotsCompanion(
      id: Value(id),
      snapshotDate: Value(snapshotDate),
      netWorth: Value(netWorth),
      assets: Value(assets),
      liabilities: Value(liabilities),
      receivables: Value(receivables),
      investedCapital: Value(investedCapital),
      expectedIncome: Value(expectedIncome),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Snapshot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Snapshot(
      id: serializer.fromJson<String>(json['id']),
      snapshotDate: serializer.fromJson<DateTime>(json['snapshotDate']),
      netWorth: serializer.fromJson<double>(json['netWorth']),
      assets: serializer.fromJson<double>(json['assets']),
      liabilities: serializer.fromJson<double>(json['liabilities']),
      receivables: serializer.fromJson<double>(json['receivables']),
      investedCapital: serializer.fromJson<double>(json['investedCapital']),
      expectedIncome: serializer.fromJson<double>(json['expectedIncome']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'snapshotDate': serializer.toJson<DateTime>(snapshotDate),
      'netWorth': serializer.toJson<double>(netWorth),
      'assets': serializer.toJson<double>(assets),
      'liabilities': serializer.toJson<double>(liabilities),
      'receivables': serializer.toJson<double>(receivables),
      'investedCapital': serializer.toJson<double>(investedCapital),
      'expectedIncome': serializer.toJson<double>(expectedIncome),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Snapshot copyWith(
          {String? id,
          DateTime? snapshotDate,
          double? netWorth,
          double? assets,
          double? liabilities,
          double? receivables,
          double? investedCapital,
          double? expectedIncome,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus}) =>
      Snapshot(
        id: id ?? this.id,
        snapshotDate: snapshotDate ?? this.snapshotDate,
        netWorth: netWorth ?? this.netWorth,
        assets: assets ?? this.assets,
        liabilities: liabilities ?? this.liabilities,
        receivables: receivables ?? this.receivables,
        investedCapital: investedCapital ?? this.investedCapital,
        expectedIncome: expectedIncome ?? this.expectedIncome,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Snapshot copyWithCompanion(SnapshotsCompanion data) {
    return Snapshot(
      id: data.id.present ? data.id.value : this.id,
      snapshotDate: data.snapshotDate.present
          ? data.snapshotDate.value
          : this.snapshotDate,
      netWorth: data.netWorth.present ? data.netWorth.value : this.netWorth,
      assets: data.assets.present ? data.assets.value : this.assets,
      liabilities:
          data.liabilities.present ? data.liabilities.value : this.liabilities,
      receivables:
          data.receivables.present ? data.receivables.value : this.receivables,
      investedCapital: data.investedCapital.present
          ? data.investedCapital.value
          : this.investedCapital,
      expectedIncome: data.expectedIncome.present
          ? data.expectedIncome.value
          : this.expectedIncome,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Snapshot(')
          ..write('id: $id, ')
          ..write('snapshotDate: $snapshotDate, ')
          ..write('netWorth: $netWorth, ')
          ..write('assets: $assets, ')
          ..write('liabilities: $liabilities, ')
          ..write('receivables: $receivables, ')
          ..write('investedCapital: $investedCapital, ')
          ..write('expectedIncome: $expectedIncome, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      snapshotDate,
      netWorth,
      assets,
      liabilities,
      receivables,
      investedCapital,
      expectedIncome,
      createdAt,
      updatedAt,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Snapshot &&
          other.id == this.id &&
          other.snapshotDate == this.snapshotDate &&
          other.netWorth == this.netWorth &&
          other.assets == this.assets &&
          other.liabilities == this.liabilities &&
          other.receivables == this.receivables &&
          other.investedCapital == this.investedCapital &&
          other.expectedIncome == this.expectedIncome &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class SnapshotsCompanion extends UpdateCompanion<Snapshot> {
  final Value<String> id;
  final Value<DateTime> snapshotDate;
  final Value<double> netWorth;
  final Value<double> assets;
  final Value<double> liabilities;
  final Value<double> receivables;
  final Value<double> investedCapital;
  final Value<double> expectedIncome;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const SnapshotsCompanion({
    this.id = const Value.absent(),
    this.snapshotDate = const Value.absent(),
    this.netWorth = const Value.absent(),
    this.assets = const Value.absent(),
    this.liabilities = const Value.absent(),
    this.receivables = const Value.absent(),
    this.investedCapital = const Value.absent(),
    this.expectedIncome = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SnapshotsCompanion.insert({
    required String id,
    required DateTime snapshotDate,
    required double netWorth,
    required double assets,
    required double liabilities,
    this.receivables = const Value.absent(),
    required double investedCapital,
    required double expectedIncome,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        snapshotDate = Value(snapshotDate),
        netWorth = Value(netWorth),
        assets = Value(assets),
        liabilities = Value(liabilities),
        investedCapital = Value(investedCapital),
        expectedIncome = Value(expectedIncome),
        createdAt = Value(createdAt);
  static Insertable<Snapshot> custom({
    Expression<String>? id,
    Expression<DateTime>? snapshotDate,
    Expression<double>? netWorth,
    Expression<double>? assets,
    Expression<double>? liabilities,
    Expression<double>? receivables,
    Expression<double>? investedCapital,
    Expression<double>? expectedIncome,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (snapshotDate != null) 'snapshot_date': snapshotDate,
      if (netWorth != null) 'net_worth': netWorth,
      if (assets != null) 'assets': assets,
      if (liabilities != null) 'liabilities': liabilities,
      if (receivables != null) 'receivables': receivables,
      if (investedCapital != null) 'invested_capital': investedCapital,
      if (expectedIncome != null) 'expected_income': expectedIncome,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SnapshotsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? snapshotDate,
      Value<double>? netWorth,
      Value<double>? assets,
      Value<double>? liabilities,
      Value<double>? receivables,
      Value<double>? investedCapital,
      Value<double>? expectedIncome,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return SnapshotsCompanion(
      id: id ?? this.id,
      snapshotDate: snapshotDate ?? this.snapshotDate,
      netWorth: netWorth ?? this.netWorth,
      assets: assets ?? this.assets,
      liabilities: liabilities ?? this.liabilities,
      receivables: receivables ?? this.receivables,
      investedCapital: investedCapital ?? this.investedCapital,
      expectedIncome: expectedIncome ?? this.expectedIncome,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (snapshotDate.present) {
      map['snapshot_date'] = Variable<DateTime>(snapshotDate.value);
    }
    if (netWorth.present) {
      map['net_worth'] = Variable<double>(netWorth.value);
    }
    if (assets.present) {
      map['assets'] = Variable<double>(assets.value);
    }
    if (liabilities.present) {
      map['liabilities'] = Variable<double>(liabilities.value);
    }
    if (receivables.present) {
      map['receivables'] = Variable<double>(receivables.value);
    }
    if (investedCapital.present) {
      map['invested_capital'] = Variable<double>(investedCapital.value);
    }
    if (expectedIncome.present) {
      map['expected_income'] = Variable<double>(expectedIncome.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('snapshotDate: $snapshotDate, ')
          ..write('netWorth: $netWorth, ')
          ..write('assets: $assets, ')
          ..write('liabilities: $liabilities, ')
          ..write('receivables: $receivables, ')
          ..write('investedCapital: $investedCapital, ')
          ..write('expectedIncome: $expectedIncome, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value']),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String? value;
  const Setting({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  Setting copyWith(
          {String? key, Value<String?> value = const Value.absent()}) =>
      Setting(
        key: key ?? this.key,
        value: value.present ? value.value : this.value,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key, Value<String?>? value, Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailsJsonMeta =
      const VerificationMeta('detailsJson');
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
      'details_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, entityType, entityId, action, detailsJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(Insertable<AuditLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('details_json')) {
      context.handle(
          _detailsJsonMeta,
          detailsJson.isAcceptableOrUnknown(
              data['details_json']!, _detailsJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      detailsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}details_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final String? detailsJson;
  final DateTime createdAt;
  const AuditLog(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.action,
      this.detailsJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || detailsJson != null) {
      map['details_json'] = Variable<String>(detailsJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      detailsJson: detailsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(detailsJson),
      createdAt: Value(createdAt),
    );
  }

  factory AuditLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      detailsJson: serializer.fromJson<String?>(json['detailsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'detailsJson': serializer.toJson<String?>(detailsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AuditLog copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          String? action,
          Value<String?> detailsJson = const Value.absent(),
          DateTime? createdAt}) =>
      AuditLog(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        action: action ?? this.action,
        detailsJson: detailsJson.present ? detailsJson.value : this.detailsJson,
        createdAt: createdAt ?? this.createdAt,
      );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      detailsJson:
          data.detailsJson.present ? data.detailsJson.value : this.detailsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entityType, entityId, action, detailsJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.detailsJson == this.detailsJson &&
          other.createdAt == this.createdAt);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String?> detailsJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String action,
    this.detailsJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        action = Value(action),
        createdAt = Value(createdAt);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? detailsJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (detailsJson != null) 'details_json': detailsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? action,
      Value<String?>? detailsJson,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      detailsJson: detailsJson ?? this.detailsJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountBalanceCachesTable extends AccountBalanceCaches
    with TableInfo<$AccountBalanceCachesTable, AccountBalanceCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountBalanceCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES accounts(id)');
  static const VerificationMeta _cashBalanceMeta =
      const VerificationMeta('cashBalance');
  @override
  late final GeneratedColumn<double> cashBalance = GeneratedColumn<double>(
      'cash_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _liabilityBalanceMeta =
      const VerificationMeta('liabilityBalance');
  @override
  late final GeneratedColumn<double> liabilityBalance = GeneratedColumn<double>(
      'liability_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _lastTransactionIdMeta =
      const VerificationMeta('lastTransactionId');
  @override
  late final GeneratedColumn<String> lastTransactionId =
      GeneratedColumn<String>('last_transaction_id', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: 'REFERENCES transactions(id)');
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [accountId, cashBalance, liabilityBalance, lastTransactionId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_balance_caches';
  @override
  VerificationContext validateIntegrity(
      Insertable<AccountBalanceCache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('cash_balance')) {
      context.handle(
          _cashBalanceMeta,
          cashBalance.isAcceptableOrUnknown(
              data['cash_balance']!, _cashBalanceMeta));
    }
    if (data.containsKey('liability_balance')) {
      context.handle(
          _liabilityBalanceMeta,
          liabilityBalance.isAcceptableOrUnknown(
              data['liability_balance']!, _liabilityBalanceMeta));
    }
    if (data.containsKey('last_transaction_id')) {
      context.handle(
          _lastTransactionIdMeta,
          lastTransactionId.isAcceptableOrUnknown(
              data['last_transaction_id']!, _lastTransactionIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId};
  @override
  AccountBalanceCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountBalanceCache(
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      cashBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cash_balance'])!,
      liabilityBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}liability_balance'])!,
      lastTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_transaction_id']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AccountBalanceCachesTable createAlias(String alias) {
    return $AccountBalanceCachesTable(attachedDatabase, alias);
  }
}

class AccountBalanceCache extends DataClass
    implements Insertable<AccountBalanceCache> {
  final String accountId;
  final double cashBalance;
  final double liabilityBalance;
  final String? lastTransactionId;
  final DateTime updatedAt;
  const AccountBalanceCache(
      {required this.accountId,
      required this.cashBalance,
      required this.liabilityBalance,
      this.lastTransactionId,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['cash_balance'] = Variable<double>(cashBalance);
    map['liability_balance'] = Variable<double>(liabilityBalance);
    if (!nullToAbsent || lastTransactionId != null) {
      map['last_transaction_id'] = Variable<String>(lastTransactionId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AccountBalanceCachesCompanion toCompanion(bool nullToAbsent) {
    return AccountBalanceCachesCompanion(
      accountId: Value(accountId),
      cashBalance: Value(cashBalance),
      liabilityBalance: Value(liabilityBalance),
      lastTransactionId: lastTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTransactionId),
      updatedAt: Value(updatedAt),
    );
  }

  factory AccountBalanceCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountBalanceCache(
      accountId: serializer.fromJson<String>(json['accountId']),
      cashBalance: serializer.fromJson<double>(json['cashBalance']),
      liabilityBalance: serializer.fromJson<double>(json['liabilityBalance']),
      lastTransactionId:
          serializer.fromJson<String?>(json['lastTransactionId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'cashBalance': serializer.toJson<double>(cashBalance),
      'liabilityBalance': serializer.toJson<double>(liabilityBalance),
      'lastTransactionId': serializer.toJson<String?>(lastTransactionId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AccountBalanceCache copyWith(
          {String? accountId,
          double? cashBalance,
          double? liabilityBalance,
          Value<String?> lastTransactionId = const Value.absent(),
          DateTime? updatedAt}) =>
      AccountBalanceCache(
        accountId: accountId ?? this.accountId,
        cashBalance: cashBalance ?? this.cashBalance,
        liabilityBalance: liabilityBalance ?? this.liabilityBalance,
        lastTransactionId: lastTransactionId.present
            ? lastTransactionId.value
            : this.lastTransactionId,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AccountBalanceCache copyWithCompanion(AccountBalanceCachesCompanion data) {
    return AccountBalanceCache(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      cashBalance:
          data.cashBalance.present ? data.cashBalance.value : this.cashBalance,
      liabilityBalance: data.liabilityBalance.present
          ? data.liabilityBalance.value
          : this.liabilityBalance,
      lastTransactionId: data.lastTransactionId.present
          ? data.lastTransactionId.value
          : this.lastTransactionId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountBalanceCache(')
          ..write('accountId: $accountId, ')
          ..write('cashBalance: $cashBalance, ')
          ..write('liabilityBalance: $liabilityBalance, ')
          ..write('lastTransactionId: $lastTransactionId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      accountId, cashBalance, liabilityBalance, lastTransactionId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountBalanceCache &&
          other.accountId == this.accountId &&
          other.cashBalance == this.cashBalance &&
          other.liabilityBalance == this.liabilityBalance &&
          other.lastTransactionId == this.lastTransactionId &&
          other.updatedAt == this.updatedAt);
}

class AccountBalanceCachesCompanion
    extends UpdateCompanion<AccountBalanceCache> {
  final Value<String> accountId;
  final Value<double> cashBalance;
  final Value<double> liabilityBalance;
  final Value<String?> lastTransactionId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AccountBalanceCachesCompanion({
    this.accountId = const Value.absent(),
    this.cashBalance = const Value.absent(),
    this.liabilityBalance = const Value.absent(),
    this.lastTransactionId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountBalanceCachesCompanion.insert({
    required String accountId,
    this.cashBalance = const Value.absent(),
    this.liabilityBalance = const Value.absent(),
    this.lastTransactionId = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : accountId = Value(accountId),
        updatedAt = Value(updatedAt);
  static Insertable<AccountBalanceCache> custom({
    Expression<String>? accountId,
    Expression<double>? cashBalance,
    Expression<double>? liabilityBalance,
    Expression<String>? lastTransactionId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (cashBalance != null) 'cash_balance': cashBalance,
      if (liabilityBalance != null) 'liability_balance': liabilityBalance,
      if (lastTransactionId != null) 'last_transaction_id': lastTransactionId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountBalanceCachesCompanion copyWith(
      {Value<String>? accountId,
      Value<double>? cashBalance,
      Value<double>? liabilityBalance,
      Value<String?>? lastTransactionId,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AccountBalanceCachesCompanion(
      accountId: accountId ?? this.accountId,
      cashBalance: cashBalance ?? this.cashBalance,
      liabilityBalance: liabilityBalance ?? this.liabilityBalance,
      lastTransactionId: lastTransactionId ?? this.lastTransactionId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (cashBalance.present) {
      map['cash_balance'] = Variable<double>(cashBalance.value);
    }
    if (liabilityBalance.present) {
      map['liability_balance'] = Variable<double>(liabilityBalance.value);
    }
    if (lastTransactionId.present) {
      map['last_transaction_id'] = Variable<String>(lastTransactionId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountBalanceCachesCompanion(')
          ..write('accountId: $accountId, ')
          ..write('cashBalance: $cashBalance, ')
          ..write('liabilityBalance: $liabilityBalance, ')
          ..write('lastTransactionId: $lastTransactionId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonBalanceCachesTable extends PersonBalanceCaches
    with TableInfo<$PersonBalanceCachesTable, PersonBalanceCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonBalanceCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _personIdMeta =
      const VerificationMeta('personId');
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
      'person_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES people(id)');
  static const VerificationMeta _receivableBalanceMeta =
      const VerificationMeta('receivableBalance');
  @override
  late final GeneratedColumn<double> receivableBalance =
      GeneratedColumn<double>('receivable_balance', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _liabilityBalanceMeta =
      const VerificationMeta('liabilityBalance');
  @override
  late final GeneratedColumn<double> liabilityBalance = GeneratedColumn<double>(
      'liability_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _lastTransactionIdMeta =
      const VerificationMeta('lastTransactionId');
  @override
  late final GeneratedColumn<String> lastTransactionId =
      GeneratedColumn<String>('last_transaction_id', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: 'REFERENCES transactions(id)');
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        personId,
        receivableBalance,
        liabilityBalance,
        lastTransactionId,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'person_balance_caches';
  @override
  VerificationContext validateIntegrity(Insertable<PersonBalanceCache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('person_id')) {
      context.handle(_personIdMeta,
          personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta));
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('receivable_balance')) {
      context.handle(
          _receivableBalanceMeta,
          receivableBalance.isAcceptableOrUnknown(
              data['receivable_balance']!, _receivableBalanceMeta));
    }
    if (data.containsKey('liability_balance')) {
      context.handle(
          _liabilityBalanceMeta,
          liabilityBalance.isAcceptableOrUnknown(
              data['liability_balance']!, _liabilityBalanceMeta));
    }
    if (data.containsKey('last_transaction_id')) {
      context.handle(
          _lastTransactionIdMeta,
          lastTransactionId.isAcceptableOrUnknown(
              data['last_transaction_id']!, _lastTransactionIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {personId};
  @override
  PersonBalanceCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonBalanceCache(
      personId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_id'])!,
      receivableBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}receivable_balance'])!,
      liabilityBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}liability_balance'])!,
      lastTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_transaction_id']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PersonBalanceCachesTable createAlias(String alias) {
    return $PersonBalanceCachesTable(attachedDatabase, alias);
  }
}

class PersonBalanceCache extends DataClass
    implements Insertable<PersonBalanceCache> {
  final String personId;
  final double receivableBalance;
  final double liabilityBalance;
  final String? lastTransactionId;
  final DateTime updatedAt;
  const PersonBalanceCache(
      {required this.personId,
      required this.receivableBalance,
      required this.liabilityBalance,
      this.lastTransactionId,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['person_id'] = Variable<String>(personId);
    map['receivable_balance'] = Variable<double>(receivableBalance);
    map['liability_balance'] = Variable<double>(liabilityBalance);
    if (!nullToAbsent || lastTransactionId != null) {
      map['last_transaction_id'] = Variable<String>(lastTransactionId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PersonBalanceCachesCompanion toCompanion(bool nullToAbsent) {
    return PersonBalanceCachesCompanion(
      personId: Value(personId),
      receivableBalance: Value(receivableBalance),
      liabilityBalance: Value(liabilityBalance),
      lastTransactionId: lastTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTransactionId),
      updatedAt: Value(updatedAt),
    );
  }

  factory PersonBalanceCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonBalanceCache(
      personId: serializer.fromJson<String>(json['personId']),
      receivableBalance: serializer.fromJson<double>(json['receivableBalance']),
      liabilityBalance: serializer.fromJson<double>(json['liabilityBalance']),
      lastTransactionId:
          serializer.fromJson<String?>(json['lastTransactionId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'personId': serializer.toJson<String>(personId),
      'receivableBalance': serializer.toJson<double>(receivableBalance),
      'liabilityBalance': serializer.toJson<double>(liabilityBalance),
      'lastTransactionId': serializer.toJson<String?>(lastTransactionId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PersonBalanceCache copyWith(
          {String? personId,
          double? receivableBalance,
          double? liabilityBalance,
          Value<String?> lastTransactionId = const Value.absent(),
          DateTime? updatedAt}) =>
      PersonBalanceCache(
        personId: personId ?? this.personId,
        receivableBalance: receivableBalance ?? this.receivableBalance,
        liabilityBalance: liabilityBalance ?? this.liabilityBalance,
        lastTransactionId: lastTransactionId.present
            ? lastTransactionId.value
            : this.lastTransactionId,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PersonBalanceCache copyWithCompanion(PersonBalanceCachesCompanion data) {
    return PersonBalanceCache(
      personId: data.personId.present ? data.personId.value : this.personId,
      receivableBalance: data.receivableBalance.present
          ? data.receivableBalance.value
          : this.receivableBalance,
      liabilityBalance: data.liabilityBalance.present
          ? data.liabilityBalance.value
          : this.liabilityBalance,
      lastTransactionId: data.lastTransactionId.present
          ? data.lastTransactionId.value
          : this.lastTransactionId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonBalanceCache(')
          ..write('personId: $personId, ')
          ..write('receivableBalance: $receivableBalance, ')
          ..write('liabilityBalance: $liabilityBalance, ')
          ..write('lastTransactionId: $lastTransactionId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(personId, receivableBalance, liabilityBalance,
      lastTransactionId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonBalanceCache &&
          other.personId == this.personId &&
          other.receivableBalance == this.receivableBalance &&
          other.liabilityBalance == this.liabilityBalance &&
          other.lastTransactionId == this.lastTransactionId &&
          other.updatedAt == this.updatedAt);
}

class PersonBalanceCachesCompanion extends UpdateCompanion<PersonBalanceCache> {
  final Value<String> personId;
  final Value<double> receivableBalance;
  final Value<double> liabilityBalance;
  final Value<String?> lastTransactionId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PersonBalanceCachesCompanion({
    this.personId = const Value.absent(),
    this.receivableBalance = const Value.absent(),
    this.liabilityBalance = const Value.absent(),
    this.lastTransactionId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonBalanceCachesCompanion.insert({
    required String personId,
    this.receivableBalance = const Value.absent(),
    this.liabilityBalance = const Value.absent(),
    this.lastTransactionId = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : personId = Value(personId),
        updatedAt = Value(updatedAt);
  static Insertable<PersonBalanceCache> custom({
    Expression<String>? personId,
    Expression<double>? receivableBalance,
    Expression<double>? liabilityBalance,
    Expression<String>? lastTransactionId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (personId != null) 'person_id': personId,
      if (receivableBalance != null) 'receivable_balance': receivableBalance,
      if (liabilityBalance != null) 'liability_balance': liabilityBalance,
      if (lastTransactionId != null) 'last_transaction_id': lastTransactionId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonBalanceCachesCompanion copyWith(
      {Value<String>? personId,
      Value<double>? receivableBalance,
      Value<double>? liabilityBalance,
      Value<String?>? lastTransactionId,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PersonBalanceCachesCompanion(
      personId: personId ?? this.personId,
      receivableBalance: receivableBalance ?? this.receivableBalance,
      liabilityBalance: liabilityBalance ?? this.liabilityBalance,
      lastTransactionId: lastTransactionId ?? this.lastTransactionId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (receivableBalance.present) {
      map['receivable_balance'] = Variable<double>(receivableBalance.value);
    }
    if (liabilityBalance.present) {
      map['liability_balance'] = Variable<double>(liabilityBalance.value);
    }
    if (lastTransactionId.present) {
      map['last_transaction_id'] = Variable<String>(lastTransactionId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonBalanceCachesCompanion(')
          ..write('personId: $personId, ')
          ..write('receivableBalance: $receivableBalance, ')
          ..write('liabilityBalance: $liabilityBalance, ')
          ..write('lastTransactionId: $lastTransactionId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentBalanceCachesTable extends InvestmentBalanceCaches
    with TableInfo<$InvestmentBalanceCachesTable, InvestmentBalanceCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentBalanceCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _investmentIdMeta =
      const VerificationMeta('investmentId');
  @override
  late final GeneratedColumn<String> investmentId = GeneratedColumn<String>(
      'investment_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES investments(id)');
  static const VerificationMeta _investedCapitalMeta =
      const VerificationMeta('investedCapital');
  @override
  late final GeneratedColumn<double> investedCapital = GeneratedColumn<double>(
      'invested_capital', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _unitsHeldMeta =
      const VerificationMeta('unitsHeld');
  @override
  late final GeneratedColumn<double> unitsHeld = GeneratedColumn<double>(
      'units_held', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _lastTransactionIdMeta =
      const VerificationMeta('lastTransactionId');
  @override
  late final GeneratedColumn<String> lastTransactionId =
      GeneratedColumn<String>('last_transaction_id', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: 'REFERENCES transactions(id)');
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [investmentId, investedCapital, unitsHeld, lastTransactionId, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investment_balance_caches';
  @override
  VerificationContext validateIntegrity(
      Insertable<InvestmentBalanceCache> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('investment_id')) {
      context.handle(
          _investmentIdMeta,
          investmentId.isAcceptableOrUnknown(
              data['investment_id']!, _investmentIdMeta));
    } else if (isInserting) {
      context.missing(_investmentIdMeta);
    }
    if (data.containsKey('invested_capital')) {
      context.handle(
          _investedCapitalMeta,
          investedCapital.isAcceptableOrUnknown(
              data['invested_capital']!, _investedCapitalMeta));
    }
    if (data.containsKey('units_held')) {
      context.handle(_unitsHeldMeta,
          unitsHeld.isAcceptableOrUnknown(data['units_held']!, _unitsHeldMeta));
    }
    if (data.containsKey('last_transaction_id')) {
      context.handle(
          _lastTransactionIdMeta,
          lastTransactionId.isAcceptableOrUnknown(
              data['last_transaction_id']!, _lastTransactionIdMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {investmentId};
  @override
  InvestmentBalanceCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentBalanceCache(
      investmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}investment_id'])!,
      investedCapital: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}invested_capital'])!,
      unitsHeld: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}units_held'])!,
      lastTransactionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_transaction_id']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $InvestmentBalanceCachesTable createAlias(String alias) {
    return $InvestmentBalanceCachesTable(attachedDatabase, alias);
  }
}

class InvestmentBalanceCache extends DataClass
    implements Insertable<InvestmentBalanceCache> {
  final String investmentId;
  final double investedCapital;
  final double unitsHeld;
  final String? lastTransactionId;
  final DateTime updatedAt;
  const InvestmentBalanceCache(
      {required this.investmentId,
      required this.investedCapital,
      required this.unitsHeld,
      this.lastTransactionId,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['investment_id'] = Variable<String>(investmentId);
    map['invested_capital'] = Variable<double>(investedCapital);
    map['units_held'] = Variable<double>(unitsHeld);
    if (!nullToAbsent || lastTransactionId != null) {
      map['last_transaction_id'] = Variable<String>(lastTransactionId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InvestmentBalanceCachesCompanion toCompanion(bool nullToAbsent) {
    return InvestmentBalanceCachesCompanion(
      investmentId: Value(investmentId),
      investedCapital: Value(investedCapital),
      unitsHeld: Value(unitsHeld),
      lastTransactionId: lastTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTransactionId),
      updatedAt: Value(updatedAt),
    );
  }

  factory InvestmentBalanceCache.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentBalanceCache(
      investmentId: serializer.fromJson<String>(json['investmentId']),
      investedCapital: serializer.fromJson<double>(json['investedCapital']),
      unitsHeld: serializer.fromJson<double>(json['unitsHeld']),
      lastTransactionId:
          serializer.fromJson<String?>(json['lastTransactionId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'investmentId': serializer.toJson<String>(investmentId),
      'investedCapital': serializer.toJson<double>(investedCapital),
      'unitsHeld': serializer.toJson<double>(unitsHeld),
      'lastTransactionId': serializer.toJson<String?>(lastTransactionId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  InvestmentBalanceCache copyWith(
          {String? investmentId,
          double? investedCapital,
          double? unitsHeld,
          Value<String?> lastTransactionId = const Value.absent(),
          DateTime? updatedAt}) =>
      InvestmentBalanceCache(
        investmentId: investmentId ?? this.investmentId,
        investedCapital: investedCapital ?? this.investedCapital,
        unitsHeld: unitsHeld ?? this.unitsHeld,
        lastTransactionId: lastTransactionId.present
            ? lastTransactionId.value
            : this.lastTransactionId,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  InvestmentBalanceCache copyWithCompanion(
      InvestmentBalanceCachesCompanion data) {
    return InvestmentBalanceCache(
      investmentId: data.investmentId.present
          ? data.investmentId.value
          : this.investmentId,
      investedCapital: data.investedCapital.present
          ? data.investedCapital.value
          : this.investedCapital,
      unitsHeld: data.unitsHeld.present ? data.unitsHeld.value : this.unitsHeld,
      lastTransactionId: data.lastTransactionId.present
          ? data.lastTransactionId.value
          : this.lastTransactionId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentBalanceCache(')
          ..write('investmentId: $investmentId, ')
          ..write('investedCapital: $investedCapital, ')
          ..write('unitsHeld: $unitsHeld, ')
          ..write('lastTransactionId: $lastTransactionId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      investmentId, investedCapital, unitsHeld, lastTransactionId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentBalanceCache &&
          other.investmentId == this.investmentId &&
          other.investedCapital == this.investedCapital &&
          other.unitsHeld == this.unitsHeld &&
          other.lastTransactionId == this.lastTransactionId &&
          other.updatedAt == this.updatedAt);
}

class InvestmentBalanceCachesCompanion
    extends UpdateCompanion<InvestmentBalanceCache> {
  final Value<String> investmentId;
  final Value<double> investedCapital;
  final Value<double> unitsHeld;
  final Value<String?> lastTransactionId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const InvestmentBalanceCachesCompanion({
    this.investmentId = const Value.absent(),
    this.investedCapital = const Value.absent(),
    this.unitsHeld = const Value.absent(),
    this.lastTransactionId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentBalanceCachesCompanion.insert({
    required String investmentId,
    this.investedCapital = const Value.absent(),
    this.unitsHeld = const Value.absent(),
    this.lastTransactionId = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : investmentId = Value(investmentId),
        updatedAt = Value(updatedAt);
  static Insertable<InvestmentBalanceCache> custom({
    Expression<String>? investmentId,
    Expression<double>? investedCapital,
    Expression<double>? unitsHeld,
    Expression<String>? lastTransactionId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (investmentId != null) 'investment_id': investmentId,
      if (investedCapital != null) 'invested_capital': investedCapital,
      if (unitsHeld != null) 'units_held': unitsHeld,
      if (lastTransactionId != null) 'last_transaction_id': lastTransactionId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentBalanceCachesCompanion copyWith(
      {Value<String>? investmentId,
      Value<double>? investedCapital,
      Value<double>? unitsHeld,
      Value<String?>? lastTransactionId,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return InvestmentBalanceCachesCompanion(
      investmentId: investmentId ?? this.investmentId,
      investedCapital: investedCapital ?? this.investedCapital,
      unitsHeld: unitsHeld ?? this.unitsHeld,
      lastTransactionId: lastTransactionId ?? this.lastTransactionId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (investmentId.present) {
      map['investment_id'] = Variable<String>(investmentId.value);
    }
    if (investedCapital.present) {
      map['invested_capital'] = Variable<double>(investedCapital.value);
    }
    if (unitsHeld.present) {
      map['units_held'] = Variable<double>(unitsHeld.value);
    }
    if (lastTransactionId.present) {
      map['last_transaction_id'] = Variable<String>(lastTransactionId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentBalanceCachesCompanion(')
          ..write('investmentId: $investmentId, ')
          ..write('investedCapital: $investedCapital, ')
          ..write('unitsHeld: $unitsHeld, ')
          ..write('lastTransactionId: $lastTransactionId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DefinitionsTable extends Definitions
    with TableInfo<$DefinitionsTable, Definition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<String> term = GeneratedColumn<String>(
      'term', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _definitionMeta =
      const VerificationMeta('definition');
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
      'definition', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _formulaMeta =
      const VerificationMeta('formula');
  @override
  late final GeneratedColumn<String> formula = GeneratedColumn<String>(
      'formula', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exampleMeta =
      const VerificationMeta('example');
  @override
  late final GeneratedColumn<String> example = GeneratedColumn<String>(
      'example', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _includedItemsMeta =
      const VerificationMeta('includedItems');
  @override
  late final GeneratedColumn<String> includedItems = GeneratedColumn<String>(
      'included_items', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _excludedItemsMeta =
      const VerificationMeta('excludedItems');
  @override
  late final GeneratedColumn<String> excludedItems = GeneratedColumn<String>(
      'excluded_items', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<int> isArchived = GeneratedColumn<int>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        term,
        definition,
        formula,
        example,
        includedItems,
        excludedItems,
        isArchived,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'definitions';
  @override
  VerificationContext validateIntegrity(Insertable<Definition> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('term')) {
      context.handle(
          _termMeta, term.isAcceptableOrUnknown(data['term']!, _termMeta));
    } else if (isInserting) {
      context.missing(_termMeta);
    }
    if (data.containsKey('definition')) {
      context.handle(
          _definitionMeta,
          definition.isAcceptableOrUnknown(
              data['definition']!, _definitionMeta));
    } else if (isInserting) {
      context.missing(_definitionMeta);
    }
    if (data.containsKey('formula')) {
      context.handle(_formulaMeta,
          formula.isAcceptableOrUnknown(data['formula']!, _formulaMeta));
    } else if (isInserting) {
      context.missing(_formulaMeta);
    }
    if (data.containsKey('example')) {
      context.handle(_exampleMeta,
          example.isAcceptableOrUnknown(data['example']!, _exampleMeta));
    } else if (isInserting) {
      context.missing(_exampleMeta);
    }
    if (data.containsKey('included_items')) {
      context.handle(
          _includedItemsMeta,
          includedItems.isAcceptableOrUnknown(
              data['included_items']!, _includedItemsMeta));
    } else if (isInserting) {
      context.missing(_includedItemsMeta);
    }
    if (data.containsKey('excluded_items')) {
      context.handle(
          _excludedItemsMeta,
          excludedItems.isAcceptableOrUnknown(
              data['excluded_items']!, _excludedItemsMeta));
    } else if (isInserting) {
      context.missing(_excludedItemsMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Definition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Definition(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      term: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}term'])!,
      definition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}definition'])!,
      formula: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}formula'])!,
      example: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}example'])!,
      includedItems: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}included_items'])!,
      excludedItems: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}excluded_items'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DefinitionsTable createAlias(String alias) {
    return $DefinitionsTable(attachedDatabase, alias);
  }
}

class Definition extends DataClass implements Insertable<Definition> {
  final String id;
  final String term;
  final String definition;
  final String formula;
  final String example;
  final String includedItems;
  final String excludedItems;
  final int isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Definition(
      {required this.id,
      required this.term,
      required this.definition,
      required this.formula,
      required this.example,
      required this.includedItems,
      required this.excludedItems,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['term'] = Variable<String>(term);
    map['definition'] = Variable<String>(definition);
    map['formula'] = Variable<String>(formula);
    map['example'] = Variable<String>(example);
    map['included_items'] = Variable<String>(includedItems);
    map['excluded_items'] = Variable<String>(excludedItems);
    map['is_archived'] = Variable<int>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DefinitionsCompanion toCompanion(bool nullToAbsent) {
    return DefinitionsCompanion(
      id: Value(id),
      term: Value(term),
      definition: Value(definition),
      formula: Value(formula),
      example: Value(example),
      includedItems: Value(includedItems),
      excludedItems: Value(excludedItems),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Definition.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Definition(
      id: serializer.fromJson<String>(json['id']),
      term: serializer.fromJson<String>(json['term']),
      definition: serializer.fromJson<String>(json['definition']),
      formula: serializer.fromJson<String>(json['formula']),
      example: serializer.fromJson<String>(json['example']),
      includedItems: serializer.fromJson<String>(json['includedItems']),
      excludedItems: serializer.fromJson<String>(json['excludedItems']),
      isArchived: serializer.fromJson<int>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'term': serializer.toJson<String>(term),
      'definition': serializer.toJson<String>(definition),
      'formula': serializer.toJson<String>(formula),
      'example': serializer.toJson<String>(example),
      'includedItems': serializer.toJson<String>(includedItems),
      'excludedItems': serializer.toJson<String>(excludedItems),
      'isArchived': serializer.toJson<int>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Definition copyWith(
          {String? id,
          String? term,
          String? definition,
          String? formula,
          String? example,
          String? includedItems,
          String? excludedItems,
          int? isArchived,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Definition(
        id: id ?? this.id,
        term: term ?? this.term,
        definition: definition ?? this.definition,
        formula: formula ?? this.formula,
        example: example ?? this.example,
        includedItems: includedItems ?? this.includedItems,
        excludedItems: excludedItems ?? this.excludedItems,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Definition copyWithCompanion(DefinitionsCompanion data) {
    return Definition(
      id: data.id.present ? data.id.value : this.id,
      term: data.term.present ? data.term.value : this.term,
      definition:
          data.definition.present ? data.definition.value : this.definition,
      formula: data.formula.present ? data.formula.value : this.formula,
      example: data.example.present ? data.example.value : this.example,
      includedItems: data.includedItems.present
          ? data.includedItems.value
          : this.includedItems,
      excludedItems: data.excludedItems.present
          ? data.excludedItems.value
          : this.excludedItems,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Definition(')
          ..write('id: $id, ')
          ..write('term: $term, ')
          ..write('definition: $definition, ')
          ..write('formula: $formula, ')
          ..write('example: $example, ')
          ..write('includedItems: $includedItems, ')
          ..write('excludedItems: $excludedItems, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, term, definition, formula, example,
      includedItems, excludedItems, isArchived, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Definition &&
          other.id == this.id &&
          other.term == this.term &&
          other.definition == this.definition &&
          other.formula == this.formula &&
          other.example == this.example &&
          other.includedItems == this.includedItems &&
          other.excludedItems == this.excludedItems &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DefinitionsCompanion extends UpdateCompanion<Definition> {
  final Value<String> id;
  final Value<String> term;
  final Value<String> definition;
  final Value<String> formula;
  final Value<String> example;
  final Value<String> includedItems;
  final Value<String> excludedItems;
  final Value<int> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DefinitionsCompanion({
    this.id = const Value.absent(),
    this.term = const Value.absent(),
    this.definition = const Value.absent(),
    this.formula = const Value.absent(),
    this.example = const Value.absent(),
    this.includedItems = const Value.absent(),
    this.excludedItems = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DefinitionsCompanion.insert({
    required String id,
    required String term,
    required String definition,
    required String formula,
    required String example,
    required String includedItems,
    required String excludedItems,
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        term = Value(term),
        definition = Value(definition),
        formula = Value(formula),
        example = Value(example),
        includedItems = Value(includedItems),
        excludedItems = Value(excludedItems),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Definition> custom({
    Expression<String>? id,
    Expression<String>? term,
    Expression<String>? definition,
    Expression<String>? formula,
    Expression<String>? example,
    Expression<String>? includedItems,
    Expression<String>? excludedItems,
    Expression<int>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (term != null) 'term': term,
      if (definition != null) 'definition': definition,
      if (formula != null) 'formula': formula,
      if (example != null) 'example': example,
      if (includedItems != null) 'included_items': includedItems,
      if (excludedItems != null) 'excluded_items': excludedItems,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DefinitionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? term,
      Value<String>? definition,
      Value<String>? formula,
      Value<String>? example,
      Value<String>? includedItems,
      Value<String>? excludedItems,
      Value<int>? isArchived,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DefinitionsCompanion(
      id: id ?? this.id,
      term: term ?? this.term,
      definition: definition ?? this.definition,
      formula: formula ?? this.formula,
      example: example ?? this.example,
      includedItems: includedItems ?? this.includedItems,
      excludedItems: excludedItems ?? this.excludedItems,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (term.present) {
      map['term'] = Variable<String>(term.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (formula.present) {
      map['formula'] = Variable<String>(formula.value);
    }
    if (example.present) {
      map['example'] = Variable<String>(example.value);
    }
    if (includedItems.present) {
      map['included_items'] = Variable<String>(includedItems.value);
    }
    if (excludedItems.present) {
      map['excluded_items'] = Variable<String>(excludedItems.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<int>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('term: $term, ')
          ..write('definition: $definition, ')
          ..write('formula: $formula, ')
          ..write('example: $example, ')
          ..write('includedItems: $includedItems, ')
          ..write('excludedItems: $excludedItems, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdjustmentsTable extends Adjustments
    with TableInfo<$AdjustmentsTable, Adjustment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdjustmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _oldAmountMeta =
      const VerificationMeta('oldAmount');
  @override
  late final GeneratedColumn<double> oldAmount = GeneratedColumn<double>(
      'old_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _newAmountMeta =
      const VerificationMeta('newAmount');
  @override
  late final GeneratedColumn<double> newAmount = GeneratedColumn<double>(
      'new_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _adjustedAmountMeta =
      const VerificationMeta('adjustedAmount');
  @override
  late final GeneratedColumn<double> adjustedAmount = GeneratedColumn<double>(
      'adjusted_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        oldAmount,
        newAmount,
        adjustedAmount,
        reason,
        createdAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adjustments';
  @override
  VerificationContext validateIntegrity(Insertable<Adjustment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('old_amount')) {
      context.handle(_oldAmountMeta,
          oldAmount.isAcceptableOrUnknown(data['old_amount']!, _oldAmountMeta));
    } else if (isInserting) {
      context.missing(_oldAmountMeta);
    }
    if (data.containsKey('new_amount')) {
      context.handle(_newAmountMeta,
          newAmount.isAcceptableOrUnknown(data['new_amount']!, _newAmountMeta));
    } else if (isInserting) {
      context.missing(_newAmountMeta);
    }
    if (data.containsKey('adjusted_amount')) {
      context.handle(
          _adjustedAmountMeta,
          adjustedAmount.isAcceptableOrUnknown(
              data['adjusted_amount']!, _adjustedAmountMeta));
    } else if (isInserting) {
      context.missing(_adjustedAmountMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Adjustment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Adjustment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      oldAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}old_amount'])!,
      newAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}new_amount'])!,
      adjustedAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}adjusted_amount'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $AdjustmentsTable createAlias(String alias) {
    return $AdjustmentsTable(attachedDatabase, alias);
  }
}

class Adjustment extends DataClass implements Insertable<Adjustment> {
  final String id;
  final String entityType;
  final String entityId;
  final double oldAmount;
  final double newAmount;
  final double adjustedAmount;
  final String reason;
  final DateTime createdAt;
  final String syncStatus;
  const Adjustment(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.oldAmount,
      required this.newAmount,
      required this.adjustedAmount,
      required this.reason,
      required this.createdAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['old_amount'] = Variable<double>(oldAmount);
    map['new_amount'] = Variable<double>(newAmount);
    map['adjusted_amount'] = Variable<double>(adjustedAmount);
    map['reason'] = Variable<String>(reason);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  AdjustmentsCompanion toCompanion(bool nullToAbsent) {
    return AdjustmentsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      oldAmount: Value(oldAmount),
      newAmount: Value(newAmount),
      adjustedAmount: Value(adjustedAmount),
      reason: Value(reason),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Adjustment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Adjustment(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      oldAmount: serializer.fromJson<double>(json['oldAmount']),
      newAmount: serializer.fromJson<double>(json['newAmount']),
      adjustedAmount: serializer.fromJson<double>(json['adjustedAmount']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'oldAmount': serializer.toJson<double>(oldAmount),
      'newAmount': serializer.toJson<double>(newAmount),
      'adjustedAmount': serializer.toJson<double>(adjustedAmount),
      'reason': serializer.toJson<String>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Adjustment copyWith(
          {String? id,
          String? entityType,
          String? entityId,
          double? oldAmount,
          double? newAmount,
          double? adjustedAmount,
          String? reason,
          DateTime? createdAt,
          String? syncStatus}) =>
      Adjustment(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        oldAmount: oldAmount ?? this.oldAmount,
        newAmount: newAmount ?? this.newAmount,
        adjustedAmount: adjustedAmount ?? this.adjustedAmount,
        reason: reason ?? this.reason,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Adjustment copyWithCompanion(AdjustmentsCompanion data) {
    return Adjustment(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      oldAmount: data.oldAmount.present ? data.oldAmount.value : this.oldAmount,
      newAmount: data.newAmount.present ? data.newAmount.value : this.newAmount,
      adjustedAmount: data.adjustedAmount.present
          ? data.adjustedAmount.value
          : this.adjustedAmount,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Adjustment(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('oldAmount: $oldAmount, ')
          ..write('newAmount: $newAmount, ')
          ..write('adjustedAmount: $adjustedAmount, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, oldAmount,
      newAmount, adjustedAmount, reason, createdAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Adjustment &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.oldAmount == this.oldAmount &&
          other.newAmount == this.newAmount &&
          other.adjustedAmount == this.adjustedAmount &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class AdjustmentsCompanion extends UpdateCompanion<Adjustment> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<double> oldAmount;
  final Value<double> newAmount;
  final Value<double> adjustedAmount;
  final Value<String> reason;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const AdjustmentsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.oldAmount = const Value.absent(),
    this.newAmount = const Value.absent(),
    this.adjustedAmount = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdjustmentsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required double oldAmount,
    required double newAmount,
    required double adjustedAmount,
    required String reason,
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityType = Value(entityType),
        entityId = Value(entityId),
        oldAmount = Value(oldAmount),
        newAmount = Value(newAmount),
        adjustedAmount = Value(adjustedAmount),
        reason = Value(reason),
        createdAt = Value(createdAt);
  static Insertable<Adjustment> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<double>? oldAmount,
    Expression<double>? newAmount,
    Expression<double>? adjustedAmount,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (oldAmount != null) 'old_amount': oldAmount,
      if (newAmount != null) 'new_amount': newAmount,
      if (adjustedAmount != null) 'adjusted_amount': adjustedAmount,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdjustmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<double>? oldAmount,
      Value<double>? newAmount,
      Value<double>? adjustedAmount,
      Value<String>? reason,
      Value<DateTime>? createdAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return AdjustmentsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      oldAmount: oldAmount ?? this.oldAmount,
      newAmount: newAmount ?? this.newAmount,
      adjustedAmount: adjustedAmount ?? this.adjustedAmount,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (oldAmount.present) {
      map['old_amount'] = Variable<double>(oldAmount.value);
    }
    if (newAmount.present) {
      map['new_amount'] = Variable<double>(newAmount.value);
    }
    if (adjustedAmount.present) {
      map['adjusted_amount'] = Variable<double>(adjustedAmount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdjustmentsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('oldAmount: $oldAmount, ')
          ..write('newAmount: $newAmount, ')
          ..write('adjustedAmount: $adjustedAmount, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MilestonesTable extends Milestones
    with TableInfo<$MilestonesTable, Milestone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilestonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateAchievedMeta =
      const VerificationMeta('dateAchieved');
  @override
  late final GeneratedColumn<DateTime> dateAchieved = GeneratedColumn<DateTime>(
      'date_achieved', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _daysSincePreviousMeta =
      const VerificationMeta('daysSincePrevious');
  @override
  late final GeneratedColumn<int> daysSincePrevious = GeneratedColumn<int>(
      'days_since_previous', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _netWorthAtAchievementMeta =
      const VerificationMeta('netWorthAtAchievement');
  @override
  late final GeneratedColumn<double> netWorthAtAchievement =
      GeneratedColumn<double>('net_worth_at_achievement', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isManualMeta =
      const VerificationMeta('isManual');
  @override
  late final GeneratedColumn<int> isManual = GeneratedColumn<int>(
      'is_manual', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        amount,
        dateAchieved,
        daysSincePrevious,
        netWorthAtAchievement,
        isManual,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milestones';
  @override
  VerificationContext validateIntegrity(Insertable<Milestone> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date_achieved')) {
      context.handle(
          _dateAchievedMeta,
          dateAchieved.isAcceptableOrUnknown(
              data['date_achieved']!, _dateAchievedMeta));
    }
    if (data.containsKey('days_since_previous')) {
      context.handle(
          _daysSincePreviousMeta,
          daysSincePrevious.isAcceptableOrUnknown(
              data['days_since_previous']!, _daysSincePreviousMeta));
    }
    if (data.containsKey('net_worth_at_achievement')) {
      context.handle(
          _netWorthAtAchievementMeta,
          netWorthAtAchievement.isAcceptableOrUnknown(
              data['net_worth_at_achievement']!, _netWorthAtAchievementMeta));
    }
    if (data.containsKey('is_manual')) {
      context.handle(_isManualMeta,
          isManual.isAcceptableOrUnknown(data['is_manual']!, _isManualMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Milestone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Milestone(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      dateAchieved: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_achieved']),
      daysSincePrevious: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}days_since_previous']),
      netWorthAtAchievement: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}net_worth_at_achievement']),
      isManual: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_manual'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MilestonesTable createAlias(String alias) {
    return $MilestonesTable(attachedDatabase, alias);
  }
}

class Milestone extends DataClass implements Insertable<Milestone> {
  final String id;
  final double amount;
  final DateTime? dateAchieved;
  final int? daysSincePrevious;
  final double? netWorthAtAchievement;
  final int isManual;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Milestone(
      {required this.id,
      required this.amount,
      this.dateAchieved,
      this.daysSincePrevious,
      this.netWorthAtAchievement,
      required this.isManual,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || dateAchieved != null) {
      map['date_achieved'] = Variable<DateTime>(dateAchieved);
    }
    if (!nullToAbsent || daysSincePrevious != null) {
      map['days_since_previous'] = Variable<int>(daysSincePrevious);
    }
    if (!nullToAbsent || netWorthAtAchievement != null) {
      map['net_worth_at_achievement'] = Variable<double>(netWorthAtAchievement);
    }
    map['is_manual'] = Variable<int>(isManual);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MilestonesCompanion toCompanion(bool nullToAbsent) {
    return MilestonesCompanion(
      id: Value(id),
      amount: Value(amount),
      dateAchieved: dateAchieved == null && nullToAbsent
          ? const Value.absent()
          : Value(dateAchieved),
      daysSincePrevious: daysSincePrevious == null && nullToAbsent
          ? const Value.absent()
          : Value(daysSincePrevious),
      netWorthAtAchievement: netWorthAtAchievement == null && nullToAbsent
          ? const Value.absent()
          : Value(netWorthAtAchievement),
      isManual: Value(isManual),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Milestone.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Milestone(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      dateAchieved: serializer.fromJson<DateTime?>(json['dateAchieved']),
      daysSincePrevious: serializer.fromJson<int?>(json['daysSincePrevious']),
      netWorthAtAchievement:
          serializer.fromJson<double?>(json['netWorthAtAchievement']),
      isManual: serializer.fromJson<int>(json['isManual']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<double>(amount),
      'dateAchieved': serializer.toJson<DateTime?>(dateAchieved),
      'daysSincePrevious': serializer.toJson<int?>(daysSincePrevious),
      'netWorthAtAchievement':
          serializer.toJson<double?>(netWorthAtAchievement),
      'isManual': serializer.toJson<int>(isManual),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Milestone copyWith(
          {String? id,
          double? amount,
          Value<DateTime?> dateAchieved = const Value.absent(),
          Value<int?> daysSincePrevious = const Value.absent(),
          Value<double?> netWorthAtAchievement = const Value.absent(),
          int? isManual,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Milestone(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        dateAchieved:
            dateAchieved.present ? dateAchieved.value : this.dateAchieved,
        daysSincePrevious: daysSincePrevious.present
            ? daysSincePrevious.value
            : this.daysSincePrevious,
        netWorthAtAchievement: netWorthAtAchievement.present
            ? netWorthAtAchievement.value
            : this.netWorthAtAchievement,
        isManual: isManual ?? this.isManual,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Milestone copyWithCompanion(MilestonesCompanion data) {
    return Milestone(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      dateAchieved: data.dateAchieved.present
          ? data.dateAchieved.value
          : this.dateAchieved,
      daysSincePrevious: data.daysSincePrevious.present
          ? data.daysSincePrevious.value
          : this.daysSincePrevious,
      netWorthAtAchievement: data.netWorthAtAchievement.present
          ? data.netWorthAtAchievement.value
          : this.netWorthAtAchievement,
      isManual: data.isManual.present ? data.isManual.value : this.isManual,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Milestone(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('dateAchieved: $dateAchieved, ')
          ..write('daysSincePrevious: $daysSincePrevious, ')
          ..write('netWorthAtAchievement: $netWorthAtAchievement, ')
          ..write('isManual: $isManual, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, dateAchieved, daysSincePrevious,
      netWorthAtAchievement, isManual, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Milestone &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.dateAchieved == this.dateAchieved &&
          other.daysSincePrevious == this.daysSincePrevious &&
          other.netWorthAtAchievement == this.netWorthAtAchievement &&
          other.isManual == this.isManual &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MilestonesCompanion extends UpdateCompanion<Milestone> {
  final Value<String> id;
  final Value<double> amount;
  final Value<DateTime?> dateAchieved;
  final Value<int?> daysSincePrevious;
  final Value<double?> netWorthAtAchievement;
  final Value<int> isManual;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MilestonesCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.dateAchieved = const Value.absent(),
    this.daysSincePrevious = const Value.absent(),
    this.netWorthAtAchievement = const Value.absent(),
    this.isManual = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MilestonesCompanion.insert({
    required String id,
    required double amount,
    this.dateAchieved = const Value.absent(),
    this.daysSincePrevious = const Value.absent(),
    this.netWorthAtAchievement = const Value.absent(),
    this.isManual = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        amount = Value(amount),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Milestone> custom({
    Expression<String>? id,
    Expression<double>? amount,
    Expression<DateTime>? dateAchieved,
    Expression<int>? daysSincePrevious,
    Expression<double>? netWorthAtAchievement,
    Expression<int>? isManual,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (dateAchieved != null) 'date_achieved': dateAchieved,
      if (daysSincePrevious != null) 'days_since_previous': daysSincePrevious,
      if (netWorthAtAchievement != null)
        'net_worth_at_achievement': netWorthAtAchievement,
      if (isManual != null) 'is_manual': isManual,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MilestonesCompanion copyWith(
      {Value<String>? id,
      Value<double>? amount,
      Value<DateTime?>? dateAchieved,
      Value<int?>? daysSincePrevious,
      Value<double?>? netWorthAtAchievement,
      Value<int>? isManual,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return MilestonesCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      dateAchieved: dateAchieved ?? this.dateAchieved,
      daysSincePrevious: daysSincePrevious ?? this.daysSincePrevious,
      netWorthAtAchievement:
          netWorthAtAchievement ?? this.netWorthAtAchievement,
      isManual: isManual ?? this.isManual,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (dateAchieved.present) {
      map['date_achieved'] = Variable<DateTime>(dateAchieved.value);
    }
    if (daysSincePrevious.present) {
      map['days_since_previous'] = Variable<int>(daysSincePrevious.value);
    }
    if (netWorthAtAchievement.present) {
      map['net_worth_at_achievement'] =
          Variable<double>(netWorthAtAchievement.value);
    }
    if (isManual.present) {
      map['is_manual'] = Variable<int>(isManual.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilestonesCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('dateAchieved: $dateAchieved, ')
          ..write('daysSincePrevious: $daysSincePrevious, ')
          ..write('netWorthAtAchievement: $netWorthAtAchievement, ')
          ..write('isManual: $isManual, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateUnlockedMeta =
      const VerificationMeta('dateUnlocked');
  @override
  late final GeneratedColumn<DateTime> dateUnlocked = GeneratedColumn<DateTime>(
      'date_unlocked', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unlockedStatusMeta =
      const VerificationMeta('unlockedStatus');
  @override
  late final GeneratedColumn<int> unlockedStatus = GeneratedColumn<int>(
      'unlocked_status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        dateUnlocked,
        category,
        unlockedStatus,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(Insertable<Achievement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('date_unlocked')) {
      context.handle(
          _dateUnlockedMeta,
          dateUnlocked.isAcceptableOrUnknown(
              data['date_unlocked']!, _dateUnlockedMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('unlocked_status')) {
      context.handle(
          _unlockedStatusMeta,
          unlockedStatus.isAcceptableOrUnknown(
              data['unlocked_status']!, _unlockedStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      dateUnlocked: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_unlocked']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      unlockedStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unlocked_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final String id;
  final String title;
  final String description;
  final DateTime? dateUnlocked;
  final String category;
  final int unlockedStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Achievement(
      {required this.id,
      required this.title,
      required this.description,
      this.dateUnlocked,
      required this.category,
      required this.unlockedStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || dateUnlocked != null) {
      map['date_unlocked'] = Variable<DateTime>(dateUnlocked);
    }
    map['category'] = Variable<String>(category);
    map['unlocked_status'] = Variable<int>(unlockedStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      dateUnlocked: dateUnlocked == null && nullToAbsent
          ? const Value.absent()
          : Value(dateUnlocked),
      category: Value(category),
      unlockedStatus: Value(unlockedStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Achievement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      dateUnlocked: serializer.fromJson<DateTime?>(json['dateUnlocked']),
      category: serializer.fromJson<String>(json['category']),
      unlockedStatus: serializer.fromJson<int>(json['unlockedStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'dateUnlocked': serializer.toJson<DateTime?>(dateUnlocked),
      'category': serializer.toJson<String>(category),
      'unlockedStatus': serializer.toJson<int>(unlockedStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Achievement copyWith(
          {String? id,
          String? title,
          String? description,
          Value<DateTime?> dateUnlocked = const Value.absent(),
          String? category,
          int? unlockedStatus,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Achievement(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        dateUnlocked:
            dateUnlocked.present ? dateUnlocked.value : this.dateUnlocked,
        category: category ?? this.category,
        unlockedStatus: unlockedStatus ?? this.unlockedStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      dateUnlocked: data.dateUnlocked.present
          ? data.dateUnlocked.value
          : this.dateUnlocked,
      category: data.category.present ? data.category.value : this.category,
      unlockedStatus: data.unlockedStatus.present
          ? data.unlockedStatus.value
          : this.unlockedStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dateUnlocked: $dateUnlocked, ')
          ..write('category: $category, ')
          ..write('unlockedStatus: $unlockedStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, dateUnlocked,
      category, unlockedStatus, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.dateUnlocked == this.dateUnlocked &&
          other.category == this.category &&
          other.unlockedStatus == this.unlockedStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime?> dateUnlocked;
  final Value<String> category;
  final Value<int> unlockedStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dateUnlocked = const Value.absent(),
    this.category = const Value.absent(),
    this.unlockedStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String id,
    required String title,
    required String description,
    this.dateUnlocked = const Value.absent(),
    required String category,
    this.unlockedStatus = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description),
        category = Value(category),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Achievement> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dateUnlocked,
    Expression<String>? category,
    Expression<int>? unlockedStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dateUnlocked != null) 'date_unlocked': dateUnlocked,
      if (category != null) 'category': category,
      if (unlockedStatus != null) 'unlocked_status': unlockedStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<DateTime?>? dateUnlocked,
      Value<String>? category,
      Value<int>? unlockedStatus,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AchievementsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateUnlocked: dateUnlocked ?? this.dateUnlocked,
      category: category ?? this.category,
      unlockedStatus: unlockedStatus ?? this.unlockedStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dateUnlocked.present) {
      map['date_unlocked'] = Variable<DateTime>(dateUnlocked.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (unlockedStatus.present) {
      map['unlocked_status'] = Variable<int>(unlockedStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dateUnlocked: $dateUnlocked, ')
          ..write('category: $category, ')
          ..write('unlockedStatus: $unlockedStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementProgressTable extends AchievementProgress
    with TableInfo<$AchievementProgressTable, AchievementProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _achievementIdMeta =
      const VerificationMeta('achievementId');
  @override
  late final GeneratedColumn<String> achievementId = GeneratedColumn<String>(
      'achievement_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentValueMeta =
      const VerificationMeta('currentValue');
  @override
  late final GeneratedColumn<double> currentValue = GeneratedColumn<double>(
      'current_value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _targetValueMeta =
      const VerificationMeta('targetValue');
  @override
  late final GeneratedColumn<double> targetValue = GeneratedColumn<double>(
      'target_value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, achievementId, currentValue, targetValue, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievement_progress';
  @override
  VerificationContext validateIntegrity(
      Insertable<AchievementProgressData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('achievement_id')) {
      context.handle(
          _achievementIdMeta,
          achievementId.isAcceptableOrUnknown(
              data['achievement_id']!, _achievementIdMeta));
    } else if (isInserting) {
      context.missing(_achievementIdMeta);
    }
    if (data.containsKey('current_value')) {
      context.handle(
          _currentValueMeta,
          currentValue.isAcceptableOrUnknown(
              data['current_value']!, _currentValueMeta));
    } else if (isInserting) {
      context.missing(_currentValueMeta);
    }
    if (data.containsKey('target_value')) {
      context.handle(
          _targetValueMeta,
          targetValue.isAcceptableOrUnknown(
              data['target_value']!, _targetValueMeta));
    } else if (isInserting) {
      context.missing(_targetValueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AchievementProgressData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementProgressData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      achievementId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}achievement_id'])!,
      currentValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_value'])!,
      targetValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AchievementProgressTable createAlias(String alias) {
    return $AchievementProgressTable(attachedDatabase, alias);
  }
}

class AchievementProgressData extends DataClass
    implements Insertable<AchievementProgressData> {
  final String id;
  final String achievementId;
  final double currentValue;
  final double targetValue;
  final DateTime updatedAt;
  const AchievementProgressData(
      {required this.id,
      required this.achievementId,
      required this.currentValue,
      required this.targetValue,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['achievement_id'] = Variable<String>(achievementId);
    map['current_value'] = Variable<double>(currentValue);
    map['target_value'] = Variable<double>(targetValue);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AchievementProgressCompanion toCompanion(bool nullToAbsent) {
    return AchievementProgressCompanion(
      id: Value(id),
      achievementId: Value(achievementId),
      currentValue: Value(currentValue),
      targetValue: Value(targetValue),
      updatedAt: Value(updatedAt),
    );
  }

  factory AchievementProgressData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementProgressData(
      id: serializer.fromJson<String>(json['id']),
      achievementId: serializer.fromJson<String>(json['achievementId']),
      currentValue: serializer.fromJson<double>(json['currentValue']),
      targetValue: serializer.fromJson<double>(json['targetValue']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'achievementId': serializer.toJson<String>(achievementId),
      'currentValue': serializer.toJson<double>(currentValue),
      'targetValue': serializer.toJson<double>(targetValue),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AchievementProgressData copyWith(
          {String? id,
          String? achievementId,
          double? currentValue,
          double? targetValue,
          DateTime? updatedAt}) =>
      AchievementProgressData(
        id: id ?? this.id,
        achievementId: achievementId ?? this.achievementId,
        currentValue: currentValue ?? this.currentValue,
        targetValue: targetValue ?? this.targetValue,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AchievementProgressData copyWithCompanion(AchievementProgressCompanion data) {
    return AchievementProgressData(
      id: data.id.present ? data.id.value : this.id,
      achievementId: data.achievementId.present
          ? data.achievementId.value
          : this.achievementId,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      targetValue:
          data.targetValue.present ? data.targetValue.value : this.targetValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementProgressData(')
          ..write('id: $id, ')
          ..write('achievementId: $achievementId, ')
          ..write('currentValue: $currentValue, ')
          ..write('targetValue: $targetValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, achievementId, currentValue, targetValue, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementProgressData &&
          other.id == this.id &&
          other.achievementId == this.achievementId &&
          other.currentValue == this.currentValue &&
          other.targetValue == this.targetValue &&
          other.updatedAt == this.updatedAt);
}

class AchievementProgressCompanion
    extends UpdateCompanion<AchievementProgressData> {
  final Value<String> id;
  final Value<String> achievementId;
  final Value<double> currentValue;
  final Value<double> targetValue;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AchievementProgressCompanion({
    this.id = const Value.absent(),
    this.achievementId = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementProgressCompanion.insert({
    required String id,
    required String achievementId,
    required double currentValue,
    required double targetValue,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        achievementId = Value(achievementId),
        currentValue = Value(currentValue),
        targetValue = Value(targetValue),
        updatedAt = Value(updatedAt);
  static Insertable<AchievementProgressData> custom({
    Expression<String>? id,
    Expression<String>? achievementId,
    Expression<double>? currentValue,
    Expression<double>? targetValue,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (achievementId != null) 'achievement_id': achievementId,
      if (currentValue != null) 'current_value': currentValue,
      if (targetValue != null) 'target_value': targetValue,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementProgressCompanion copyWith(
      {Value<String>? id,
      Value<String>? achievementId,
      Value<double>? currentValue,
      Value<double>? targetValue,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AchievementProgressCompanion(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (achievementId.present) {
      map['achievement_id'] = Variable<String>(achievementId.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<double>(currentValue.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<double>(targetValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementProgressCompanion(')
          ..write('id: $id, ')
          ..write('achievementId: $achievementId, ')
          ..write('currentValue: $currentValue, ')
          ..write('targetValue: $targetValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MtfPositionsTable extends MtfPositions
    with TableInfo<$MtfPositionsTable, MtfPosition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MtfPositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _investmentIdMeta =
      const VerificationMeta('investmentId');
  @override
  late final GeneratedColumn<String> investmentId = GeneratedColumn<String>(
      'investment_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES investments(id)');
  static const VerificationMeta _brokerMeta = const VerificationMeta('broker');
  @override
  late final GeneratedColumn<String> broker = GeneratedColumn<String>(
      'broker', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _instrumentMeta =
      const VerificationMeta('instrument');
  @override
  late final GeneratedColumn<String> instrument = GeneratedColumn<String>(
      'instrument', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitsMeta = const VerificationMeta('units');
  @override
  late final GeneratedColumn<double> units = GeneratedColumn<double>(
      'units', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _averagePriceMeta =
      const VerificationMeta('averagePrice');
  @override
  late final GeneratedColumn<double> averagePrice = GeneratedColumn<double>(
      'average_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _ownCapitalMeta =
      const VerificationMeta('ownCapital');
  @override
  late final GeneratedColumn<double> ownCapital = GeneratedColumn<double>(
      'own_capital', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _borrowedCapitalMeta =
      const VerificationMeta('borrowedCapital');
  @override
  late final GeneratedColumn<double> borrowedCapital = GeneratedColumn<double>(
      'borrowed_capital', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _interestRateMeta =
      const VerificationMeta('interestRate');
  @override
  late final GeneratedColumn<double> interestRate = GeneratedColumn<double>(
      'interest_rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _openingDateMeta =
      const VerificationMeta('openingDate');
  @override
  late final GeneratedColumn<DateTime> openingDate = GeneratedColumn<DateTime>(
      'opening_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _closedDateMeta =
      const VerificationMeta('closedDate');
  @override
  late final GeneratedColumn<DateTime> closedDate = GeneratedColumn<DateTime>(
      'closed_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isClosedMeta =
      const VerificationMeta('isClosed');
  @override
  late final GeneratedColumn<int> isClosed = GeneratedColumn<int>(
      'is_closed', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _lastAccrualDateMeta =
      const VerificationMeta('lastAccrualDate');
  @override
  late final GeneratedColumn<DateTime> lastAccrualDate =
      GeneratedColumn<DateTime>('last_accrual_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        investmentId,
        broker,
        instrument,
        units,
        averagePrice,
        ownCapital,
        borrowedCapital,
        interestRate,
        openingDate,
        closedDate,
        isClosed,
        createdAt,
        updatedAt,
        syncStatus,
        lastAccrualDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mtf_positions';
  @override
  VerificationContext validateIntegrity(Insertable<MtfPosition> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('investment_id')) {
      context.handle(
          _investmentIdMeta,
          investmentId.isAcceptableOrUnknown(
              data['investment_id']!, _investmentIdMeta));
    } else if (isInserting) {
      context.missing(_investmentIdMeta);
    }
    if (data.containsKey('broker')) {
      context.handle(_brokerMeta,
          broker.isAcceptableOrUnknown(data['broker']!, _brokerMeta));
    } else if (isInserting) {
      context.missing(_brokerMeta);
    }
    if (data.containsKey('instrument')) {
      context.handle(
          _instrumentMeta,
          instrument.isAcceptableOrUnknown(
              data['instrument']!, _instrumentMeta));
    } else if (isInserting) {
      context.missing(_instrumentMeta);
    }
    if (data.containsKey('units')) {
      context.handle(
          _unitsMeta, units.isAcceptableOrUnknown(data['units']!, _unitsMeta));
    } else if (isInserting) {
      context.missing(_unitsMeta);
    }
    if (data.containsKey('average_price')) {
      context.handle(
          _averagePriceMeta,
          averagePrice.isAcceptableOrUnknown(
              data['average_price']!, _averagePriceMeta));
    } else if (isInserting) {
      context.missing(_averagePriceMeta);
    }
    if (data.containsKey('own_capital')) {
      context.handle(
          _ownCapitalMeta,
          ownCapital.isAcceptableOrUnknown(
              data['own_capital']!, _ownCapitalMeta));
    } else if (isInserting) {
      context.missing(_ownCapitalMeta);
    }
    if (data.containsKey('borrowed_capital')) {
      context.handle(
          _borrowedCapitalMeta,
          borrowedCapital.isAcceptableOrUnknown(
              data['borrowed_capital']!, _borrowedCapitalMeta));
    } else if (isInserting) {
      context.missing(_borrowedCapitalMeta);
    }
    if (data.containsKey('interest_rate')) {
      context.handle(
          _interestRateMeta,
          interestRate.isAcceptableOrUnknown(
              data['interest_rate']!, _interestRateMeta));
    } else if (isInserting) {
      context.missing(_interestRateMeta);
    }
    if (data.containsKey('opening_date')) {
      context.handle(
          _openingDateMeta,
          openingDate.isAcceptableOrUnknown(
              data['opening_date']!, _openingDateMeta));
    } else if (isInserting) {
      context.missing(_openingDateMeta);
    }
    if (data.containsKey('closed_date')) {
      context.handle(
          _closedDateMeta,
          closedDate.isAcceptableOrUnknown(
              data['closed_date']!, _closedDateMeta));
    }
    if (data.containsKey('is_closed')) {
      context.handle(_isClosedMeta,
          isClosed.isAcceptableOrUnknown(data['is_closed']!, _isClosedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('last_accrual_date')) {
      context.handle(
          _lastAccrualDateMeta,
          lastAccrualDate.isAcceptableOrUnknown(
              data['last_accrual_date']!, _lastAccrualDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MtfPosition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MtfPosition(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      investmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}investment_id'])!,
      broker: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}broker'])!,
      instrument: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instrument'])!,
      units: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}units'])!,
      averagePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}average_price'])!,
      ownCapital: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}own_capital'])!,
      borrowedCapital: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}borrowed_capital'])!,
      interestRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}interest_rate'])!,
      openingDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}opening_date'])!,
      closedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}closed_date']),
      isClosed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_closed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastAccrualDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_accrual_date']),
    );
  }

  @override
  $MtfPositionsTable createAlias(String alias) {
    return $MtfPositionsTable(attachedDatabase, alias);
  }
}

class MtfPosition extends DataClass implements Insertable<MtfPosition> {
  final String id;
  final String investmentId;
  final String broker;
  final String instrument;
  final double units;
  final double averagePrice;
  final double ownCapital;
  final double borrowedCapital;
  final double interestRate;
  final DateTime openingDate;
  final DateTime? closedDate;
  final int isClosed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastAccrualDate;
  const MtfPosition(
      {required this.id,
      required this.investmentId,
      required this.broker,
      required this.instrument,
      required this.units,
      required this.averagePrice,
      required this.ownCapital,
      required this.borrowedCapital,
      required this.interestRate,
      required this.openingDate,
      this.closedDate,
      required this.isClosed,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.lastAccrualDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['investment_id'] = Variable<String>(investmentId);
    map['broker'] = Variable<String>(broker);
    map['instrument'] = Variable<String>(instrument);
    map['units'] = Variable<double>(units);
    map['average_price'] = Variable<double>(averagePrice);
    map['own_capital'] = Variable<double>(ownCapital);
    map['borrowed_capital'] = Variable<double>(borrowedCapital);
    map['interest_rate'] = Variable<double>(interestRate);
    map['opening_date'] = Variable<DateTime>(openingDate);
    if (!nullToAbsent || closedDate != null) {
      map['closed_date'] = Variable<DateTime>(closedDate);
    }
    map['is_closed'] = Variable<int>(isClosed);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastAccrualDate != null) {
      map['last_accrual_date'] = Variable<DateTime>(lastAccrualDate);
    }
    return map;
  }

  MtfPositionsCompanion toCompanion(bool nullToAbsent) {
    return MtfPositionsCompanion(
      id: Value(id),
      investmentId: Value(investmentId),
      broker: Value(broker),
      instrument: Value(instrument),
      units: Value(units),
      averagePrice: Value(averagePrice),
      ownCapital: Value(ownCapital),
      borrowedCapital: Value(borrowedCapital),
      interestRate: Value(interestRate),
      openingDate: Value(openingDate),
      closedDate: closedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(closedDate),
      isClosed: Value(isClosed),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      lastAccrualDate: lastAccrualDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccrualDate),
    );
  }

  factory MtfPosition.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MtfPosition(
      id: serializer.fromJson<String>(json['id']),
      investmentId: serializer.fromJson<String>(json['investmentId']),
      broker: serializer.fromJson<String>(json['broker']),
      instrument: serializer.fromJson<String>(json['instrument']),
      units: serializer.fromJson<double>(json['units']),
      averagePrice: serializer.fromJson<double>(json['averagePrice']),
      ownCapital: serializer.fromJson<double>(json['ownCapital']),
      borrowedCapital: serializer.fromJson<double>(json['borrowedCapital']),
      interestRate: serializer.fromJson<double>(json['interestRate']),
      openingDate: serializer.fromJson<DateTime>(json['openingDate']),
      closedDate: serializer.fromJson<DateTime?>(json['closedDate']),
      isClosed: serializer.fromJson<int>(json['isClosed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastAccrualDate: serializer.fromJson<DateTime?>(json['lastAccrualDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'investmentId': serializer.toJson<String>(investmentId),
      'broker': serializer.toJson<String>(broker),
      'instrument': serializer.toJson<String>(instrument),
      'units': serializer.toJson<double>(units),
      'averagePrice': serializer.toJson<double>(averagePrice),
      'ownCapital': serializer.toJson<double>(ownCapital),
      'borrowedCapital': serializer.toJson<double>(borrowedCapital),
      'interestRate': serializer.toJson<double>(interestRate),
      'openingDate': serializer.toJson<DateTime>(openingDate),
      'closedDate': serializer.toJson<DateTime?>(closedDate),
      'isClosed': serializer.toJson<int>(isClosed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastAccrualDate': serializer.toJson<DateTime?>(lastAccrualDate),
    };
  }

  MtfPosition copyWith(
          {String? id,
          String? investmentId,
          String? broker,
          String? instrument,
          double? units,
          double? averagePrice,
          double? ownCapital,
          double? borrowedCapital,
          double? interestRate,
          DateTime? openingDate,
          Value<DateTime?> closedDate = const Value.absent(),
          int? isClosed,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus,
          Value<DateTime?> lastAccrualDate = const Value.absent()}) =>
      MtfPosition(
        id: id ?? this.id,
        investmentId: investmentId ?? this.investmentId,
        broker: broker ?? this.broker,
        instrument: instrument ?? this.instrument,
        units: units ?? this.units,
        averagePrice: averagePrice ?? this.averagePrice,
        ownCapital: ownCapital ?? this.ownCapital,
        borrowedCapital: borrowedCapital ?? this.borrowedCapital,
        interestRate: interestRate ?? this.interestRate,
        openingDate: openingDate ?? this.openingDate,
        closedDate: closedDate.present ? closedDate.value : this.closedDate,
        isClosed: isClosed ?? this.isClosed,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastAccrualDate: lastAccrualDate.present
            ? lastAccrualDate.value
            : this.lastAccrualDate,
      );
  MtfPosition copyWithCompanion(MtfPositionsCompanion data) {
    return MtfPosition(
      id: data.id.present ? data.id.value : this.id,
      investmentId: data.investmentId.present
          ? data.investmentId.value
          : this.investmentId,
      broker: data.broker.present ? data.broker.value : this.broker,
      instrument:
          data.instrument.present ? data.instrument.value : this.instrument,
      units: data.units.present ? data.units.value : this.units,
      averagePrice: data.averagePrice.present
          ? data.averagePrice.value
          : this.averagePrice,
      ownCapital:
          data.ownCapital.present ? data.ownCapital.value : this.ownCapital,
      borrowedCapital: data.borrowedCapital.present
          ? data.borrowedCapital.value
          : this.borrowedCapital,
      interestRate: data.interestRate.present
          ? data.interestRate.value
          : this.interestRate,
      openingDate:
          data.openingDate.present ? data.openingDate.value : this.openingDate,
      closedDate:
          data.closedDate.present ? data.closedDate.value : this.closedDate,
      isClosed: data.isClosed.present ? data.isClosed.value : this.isClosed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastAccrualDate: data.lastAccrualDate.present
          ? data.lastAccrualDate.value
          : this.lastAccrualDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MtfPosition(')
          ..write('id: $id, ')
          ..write('investmentId: $investmentId, ')
          ..write('broker: $broker, ')
          ..write('instrument: $instrument, ')
          ..write('units: $units, ')
          ..write('averagePrice: $averagePrice, ')
          ..write('ownCapital: $ownCapital, ')
          ..write('borrowedCapital: $borrowedCapital, ')
          ..write('interestRate: $interestRate, ')
          ..write('openingDate: $openingDate, ')
          ..write('closedDate: $closedDate, ')
          ..write('isClosed: $isClosed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastAccrualDate: $lastAccrualDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      investmentId,
      broker,
      instrument,
      units,
      averagePrice,
      ownCapital,
      borrowedCapital,
      interestRate,
      openingDate,
      closedDate,
      isClosed,
      createdAt,
      updatedAt,
      syncStatus,
      lastAccrualDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MtfPosition &&
          other.id == this.id &&
          other.investmentId == this.investmentId &&
          other.broker == this.broker &&
          other.instrument == this.instrument &&
          other.units == this.units &&
          other.averagePrice == this.averagePrice &&
          other.ownCapital == this.ownCapital &&
          other.borrowedCapital == this.borrowedCapital &&
          other.interestRate == this.interestRate &&
          other.openingDate == this.openingDate &&
          other.closedDate == this.closedDate &&
          other.isClosed == this.isClosed &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastAccrualDate == this.lastAccrualDate);
}

class MtfPositionsCompanion extends UpdateCompanion<MtfPosition> {
  final Value<String> id;
  final Value<String> investmentId;
  final Value<String> broker;
  final Value<String> instrument;
  final Value<double> units;
  final Value<double> averagePrice;
  final Value<double> ownCapital;
  final Value<double> borrowedCapital;
  final Value<double> interestRate;
  final Value<DateTime> openingDate;
  final Value<DateTime?> closedDate;
  final Value<int> isClosed;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastAccrualDate;
  final Value<int> rowid;
  const MtfPositionsCompanion({
    this.id = const Value.absent(),
    this.investmentId = const Value.absent(),
    this.broker = const Value.absent(),
    this.instrument = const Value.absent(),
    this.units = const Value.absent(),
    this.averagePrice = const Value.absent(),
    this.ownCapital = const Value.absent(),
    this.borrowedCapital = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.openingDate = const Value.absent(),
    this.closedDate = const Value.absent(),
    this.isClosed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastAccrualDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MtfPositionsCompanion.insert({
    required String id,
    required String investmentId,
    required String broker,
    required String instrument,
    required double units,
    required double averagePrice,
    required double ownCapital,
    required double borrowedCapital,
    required double interestRate,
    required DateTime openingDate,
    this.closedDate = const Value.absent(),
    this.isClosed = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.lastAccrualDate = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        investmentId = Value(investmentId),
        broker = Value(broker),
        instrument = Value(instrument),
        units = Value(units),
        averagePrice = Value(averagePrice),
        ownCapital = Value(ownCapital),
        borrowedCapital = Value(borrowedCapital),
        interestRate = Value(interestRate),
        openingDate = Value(openingDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<MtfPosition> custom({
    Expression<String>? id,
    Expression<String>? investmentId,
    Expression<String>? broker,
    Expression<String>? instrument,
    Expression<double>? units,
    Expression<double>? averagePrice,
    Expression<double>? ownCapital,
    Expression<double>? borrowedCapital,
    Expression<double>? interestRate,
    Expression<DateTime>? openingDate,
    Expression<DateTime>? closedDate,
    Expression<int>? isClosed,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastAccrualDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (investmentId != null) 'investment_id': investmentId,
      if (broker != null) 'broker': broker,
      if (instrument != null) 'instrument': instrument,
      if (units != null) 'units': units,
      if (averagePrice != null) 'average_price': averagePrice,
      if (ownCapital != null) 'own_capital': ownCapital,
      if (borrowedCapital != null) 'borrowed_capital': borrowedCapital,
      if (interestRate != null) 'interest_rate': interestRate,
      if (openingDate != null) 'opening_date': openingDate,
      if (closedDate != null) 'closed_date': closedDate,
      if (isClosed != null) 'is_closed': isClosed,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastAccrualDate != null) 'last_accrual_date': lastAccrualDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MtfPositionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? investmentId,
      Value<String>? broker,
      Value<String>? instrument,
      Value<double>? units,
      Value<double>? averagePrice,
      Value<double>? ownCapital,
      Value<double>? borrowedCapital,
      Value<double>? interestRate,
      Value<DateTime>? openingDate,
      Value<DateTime?>? closedDate,
      Value<int>? isClosed,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastAccrualDate,
      Value<int>? rowid}) {
    return MtfPositionsCompanion(
      id: id ?? this.id,
      investmentId: investmentId ?? this.investmentId,
      broker: broker ?? this.broker,
      instrument: instrument ?? this.instrument,
      units: units ?? this.units,
      averagePrice: averagePrice ?? this.averagePrice,
      ownCapital: ownCapital ?? this.ownCapital,
      borrowedCapital: borrowedCapital ?? this.borrowedCapital,
      interestRate: interestRate ?? this.interestRate,
      openingDate: openingDate ?? this.openingDate,
      closedDate: closedDate ?? this.closedDate,
      isClosed: isClosed ?? this.isClosed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastAccrualDate: lastAccrualDate ?? this.lastAccrualDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (investmentId.present) {
      map['investment_id'] = Variable<String>(investmentId.value);
    }
    if (broker.present) {
      map['broker'] = Variable<String>(broker.value);
    }
    if (instrument.present) {
      map['instrument'] = Variable<String>(instrument.value);
    }
    if (units.present) {
      map['units'] = Variable<double>(units.value);
    }
    if (averagePrice.present) {
      map['average_price'] = Variable<double>(averagePrice.value);
    }
    if (ownCapital.present) {
      map['own_capital'] = Variable<double>(ownCapital.value);
    }
    if (borrowedCapital.present) {
      map['borrowed_capital'] = Variable<double>(borrowedCapital.value);
    }
    if (interestRate.present) {
      map['interest_rate'] = Variable<double>(interestRate.value);
    }
    if (openingDate.present) {
      map['opening_date'] = Variable<DateTime>(openingDate.value);
    }
    if (closedDate.present) {
      map['closed_date'] = Variable<DateTime>(closedDate.value);
    }
    if (isClosed.present) {
      map['is_closed'] = Variable<int>(isClosed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastAccrualDate.present) {
      map['last_accrual_date'] = Variable<DateTime>(lastAccrualDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MtfPositionsCompanion(')
          ..write('id: $id, ')
          ..write('investmentId: $investmentId, ')
          ..write('broker: $broker, ')
          ..write('instrument: $instrument, ')
          ..write('units: $units, ')
          ..write('averagePrice: $averagePrice, ')
          ..write('ownCapital: $ownCapital, ')
          ..write('borrowedCapital: $borrowedCapital, ')
          ..write('interestRate: $interestRate, ')
          ..write('openingDate: $openingDate, ')
          ..write('closedDate: $closedDate, ')
          ..write('isClosed: $isClosed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastAccrualDate: $lastAccrualDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $PeopleTable people = $PeopleTable(this);
  late final $InvestmentsTable investments = $InvestmentsTable(this);
  late final $InvestmentLotsTable investmentLots = $InvestmentLotsTable(this);
  late final $InvestmentLotConsumptionsTable investmentLotConsumptions =
      $InvestmentLotConsumptionsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $ExpectedIncomesTable expectedIncomes =
      $ExpectedIncomesTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $GoalMilestonesTable goalMilestones = $GoalMilestonesTable(this);
  late final $SnapshotsTable snapshots = $SnapshotsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $AccountBalanceCachesTable accountBalanceCaches =
      $AccountBalanceCachesTable(this);
  late final $PersonBalanceCachesTable personBalanceCaches =
      $PersonBalanceCachesTable(this);
  late final $InvestmentBalanceCachesTable investmentBalanceCaches =
      $InvestmentBalanceCachesTable(this);
  late final $DefinitionsTable definitions = $DefinitionsTable(this);
  late final $AdjustmentsTable adjustments = $AdjustmentsTable(this);
  late final $MilestonesTable milestones = $MilestonesTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $AchievementProgressTable achievementProgress =
      $AchievementProgressTable(this);
  late final $MtfPositionsTable mtfPositions = $MtfPositionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        accounts,
        people,
        investments,
        investmentLots,
        investmentLotConsumptions,
        transactions,
        expectedIncomes,
        goals,
        goalMilestones,
        snapshots,
        settings,
        auditLogs,
        accountBalanceCaches,
        personBalanceCaches,
        investmentBalanceCaches,
        definitions,
        adjustments,
        milestones,
        achievements,
        achievementProgress,
        mtfPositions
      ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String name,
  required String type,
  Value<String?> notes,
  Value<int> isArchived,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<String?> notes,
  Value<int> isArchived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AccountBalanceCachesTable,
      List<AccountBalanceCache>> _accountBalanceCachesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.accountBalanceCaches,
          aliasName: $_aliasNameGenerator(
              db.accounts.id, db.accountBalanceCaches.accountId));

  $$AccountBalanceCachesTableProcessedTableManager
      get accountBalanceCachesRefs {
    final manager = $$AccountBalanceCachesTableTableManager(
            $_db, $_db.accountBalanceCaches)
        .filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_accountBalanceCachesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  Expression<bool> accountBalanceCachesRefs(
      Expression<bool> Function($$AccountBalanceCachesTableFilterComposer f)
          f) {
    final $$AccountBalanceCachesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.accountBalanceCaches,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountBalanceCachesTableFilterComposer(
              $db: $db,
              $table: $db.accountBalanceCaches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  Expression<T> accountBalanceCachesRefs<T extends Object>(
      Expression<T> Function($$AccountBalanceCachesTableAnnotationComposer a)
          f) {
    final $$AccountBalanceCachesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.accountBalanceCaches,
            getReferencedColumn: (t) => t.accountId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$AccountBalanceCachesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.accountBalanceCaches,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function({bool accountBalanceCachesRefs})> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            name: name,
            type: type,
            notes: notes,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String type,
            Value<String?> notes = const Value.absent(),
            Value<int> isArchived = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            name: name,
            type: type,
            notes: notes,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AccountsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({accountBalanceCachesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (accountBalanceCachesRefs) db.accountBalanceCaches
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (accountBalanceCachesRefs)
                    await $_getPrefetchedData<Account, $AccountsTable,
                            AccountBalanceCache>(
                        currentTable: table,
                        referencedTable: $$AccountsTableReferences
                            ._accountBalanceCachesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AccountsTableReferences(db, table, p0)
                                .accountBalanceCachesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.accountId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, $$AccountsTableReferences),
    Account,
    PrefetchHooks Function({bool accountBalanceCachesRefs})>;
typedef $$PeopleTableCreateCompanionBuilder = PeopleCompanion Function({
  required String id,
  required String name,
  Value<String?> phone,
  Value<String?> notes,
  Value<int> isArchived,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$PeopleTableUpdateCompanionBuilder = PeopleCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> notes,
  Value<int> isArchived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$PeopleTableReferences
    extends BaseReferences<_$AppDatabase, $PeopleTable, PeopleData> {
  $$PeopleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PersonBalanceCachesTable,
      List<PersonBalanceCache>> _personBalanceCachesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.personBalanceCaches,
          aliasName: $_aliasNameGenerator(
              db.people.id, db.personBalanceCaches.personId));

  $$PersonBalanceCachesTableProcessedTableManager get personBalanceCachesRefs {
    final manager = $$PersonBalanceCachesTableTableManager(
            $_db, $_db.personBalanceCaches)
        .filter((f) => f.personId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_personBalanceCachesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PeopleTableFilterComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  Expression<bool> personBalanceCachesRefs(
      Expression<bool> Function($$PersonBalanceCachesTableFilterComposer f) f) {
    final $$PersonBalanceCachesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.personBalanceCaches,
        getReferencedColumn: (t) => t.personId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PersonBalanceCachesTableFilterComposer(
              $db: $db,
              $table: $db.personBalanceCaches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PeopleTableOrderingComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$PeopleTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  Expression<T> personBalanceCachesRefs<T extends Object>(
      Expression<T> Function($$PersonBalanceCachesTableAnnotationComposer a)
          f) {
    final $$PersonBalanceCachesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.personBalanceCaches,
            getReferencedColumn: (t) => t.personId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PersonBalanceCachesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.personBalanceCaches,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PeopleTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PeopleTable,
    PeopleData,
    $$PeopleTableFilterComposer,
    $$PeopleTableOrderingComposer,
    $$PeopleTableAnnotationComposer,
    $$PeopleTableCreateCompanionBuilder,
    $$PeopleTableUpdateCompanionBuilder,
    (PeopleData, $$PeopleTableReferences),
    PeopleData,
    PrefetchHooks Function({bool personBalanceCachesRefs})> {
  $$PeopleTableTableManager(_$AppDatabase db, $PeopleTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PeopleCompanion(
            id: id,
            name: name,
            phone: phone,
            notes: notes,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> isArchived = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PeopleCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            notes: notes,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PeopleTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({personBalanceCachesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (personBalanceCachesRefs) db.personBalanceCaches
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (personBalanceCachesRefs)
                    await $_getPrefetchedData<PeopleData, $PeopleTable,
                            PersonBalanceCache>(
                        currentTable: table,
                        referencedTable: $$PeopleTableReferences
                            ._personBalanceCachesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PeopleTableReferences(db, table, p0)
                                .personBalanceCachesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.personId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PeopleTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PeopleTable,
    PeopleData,
    $$PeopleTableFilterComposer,
    $$PeopleTableOrderingComposer,
    $$PeopleTableAnnotationComposer,
    $$PeopleTableCreateCompanionBuilder,
    $$PeopleTableUpdateCompanionBuilder,
    (PeopleData, $$PeopleTableReferences),
    PeopleData,
    PrefetchHooks Function({bool personBalanceCachesRefs})>;
typedef $$InvestmentsTableCreateCompanionBuilder = InvestmentsCompanion
    Function({
  required String id,
  required String name,
  required String type,
  Value<String?> symbol,
  Value<double?> marketValue,
  Value<DateTime?> marketValueUpdatedAt,
  Value<int> isArchived,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$InvestmentsTableUpdateCompanionBuilder = InvestmentsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<String?> symbol,
  Value<double?> marketValue,
  Value<DateTime?> marketValueUpdatedAt,
  Value<int> isArchived,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$InvestmentsTableReferences
    extends BaseReferences<_$AppDatabase, $InvestmentsTable, Investment> {
  $$InvestmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InvestmentBalanceCachesTable,
      List<InvestmentBalanceCache>> _investmentBalanceCachesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.investmentBalanceCaches,
          aliasName: $_aliasNameGenerator(
              db.investments.id, db.investmentBalanceCaches.investmentId));

  $$InvestmentBalanceCachesTableProcessedTableManager
      get investmentBalanceCachesRefs {
    final manager = $$InvestmentBalanceCachesTableTableManager(
            $_db, $_db.investmentBalanceCaches)
        .filter(
            (f) => f.investmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_investmentBalanceCachesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MtfPositionsTable, List<MtfPosition>>
      _mtfPositionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.mtfPositions,
              aliasName: $_aliasNameGenerator(
                  db.investments.id, db.mtfPositions.investmentId));

  $$MtfPositionsTableProcessedTableManager get mtfPositionsRefs {
    final manager = $$MtfPositionsTableTableManager($_db, $_db.mtfPositions)
        .filter(
            (f) => f.investmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mtfPositionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$InvestmentsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get marketValue => $composableBuilder(
      column: $table.marketValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get marketValueUpdatedAt => $composableBuilder(
      column: $table.marketValueUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  Expression<bool> investmentBalanceCachesRefs(
      Expression<bool> Function($$InvestmentBalanceCachesTableFilterComposer f)
          f) {
    final $$InvestmentBalanceCachesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.investmentBalanceCaches,
            getReferencedColumn: (t) => t.investmentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InvestmentBalanceCachesTableFilterComposer(
                  $db: $db,
                  $table: $db.investmentBalanceCaches,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> mtfPositionsRefs(
      Expression<bool> Function($$MtfPositionsTableFilterComposer f) f) {
    final $$MtfPositionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mtfPositions,
        getReferencedColumn: (t) => t.investmentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MtfPositionsTableFilterComposer(
              $db: $db,
              $table: $db.mtfPositions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$InvestmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get marketValue => $composableBuilder(
      column: $table.marketValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get marketValueUpdatedAt => $composableBuilder(
      column: $table.marketValueUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$InvestmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentsTable> {
  $$InvestmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<double> get marketValue => $composableBuilder(
      column: $table.marketValue, builder: (column) => column);

  GeneratedColumn<DateTime> get marketValueUpdatedAt => $composableBuilder(
      column: $table.marketValueUpdatedAt, builder: (column) => column);

  GeneratedColumn<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  Expression<T> investmentBalanceCachesRefs<T extends Object>(
      Expression<T> Function($$InvestmentBalanceCachesTableAnnotationComposer a)
          f) {
    final $$InvestmentBalanceCachesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.investmentBalanceCaches,
            getReferencedColumn: (t) => t.investmentId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InvestmentBalanceCachesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.investmentBalanceCaches,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> mtfPositionsRefs<T extends Object>(
      Expression<T> Function($$MtfPositionsTableAnnotationComposer a) f) {
    final $$MtfPositionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mtfPositions,
        getReferencedColumn: (t) => t.investmentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MtfPositionsTableAnnotationComposer(
              $db: $db,
              $table: $db.mtfPositions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$InvestmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvestmentsTable,
    Investment,
    $$InvestmentsTableFilterComposer,
    $$InvestmentsTableOrderingComposer,
    $$InvestmentsTableAnnotationComposer,
    $$InvestmentsTableCreateCompanionBuilder,
    $$InvestmentsTableUpdateCompanionBuilder,
    (Investment, $$InvestmentsTableReferences),
    Investment,
    PrefetchHooks Function(
        {bool investmentBalanceCachesRefs, bool mtfPositionsRefs})> {
  $$InvestmentsTableTableManager(_$AppDatabase db, $InvestmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> symbol = const Value.absent(),
            Value<double?> marketValue = const Value.absent(),
            Value<DateTime?> marketValueUpdatedAt = const Value.absent(),
            Value<int> isArchived = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvestmentsCompanion(
            id: id,
            name: name,
            type: type,
            symbol: symbol,
            marketValue: marketValue,
            marketValueUpdatedAt: marketValueUpdatedAt,
            isArchived: isArchived,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String type,
            Value<String?> symbol = const Value.absent(),
            Value<double?> marketValue = const Value.absent(),
            Value<DateTime?> marketValueUpdatedAt = const Value.absent(),
            Value<int> isArchived = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvestmentsCompanion.insert(
            id: id,
            name: name,
            type: type,
            symbol: symbol,
            marketValue: marketValue,
            marketValueUpdatedAt: marketValueUpdatedAt,
            isArchived: isArchived,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InvestmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {investmentBalanceCachesRefs = false, mtfPositionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (investmentBalanceCachesRefs) db.investmentBalanceCaches,
                if (mtfPositionsRefs) db.mtfPositions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (investmentBalanceCachesRefs)
                    await $_getPrefetchedData<Investment, $InvestmentsTable,
                            InvestmentBalanceCache>(
                        currentTable: table,
                        referencedTable: $$InvestmentsTableReferences
                            ._investmentBalanceCachesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InvestmentsTableReferences(db, table, p0)
                                .investmentBalanceCachesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.investmentId == item.id),
                        typedResults: items),
                  if (mtfPositionsRefs)
                    await $_getPrefetchedData<Investment, $InvestmentsTable,
                            MtfPosition>(
                        currentTable: table,
                        referencedTable: $$InvestmentsTableReferences
                            ._mtfPositionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InvestmentsTableReferences(db, table, p0)
                                .mtfPositionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.investmentId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$InvestmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvestmentsTable,
    Investment,
    $$InvestmentsTableFilterComposer,
    $$InvestmentsTableOrderingComposer,
    $$InvestmentsTableAnnotationComposer,
    $$InvestmentsTableCreateCompanionBuilder,
    $$InvestmentsTableUpdateCompanionBuilder,
    (Investment, $$InvestmentsTableReferences),
    Investment,
    PrefetchHooks Function(
        {bool investmentBalanceCachesRefs, bool mtfPositionsRefs})>;
typedef $$InvestmentLotsTableCreateCompanionBuilder = InvestmentLotsCompanion
    Function({
  required String id,
  required String investmentId,
  required String buyTransactionId,
  required double unitsPurchased,
  required double unitsRemaining,
  required double costPerUnit,
  required DateTime purchaseDate,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$InvestmentLotsTableUpdateCompanionBuilder = InvestmentLotsCompanion
    Function({
  Value<String> id,
  Value<String> investmentId,
  Value<String> buyTransactionId,
  Value<double> unitsPurchased,
  Value<double> unitsRemaining,
  Value<double> costPerUnit,
  Value<DateTime> purchaseDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$InvestmentLotsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentLotsTable> {
  $$InvestmentLotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get investmentId => $composableBuilder(
      column: $table.investmentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get buyTransactionId => $composableBuilder(
      column: $table.buyTransactionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitsPurchased => $composableBuilder(
      column: $table.unitsPurchased,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitsRemaining => $composableBuilder(
      column: $table.unitsRemaining,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPerUnit => $composableBuilder(
      column: $table.costPerUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$InvestmentLotsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentLotsTable> {
  $$InvestmentLotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get investmentId => $composableBuilder(
      column: $table.investmentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get buyTransactionId => $composableBuilder(
      column: $table.buyTransactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitsPurchased => $composableBuilder(
      column: $table.unitsPurchased,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitsRemaining => $composableBuilder(
      column: $table.unitsRemaining,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPerUnit => $composableBuilder(
      column: $table.costPerUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$InvestmentLotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentLotsTable> {
  $$InvestmentLotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get investmentId => $composableBuilder(
      column: $table.investmentId, builder: (column) => column);

  GeneratedColumn<String> get buyTransactionId => $composableBuilder(
      column: $table.buyTransactionId, builder: (column) => column);

  GeneratedColumn<double> get unitsPurchased => $composableBuilder(
      column: $table.unitsPurchased, builder: (column) => column);

  GeneratedColumn<double> get unitsRemaining => $composableBuilder(
      column: $table.unitsRemaining, builder: (column) => column);

  GeneratedColumn<double> get costPerUnit => $composableBuilder(
      column: $table.costPerUnit, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
      column: $table.purchaseDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$InvestmentLotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvestmentLotsTable,
    InvestmentLot,
    $$InvestmentLotsTableFilterComposer,
    $$InvestmentLotsTableOrderingComposer,
    $$InvestmentLotsTableAnnotationComposer,
    $$InvestmentLotsTableCreateCompanionBuilder,
    $$InvestmentLotsTableUpdateCompanionBuilder,
    (
      InvestmentLot,
      BaseReferences<_$AppDatabase, $InvestmentLotsTable, InvestmentLot>
    ),
    InvestmentLot,
    PrefetchHooks Function()> {
  $$InvestmentLotsTableTableManager(
      _$AppDatabase db, $InvestmentLotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentLotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentLotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentLotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> investmentId = const Value.absent(),
            Value<String> buyTransactionId = const Value.absent(),
            Value<double> unitsPurchased = const Value.absent(),
            Value<double> unitsRemaining = const Value.absent(),
            Value<double> costPerUnit = const Value.absent(),
            Value<DateTime> purchaseDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvestmentLotsCompanion(
            id: id,
            investmentId: investmentId,
            buyTransactionId: buyTransactionId,
            unitsPurchased: unitsPurchased,
            unitsRemaining: unitsRemaining,
            costPerUnit: costPerUnit,
            purchaseDate: purchaseDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String investmentId,
            required String buyTransactionId,
            required double unitsPurchased,
            required double unitsRemaining,
            required double costPerUnit,
            required DateTime purchaseDate,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvestmentLotsCompanion.insert(
            id: id,
            investmentId: investmentId,
            buyTransactionId: buyTransactionId,
            unitsPurchased: unitsPurchased,
            unitsRemaining: unitsRemaining,
            costPerUnit: costPerUnit,
            purchaseDate: purchaseDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InvestmentLotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvestmentLotsTable,
    InvestmentLot,
    $$InvestmentLotsTableFilterComposer,
    $$InvestmentLotsTableOrderingComposer,
    $$InvestmentLotsTableAnnotationComposer,
    $$InvestmentLotsTableCreateCompanionBuilder,
    $$InvestmentLotsTableUpdateCompanionBuilder,
    (
      InvestmentLot,
      BaseReferences<_$AppDatabase, $InvestmentLotsTable, InvestmentLot>
    ),
    InvestmentLot,
    PrefetchHooks Function()>;
typedef $$InvestmentLotConsumptionsTableCreateCompanionBuilder
    = InvestmentLotConsumptionsCompanion Function({
  required String id,
  required String sellTransactionId,
  required String lotId,
  required double unitsConsumed,
  required double costBasis,
  required double proceedsAllocated,
  required double realizedGainLoss,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$InvestmentLotConsumptionsTableUpdateCompanionBuilder
    = InvestmentLotConsumptionsCompanion Function({
  Value<String> id,
  Value<String> sellTransactionId,
  Value<String> lotId,
  Value<double> unitsConsumed,
  Value<double> costBasis,
  Value<double> proceedsAllocated,
  Value<double> realizedGainLoss,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$InvestmentLotConsumptionsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentLotConsumptionsTable> {
  $$InvestmentLotConsumptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sellTransactionId => $composableBuilder(
      column: $table.sellTransactionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lotId => $composableBuilder(
      column: $table.lotId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitsConsumed => $composableBuilder(
      column: $table.unitsConsumed, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costBasis => $composableBuilder(
      column: $table.costBasis, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proceedsAllocated => $composableBuilder(
      column: $table.proceedsAllocated,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get realizedGainLoss => $composableBuilder(
      column: $table.realizedGainLoss,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$InvestmentLotConsumptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentLotConsumptionsTable> {
  $$InvestmentLotConsumptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sellTransactionId => $composableBuilder(
      column: $table.sellTransactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lotId => $composableBuilder(
      column: $table.lotId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitsConsumed => $composableBuilder(
      column: $table.unitsConsumed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costBasis => $composableBuilder(
      column: $table.costBasis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proceedsAllocated => $composableBuilder(
      column: $table.proceedsAllocated,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get realizedGainLoss => $composableBuilder(
      column: $table.realizedGainLoss,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$InvestmentLotConsumptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentLotConsumptionsTable> {
  $$InvestmentLotConsumptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sellTransactionId => $composableBuilder(
      column: $table.sellTransactionId, builder: (column) => column);

  GeneratedColumn<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<double> get unitsConsumed => $composableBuilder(
      column: $table.unitsConsumed, builder: (column) => column);

  GeneratedColumn<double> get costBasis =>
      $composableBuilder(column: $table.costBasis, builder: (column) => column);

  GeneratedColumn<double> get proceedsAllocated => $composableBuilder(
      column: $table.proceedsAllocated, builder: (column) => column);

  GeneratedColumn<double> get realizedGainLoss => $composableBuilder(
      column: $table.realizedGainLoss, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InvestmentLotConsumptionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvestmentLotConsumptionsTable,
    InvestmentLotConsumption,
    $$InvestmentLotConsumptionsTableFilterComposer,
    $$InvestmentLotConsumptionsTableOrderingComposer,
    $$InvestmentLotConsumptionsTableAnnotationComposer,
    $$InvestmentLotConsumptionsTableCreateCompanionBuilder,
    $$InvestmentLotConsumptionsTableUpdateCompanionBuilder,
    (
      InvestmentLotConsumption,
      BaseReferences<_$AppDatabase, $InvestmentLotConsumptionsTable,
          InvestmentLotConsumption>
    ),
    InvestmentLotConsumption,
    PrefetchHooks Function()> {
  $$InvestmentLotConsumptionsTableTableManager(
      _$AppDatabase db, $InvestmentLotConsumptionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentLotConsumptionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentLotConsumptionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentLotConsumptionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sellTransactionId = const Value.absent(),
            Value<String> lotId = const Value.absent(),
            Value<double> unitsConsumed = const Value.absent(),
            Value<double> costBasis = const Value.absent(),
            Value<double> proceedsAllocated = const Value.absent(),
            Value<double> realizedGainLoss = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvestmentLotConsumptionsCompanion(
            id: id,
            sellTransactionId: sellTransactionId,
            lotId: lotId,
            unitsConsumed: unitsConsumed,
            costBasis: costBasis,
            proceedsAllocated: proceedsAllocated,
            realizedGainLoss: realizedGainLoss,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sellTransactionId,
            required String lotId,
            required double unitsConsumed,
            required double costBasis,
            required double proceedsAllocated,
            required double realizedGainLoss,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              InvestmentLotConsumptionsCompanion.insert(
            id: id,
            sellTransactionId: sellTransactionId,
            lotId: lotId,
            unitsConsumed: unitsConsumed,
            costBasis: costBasis,
            proceedsAllocated: proceedsAllocated,
            realizedGainLoss: realizedGainLoss,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InvestmentLotConsumptionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $InvestmentLotConsumptionsTable,
        InvestmentLotConsumption,
        $$InvestmentLotConsumptionsTableFilterComposer,
        $$InvestmentLotConsumptionsTableOrderingComposer,
        $$InvestmentLotConsumptionsTableAnnotationComposer,
        $$InvestmentLotConsumptionsTableCreateCompanionBuilder,
        $$InvestmentLotConsumptionsTableUpdateCompanionBuilder,
        (
          InvestmentLotConsumption,
          BaseReferences<_$AppDatabase, $InvestmentLotConsumptionsTable,
              InvestmentLotConsumption>
        ),
        InvestmentLotConsumption,
        PrefetchHooks Function()>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  required String id,
  required String type,
  required double amount,
  Value<String?> category,
  Value<String?> fromAccountId,
  Value<String?> toAccountId,
  Value<String?> personId,
  Value<String?> investmentId,
  Value<String?> voidedTransactionId,
  Value<String?> notes,
  Value<double?> pricePerUnit,
  Value<double?> units,
  required DateTime transactionDate,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<String> id,
  Value<String> type,
  Value<double> amount,
  Value<String?> category,
  Value<String?> fromAccountId,
  Value<String?> toAccountId,
  Value<String?> personId,
  Value<String?> investmentId,
  Value<String?> voidedTransactionId,
  Value<String?> notes,
  Value<double?> pricePerUnit,
  Value<double?> units,
  Value<DateTime> transactionDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AccountBalanceCachesTable,
      List<AccountBalanceCache>> _accountBalanceCachesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.accountBalanceCaches,
          aliasName: $_aliasNameGenerator(
              db.transactions.id, db.accountBalanceCaches.lastTransactionId));

  $$AccountBalanceCachesTableProcessedTableManager
      get accountBalanceCachesRefs {
    final manager =
        $$AccountBalanceCachesTableTableManager($_db, $_db.accountBalanceCaches)
            .filter((f) =>
                f.lastTransactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_accountBalanceCachesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PersonBalanceCachesTable,
      List<PersonBalanceCache>> _personBalanceCachesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.personBalanceCaches,
          aliasName: $_aliasNameGenerator(
              db.transactions.id, db.personBalanceCaches.lastTransactionId));

  $$PersonBalanceCachesTableProcessedTableManager get personBalanceCachesRefs {
    final manager =
        $$PersonBalanceCachesTableTableManager($_db, $_db.personBalanceCaches)
            .filter((f) =>
                f.lastTransactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_personBalanceCachesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InvestmentBalanceCachesTable,
      List<InvestmentBalanceCache>> _investmentBalanceCachesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.investmentBalanceCaches,
          aliasName: $_aliasNameGenerator(db.transactions.id,
              db.investmentBalanceCaches.lastTransactionId));

  $$InvestmentBalanceCachesTableProcessedTableManager
      get investmentBalanceCachesRefs {
    final manager = $$InvestmentBalanceCachesTableTableManager(
            $_db, $_db.investmentBalanceCaches)
        .filter((f) =>
            f.lastTransactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_investmentBalanceCachesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromAccountId => $composableBuilder(
      column: $table.fromAccountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toAccountId => $composableBuilder(
      column: $table.toAccountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get investmentId => $composableBuilder(
      column: $table.investmentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voidedTransactionId => $composableBuilder(
      column: $table.voidedTransactionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pricePerUnit => $composableBuilder(
      column: $table.pricePerUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get units => $composableBuilder(
      column: $table.units, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  Expression<bool> accountBalanceCachesRefs(
      Expression<bool> Function($$AccountBalanceCachesTableFilterComposer f)
          f) {
    final $$AccountBalanceCachesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.accountBalanceCaches,
        getReferencedColumn: (t) => t.lastTransactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountBalanceCachesTableFilterComposer(
              $db: $db,
              $table: $db.accountBalanceCaches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> personBalanceCachesRefs(
      Expression<bool> Function($$PersonBalanceCachesTableFilterComposer f) f) {
    final $$PersonBalanceCachesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.personBalanceCaches,
        getReferencedColumn: (t) => t.lastTransactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PersonBalanceCachesTableFilterComposer(
              $db: $db,
              $table: $db.personBalanceCaches,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> investmentBalanceCachesRefs(
      Expression<bool> Function($$InvestmentBalanceCachesTableFilterComposer f)
          f) {
    final $$InvestmentBalanceCachesTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.investmentBalanceCaches,
            getReferencedColumn: (t) => t.lastTransactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InvestmentBalanceCachesTableFilterComposer(
                  $db: $db,
                  $table: $db.investmentBalanceCaches,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fromAccountId => $composableBuilder(
      column: $table.fromAccountId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toAccountId => $composableBuilder(
      column: $table.toAccountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get investmentId => $composableBuilder(
      column: $table.investmentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voidedTransactionId => $composableBuilder(
      column: $table.voidedTransactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pricePerUnit => $composableBuilder(
      column: $table.pricePerUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get units => $composableBuilder(
      column: $table.units, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get fromAccountId => $composableBuilder(
      column: $table.fromAccountId, builder: (column) => column);

  GeneratedColumn<String> get toAccountId => $composableBuilder(
      column: $table.toAccountId, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get investmentId => $composableBuilder(
      column: $table.investmentId, builder: (column) => column);

  GeneratedColumn<String> get voidedTransactionId => $composableBuilder(
      column: $table.voidedTransactionId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get pricePerUnit => $composableBuilder(
      column: $table.pricePerUnit, builder: (column) => column);

  GeneratedColumn<double> get units =>
      $composableBuilder(column: $table.units, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  Expression<T> accountBalanceCachesRefs<T extends Object>(
      Expression<T> Function($$AccountBalanceCachesTableAnnotationComposer a)
          f) {
    final $$AccountBalanceCachesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.accountBalanceCaches,
            getReferencedColumn: (t) => t.lastTransactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$AccountBalanceCachesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.accountBalanceCaches,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> personBalanceCachesRefs<T extends Object>(
      Expression<T> Function($$PersonBalanceCachesTableAnnotationComposer a)
          f) {
    final $$PersonBalanceCachesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.personBalanceCaches,
            getReferencedColumn: (t) => t.lastTransactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PersonBalanceCachesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.personBalanceCaches,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> investmentBalanceCachesRefs<T extends Object>(
      Expression<T> Function($$InvestmentBalanceCachesTableAnnotationComposer a)
          f) {
    final $$InvestmentBalanceCachesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.investmentBalanceCaches,
            getReferencedColumn: (t) => t.lastTransactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InvestmentBalanceCachesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.investmentBalanceCaches,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function(
        {bool accountBalanceCachesRefs,
        bool personBalanceCachesRefs,
        bool investmentBalanceCachesRefs})> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> fromAccountId = const Value.absent(),
            Value<String?> toAccountId = const Value.absent(),
            Value<String?> personId = const Value.absent(),
            Value<String?> investmentId = const Value.absent(),
            Value<String?> voidedTransactionId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<double?> pricePerUnit = const Value.absent(),
            Value<double?> units = const Value.absent(),
            Value<DateTime> transactionDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            type: type,
            amount: amount,
            category: category,
            fromAccountId: fromAccountId,
            toAccountId: toAccountId,
            personId: personId,
            investmentId: investmentId,
            voidedTransactionId: voidedTransactionId,
            notes: notes,
            pricePerUnit: pricePerUnit,
            units: units,
            transactionDate: transactionDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required double amount,
            Value<String?> category = const Value.absent(),
            Value<String?> fromAccountId = const Value.absent(),
            Value<String?> toAccountId = const Value.absent(),
            Value<String?> personId = const Value.absent(),
            Value<String?> investmentId = const Value.absent(),
            Value<String?> voidedTransactionId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<double?> pricePerUnit = const Value.absent(),
            Value<double?> units = const Value.absent(),
            required DateTime transactionDate,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            type: type,
            amount: amount,
            category: category,
            fromAccountId: fromAccountId,
            toAccountId: toAccountId,
            personId: personId,
            investmentId: investmentId,
            voidedTransactionId: voidedTransactionId,
            notes: notes,
            pricePerUnit: pricePerUnit,
            units: units,
            transactionDate: transactionDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {accountBalanceCachesRefs = false,
              personBalanceCachesRefs = false,
              investmentBalanceCachesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (accountBalanceCachesRefs) db.accountBalanceCaches,
                if (personBalanceCachesRefs) db.personBalanceCaches,
                if (investmentBalanceCachesRefs) db.investmentBalanceCaches
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (accountBalanceCachesRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            AccountBalanceCache>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._accountBalanceCachesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .accountBalanceCachesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.lastTransactionId == item.id),
                        typedResults: items),
                  if (personBalanceCachesRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            PersonBalanceCache>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._personBalanceCachesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .personBalanceCachesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.lastTransactionId == item.id),
                        typedResults: items),
                  if (investmentBalanceCachesRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            InvestmentBalanceCache>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._investmentBalanceCachesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .investmentBalanceCachesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.lastTransactionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function(
        {bool accountBalanceCachesRefs,
        bool personBalanceCachesRefs,
        bool investmentBalanceCachesRefs})>;
typedef $$ExpectedIncomesTableCreateCompanionBuilder = ExpectedIncomesCompanion
    Function({
  required String id,
  required String source,
  required double amount,
  required String status,
  Value<DateTime?> expectedDate,
  Value<String?> receivedTransactionId,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$ExpectedIncomesTableUpdateCompanionBuilder = ExpectedIncomesCompanion
    Function({
  Value<String> id,
  Value<String> source,
  Value<double> amount,
  Value<String> status,
  Value<DateTime?> expectedDate,
  Value<String?> receivedTransactionId,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$ExpectedIncomesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpectedIncomesTable> {
  $$ExpectedIncomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expectedDate => $composableBuilder(
      column: $table.expectedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receivedTransactionId => $composableBuilder(
      column: $table.receivedTransactionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$ExpectedIncomesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpectedIncomesTable> {
  $$ExpectedIncomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expectedDate => $composableBuilder(
      column: $table.expectedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receivedTransactionId => $composableBuilder(
      column: $table.receivedTransactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$ExpectedIncomesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpectedIncomesTable> {
  $$ExpectedIncomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get expectedDate => $composableBuilder(
      column: $table.expectedDate, builder: (column) => column);

  GeneratedColumn<String> get receivedTransactionId => $composableBuilder(
      column: $table.receivedTransactionId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$ExpectedIncomesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpectedIncomesTable,
    ExpectedIncome,
    $$ExpectedIncomesTableFilterComposer,
    $$ExpectedIncomesTableOrderingComposer,
    $$ExpectedIncomesTableAnnotationComposer,
    $$ExpectedIncomesTableCreateCompanionBuilder,
    $$ExpectedIncomesTableUpdateCompanionBuilder,
    (
      ExpectedIncome,
      BaseReferences<_$AppDatabase, $ExpectedIncomesTable, ExpectedIncome>
    ),
    ExpectedIncome,
    PrefetchHooks Function()> {
  $$ExpectedIncomesTableTableManager(
      _$AppDatabase db, $ExpectedIncomesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpectedIncomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpectedIncomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpectedIncomesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> expectedDate = const Value.absent(),
            Value<String?> receivedTransactionId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpectedIncomesCompanion(
            id: id,
            source: source,
            amount: amount,
            status: status,
            expectedDate: expectedDate,
            receivedTransactionId: receivedTransactionId,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String source,
            required double amount,
            required String status,
            Value<DateTime?> expectedDate = const Value.absent(),
            Value<String?> receivedTransactionId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpectedIncomesCompanion.insert(
            id: id,
            source: source,
            amount: amount,
            status: status,
            expectedDate: expectedDate,
            receivedTransactionId: receivedTransactionId,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExpectedIncomesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpectedIncomesTable,
    ExpectedIncome,
    $$ExpectedIncomesTableFilterComposer,
    $$ExpectedIncomesTableOrderingComposer,
    $$ExpectedIncomesTableAnnotationComposer,
    $$ExpectedIncomesTableCreateCompanionBuilder,
    $$ExpectedIncomesTableUpdateCompanionBuilder,
    (
      ExpectedIncome,
      BaseReferences<_$AppDatabase, $ExpectedIncomesTable, ExpectedIncome>
    ),
    ExpectedIncome,
    PrefetchHooks Function()>;
typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  required String id,
  required String name,
  required double targetAmount,
  Value<double> currentAmount,
  Value<DateTime?> deadline,
  Value<String?> notes,
  Value<int> isArchived,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<double> targetAmount,
  Value<double> currentAmount,
  Value<DateTime?> deadline,
  Value<String?> notes,
  Value<int> isArchived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => column);

  GeneratedColumn<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$GoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalsTable,
    Goal,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
    Goal,
    PrefetchHooks Function()> {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> targetAmount = const Value.absent(),
            Value<double> currentAmount = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalsCompanion(
            id: id,
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            deadline: deadline,
            notes: notes,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required double targetAmount,
            Value<double> currentAmount = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> isArchived = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalsCompanion.insert(
            id: id,
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            deadline: deadline,
            notes: notes,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GoalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalsTable,
    Goal,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
    Goal,
    PrefetchHooks Function()>;
typedef $$GoalMilestonesTableCreateCompanionBuilder = GoalMilestonesCompanion
    Function({
  required String id,
  required String goalId,
  required String name,
  required double targetAmount,
  Value<DateTime?> reachedAt,
  Value<int> isArchived,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$GoalMilestonesTableUpdateCompanionBuilder = GoalMilestonesCompanion
    Function({
  Value<String> id,
  Value<String> goalId,
  Value<String> name,
  Value<double> targetAmount,
  Value<DateTime?> reachedAt,
  Value<int> isArchived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$GoalMilestonesTableFilterComposer
    extends Composer<_$AppDatabase, $GoalMilestonesTable> {
  $$GoalMilestonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get goalId => $composableBuilder(
      column: $table.goalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get reachedAt => $composableBuilder(
      column: $table.reachedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$GoalMilestonesTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalMilestonesTable> {
  $$GoalMilestonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goalId => $composableBuilder(
      column: $table.goalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get reachedAt => $composableBuilder(
      column: $table.reachedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$GoalMilestonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalMilestonesTable> {
  $$GoalMilestonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get goalId =>
      $composableBuilder(column: $table.goalId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get reachedAt =>
      $composableBuilder(column: $table.reachedAt, builder: (column) => column);

  GeneratedColumn<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GoalMilestonesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalMilestonesTable,
    GoalMilestone,
    $$GoalMilestonesTableFilterComposer,
    $$GoalMilestonesTableOrderingComposer,
    $$GoalMilestonesTableAnnotationComposer,
    $$GoalMilestonesTableCreateCompanionBuilder,
    $$GoalMilestonesTableUpdateCompanionBuilder,
    (
      GoalMilestone,
      BaseReferences<_$AppDatabase, $GoalMilestonesTable, GoalMilestone>
    ),
    GoalMilestone,
    PrefetchHooks Function()> {
  $$GoalMilestonesTableTableManager(
      _$AppDatabase db, $GoalMilestonesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalMilestonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalMilestonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalMilestonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> goalId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> targetAmount = const Value.absent(),
            Value<DateTime?> reachedAt = const Value.absent(),
            Value<int> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalMilestonesCompanion(
            id: id,
            goalId: goalId,
            name: name,
            targetAmount: targetAmount,
            reachedAt: reachedAt,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String goalId,
            required String name,
            required double targetAmount,
            Value<DateTime?> reachedAt = const Value.absent(),
            Value<int> isArchived = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalMilestonesCompanion.insert(
            id: id,
            goalId: goalId,
            name: name,
            targetAmount: targetAmount,
            reachedAt: reachedAt,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GoalMilestonesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalMilestonesTable,
    GoalMilestone,
    $$GoalMilestonesTableFilterComposer,
    $$GoalMilestonesTableOrderingComposer,
    $$GoalMilestonesTableAnnotationComposer,
    $$GoalMilestonesTableCreateCompanionBuilder,
    $$GoalMilestonesTableUpdateCompanionBuilder,
    (
      GoalMilestone,
      BaseReferences<_$AppDatabase, $GoalMilestonesTable, GoalMilestone>
    ),
    GoalMilestone,
    PrefetchHooks Function()>;
typedef $$SnapshotsTableCreateCompanionBuilder = SnapshotsCompanion Function({
  required String id,
  required DateTime snapshotDate,
  required double netWorth,
  required double assets,
  required double liabilities,
  Value<double> receivables,
  required double investedCapital,
  required double expectedIncome,
  required DateTime createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$SnapshotsTableUpdateCompanionBuilder = SnapshotsCompanion Function({
  Value<String> id,
  Value<DateTime> snapshotDate,
  Value<double> netWorth,
  Value<double> assets,
  Value<double> liabilities,
  Value<double> receivables,
  Value<double> investedCapital,
  Value<double> expectedIncome,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$SnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $SnapshotsTable> {
  $$SnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get snapshotDate => $composableBuilder(
      column: $table.snapshotDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get netWorth => $composableBuilder(
      column: $table.netWorth, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get assets => $composableBuilder(
      column: $table.assets, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get liabilities => $composableBuilder(
      column: $table.liabilities, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get receivables => $composableBuilder(
      column: $table.receivables, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get investedCapital => $composableBuilder(
      column: $table.investedCapital,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get expectedIncome => $composableBuilder(
      column: $table.expectedIncome,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$SnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $SnapshotsTable> {
  $$SnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get snapshotDate => $composableBuilder(
      column: $table.snapshotDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get netWorth => $composableBuilder(
      column: $table.netWorth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get assets => $composableBuilder(
      column: $table.assets, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get liabilities => $composableBuilder(
      column: $table.liabilities, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get receivables => $composableBuilder(
      column: $table.receivables, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get investedCapital => $composableBuilder(
      column: $table.investedCapital,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get expectedIncome => $composableBuilder(
      column: $table.expectedIncome,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$SnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnapshotsTable> {
  $$SnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get snapshotDate => $composableBuilder(
      column: $table.snapshotDate, builder: (column) => column);

  GeneratedColumn<double> get netWorth =>
      $composableBuilder(column: $table.netWorth, builder: (column) => column);

  GeneratedColumn<double> get assets =>
      $composableBuilder(column: $table.assets, builder: (column) => column);

  GeneratedColumn<double> get liabilities => $composableBuilder(
      column: $table.liabilities, builder: (column) => column);

  GeneratedColumn<double> get receivables => $composableBuilder(
      column: $table.receivables, builder: (column) => column);

  GeneratedColumn<double> get investedCapital => $composableBuilder(
      column: $table.investedCapital, builder: (column) => column);

  GeneratedColumn<double> get expectedIncome => $composableBuilder(
      column: $table.expectedIncome, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$SnapshotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SnapshotsTable,
    Snapshot,
    $$SnapshotsTableFilterComposer,
    $$SnapshotsTableOrderingComposer,
    $$SnapshotsTableAnnotationComposer,
    $$SnapshotsTableCreateCompanionBuilder,
    $$SnapshotsTableUpdateCompanionBuilder,
    (Snapshot, BaseReferences<_$AppDatabase, $SnapshotsTable, Snapshot>),
    Snapshot,
    PrefetchHooks Function()> {
  $$SnapshotsTableTableManager(_$AppDatabase db, $SnapshotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> snapshotDate = const Value.absent(),
            Value<double> netWorth = const Value.absent(),
            Value<double> assets = const Value.absent(),
            Value<double> liabilities = const Value.absent(),
            Value<double> receivables = const Value.absent(),
            Value<double> investedCapital = const Value.absent(),
            Value<double> expectedIncome = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SnapshotsCompanion(
            id: id,
            snapshotDate: snapshotDate,
            netWorth: netWorth,
            assets: assets,
            liabilities: liabilities,
            receivables: receivables,
            investedCapital: investedCapital,
            expectedIncome: expectedIncome,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime snapshotDate,
            required double netWorth,
            required double assets,
            required double liabilities,
            Value<double> receivables = const Value.absent(),
            required double investedCapital,
            required double expectedIncome,
            required DateTime createdAt,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SnapshotsCompanion.insert(
            id: id,
            snapshotDate: snapshotDate,
            netWorth: netWorth,
            assets: assets,
            liabilities: liabilities,
            receivables: receivables,
            investedCapital: investedCapital,
            expectedIncome: expectedIncome,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SnapshotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SnapshotsTable,
    Snapshot,
    $$SnapshotsTableFilterComposer,
    $$SnapshotsTableOrderingComposer,
    $$SnapshotsTableAnnotationComposer,
    $$SnapshotsTableCreateCompanionBuilder,
    $$SnapshotsTableUpdateCompanionBuilder,
    (Snapshot, BaseReferences<_$AppDatabase, $SnapshotsTable, Snapshot>),
    Snapshot,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  Value<String?> value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String?> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;
typedef $$AuditLogsTableCreateCompanionBuilder = AuditLogsCompanion Function({
  required String id,
  required String entityType,
  required String entityId,
  required String action,
  Value<String?> detailsJson,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$AuditLogsTableUpdateCompanionBuilder = AuditLogsCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> action,
  Value<String?> detailsJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detailsJson => $composableBuilder(
      column: $table.detailsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detailsJson => $composableBuilder(
      column: $table.detailsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get detailsJson => $composableBuilder(
      column: $table.detailsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuditLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AuditLogsTable,
    AuditLog,
    $$AuditLogsTableFilterComposer,
    $$AuditLogsTableOrderingComposer,
    $$AuditLogsTableAnnotationComposer,
    $$AuditLogsTableCreateCompanionBuilder,
    $$AuditLogsTableUpdateCompanionBuilder,
    (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
    AuditLog,
    PrefetchHooks Function()> {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String?> detailsJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditLogsCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            detailsJson: detailsJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required String action,
            Value<String?> detailsJson = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AuditLogsCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            detailsJson: detailsJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AuditLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AuditLogsTable,
    AuditLog,
    $$AuditLogsTableFilterComposer,
    $$AuditLogsTableOrderingComposer,
    $$AuditLogsTableAnnotationComposer,
    $$AuditLogsTableCreateCompanionBuilder,
    $$AuditLogsTableUpdateCompanionBuilder,
    (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
    AuditLog,
    PrefetchHooks Function()>;
typedef $$AccountBalanceCachesTableCreateCompanionBuilder
    = AccountBalanceCachesCompanion Function({
  required String accountId,
  Value<double> cashBalance,
  Value<double> liabilityBalance,
  Value<String?> lastTransactionId,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AccountBalanceCachesTableUpdateCompanionBuilder
    = AccountBalanceCachesCompanion Function({
  Value<String> accountId,
  Value<double> cashBalance,
  Value<double> liabilityBalance,
  Value<String?> lastTransactionId,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$AccountBalanceCachesTableReferences extends BaseReferences<
    _$AppDatabase, $AccountBalanceCachesTable, AccountBalanceCache> {
  $$AccountBalanceCachesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias($_aliasNameGenerator(
          db.accountBalanceCaches.accountId, db.accounts.id));

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<String>('account_id')!;

    final manager = $$AccountsTableTableManager($_db, $_db.accounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TransactionsTable _lastTransactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.accountBalanceCaches.lastTransactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager? get lastTransactionId {
    final $_column = $_itemColumn<String>('last_transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lastTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AccountBalanceCachesTableFilterComposer
    extends Composer<_$AppDatabase, $AccountBalanceCachesTable> {
  $$AccountBalanceCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get cashBalance => $composableBuilder(
      column: $table.cashBalance, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get liabilityBalance => $composableBuilder(
      column: $table.liabilityBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableFilterComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableFilterComposer get lastTransactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lastTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountBalanceCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountBalanceCachesTable> {
  $$AccountBalanceCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get cashBalance => $composableBuilder(
      column: $table.cashBalance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get liabilityBalance => $composableBuilder(
      column: $table.liabilityBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableOrderingComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableOrderingComposer get lastTransactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lastTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountBalanceCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountBalanceCachesTable> {
  $$AccountBalanceCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get cashBalance => $composableBuilder(
      column: $table.cashBalance, builder: (column) => column);

  GeneratedColumn<double> get liabilityBalance => $composableBuilder(
      column: $table.liabilityBalance, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.accounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.accounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableAnnotationComposer get lastTransactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lastTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AccountBalanceCachesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountBalanceCachesTable,
    AccountBalanceCache,
    $$AccountBalanceCachesTableFilterComposer,
    $$AccountBalanceCachesTableOrderingComposer,
    $$AccountBalanceCachesTableAnnotationComposer,
    $$AccountBalanceCachesTableCreateCompanionBuilder,
    $$AccountBalanceCachesTableUpdateCompanionBuilder,
    (AccountBalanceCache, $$AccountBalanceCachesTableReferences),
    AccountBalanceCache,
    PrefetchHooks Function({bool accountId, bool lastTransactionId})> {
  $$AccountBalanceCachesTableTableManager(
      _$AppDatabase db, $AccountBalanceCachesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountBalanceCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountBalanceCachesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountBalanceCachesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> accountId = const Value.absent(),
            Value<double> cashBalance = const Value.absent(),
            Value<double> liabilityBalance = const Value.absent(),
            Value<String?> lastTransactionId = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountBalanceCachesCompanion(
            accountId: accountId,
            cashBalance: cashBalance,
            liabilityBalance: liabilityBalance,
            lastTransactionId: lastTransactionId,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String accountId,
            Value<double> cashBalance = const Value.absent(),
            Value<double> liabilityBalance = const Value.absent(),
            Value<String?> lastTransactionId = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountBalanceCachesCompanion.insert(
            accountId: accountId,
            cashBalance: cashBalance,
            liabilityBalance: liabilityBalance,
            lastTransactionId: lastTransactionId,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AccountBalanceCachesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {accountId = false, lastTransactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable: $$AccountBalanceCachesTableReferences
                        ._accountIdTable(db),
                    referencedColumn: $$AccountBalanceCachesTableReferences
                        ._accountIdTable(db)
                        .id,
                  ) as T;
                }
                if (lastTransactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.lastTransactionId,
                    referencedTable: $$AccountBalanceCachesTableReferences
                        ._lastTransactionIdTable(db),
                    referencedColumn: $$AccountBalanceCachesTableReferences
                        ._lastTransactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AccountBalanceCachesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $AccountBalanceCachesTable,
        AccountBalanceCache,
        $$AccountBalanceCachesTableFilterComposer,
        $$AccountBalanceCachesTableOrderingComposer,
        $$AccountBalanceCachesTableAnnotationComposer,
        $$AccountBalanceCachesTableCreateCompanionBuilder,
        $$AccountBalanceCachesTableUpdateCompanionBuilder,
        (AccountBalanceCache, $$AccountBalanceCachesTableReferences),
        AccountBalanceCache,
        PrefetchHooks Function({bool accountId, bool lastTransactionId})>;
typedef $$PersonBalanceCachesTableCreateCompanionBuilder
    = PersonBalanceCachesCompanion Function({
  required String personId,
  Value<double> receivableBalance,
  Value<double> liabilityBalance,
  Value<String?> lastTransactionId,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PersonBalanceCachesTableUpdateCompanionBuilder
    = PersonBalanceCachesCompanion Function({
  Value<String> personId,
  Value<double> receivableBalance,
  Value<double> liabilityBalance,
  Value<String?> lastTransactionId,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$PersonBalanceCachesTableReferences extends BaseReferences<
    _$AppDatabase, $PersonBalanceCachesTable, PersonBalanceCache> {
  $$PersonBalanceCachesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PeopleTable _personIdTable(_$AppDatabase db) => db.people.createAlias(
      $_aliasNameGenerator(db.personBalanceCaches.personId, db.people.id));

  $$PeopleTableProcessedTableManager get personId {
    final $_column = $_itemColumn<String>('person_id')!;

    final manager = $$PeopleTableTableManager($_db, $_db.people)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TransactionsTable _lastTransactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.personBalanceCaches.lastTransactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager? get lastTransactionId {
    final $_column = $_itemColumn<String>('last_transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lastTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PersonBalanceCachesTableFilterComposer
    extends Composer<_$AppDatabase, $PersonBalanceCachesTable> {
  $$PersonBalanceCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get receivableBalance => $composableBuilder(
      column: $table.receivableBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get liabilityBalance => $composableBuilder(
      column: $table.liabilityBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableFilterComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableFilterComposer get lastTransactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lastTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PersonBalanceCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonBalanceCachesTable> {
  $$PersonBalanceCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get receivableBalance => $composableBuilder(
      column: $table.receivableBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get liabilityBalance => $composableBuilder(
      column: $table.liabilityBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableOrderingComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableOrderingComposer get lastTransactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lastTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PersonBalanceCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonBalanceCachesTable> {
  $$PersonBalanceCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get receivableBalance => $composableBuilder(
      column: $table.receivableBalance, builder: (column) => column);

  GeneratedColumn<double> get liabilityBalance => $composableBuilder(
      column: $table.liabilityBalance, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.personId,
        referencedTable: $db.people,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PeopleTableAnnotationComposer(
              $db: $db,
              $table: $db.people,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableAnnotationComposer get lastTransactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lastTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PersonBalanceCachesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PersonBalanceCachesTable,
    PersonBalanceCache,
    $$PersonBalanceCachesTableFilterComposer,
    $$PersonBalanceCachesTableOrderingComposer,
    $$PersonBalanceCachesTableAnnotationComposer,
    $$PersonBalanceCachesTableCreateCompanionBuilder,
    $$PersonBalanceCachesTableUpdateCompanionBuilder,
    (PersonBalanceCache, $$PersonBalanceCachesTableReferences),
    PersonBalanceCache,
    PrefetchHooks Function({bool personId, bool lastTransactionId})> {
  $$PersonBalanceCachesTableTableManager(
      _$AppDatabase db, $PersonBalanceCachesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonBalanceCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonBalanceCachesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonBalanceCachesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> personId = const Value.absent(),
            Value<double> receivableBalance = const Value.absent(),
            Value<double> liabilityBalance = const Value.absent(),
            Value<String?> lastTransactionId = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PersonBalanceCachesCompanion(
            personId: personId,
            receivableBalance: receivableBalance,
            liabilityBalance: liabilityBalance,
            lastTransactionId: lastTransactionId,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String personId,
            Value<double> receivableBalance = const Value.absent(),
            Value<double> liabilityBalance = const Value.absent(),
            Value<String?> lastTransactionId = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PersonBalanceCachesCompanion.insert(
            personId: personId,
            receivableBalance: receivableBalance,
            liabilityBalance: liabilityBalance,
            lastTransactionId: lastTransactionId,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PersonBalanceCachesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {personId = false, lastTransactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (personId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.personId,
                    referencedTable:
                        $$PersonBalanceCachesTableReferences._personIdTable(db),
                    referencedColumn: $$PersonBalanceCachesTableReferences
                        ._personIdTable(db)
                        .id,
                  ) as T;
                }
                if (lastTransactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.lastTransactionId,
                    referencedTable: $$PersonBalanceCachesTableReferences
                        ._lastTransactionIdTable(db),
                    referencedColumn: $$PersonBalanceCachesTableReferences
                        ._lastTransactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PersonBalanceCachesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PersonBalanceCachesTable,
    PersonBalanceCache,
    $$PersonBalanceCachesTableFilterComposer,
    $$PersonBalanceCachesTableOrderingComposer,
    $$PersonBalanceCachesTableAnnotationComposer,
    $$PersonBalanceCachesTableCreateCompanionBuilder,
    $$PersonBalanceCachesTableUpdateCompanionBuilder,
    (PersonBalanceCache, $$PersonBalanceCachesTableReferences),
    PersonBalanceCache,
    PrefetchHooks Function({bool personId, bool lastTransactionId})>;
typedef $$InvestmentBalanceCachesTableCreateCompanionBuilder
    = InvestmentBalanceCachesCompanion Function({
  required String investmentId,
  Value<double> investedCapital,
  Value<double> unitsHeld,
  Value<String?> lastTransactionId,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$InvestmentBalanceCachesTableUpdateCompanionBuilder
    = InvestmentBalanceCachesCompanion Function({
  Value<String> investmentId,
  Value<double> investedCapital,
  Value<double> unitsHeld,
  Value<String?> lastTransactionId,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$InvestmentBalanceCachesTableReferences extends BaseReferences<
    _$AppDatabase, $InvestmentBalanceCachesTable, InvestmentBalanceCache> {
  $$InvestmentBalanceCachesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $InvestmentsTable _investmentIdTable(_$AppDatabase db) =>
      db.investments.createAlias($_aliasNameGenerator(
          db.investmentBalanceCaches.investmentId, db.investments.id));

  $$InvestmentsTableProcessedTableManager get investmentId {
    final $_column = $_itemColumn<String>('investment_id')!;

    final manager = $$InvestmentsTableTableManager($_db, $_db.investments)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_investmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TransactionsTable _lastTransactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.investmentBalanceCaches.lastTransactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager? get lastTransactionId {
    final $_column = $_itemColumn<String>('last_transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lastTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InvestmentBalanceCachesTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentBalanceCachesTable> {
  $$InvestmentBalanceCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get investedCapital => $composableBuilder(
      column: $table.investedCapital,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitsHeld => $composableBuilder(
      column: $table.unitsHeld, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$InvestmentsTableFilterComposer get investmentId {
    final $$InvestmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.investmentId,
        referencedTable: $db.investments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvestmentsTableFilterComposer(
              $db: $db,
              $table: $db.investments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableFilterComposer get lastTransactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lastTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvestmentBalanceCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentBalanceCachesTable> {
  $$InvestmentBalanceCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get investedCapital => $composableBuilder(
      column: $table.investedCapital,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitsHeld => $composableBuilder(
      column: $table.unitsHeld, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$InvestmentsTableOrderingComposer get investmentId {
    final $$InvestmentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.investmentId,
        referencedTable: $db.investments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvestmentsTableOrderingComposer(
              $db: $db,
              $table: $db.investments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableOrderingComposer get lastTransactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lastTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvestmentBalanceCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentBalanceCachesTable> {
  $$InvestmentBalanceCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get investedCapital => $composableBuilder(
      column: $table.investedCapital, builder: (column) => column);

  GeneratedColumn<double> get unitsHeld =>
      $composableBuilder(column: $table.unitsHeld, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$InvestmentsTableAnnotationComposer get investmentId {
    final $$InvestmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.investmentId,
        referencedTable: $db.investments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvestmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.investments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TransactionsTableAnnotationComposer get lastTransactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.lastTransactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InvestmentBalanceCachesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvestmentBalanceCachesTable,
    InvestmentBalanceCache,
    $$InvestmentBalanceCachesTableFilterComposer,
    $$InvestmentBalanceCachesTableOrderingComposer,
    $$InvestmentBalanceCachesTableAnnotationComposer,
    $$InvestmentBalanceCachesTableCreateCompanionBuilder,
    $$InvestmentBalanceCachesTableUpdateCompanionBuilder,
    (InvestmentBalanceCache, $$InvestmentBalanceCachesTableReferences),
    InvestmentBalanceCache,
    PrefetchHooks Function({bool investmentId, bool lastTransactionId})> {
  $$InvestmentBalanceCachesTableTableManager(
      _$AppDatabase db, $InvestmentBalanceCachesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentBalanceCachesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentBalanceCachesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentBalanceCachesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> investmentId = const Value.absent(),
            Value<double> investedCapital = const Value.absent(),
            Value<double> unitsHeld = const Value.absent(),
            Value<String?> lastTransactionId = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvestmentBalanceCachesCompanion(
            investmentId: investmentId,
            investedCapital: investedCapital,
            unitsHeld: unitsHeld,
            lastTransactionId: lastTransactionId,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String investmentId,
            Value<double> investedCapital = const Value.absent(),
            Value<double> unitsHeld = const Value.absent(),
            Value<String?> lastTransactionId = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              InvestmentBalanceCachesCompanion.insert(
            investmentId: investmentId,
            investedCapital: investedCapital,
            unitsHeld: unitsHeld,
            lastTransactionId: lastTransactionId,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InvestmentBalanceCachesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {investmentId = false, lastTransactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (investmentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.investmentId,
                    referencedTable: $$InvestmentBalanceCachesTableReferences
                        ._investmentIdTable(db),
                    referencedColumn: $$InvestmentBalanceCachesTableReferences
                        ._investmentIdTable(db)
                        .id,
                  ) as T;
                }
                if (lastTransactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.lastTransactionId,
                    referencedTable: $$InvestmentBalanceCachesTableReferences
                        ._lastTransactionIdTable(db),
                    referencedColumn: $$InvestmentBalanceCachesTableReferences
                        ._lastTransactionIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InvestmentBalanceCachesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $InvestmentBalanceCachesTable,
        InvestmentBalanceCache,
        $$InvestmentBalanceCachesTableFilterComposer,
        $$InvestmentBalanceCachesTableOrderingComposer,
        $$InvestmentBalanceCachesTableAnnotationComposer,
        $$InvestmentBalanceCachesTableCreateCompanionBuilder,
        $$InvestmentBalanceCachesTableUpdateCompanionBuilder,
        (InvestmentBalanceCache, $$InvestmentBalanceCachesTableReferences),
        InvestmentBalanceCache,
        PrefetchHooks Function({bool investmentId, bool lastTransactionId})>;
typedef $$DefinitionsTableCreateCompanionBuilder = DefinitionsCompanion
    Function({
  required String id,
  required String term,
  required String definition,
  required String formula,
  required String example,
  required String includedItems,
  required String excludedItems,
  Value<int> isArchived,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DefinitionsTableUpdateCompanionBuilder = DefinitionsCompanion
    Function({
  Value<String> id,
  Value<String> term,
  Value<String> definition,
  Value<String> formula,
  Value<String> example,
  Value<String> includedItems,
  Value<String> excludedItems,
  Value<int> isArchived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $DefinitionsTable> {
  $$DefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get term => $composableBuilder(
      column: $table.term, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get definition => $composableBuilder(
      column: $table.definition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formula => $composableBuilder(
      column: $table.formula, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get example => $composableBuilder(
      column: $table.example, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get includedItems => $composableBuilder(
      column: $table.includedItems, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get excludedItems => $composableBuilder(
      column: $table.excludedItems, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DefinitionsTable> {
  $$DefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get term => $composableBuilder(
      column: $table.term, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get definition => $composableBuilder(
      column: $table.definition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formula => $composableBuilder(
      column: $table.formula, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get example => $composableBuilder(
      column: $table.example, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get includedItems => $composableBuilder(
      column: $table.includedItems,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get excludedItems => $composableBuilder(
      column: $table.excludedItems,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DefinitionsTable> {
  $$DefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
      column: $table.definition, builder: (column) => column);

  GeneratedColumn<String> get formula =>
      $composableBuilder(column: $table.formula, builder: (column) => column);

  GeneratedColumn<String> get example =>
      $composableBuilder(column: $table.example, builder: (column) => column);

  GeneratedColumn<String> get includedItems => $composableBuilder(
      column: $table.includedItems, builder: (column) => column);

  GeneratedColumn<String> get excludedItems => $composableBuilder(
      column: $table.excludedItems, builder: (column) => column);

  GeneratedColumn<int> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DefinitionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DefinitionsTable,
    Definition,
    $$DefinitionsTableFilterComposer,
    $$DefinitionsTableOrderingComposer,
    $$DefinitionsTableAnnotationComposer,
    $$DefinitionsTableCreateCompanionBuilder,
    $$DefinitionsTableUpdateCompanionBuilder,
    (Definition, BaseReferences<_$AppDatabase, $DefinitionsTable, Definition>),
    Definition,
    PrefetchHooks Function()> {
  $$DefinitionsTableTableManager(_$AppDatabase db, $DefinitionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DefinitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DefinitionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> term = const Value.absent(),
            Value<String> definition = const Value.absent(),
            Value<String> formula = const Value.absent(),
            Value<String> example = const Value.absent(),
            Value<String> includedItems = const Value.absent(),
            Value<String> excludedItems = const Value.absent(),
            Value<int> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DefinitionsCompanion(
            id: id,
            term: term,
            definition: definition,
            formula: formula,
            example: example,
            includedItems: includedItems,
            excludedItems: excludedItems,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String term,
            required String definition,
            required String formula,
            required String example,
            required String includedItems,
            required String excludedItems,
            Value<int> isArchived = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DefinitionsCompanion.insert(
            id: id,
            term: term,
            definition: definition,
            formula: formula,
            example: example,
            includedItems: includedItems,
            excludedItems: excludedItems,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DefinitionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DefinitionsTable,
    Definition,
    $$DefinitionsTableFilterComposer,
    $$DefinitionsTableOrderingComposer,
    $$DefinitionsTableAnnotationComposer,
    $$DefinitionsTableCreateCompanionBuilder,
    $$DefinitionsTableUpdateCompanionBuilder,
    (Definition, BaseReferences<_$AppDatabase, $DefinitionsTable, Definition>),
    Definition,
    PrefetchHooks Function()>;
typedef $$AdjustmentsTableCreateCompanionBuilder = AdjustmentsCompanion
    Function({
  required String id,
  required String entityType,
  required String entityId,
  required double oldAmount,
  required double newAmount,
  required double adjustedAmount,
  required String reason,
  required DateTime createdAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$AdjustmentsTableUpdateCompanionBuilder = AdjustmentsCompanion
    Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<double> oldAmount,
  Value<double> newAmount,
  Value<double> adjustedAmount,
  Value<String> reason,
  Value<DateTime> createdAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$AdjustmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AdjustmentsTable> {
  $$AdjustmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get oldAmount => $composableBuilder(
      column: $table.oldAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get newAmount => $composableBuilder(
      column: $table.newAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get adjustedAmount => $composableBuilder(
      column: $table.adjustedAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$AdjustmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AdjustmentsTable> {
  $$AdjustmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get oldAmount => $composableBuilder(
      column: $table.oldAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get newAmount => $composableBuilder(
      column: $table.newAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get adjustedAmount => $composableBuilder(
      column: $table.adjustedAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$AdjustmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdjustmentsTable> {
  $$AdjustmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<double> get oldAmount =>
      $composableBuilder(column: $table.oldAmount, builder: (column) => column);

  GeneratedColumn<double> get newAmount =>
      $composableBuilder(column: $table.newAmount, builder: (column) => column);

  GeneratedColumn<double> get adjustedAmount => $composableBuilder(
      column: $table.adjustedAmount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$AdjustmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AdjustmentsTable,
    Adjustment,
    $$AdjustmentsTableFilterComposer,
    $$AdjustmentsTableOrderingComposer,
    $$AdjustmentsTableAnnotationComposer,
    $$AdjustmentsTableCreateCompanionBuilder,
    $$AdjustmentsTableUpdateCompanionBuilder,
    (Adjustment, BaseReferences<_$AppDatabase, $AdjustmentsTable, Adjustment>),
    Adjustment,
    PrefetchHooks Function()> {
  $$AdjustmentsTableTableManager(_$AppDatabase db, $AdjustmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdjustmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdjustmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdjustmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<double> oldAmount = const Value.absent(),
            Value<double> newAmount = const Value.absent(),
            Value<double> adjustedAmount = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AdjustmentsCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            oldAmount: oldAmount,
            newAmount: newAmount,
            adjustedAmount: adjustedAmount,
            reason: reason,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityType,
            required String entityId,
            required double oldAmount,
            required double newAmount,
            required double adjustedAmount,
            required String reason,
            required DateTime createdAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AdjustmentsCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            oldAmount: oldAmount,
            newAmount: newAmount,
            adjustedAmount: adjustedAmount,
            reason: reason,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AdjustmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AdjustmentsTable,
    Adjustment,
    $$AdjustmentsTableFilterComposer,
    $$AdjustmentsTableOrderingComposer,
    $$AdjustmentsTableAnnotationComposer,
    $$AdjustmentsTableCreateCompanionBuilder,
    $$AdjustmentsTableUpdateCompanionBuilder,
    (Adjustment, BaseReferences<_$AppDatabase, $AdjustmentsTable, Adjustment>),
    Adjustment,
    PrefetchHooks Function()>;
typedef $$MilestonesTableCreateCompanionBuilder = MilestonesCompanion Function({
  required String id,
  required double amount,
  Value<DateTime?> dateAchieved,
  Value<int?> daysSincePrevious,
  Value<double?> netWorthAtAchievement,
  Value<int> isManual,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$MilestonesTableUpdateCompanionBuilder = MilestonesCompanion Function({
  Value<String> id,
  Value<double> amount,
  Value<DateTime?> dateAchieved,
  Value<int?> daysSincePrevious,
  Value<double?> netWorthAtAchievement,
  Value<int> isManual,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$MilestonesTableFilterComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateAchieved => $composableBuilder(
      column: $table.dateAchieved, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get daysSincePrevious => $composableBuilder(
      column: $table.daysSincePrevious,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get netWorthAtAchievement => $composableBuilder(
      column: $table.netWorthAtAchievement,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isManual => $composableBuilder(
      column: $table.isManual, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MilestonesTableOrderingComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateAchieved => $composableBuilder(
      column: $table.dateAchieved,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get daysSincePrevious => $composableBuilder(
      column: $table.daysSincePrevious,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get netWorthAtAchievement => $composableBuilder(
      column: $table.netWorthAtAchievement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isManual => $composableBuilder(
      column: $table.isManual, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MilestonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAchieved => $composableBuilder(
      column: $table.dateAchieved, builder: (column) => column);

  GeneratedColumn<int> get daysSincePrevious => $composableBuilder(
      column: $table.daysSincePrevious, builder: (column) => column);

  GeneratedColumn<double> get netWorthAtAchievement => $composableBuilder(
      column: $table.netWorthAtAchievement, builder: (column) => column);

  GeneratedColumn<int> get isManual =>
      $composableBuilder(column: $table.isManual, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MilestonesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MilestonesTable,
    Milestone,
    $$MilestonesTableFilterComposer,
    $$MilestonesTableOrderingComposer,
    $$MilestonesTableAnnotationComposer,
    $$MilestonesTableCreateCompanionBuilder,
    $$MilestonesTableUpdateCompanionBuilder,
    (Milestone, BaseReferences<_$AppDatabase, $MilestonesTable, Milestone>),
    Milestone,
    PrefetchHooks Function()> {
  $$MilestonesTableTableManager(_$AppDatabase db, $MilestonesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MilestonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MilestonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MilestonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime?> dateAchieved = const Value.absent(),
            Value<int?> daysSincePrevious = const Value.absent(),
            Value<double?> netWorthAtAchievement = const Value.absent(),
            Value<int> isManual = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MilestonesCompanion(
            id: id,
            amount: amount,
            dateAchieved: dateAchieved,
            daysSincePrevious: daysSincePrevious,
            netWorthAtAchievement: netWorthAtAchievement,
            isManual: isManual,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required double amount,
            Value<DateTime?> dateAchieved = const Value.absent(),
            Value<int?> daysSincePrevious = const Value.absent(),
            Value<double?> netWorthAtAchievement = const Value.absent(),
            Value<int> isManual = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MilestonesCompanion.insert(
            id: id,
            amount: amount,
            dateAchieved: dateAchieved,
            daysSincePrevious: daysSincePrevious,
            netWorthAtAchievement: netWorthAtAchievement,
            isManual: isManual,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MilestonesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MilestonesTable,
    Milestone,
    $$MilestonesTableFilterComposer,
    $$MilestonesTableOrderingComposer,
    $$MilestonesTableAnnotationComposer,
    $$MilestonesTableCreateCompanionBuilder,
    $$MilestonesTableUpdateCompanionBuilder,
    (Milestone, BaseReferences<_$AppDatabase, $MilestonesTable, Milestone>),
    Milestone,
    PrefetchHooks Function()>;
typedef $$AchievementsTableCreateCompanionBuilder = AchievementsCompanion
    Function({
  required String id,
  required String title,
  required String description,
  Value<DateTime?> dateUnlocked,
  required String category,
  Value<int> unlockedStatus,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AchievementsTableUpdateCompanionBuilder = AchievementsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<DateTime?> dateUnlocked,
  Value<String> category,
  Value<int> unlockedStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateUnlocked => $composableBuilder(
      column: $table.dateUnlocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unlockedStatus => $composableBuilder(
      column: $table.unlockedStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateUnlocked => $composableBuilder(
      column: $table.dateUnlocked,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unlockedStatus => $composableBuilder(
      column: $table.unlockedStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get dateUnlocked => $composableBuilder(
      column: $table.dateUnlocked, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get unlockedStatus => $composableBuilder(
      column: $table.unlockedStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AchievementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AchievementsTable,
    Achievement,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableAnnotationComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder,
    (
      Achievement,
      BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>
    ),
    Achievement,
    PrefetchHooks Function()> {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<DateTime?> dateUnlocked = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> unlockedStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsCompanion(
            id: id,
            title: title,
            description: description,
            dateUnlocked: dateUnlocked,
            category: category,
            unlockedStatus: unlockedStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String description,
            Value<DateTime?> dateUnlocked = const Value.absent(),
            required String category,
            Value<int> unlockedStatus = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsCompanion.insert(
            id: id,
            title: title,
            description: description,
            dateUnlocked: dateUnlocked,
            category: category,
            unlockedStatus: unlockedStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AchievementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AchievementsTable,
    Achievement,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableAnnotationComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder,
    (
      Achievement,
      BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>
    ),
    Achievement,
    PrefetchHooks Function()>;
typedef $$AchievementProgressTableCreateCompanionBuilder
    = AchievementProgressCompanion Function({
  required String id,
  required String achievementId,
  required double currentValue,
  required double targetValue,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AchievementProgressTableUpdateCompanionBuilder
    = AchievementProgressCompanion Function({
  Value<String> id,
  Value<String> achievementId,
  Value<double> currentValue,
  Value<double> targetValue,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AchievementProgressTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementProgressTable> {
  $$AchievementProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get achievementId => $composableBuilder(
      column: $table.achievementId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentValue => $composableBuilder(
      column: $table.currentValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AchievementProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementProgressTable> {
  $$AchievementProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get achievementId => $composableBuilder(
      column: $table.achievementId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentValue => $composableBuilder(
      column: $table.currentValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AchievementProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementProgressTable> {
  $$AchievementProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get achievementId => $composableBuilder(
      column: $table.achievementId, builder: (column) => column);

  GeneratedColumn<double> get currentValue => $composableBuilder(
      column: $table.currentValue, builder: (column) => column);

  GeneratedColumn<double> get targetValue => $composableBuilder(
      column: $table.targetValue, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AchievementProgressTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AchievementProgressTable,
    AchievementProgressData,
    $$AchievementProgressTableFilterComposer,
    $$AchievementProgressTableOrderingComposer,
    $$AchievementProgressTableAnnotationComposer,
    $$AchievementProgressTableCreateCompanionBuilder,
    $$AchievementProgressTableUpdateCompanionBuilder,
    (
      AchievementProgressData,
      BaseReferences<_$AppDatabase, $AchievementProgressTable,
          AchievementProgressData>
    ),
    AchievementProgressData,
    PrefetchHooks Function()> {
  $$AchievementProgressTableTableManager(
      _$AppDatabase db, $AchievementProgressTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementProgressTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementProgressTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> achievementId = const Value.absent(),
            Value<double> currentValue = const Value.absent(),
            Value<double> targetValue = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementProgressCompanion(
            id: id,
            achievementId: achievementId,
            currentValue: currentValue,
            targetValue: targetValue,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String achievementId,
            required double currentValue,
            required double targetValue,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementProgressCompanion.insert(
            id: id,
            achievementId: achievementId,
            currentValue: currentValue,
            targetValue: targetValue,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AchievementProgressTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AchievementProgressTable,
    AchievementProgressData,
    $$AchievementProgressTableFilterComposer,
    $$AchievementProgressTableOrderingComposer,
    $$AchievementProgressTableAnnotationComposer,
    $$AchievementProgressTableCreateCompanionBuilder,
    $$AchievementProgressTableUpdateCompanionBuilder,
    (
      AchievementProgressData,
      BaseReferences<_$AppDatabase, $AchievementProgressTable,
          AchievementProgressData>
    ),
    AchievementProgressData,
    PrefetchHooks Function()>;
typedef $$MtfPositionsTableCreateCompanionBuilder = MtfPositionsCompanion
    Function({
  required String id,
  required String investmentId,
  required String broker,
  required String instrument,
  required double units,
  required double averagePrice,
  required double ownCapital,
  required double borrowedCapital,
  required double interestRate,
  required DateTime openingDate,
  Value<DateTime?> closedDate,
  Value<int> isClosed,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastAccrualDate,
  Value<int> rowid,
});
typedef $$MtfPositionsTableUpdateCompanionBuilder = MtfPositionsCompanion
    Function({
  Value<String> id,
  Value<String> investmentId,
  Value<String> broker,
  Value<String> instrument,
  Value<double> units,
  Value<double> averagePrice,
  Value<double> ownCapital,
  Value<double> borrowedCapital,
  Value<double> interestRate,
  Value<DateTime> openingDate,
  Value<DateTime?> closedDate,
  Value<int> isClosed,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastAccrualDate,
  Value<int> rowid,
});

final class $$MtfPositionsTableReferences
    extends BaseReferences<_$AppDatabase, $MtfPositionsTable, MtfPosition> {
  $$MtfPositionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvestmentsTable _investmentIdTable(_$AppDatabase db) =>
      db.investments.createAlias($_aliasNameGenerator(
          db.mtfPositions.investmentId, db.investments.id));

  $$InvestmentsTableProcessedTableManager get investmentId {
    final $_column = $_itemColumn<String>('investment_id')!;

    final manager = $$InvestmentsTableTableManager($_db, $_db.investments)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_investmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MtfPositionsTableFilterComposer
    extends Composer<_$AppDatabase, $MtfPositionsTable> {
  $$MtfPositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get broker => $composableBuilder(
      column: $table.broker, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instrument => $composableBuilder(
      column: $table.instrument, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get units => $composableBuilder(
      column: $table.units, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get averagePrice => $composableBuilder(
      column: $table.averagePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get ownCapital => $composableBuilder(
      column: $table.ownCapital, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get borrowedCapital => $composableBuilder(
      column: $table.borrowedCapital,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get interestRate => $composableBuilder(
      column: $table.interestRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get openingDate => $composableBuilder(
      column: $table.openingDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get closedDate => $composableBuilder(
      column: $table.closedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isClosed => $composableBuilder(
      column: $table.isClosed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAccrualDate => $composableBuilder(
      column: $table.lastAccrualDate,
      builder: (column) => ColumnFilters(column));

  $$InvestmentsTableFilterComposer get investmentId {
    final $$InvestmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.investmentId,
        referencedTable: $db.investments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvestmentsTableFilterComposer(
              $db: $db,
              $table: $db.investments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MtfPositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MtfPositionsTable> {
  $$MtfPositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get broker => $composableBuilder(
      column: $table.broker, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instrument => $composableBuilder(
      column: $table.instrument, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get units => $composableBuilder(
      column: $table.units, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get averagePrice => $composableBuilder(
      column: $table.averagePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get ownCapital => $composableBuilder(
      column: $table.ownCapital, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get borrowedCapital => $composableBuilder(
      column: $table.borrowedCapital,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get interestRate => $composableBuilder(
      column: $table.interestRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get openingDate => $composableBuilder(
      column: $table.openingDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get closedDate => $composableBuilder(
      column: $table.closedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isClosed => $composableBuilder(
      column: $table.isClosed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAccrualDate => $composableBuilder(
      column: $table.lastAccrualDate,
      builder: (column) => ColumnOrderings(column));

  $$InvestmentsTableOrderingComposer get investmentId {
    final $$InvestmentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.investmentId,
        referencedTable: $db.investments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvestmentsTableOrderingComposer(
              $db: $db,
              $table: $db.investments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MtfPositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MtfPositionsTable> {
  $$MtfPositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get broker =>
      $composableBuilder(column: $table.broker, builder: (column) => column);

  GeneratedColumn<String> get instrument => $composableBuilder(
      column: $table.instrument, builder: (column) => column);

  GeneratedColumn<double> get units =>
      $composableBuilder(column: $table.units, builder: (column) => column);

  GeneratedColumn<double> get averagePrice => $composableBuilder(
      column: $table.averagePrice, builder: (column) => column);

  GeneratedColumn<double> get ownCapital => $composableBuilder(
      column: $table.ownCapital, builder: (column) => column);

  GeneratedColumn<double> get borrowedCapital => $composableBuilder(
      column: $table.borrowedCapital, builder: (column) => column);

  GeneratedColumn<double> get interestRate => $composableBuilder(
      column: $table.interestRate, builder: (column) => column);

  GeneratedColumn<DateTime> get openingDate => $composableBuilder(
      column: $table.openingDate, builder: (column) => column);

  GeneratedColumn<DateTime> get closedDate => $composableBuilder(
      column: $table.closedDate, builder: (column) => column);

  GeneratedColumn<int> get isClosed =>
      $composableBuilder(column: $table.isClosed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccrualDate => $composableBuilder(
      column: $table.lastAccrualDate, builder: (column) => column);

  $$InvestmentsTableAnnotationComposer get investmentId {
    final $$InvestmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.investmentId,
        referencedTable: $db.investments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InvestmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.investments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MtfPositionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MtfPositionsTable,
    MtfPosition,
    $$MtfPositionsTableFilterComposer,
    $$MtfPositionsTableOrderingComposer,
    $$MtfPositionsTableAnnotationComposer,
    $$MtfPositionsTableCreateCompanionBuilder,
    $$MtfPositionsTableUpdateCompanionBuilder,
    (MtfPosition, $$MtfPositionsTableReferences),
    MtfPosition,
    PrefetchHooks Function({bool investmentId})> {
  $$MtfPositionsTableTableManager(_$AppDatabase db, $MtfPositionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MtfPositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MtfPositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MtfPositionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> investmentId = const Value.absent(),
            Value<String> broker = const Value.absent(),
            Value<String> instrument = const Value.absent(),
            Value<double> units = const Value.absent(),
            Value<double> averagePrice = const Value.absent(),
            Value<double> ownCapital = const Value.absent(),
            Value<double> borrowedCapital = const Value.absent(),
            Value<double> interestRate = const Value.absent(),
            Value<DateTime> openingDate = const Value.absent(),
            Value<DateTime?> closedDate = const Value.absent(),
            Value<int> isClosed = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastAccrualDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MtfPositionsCompanion(
            id: id,
            investmentId: investmentId,
            broker: broker,
            instrument: instrument,
            units: units,
            averagePrice: averagePrice,
            ownCapital: ownCapital,
            borrowedCapital: borrowedCapital,
            interestRate: interestRate,
            openingDate: openingDate,
            closedDate: closedDate,
            isClosed: isClosed,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastAccrualDate: lastAccrualDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String investmentId,
            required String broker,
            required String instrument,
            required double units,
            required double averagePrice,
            required double ownCapital,
            required double borrowedCapital,
            required double interestRate,
            required DateTime openingDate,
            Value<DateTime?> closedDate = const Value.absent(),
            Value<int> isClosed = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastAccrualDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MtfPositionsCompanion.insert(
            id: id,
            investmentId: investmentId,
            broker: broker,
            instrument: instrument,
            units: units,
            averagePrice: averagePrice,
            ownCapital: ownCapital,
            borrowedCapital: borrowedCapital,
            interestRate: interestRate,
            openingDate: openingDate,
            closedDate: closedDate,
            isClosed: isClosed,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastAccrualDate: lastAccrualDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MtfPositionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({investmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (investmentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.investmentId,
                    referencedTable:
                        $$MtfPositionsTableReferences._investmentIdTable(db),
                    referencedColumn:
                        $$MtfPositionsTableReferences._investmentIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MtfPositionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MtfPositionsTable,
    MtfPosition,
    $$MtfPositionsTableFilterComposer,
    $$MtfPositionsTableOrderingComposer,
    $$MtfPositionsTableAnnotationComposer,
    $$MtfPositionsTableCreateCompanionBuilder,
    $$MtfPositionsTableUpdateCompanionBuilder,
    (MtfPosition, $$MtfPositionsTableReferences),
    MtfPosition,
    PrefetchHooks Function({bool investmentId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
  $$InvestmentsTableTableManager get investments =>
      $$InvestmentsTableTableManager(_db, _db.investments);
  $$InvestmentLotsTableTableManager get investmentLots =>
      $$InvestmentLotsTableTableManager(_db, _db.investmentLots);
  $$InvestmentLotConsumptionsTableTableManager get investmentLotConsumptions =>
      $$InvestmentLotConsumptionsTableTableManager(
          _db, _db.investmentLotConsumptions);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$ExpectedIncomesTableTableManager get expectedIncomes =>
      $$ExpectedIncomesTableTableManager(_db, _db.expectedIncomes);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$GoalMilestonesTableTableManager get goalMilestones =>
      $$GoalMilestonesTableTableManager(_db, _db.goalMilestones);
  $$SnapshotsTableTableManager get snapshots =>
      $$SnapshotsTableTableManager(_db, _db.snapshots);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$AccountBalanceCachesTableTableManager get accountBalanceCaches =>
      $$AccountBalanceCachesTableTableManager(_db, _db.accountBalanceCaches);
  $$PersonBalanceCachesTableTableManager get personBalanceCaches =>
      $$PersonBalanceCachesTableTableManager(_db, _db.personBalanceCaches);
  $$InvestmentBalanceCachesTableTableManager get investmentBalanceCaches =>
      $$InvestmentBalanceCachesTableTableManager(
          _db, _db.investmentBalanceCaches);
  $$DefinitionsTableTableManager get definitions =>
      $$DefinitionsTableTableManager(_db, _db.definitions);
  $$AdjustmentsTableTableManager get adjustments =>
      $$AdjustmentsTableTableManager(_db, _db.adjustments);
  $$MilestonesTableTableManager get milestones =>
      $$MilestonesTableTableManager(_db, _db.milestones);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$AchievementProgressTableTableManager get achievementProgress =>
      $$AchievementProgressTableTableManager(_db, _db.achievementProgress);
  $$MtfPositionsTableTableManager get mtfPositions =>
      $$MtfPositionsTableTableManager(_db, _db.mtfPositions);
}
