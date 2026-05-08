// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _prenomMeta = const VerificationMeta('prenom');
  @override
  late final GeneratedColumn<String> prenom = GeneratedColumn<String>(
      'prenom', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _avatarPathMeta =
      const VerificationMeta('avatarPath');
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
      'avatar_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('enfant'));
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pinHashMeta =
      const VerificationMeta('pinHash');
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
      'pin_hash', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _allowDiscoveryModeMeta =
      const VerificationMeta('allowDiscoveryMode');
  @override
  late final GeneratedColumn<bool> allowDiscoveryMode = GeneratedColumn<bool>(
      'allow_discovery_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("allow_discovery_mode" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _archivedAtMeta =
      const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
      'archived_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        prenom,
        nom,
        avatarPath,
        type,
        parentId,
        pinHash,
        allowDiscoveryMode,
        createdAt,
        archivedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('prenom')) {
      context.handle(_prenomMeta,
          prenom.isAcceptableOrUnknown(data['prenom']!, _prenomMeta));
    } else if (isInserting) {
      context.missing(_prenomMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
          _avatarPathMeta,
          avatarPath.isAcceptableOrUnknown(
              data['avatar_path']!, _avatarPathMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('pin_hash')) {
      context.handle(_pinHashMeta,
          pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta));
    }
    if (data.containsKey('allow_discovery_mode')) {
      context.handle(
          _allowDiscoveryModeMeta,
          allowDiscoveryMode.isAcceptableOrUnknown(
              data['allow_discovery_mode']!, _allowDiscoveryModeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('archived_at')) {
      context.handle(
          _archivedAtMeta,
          archivedAt.isAcceptableOrUnknown(
              data['archived_at']!, _archivedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      prenom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prenom'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom']),
      avatarPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_path']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parent_id']),
      pinHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pin_hash']),
      allowDiscoveryMode: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}allow_discovery_mode'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      archivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}archived_at']),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  /// Identifiant auto-incrémenté.
  final int id;

  /// Prénom affiché dans l'UI.
  final String prenom;

  /// Nom de famille (optionnel — enfant souvent identifié par prénom seul).
  final String? nom;

  /// Chemin local de l'avatar (image choisie depuis la galerie, pas de réseau).
  final String? avatarPath;

  /// Type de profil : 'praticien' ou 'enfant'.
  final String type;

  /// Id du praticien parent (null si profil praticien).
  final int? parentId;

  /// Hash SHA-256 du PIN (praticien uniquement). Null = pas de PIN.
  final String? pinHash;

  /// Autorise le mode Découverte (sélection libre par niveau Dubois-Buyse).
  /// Activé par défaut — le praticien peut le désactiver profil par profil.
  final bool allowDiscoveryMode;

  /// Date de création du profil.
  final DateTime createdAt;

  /// Date d'archivage (null = profil actif). Un profil archivé n'apparaît
  /// plus dans l'écran de connexion mais toutes ses données sont conservées.
  final DateTime? archivedAt;
  const Profile(
      {required this.id,
      required this.prenom,
      this.nom,
      this.avatarPath,
      required this.type,
      this.parentId,
      this.pinHash,
      required this.allowDiscoveryMode,
      required this.createdAt,
      this.archivedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['prenom'] = Variable<String>(prenom);
    if (!nullToAbsent || nom != null) {
      map['nom'] = Variable<String>(nom);
    }
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    map['allow_discovery_mode'] = Variable<bool>(allowDiscoveryMode);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      prenom: Value(prenom),
      nom: nom == null && nullToAbsent ? const Value.absent() : Value(nom),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      type: Value(type),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      pinHash: pinHash == null && nullToAbsent
          ? const Value.absent()
          : Value(pinHash),
      allowDiscoveryMode: Value(allowDiscoveryMode),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      prenom: serializer.fromJson<String>(json['prenom']),
      nom: serializer.fromJson<String?>(json['nom']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      type: serializer.fromJson<String>(json['type']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      allowDiscoveryMode: serializer.fromJson<bool>(json['allowDiscoveryMode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'prenom': serializer.toJson<String>(prenom),
      'nom': serializer.toJson<String?>(nom),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'type': serializer.toJson<String>(type),
      'parentId': serializer.toJson<int?>(parentId),
      'pinHash': serializer.toJson<String?>(pinHash),
      'allowDiscoveryMode': serializer.toJson<bool>(allowDiscoveryMode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  Profile copyWith(
          {int? id,
          String? prenom,
          Value<String?> nom = const Value.absent(),
          Value<String?> avatarPath = const Value.absent(),
          String? type,
          Value<int?> parentId = const Value.absent(),
          Value<String?> pinHash = const Value.absent(),
          bool? allowDiscoveryMode,
          DateTime? createdAt,
          Value<DateTime?> archivedAt = const Value.absent()}) =>
      Profile(
        id: id ?? this.id,
        prenom: prenom ?? this.prenom,
        nom: nom.present ? nom.value : this.nom,
        avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
        type: type ?? this.type,
        parentId: parentId.present ? parentId.value : this.parentId,
        pinHash: pinHash.present ? pinHash.value : this.pinHash,
        allowDiscoveryMode: allowDiscoveryMode ?? this.allowDiscoveryMode,
        createdAt: createdAt ?? this.createdAt,
        archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
      );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      prenom: data.prenom.present ? data.prenom.value : this.prenom,
      nom: data.nom.present ? data.nom.value : this.nom,
      avatarPath:
          data.avatarPath.present ? data.avatarPath.value : this.avatarPath,
      type: data.type.present ? data.type.value : this.type,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      allowDiscoveryMode: data.allowDiscoveryMode.present
          ? data.allowDiscoveryMode.value
          : this.allowDiscoveryMode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('prenom: $prenom, ')
          ..write('nom: $nom, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('type: $type, ')
          ..write('parentId: $parentId, ')
          ..write('pinHash: $pinHash, ')
          ..write('allowDiscoveryMode: $allowDiscoveryMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, prenom, nom, avatarPath, type, parentId,
      pinHash, allowDiscoveryMode, createdAt, archivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.prenom == this.prenom &&
          other.nom == this.nom &&
          other.avatarPath == this.avatarPath &&
          other.type == this.type &&
          other.parentId == this.parentId &&
          other.pinHash == this.pinHash &&
          other.allowDiscoveryMode == this.allowDiscoveryMode &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> prenom;
  final Value<String?> nom;
  final Value<String?> avatarPath;
  final Value<String> type;
  final Value<int?> parentId;
  final Value<String?> pinHash;
  final Value<bool> allowDiscoveryMode;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.prenom = const Value.absent(),
    this.nom = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.type = const Value.absent(),
    this.parentId = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.allowDiscoveryMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String prenom,
    this.nom = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.type = const Value.absent(),
    this.parentId = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.allowDiscoveryMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  }) : prenom = Value(prenom);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? prenom,
    Expression<String>? nom,
    Expression<String>? avatarPath,
    Expression<String>? type,
    Expression<int>? parentId,
    Expression<String>? pinHash,
    Expression<bool>? allowDiscoveryMode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (prenom != null) 'prenom': prenom,
      if (nom != null) 'nom': nom,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (type != null) 'type': type,
      if (parentId != null) 'parent_id': parentId,
      if (pinHash != null) 'pin_hash': pinHash,
      if (allowDiscoveryMode != null)
        'allow_discovery_mode': allowDiscoveryMode,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
    });
  }

  ProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? prenom,
      Value<String?>? nom,
      Value<String?>? avatarPath,
      Value<String>? type,
      Value<int?>? parentId,
      Value<String?>? pinHash,
      Value<bool>? allowDiscoveryMode,
      Value<DateTime>? createdAt,
      Value<DateTime?>? archivedAt}) {
    return ProfilesCompanion(
      id: id ?? this.id,
      prenom: prenom ?? this.prenom,
      nom: nom ?? this.nom,
      avatarPath: avatarPath ?? this.avatarPath,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      pinHash: pinHash ?? this.pinHash,
      allowDiscoveryMode: allowDiscoveryMode ?? this.allowDiscoveryMode,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (prenom.present) {
      map['prenom'] = Variable<String>(prenom.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (allowDiscoveryMode.present) {
      map['allow_discovery_mode'] = Variable<bool>(allowDiscoveryMode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('prenom: $prenom, ')
          ..write('nom: $nom, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('type: $type, ')
          ..write('parentId: $parentId, ')
          ..write('pinHash: $pinHash, ')
          ..write('allowDiscoveryMode: $allowDiscoveryMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }
}

class $DictionariesTable extends Dictionaries
    with TableInfo<$DictionariesTable, Dictionary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DictionariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
      'nom', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _couleurMeta =
      const VerificationMeta('couleur');
  @override
  late final GeneratedColumn<String> couleur = GeneratedColumn<String>(
      'couleur', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#6A5AE0'));
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('book'));
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, nom, description, couleur, icon, active, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dictionaries';
  @override
  VerificationContext validateIntegrity(Insertable<Dictionary> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('nom')) {
      context.handle(
          _nomMeta, nom.isAcceptableOrUnknown(data['nom']!, _nomMeta));
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('couleur')) {
      context.handle(_couleurMeta,
          couleur.isAcceptableOrUnknown(data['couleur']!, _couleurMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dictionary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dictionary(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      nom: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nom'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      couleur: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}couleur'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DictionariesTable createAlias(String alias) {
    return $DictionariesTable(attachedDatabase, alias);
  }
}

class Dictionary extends DataClass implements Insertable<Dictionary> {
  final int id;

  /// Profil propriétaire du dictionnaire (enfant ou praticien).
  final int profileId;

  /// Nom du dictionnaire (ex : "Sons [f] et [v]").
  final String nom;

  /// Description libre du dictionnaire.
  final String? description;

  /// Couleur hexadécimale de l'étiquette (#RRGGBB).
  final String couleur;

  /// Icône Material (nom de l'icône en chaîne).
  final String icon;

  /// Dictionnaire actif ou archivé.
  final bool active;

  /// Date de création.
  final DateTime createdAt;
  const Dictionary(
      {required this.id,
      required this.profileId,
      required this.nom,
      this.description,
      required this.couleur,
      required this.icon,
      required this.active,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['nom'] = Variable<String>(nom);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['couleur'] = Variable<String>(couleur);
    map['icon'] = Variable<String>(icon);
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DictionariesCompanion toCompanion(bool nullToAbsent) {
    return DictionariesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      nom: Value(nom),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      couleur: Value(couleur),
      icon: Value(icon),
      active: Value(active),
      createdAt: Value(createdAt),
    );
  }

  factory Dictionary.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dictionary(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      nom: serializer.fromJson<String>(json['nom']),
      description: serializer.fromJson<String?>(json['description']),
      couleur: serializer.fromJson<String>(json['couleur']),
      icon: serializer.fromJson<String>(json['icon']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'nom': serializer.toJson<String>(nom),
      'description': serializer.toJson<String?>(description),
      'couleur': serializer.toJson<String>(couleur),
      'icon': serializer.toJson<String>(icon),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Dictionary copyWith(
          {int? id,
          int? profileId,
          String? nom,
          Value<String?> description = const Value.absent(),
          String? couleur,
          String? icon,
          bool? active,
          DateTime? createdAt}) =>
      Dictionary(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        nom: nom ?? this.nom,
        description: description.present ? description.value : this.description,
        couleur: couleur ?? this.couleur,
        icon: icon ?? this.icon,
        active: active ?? this.active,
        createdAt: createdAt ?? this.createdAt,
      );
  Dictionary copyWithCompanion(DictionariesCompanion data) {
    return Dictionary(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      nom: data.nom.present ? data.nom.value : this.nom,
      description:
          data.description.present ? data.description.value : this.description,
      couleur: data.couleur.present ? data.couleur.value : this.couleur,
      icon: data.icon.present ? data.icon.value : this.icon,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dictionary(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('nom: $nom, ')
          ..write('description: $description, ')
          ..write('couleur: $couleur, ')
          ..write('icon: $icon, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, profileId, nom, description, couleur, icon, active, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dictionary &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.nom == this.nom &&
          other.description == this.description &&
          other.couleur == this.couleur &&
          other.icon == this.icon &&
          other.active == this.active &&
          other.createdAt == this.createdAt);
}

class DictionariesCompanion extends UpdateCompanion<Dictionary> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> nom;
  final Value<String?> description;
  final Value<String> couleur;
  final Value<String> icon;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  const DictionariesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.nom = const Value.absent(),
    this.description = const Value.absent(),
    this.couleur = const Value.absent(),
    this.icon = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DictionariesCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required String nom,
    this.description = const Value.absent(),
    this.couleur = const Value.absent(),
    this.icon = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : profileId = Value(profileId),
        nom = Value(nom);
  static Insertable<Dictionary> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? nom,
    Expression<String>? description,
    Expression<String>? couleur,
    Expression<String>? icon,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (nom != null) 'nom': nom,
      if (description != null) 'description': description,
      if (couleur != null) 'couleur': couleur,
      if (icon != null) 'icon': icon,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DictionariesCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? nom,
      Value<String?>? description,
      Value<String>? couleur,
      Value<String>? icon,
      Value<bool>? active,
      Value<DateTime>? createdAt}) {
    return DictionariesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      couleur: couleur ?? this.couleur,
      icon: icon ?? this.icon,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (couleur.present) {
      map['couleur'] = Variable<String>(couleur.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DictionariesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('nom: $nom, ')
          ..write('description: $description, ')
          ..write('couleur: $couleur, ')
          ..write('icon: $icon, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DictionaryAssignmentsTable extends DictionaryAssignments
    with TableInfo<$DictionaryAssignmentsTable, DictionaryAssignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DictionaryAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dictionaryIdMeta =
      const VerificationMeta('dictionaryId');
  @override
  late final GeneratedColumn<int> dictionaryId = GeneratedColumn<int>(
      'dictionary_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES dictionaries (id)'));
  static const VerificationMeta _childIdMeta =
      const VerificationMeta('childId');
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
      'child_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  static const VerificationMeta _assignedAtMeta =
      const VerificationMeta('assignedAt');
  @override
  late final GeneratedColumn<DateTime> assignedAt = GeneratedColumn<DateTime>(
      'assigned_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, dictionaryId, childId, assignedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dictionary_assignments';
  @override
  VerificationContext validateIntegrity(
      Insertable<DictionaryAssignment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dictionary_id')) {
      context.handle(
          _dictionaryIdMeta,
          dictionaryId.isAcceptableOrUnknown(
              data['dictionary_id']!, _dictionaryIdMeta));
    } else if (isInserting) {
      context.missing(_dictionaryIdMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(_childIdMeta,
          childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta));
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('assigned_at')) {
      context.handle(
          _assignedAtMeta,
          assignedAt.isAcceptableOrUnknown(
              data['assigned_at']!, _assignedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {dictionaryId, childId},
      ];
  @override
  DictionaryAssignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DictionaryAssignment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dictionaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dictionary_id'])!,
      childId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}child_id'])!,
      assignedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}assigned_at'])!,
    );
  }

  @override
  $DictionaryAssignmentsTable createAlias(String alias) {
    return $DictionaryAssignmentsTable(attachedDatabase, alias);
  }
}

class DictionaryAssignment extends DataClass
    implements Insertable<DictionaryAssignment> {
  final int id;

  /// Dictionnaire assigné (propriété du praticien).
  final int dictionaryId;

  /// Enfant bénéficiaire de l'assignation.
  final int childId;

  /// Date d'assignation.
  final DateTime assignedAt;
  const DictionaryAssignment(
      {required this.id,
      required this.dictionaryId,
      required this.childId,
      required this.assignedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dictionary_id'] = Variable<int>(dictionaryId);
    map['child_id'] = Variable<int>(childId);
    map['assigned_at'] = Variable<DateTime>(assignedAt);
    return map;
  }

  DictionaryAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return DictionaryAssignmentsCompanion(
      id: Value(id),
      dictionaryId: Value(dictionaryId),
      childId: Value(childId),
      assignedAt: Value(assignedAt),
    );
  }

  factory DictionaryAssignment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DictionaryAssignment(
      id: serializer.fromJson<int>(json['id']),
      dictionaryId: serializer.fromJson<int>(json['dictionaryId']),
      childId: serializer.fromJson<int>(json['childId']),
      assignedAt: serializer.fromJson<DateTime>(json['assignedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dictionaryId': serializer.toJson<int>(dictionaryId),
      'childId': serializer.toJson<int>(childId),
      'assignedAt': serializer.toJson<DateTime>(assignedAt),
    };
  }

  DictionaryAssignment copyWith(
          {int? id, int? dictionaryId, int? childId, DateTime? assignedAt}) =>
      DictionaryAssignment(
        id: id ?? this.id,
        dictionaryId: dictionaryId ?? this.dictionaryId,
        childId: childId ?? this.childId,
        assignedAt: assignedAt ?? this.assignedAt,
      );
  DictionaryAssignment copyWithCompanion(DictionaryAssignmentsCompanion data) {
    return DictionaryAssignment(
      id: data.id.present ? data.id.value : this.id,
      dictionaryId: data.dictionaryId.present
          ? data.dictionaryId.value
          : this.dictionaryId,
      childId: data.childId.present ? data.childId.value : this.childId,
      assignedAt:
          data.assignedAt.present ? data.assignedAt.value : this.assignedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryAssignment(')
          ..write('id: $id, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('childId: $childId, ')
          ..write('assignedAt: $assignedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dictionaryId, childId, assignedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DictionaryAssignment &&
          other.id == this.id &&
          other.dictionaryId == this.dictionaryId &&
          other.childId == this.childId &&
          other.assignedAt == this.assignedAt);
}

class DictionaryAssignmentsCompanion
    extends UpdateCompanion<DictionaryAssignment> {
  final Value<int> id;
  final Value<int> dictionaryId;
  final Value<int> childId;
  final Value<DateTime> assignedAt;
  const DictionaryAssignmentsCompanion({
    this.id = const Value.absent(),
    this.dictionaryId = const Value.absent(),
    this.childId = const Value.absent(),
    this.assignedAt = const Value.absent(),
  });
  DictionaryAssignmentsCompanion.insert({
    this.id = const Value.absent(),
    required int dictionaryId,
    required int childId,
    this.assignedAt = const Value.absent(),
  })  : dictionaryId = Value(dictionaryId),
        childId = Value(childId);
  static Insertable<DictionaryAssignment> custom({
    Expression<int>? id,
    Expression<int>? dictionaryId,
    Expression<int>? childId,
    Expression<DateTime>? assignedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dictionaryId != null) 'dictionary_id': dictionaryId,
      if (childId != null) 'child_id': childId,
      if (assignedAt != null) 'assigned_at': assignedAt,
    });
  }

  DictionaryAssignmentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? dictionaryId,
      Value<int>? childId,
      Value<DateTime>? assignedAt}) {
    return DictionaryAssignmentsCompanion(
      id: id ?? this.id,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      childId: childId ?? this.childId,
      assignedAt: assignedAt ?? this.assignedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dictionaryId.present) {
      map['dictionary_id'] = Variable<int>(dictionaryId.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (assignedAt.present) {
      map['assigned_at'] = Variable<DateTime>(assignedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryAssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('childId: $childId, ')
          ..write('assignedAt: $assignedAt')
          ..write(')'))
        .toString();
  }
}

class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dictionaryIdMeta =
      const VerificationMeta('dictionaryId');
  @override
  late final GeneratedColumn<int> dictionaryId = GeneratedColumn<int>(
      'dictionary_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES dictionaries (id)'));
  static const VerificationMeta _motMeta = const VerificationMeta('mot');
  @override
  late final GeneratedColumn<String> mot = GeneratedColumn<String>(
      'mot', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _definitionMeta =
      const VerificationMeta('definition');
  @override
  late final GeneratedColumn<String> definition = GeneratedColumn<String>(
      'definition', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _defCroisesMeta =
      const VerificationMeta('defCroises');
  @override
  late final GeneratedColumn<String> defCroises = GeneratedColumn<String>(
      'def_croises', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _defFlechesMeta =
      const VerificationMeta('defFleches');
  @override
  late final GeneratedColumn<String> defFleches = GeneratedColumn<String>(
      'def_fleches', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _audioPathMeta =
      const VerificationMeta('audioPath');
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
      'audio_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dictionaryId,
        mot,
        definition,
        defCroises,
        defFleches,
        imagePath,
        audioPath,
        tags,
        difficulty,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(Insertable<Word> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dictionary_id')) {
      context.handle(
          _dictionaryIdMeta,
          dictionaryId.isAcceptableOrUnknown(
              data['dictionary_id']!, _dictionaryIdMeta));
    } else if (isInserting) {
      context.missing(_dictionaryIdMeta);
    }
    if (data.containsKey('mot')) {
      context.handle(
          _motMeta, mot.isAcceptableOrUnknown(data['mot']!, _motMeta));
    } else if (isInserting) {
      context.missing(_motMeta);
    }
    if (data.containsKey('definition')) {
      context.handle(
          _definitionMeta,
          definition.isAcceptableOrUnknown(
              data['definition']!, _definitionMeta));
    }
    if (data.containsKey('def_croises')) {
      context.handle(
          _defCroisesMeta,
          defCroises.isAcceptableOrUnknown(
              data['def_croises']!, _defCroisesMeta));
    }
    if (data.containsKey('def_fleches')) {
      context.handle(
          _defFlechesMeta,
          defFleches.isAcceptableOrUnknown(
              data['def_fleches']!, _defFlechesMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('audio_path')) {
      context.handle(_audioPathMeta,
          audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dictionaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dictionary_id'])!,
      mot: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mot'])!,
      definition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}definition']),
      defCroises: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}def_croises']),
      defFleches: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}def_fleches']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      audioPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_path']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}difficulty'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class Word extends DataClass implements Insertable<Word> {
  final int id;

  /// Dictionnaire auquel appartient ce mot.
  final int dictionaryId;

  /// Le mot orthographié (clé de référence vers lexique4.db).
  final String mot;

  /// Définition courante (saisie manuelle ou issue de definitions.db).
  final String? definition;

  /// Définition en mots-croisés (courte, issue de definitions.db si disponible).
  final String? defCroises;

  /// Définition en mots-fléchés (issue de definitions.db si disponible).
  final String? defFleches;

  /// Chemin local de l'image associée (sélectionnée depuis la galerie).
  final String? imagePath;

  /// Chemin local de l'audio enregistré pour ce mot.
  final String? audioPath;

  /// Tags en JSON (ex : ["animal","maison"]). Utilisé pour filtrer en jeu.
  final String tags;

  /// Niveau de difficulté manuel : 1 (facile) → 3 (difficile).
  final int difficulty;

  /// Date d'ajout au dictionnaire.
  final DateTime createdAt;
  const Word(
      {required this.id,
      required this.dictionaryId,
      required this.mot,
      this.definition,
      this.defCroises,
      this.defFleches,
      this.imagePath,
      this.audioPath,
      required this.tags,
      required this.difficulty,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dictionary_id'] = Variable<int>(dictionaryId);
    map['mot'] = Variable<String>(mot);
    if (!nullToAbsent || definition != null) {
      map['definition'] = Variable<String>(definition);
    }
    if (!nullToAbsent || defCroises != null) {
      map['def_croises'] = Variable<String>(defCroises);
    }
    if (!nullToAbsent || defFleches != null) {
      map['def_fleches'] = Variable<String>(defFleches);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    map['tags'] = Variable<String>(tags);
    map['difficulty'] = Variable<int>(difficulty);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      dictionaryId: Value(dictionaryId),
      mot: Value(mot),
      definition: definition == null && nullToAbsent
          ? const Value.absent()
          : Value(definition),
      defCroises: defCroises == null && nullToAbsent
          ? const Value.absent()
          : Value(defCroises),
      defFleches: defFleches == null && nullToAbsent
          ? const Value.absent()
          : Value(defFleches),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      tags: Value(tags),
      difficulty: Value(difficulty),
      createdAt: Value(createdAt),
    );
  }

  factory Word.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      id: serializer.fromJson<int>(json['id']),
      dictionaryId: serializer.fromJson<int>(json['dictionaryId']),
      mot: serializer.fromJson<String>(json['mot']),
      definition: serializer.fromJson<String?>(json['definition']),
      defCroises: serializer.fromJson<String?>(json['defCroises']),
      defFleches: serializer.fromJson<String?>(json['defFleches']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      tags: serializer.fromJson<String>(json['tags']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dictionaryId': serializer.toJson<int>(dictionaryId),
      'mot': serializer.toJson<String>(mot),
      'definition': serializer.toJson<String?>(definition),
      'defCroises': serializer.toJson<String?>(defCroises),
      'defFleches': serializer.toJson<String?>(defFleches),
      'imagePath': serializer.toJson<String?>(imagePath),
      'audioPath': serializer.toJson<String?>(audioPath),
      'tags': serializer.toJson<String>(tags),
      'difficulty': serializer.toJson<int>(difficulty),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Word copyWith(
          {int? id,
          int? dictionaryId,
          String? mot,
          Value<String?> definition = const Value.absent(),
          Value<String?> defCroises = const Value.absent(),
          Value<String?> defFleches = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          Value<String?> audioPath = const Value.absent(),
          String? tags,
          int? difficulty,
          DateTime? createdAt}) =>
      Word(
        id: id ?? this.id,
        dictionaryId: dictionaryId ?? this.dictionaryId,
        mot: mot ?? this.mot,
        definition: definition.present ? definition.value : this.definition,
        defCroises: defCroises.present ? defCroises.value : this.defCroises,
        defFleches: defFleches.present ? defFleches.value : this.defFleches,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        audioPath: audioPath.present ? audioPath.value : this.audioPath,
        tags: tags ?? this.tags,
        difficulty: difficulty ?? this.difficulty,
        createdAt: createdAt ?? this.createdAt,
      );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      dictionaryId: data.dictionaryId.present
          ? data.dictionaryId.value
          : this.dictionaryId,
      mot: data.mot.present ? data.mot.value : this.mot,
      definition:
          data.definition.present ? data.definition.value : this.definition,
      defCroises:
          data.defCroises.present ? data.defCroises.value : this.defCroises,
      defFleches:
          data.defFleches.present ? data.defFleches.value : this.defFleches,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      tags: data.tags.present ? data.tags.value : this.tags,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('mot: $mot, ')
          ..write('definition: $definition, ')
          ..write('defCroises: $defCroises, ')
          ..write('defFleches: $defFleches, ')
          ..write('imagePath: $imagePath, ')
          ..write('audioPath: $audioPath, ')
          ..write('tags: $tags, ')
          ..write('difficulty: $difficulty, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dictionaryId, mot, definition, defCroises,
      defFleches, imagePath, audioPath, tags, difficulty, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.dictionaryId == this.dictionaryId &&
          other.mot == this.mot &&
          other.definition == this.definition &&
          other.defCroises == this.defCroises &&
          other.defFleches == this.defFleches &&
          other.imagePath == this.imagePath &&
          other.audioPath == this.audioPath &&
          other.tags == this.tags &&
          other.difficulty == this.difficulty &&
          other.createdAt == this.createdAt);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> id;
  final Value<int> dictionaryId;
  final Value<String> mot;
  final Value<String?> definition;
  final Value<String?> defCroises;
  final Value<String?> defFleches;
  final Value<String?> imagePath;
  final Value<String?> audioPath;
  final Value<String> tags;
  final Value<int> difficulty;
  final Value<DateTime> createdAt;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.dictionaryId = const Value.absent(),
    this.mot = const Value.absent(),
    this.definition = const Value.absent(),
    this.defCroises = const Value.absent(),
    this.defFleches = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.tags = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required int dictionaryId,
    required String mot,
    this.definition = const Value.absent(),
    this.defCroises = const Value.absent(),
    this.defFleches = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.tags = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : dictionaryId = Value(dictionaryId),
        mot = Value(mot);
  static Insertable<Word> custom({
    Expression<int>? id,
    Expression<int>? dictionaryId,
    Expression<String>? mot,
    Expression<String>? definition,
    Expression<String>? defCroises,
    Expression<String>? defFleches,
    Expression<String>? imagePath,
    Expression<String>? audioPath,
    Expression<String>? tags,
    Expression<int>? difficulty,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dictionaryId != null) 'dictionary_id': dictionaryId,
      if (mot != null) 'mot': mot,
      if (definition != null) 'definition': definition,
      if (defCroises != null) 'def_croises': defCroises,
      if (defFleches != null) 'def_fleches': defFleches,
      if (imagePath != null) 'image_path': imagePath,
      if (audioPath != null) 'audio_path': audioPath,
      if (tags != null) 'tags': tags,
      if (difficulty != null) 'difficulty': difficulty,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WordsCompanion copyWith(
      {Value<int>? id,
      Value<int>? dictionaryId,
      Value<String>? mot,
      Value<String?>? definition,
      Value<String?>? defCroises,
      Value<String?>? defFleches,
      Value<String?>? imagePath,
      Value<String?>? audioPath,
      Value<String>? tags,
      Value<int>? difficulty,
      Value<DateTime>? createdAt}) {
    return WordsCompanion(
      id: id ?? this.id,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      mot: mot ?? this.mot,
      definition: definition ?? this.definition,
      defCroises: defCroises ?? this.defCroises,
      defFleches: defFleches ?? this.defFleches,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dictionaryId.present) {
      map['dictionary_id'] = Variable<int>(dictionaryId.value);
    }
    if (mot.present) {
      map['mot'] = Variable<String>(mot.value);
    }
    if (definition.present) {
      map['definition'] = Variable<String>(definition.value);
    }
    if (defCroises.present) {
      map['def_croises'] = Variable<String>(defCroises.value);
    }
    if (defFleches.present) {
      map['def_fleches'] = Variable<String>(defFleches.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('mot: $mot, ')
          ..write('definition: $definition, ')
          ..write('defCroises: $defCroises, ')
          ..write('defFleches: $defFleches, ')
          ..write('imagePath: $imagePath, ')
          ..write('audioPath: $audioPath, ')
          ..write('tags: $tags, ')
          ..write('difficulty: $difficulty, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WordMasteryTable extends WordMastery
    with TableInfo<$WordMasteryTable, WordMasteryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordMasteryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES words (id)'));
  static const VerificationMeta _nbSeenMeta = const VerificationMeta('nbSeen');
  @override
  late final GeneratedColumn<int> nbSeen = GeneratedColumn<int>(
      'nb_seen', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nbSuccessMeta =
      const VerificationMeta('nbSuccess');
  @override
  late final GeneratedColumn<int> nbSuccess = GeneratedColumn<int>(
      'nb_success', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nbFirstTryMeta =
      const VerificationMeta('nbFirstTry');
  @override
  late final GeneratedColumn<int> nbFirstTry = GeneratedColumn<int>(
      'nb_first_try', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _consecutiveOkMeta =
      const VerificationMeta('consecutiveOk');
  @override
  late final GeneratedColumn<int> consecutiveOk = GeneratedColumn<int>(
      'consecutive_ok', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _leitnerBoxMeta =
      const VerificationMeta('leitnerBox');
  @override
  late final GeneratedColumn<int> leitnerBox = GeneratedColumn<int>(
      'leitner_box', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _nextReviewMeta =
      const VerificationMeta('nextReview');
  @override
  late final GeneratedColumn<DateTime> nextReview = GeneratedColumn<DateTime>(
      'next_review', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSeenMeta =
      const VerificationMeta('lastSeen');
  @override
  late final GeneratedColumn<DateTime> lastSeen = GeneratedColumn<DateTime>(
      'last_seen', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _masteryLevelMeta =
      const VerificationMeta('masteryLevel');
  @override
  late final GeneratedColumn<int> masteryLevel = GeneratedColumn<int>(
      'mastery_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        wordId,
        nbSeen,
        nbSuccess,
        nbFirstTry,
        consecutiveOk,
        leitnerBox,
        nextReview,
        lastSeen,
        masteryLevel
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_mastery';
  @override
  VerificationContext validateIntegrity(Insertable<WordMasteryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('nb_seen')) {
      context.handle(_nbSeenMeta,
          nbSeen.isAcceptableOrUnknown(data['nb_seen']!, _nbSeenMeta));
    }
    if (data.containsKey('nb_success')) {
      context.handle(_nbSuccessMeta,
          nbSuccess.isAcceptableOrUnknown(data['nb_success']!, _nbSuccessMeta));
    }
    if (data.containsKey('nb_first_try')) {
      context.handle(
          _nbFirstTryMeta,
          nbFirstTry.isAcceptableOrUnknown(
              data['nb_first_try']!, _nbFirstTryMeta));
    }
    if (data.containsKey('consecutive_ok')) {
      context.handle(
          _consecutiveOkMeta,
          consecutiveOk.isAcceptableOrUnknown(
              data['consecutive_ok']!, _consecutiveOkMeta));
    }
    if (data.containsKey('leitner_box')) {
      context.handle(
          _leitnerBoxMeta,
          leitnerBox.isAcceptableOrUnknown(
              data['leitner_box']!, _leitnerBoxMeta));
    }
    if (data.containsKey('next_review')) {
      context.handle(
          _nextReviewMeta,
          nextReview.isAcceptableOrUnknown(
              data['next_review']!, _nextReviewMeta));
    }
    if (data.containsKey('last_seen')) {
      context.handle(_lastSeenMeta,
          lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta));
    }
    if (data.containsKey('mastery_level')) {
      context.handle(
          _masteryLevelMeta,
          masteryLevel.isAcceptableOrUnknown(
              data['mastery_level']!, _masteryLevelMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {profileId, wordId},
      ];
  @override
  WordMasteryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordMasteryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_id'])!,
      nbSeen: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nb_seen'])!,
      nbSuccess: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nb_success'])!,
      nbFirstTry: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nb_first_try'])!,
      consecutiveOk: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}consecutive_ok'])!,
      leitnerBox: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}leitner_box'])!,
      nextReview: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_review']),
      lastSeen: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_seen']),
      masteryLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mastery_level'])!,
    );
  }

  @override
  $WordMasteryTable createAlias(String alias) {
    return $WordMasteryTable(attachedDatabase, alias);
  }
}

class WordMasteryData extends DataClass implements Insertable<WordMasteryData> {
  final int id;

  /// Profil concerné.
  final int profileId;

  /// Mot concerné.
  final int wordId;

  /// Nombre total de présentations du mot.
  final int nbSeen;

  /// Nombre de réussites totales.
  final int nbSuccess;

  /// Nombre de réussites du premier coup (sans aide).
  final int nbFirstTry;

  /// Réussites consécutives en cours.
  final int consecutiveOk;

  /// Boîte Leitner actuelle (1 = nouveau, 5 = maîtrisé).
  final int leitnerBox;

  /// Prochaine date de révision calculée par le SRS.
  final DateTime? nextReview;

  /// Dernière date de présentation.
  final DateTime? lastSeen;

  /// Niveau de maîtrise calculé : 0 (non vu) → 4 (maîtrisé).
  final int masteryLevel;
  const WordMasteryData(
      {required this.id,
      required this.profileId,
      required this.wordId,
      required this.nbSeen,
      required this.nbSuccess,
      required this.nbFirstTry,
      required this.consecutiveOk,
      required this.leitnerBox,
      this.nextReview,
      this.lastSeen,
      required this.masteryLevel});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['word_id'] = Variable<int>(wordId);
    map['nb_seen'] = Variable<int>(nbSeen);
    map['nb_success'] = Variable<int>(nbSuccess);
    map['nb_first_try'] = Variable<int>(nbFirstTry);
    map['consecutive_ok'] = Variable<int>(consecutiveOk);
    map['leitner_box'] = Variable<int>(leitnerBox);
    if (!nullToAbsent || nextReview != null) {
      map['next_review'] = Variable<DateTime>(nextReview);
    }
    if (!nullToAbsent || lastSeen != null) {
      map['last_seen'] = Variable<DateTime>(lastSeen);
    }
    map['mastery_level'] = Variable<int>(masteryLevel);
    return map;
  }

  WordMasteryCompanion toCompanion(bool nullToAbsent) {
    return WordMasteryCompanion(
      id: Value(id),
      profileId: Value(profileId),
      wordId: Value(wordId),
      nbSeen: Value(nbSeen),
      nbSuccess: Value(nbSuccess),
      nbFirstTry: Value(nbFirstTry),
      consecutiveOk: Value(consecutiveOk),
      leitnerBox: Value(leitnerBox),
      nextReview: nextReview == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReview),
      lastSeen: lastSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeen),
      masteryLevel: Value(masteryLevel),
    );
  }

  factory WordMasteryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordMasteryData(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      wordId: serializer.fromJson<int>(json['wordId']),
      nbSeen: serializer.fromJson<int>(json['nbSeen']),
      nbSuccess: serializer.fromJson<int>(json['nbSuccess']),
      nbFirstTry: serializer.fromJson<int>(json['nbFirstTry']),
      consecutiveOk: serializer.fromJson<int>(json['consecutiveOk']),
      leitnerBox: serializer.fromJson<int>(json['leitnerBox']),
      nextReview: serializer.fromJson<DateTime?>(json['nextReview']),
      lastSeen: serializer.fromJson<DateTime?>(json['lastSeen']),
      masteryLevel: serializer.fromJson<int>(json['masteryLevel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'wordId': serializer.toJson<int>(wordId),
      'nbSeen': serializer.toJson<int>(nbSeen),
      'nbSuccess': serializer.toJson<int>(nbSuccess),
      'nbFirstTry': serializer.toJson<int>(nbFirstTry),
      'consecutiveOk': serializer.toJson<int>(consecutiveOk),
      'leitnerBox': serializer.toJson<int>(leitnerBox),
      'nextReview': serializer.toJson<DateTime?>(nextReview),
      'lastSeen': serializer.toJson<DateTime?>(lastSeen),
      'masteryLevel': serializer.toJson<int>(masteryLevel),
    };
  }

  WordMasteryData copyWith(
          {int? id,
          int? profileId,
          int? wordId,
          int? nbSeen,
          int? nbSuccess,
          int? nbFirstTry,
          int? consecutiveOk,
          int? leitnerBox,
          Value<DateTime?> nextReview = const Value.absent(),
          Value<DateTime?> lastSeen = const Value.absent(),
          int? masteryLevel}) =>
      WordMasteryData(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        wordId: wordId ?? this.wordId,
        nbSeen: nbSeen ?? this.nbSeen,
        nbSuccess: nbSuccess ?? this.nbSuccess,
        nbFirstTry: nbFirstTry ?? this.nbFirstTry,
        consecutiveOk: consecutiveOk ?? this.consecutiveOk,
        leitnerBox: leitnerBox ?? this.leitnerBox,
        nextReview: nextReview.present ? nextReview.value : this.nextReview,
        lastSeen: lastSeen.present ? lastSeen.value : this.lastSeen,
        masteryLevel: masteryLevel ?? this.masteryLevel,
      );
  WordMasteryData copyWithCompanion(WordMasteryCompanion data) {
    return WordMasteryData(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      nbSeen: data.nbSeen.present ? data.nbSeen.value : this.nbSeen,
      nbSuccess: data.nbSuccess.present ? data.nbSuccess.value : this.nbSuccess,
      nbFirstTry:
          data.nbFirstTry.present ? data.nbFirstTry.value : this.nbFirstTry,
      consecutiveOk: data.consecutiveOk.present
          ? data.consecutiveOk.value
          : this.consecutiveOk,
      leitnerBox:
          data.leitnerBox.present ? data.leitnerBox.value : this.leitnerBox,
      nextReview:
          data.nextReview.present ? data.nextReview.value : this.nextReview,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      masteryLevel: data.masteryLevel.present
          ? data.masteryLevel.value
          : this.masteryLevel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordMasteryData(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('wordId: $wordId, ')
          ..write('nbSeen: $nbSeen, ')
          ..write('nbSuccess: $nbSuccess, ')
          ..write('nbFirstTry: $nbFirstTry, ')
          ..write('consecutiveOk: $consecutiveOk, ')
          ..write('leitnerBox: $leitnerBox, ')
          ..write('nextReview: $nextReview, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('masteryLevel: $masteryLevel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      profileId,
      wordId,
      nbSeen,
      nbSuccess,
      nbFirstTry,
      consecutiveOk,
      leitnerBox,
      nextReview,
      lastSeen,
      masteryLevel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordMasteryData &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.wordId == this.wordId &&
          other.nbSeen == this.nbSeen &&
          other.nbSuccess == this.nbSuccess &&
          other.nbFirstTry == this.nbFirstTry &&
          other.consecutiveOk == this.consecutiveOk &&
          other.leitnerBox == this.leitnerBox &&
          other.nextReview == this.nextReview &&
          other.lastSeen == this.lastSeen &&
          other.masteryLevel == this.masteryLevel);
}

class WordMasteryCompanion extends UpdateCompanion<WordMasteryData> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<int> wordId;
  final Value<int> nbSeen;
  final Value<int> nbSuccess;
  final Value<int> nbFirstTry;
  final Value<int> consecutiveOk;
  final Value<int> leitnerBox;
  final Value<DateTime?> nextReview;
  final Value<DateTime?> lastSeen;
  final Value<int> masteryLevel;
  const WordMasteryCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.nbSeen = const Value.absent(),
    this.nbSuccess = const Value.absent(),
    this.nbFirstTry = const Value.absent(),
    this.consecutiveOk = const Value.absent(),
    this.leitnerBox = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.masteryLevel = const Value.absent(),
  });
  WordMasteryCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required int wordId,
    this.nbSeen = const Value.absent(),
    this.nbSuccess = const Value.absent(),
    this.nbFirstTry = const Value.absent(),
    this.consecutiveOk = const Value.absent(),
    this.leitnerBox = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.masteryLevel = const Value.absent(),
  })  : profileId = Value(profileId),
        wordId = Value(wordId);
  static Insertable<WordMasteryData> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<int>? wordId,
    Expression<int>? nbSeen,
    Expression<int>? nbSuccess,
    Expression<int>? nbFirstTry,
    Expression<int>? consecutiveOk,
    Expression<int>? leitnerBox,
    Expression<DateTime>? nextReview,
    Expression<DateTime>? lastSeen,
    Expression<int>? masteryLevel,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (wordId != null) 'word_id': wordId,
      if (nbSeen != null) 'nb_seen': nbSeen,
      if (nbSuccess != null) 'nb_success': nbSuccess,
      if (nbFirstTry != null) 'nb_first_try': nbFirstTry,
      if (consecutiveOk != null) 'consecutive_ok': consecutiveOk,
      if (leitnerBox != null) 'leitner_box': leitnerBox,
      if (nextReview != null) 'next_review': nextReview,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (masteryLevel != null) 'mastery_level': masteryLevel,
    });
  }

  WordMasteryCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<int>? wordId,
      Value<int>? nbSeen,
      Value<int>? nbSuccess,
      Value<int>? nbFirstTry,
      Value<int>? consecutiveOk,
      Value<int>? leitnerBox,
      Value<DateTime?>? nextReview,
      Value<DateTime?>? lastSeen,
      Value<int>? masteryLevel}) {
    return WordMasteryCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      wordId: wordId ?? this.wordId,
      nbSeen: nbSeen ?? this.nbSeen,
      nbSuccess: nbSuccess ?? this.nbSuccess,
      nbFirstTry: nbFirstTry ?? this.nbFirstTry,
      consecutiveOk: consecutiveOk ?? this.consecutiveOk,
      leitnerBox: leitnerBox ?? this.leitnerBox,
      nextReview: nextReview ?? this.nextReview,
      lastSeen: lastSeen ?? this.lastSeen,
      masteryLevel: masteryLevel ?? this.masteryLevel,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (nbSeen.present) {
      map['nb_seen'] = Variable<int>(nbSeen.value);
    }
    if (nbSuccess.present) {
      map['nb_success'] = Variable<int>(nbSuccess.value);
    }
    if (nbFirstTry.present) {
      map['nb_first_try'] = Variable<int>(nbFirstTry.value);
    }
    if (consecutiveOk.present) {
      map['consecutive_ok'] = Variable<int>(consecutiveOk.value);
    }
    if (leitnerBox.present) {
      map['leitner_box'] = Variable<int>(leitnerBox.value);
    }
    if (nextReview.present) {
      map['next_review'] = Variable<DateTime>(nextReview.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<DateTime>(lastSeen.value);
    }
    if (masteryLevel.present) {
      map['mastery_level'] = Variable<int>(masteryLevel.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordMasteryCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('wordId: $wordId, ')
          ..write('nbSeen: $nbSeen, ')
          ..write('nbSuccess: $nbSuccess, ')
          ..write('nbFirstTry: $nbFirstTry, ')
          ..write('consecutiveOk: $consecutiveOk, ')
          ..write('leitnerBox: $leitnerBox, ')
          ..write('nextReview: $nextReview, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('masteryLevel: $masteryLevel')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  static const VerificationMeta _dictionaryIdMeta =
      const VerificationMeta('dictionaryId');
  @override
  late final GeneratedColumn<int> dictionaryId = GeneratedColumn<int>(
      'dictionary_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES dictionaries (id)'));
  static const VerificationMeta _activityTypeMeta =
      const VerificationMeta('activityType');
  @override
  late final GeneratedColumn<String> activityType = GeneratedColumn<String>(
      'activity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
      'score', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, dictionaryId, activityType, startedAt, endedAt, score];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('dictionary_id')) {
      context.handle(
          _dictionaryIdMeta,
          dictionaryId.isAcceptableOrUnknown(
              data['dictionary_id']!, _dictionaryIdMeta));
    } else if (isInserting) {
      context.missing(_dictionaryIdMeta);
    }
    if (data.containsKey('activity_type')) {
      context.handle(
          _activityTypeMeta,
          activityType.isAcceptableOrUnknown(
              data['activity_type']!, _activityTypeMeta));
    } else if (isInserting) {
      context.missing(_activityTypeMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      dictionaryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dictionary_id'])!,
      activityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_type'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}score'])!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;

  /// Profil qui a joué la session.
  final int profileId;

  /// Dictionnaire utilisé pendant la session.
  final int dictionaryId;

  /// Type d'activité : 'memoire' | 'puzzle' | 'reconnaissance' | 'dictee' | 'associations'.
  final String activityType;

  /// Horodatage de début de session.
  final DateTime startedAt;

  /// Horodatage de fin (null si session interrompue).
  final DateTime? endedAt;

  /// Score total de la session (0-100).
  final int score;
  const Session(
      {required this.id,
      required this.profileId,
      required this.dictionaryId,
      required this.activityType,
      required this.startedAt,
      this.endedAt,
      required this.score});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['dictionary_id'] = Variable<int>(dictionaryId);
    map['activity_type'] = Variable<String>(activityType);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['score'] = Variable<int>(score);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      dictionaryId: Value(dictionaryId),
      activityType: Value(activityType),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      score: Value(score),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      dictionaryId: serializer.fromJson<int>(json['dictionaryId']),
      activityType: serializer.fromJson<String>(json['activityType']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      score: serializer.fromJson<int>(json['score']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'dictionaryId': serializer.toJson<int>(dictionaryId),
      'activityType': serializer.toJson<String>(activityType),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'score': serializer.toJson<int>(score),
    };
  }

  Session copyWith(
          {int? id,
          int? profileId,
          int? dictionaryId,
          String? activityType,
          DateTime? startedAt,
          Value<DateTime?> endedAt = const Value.absent(),
          int? score}) =>
      Session(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        dictionaryId: dictionaryId ?? this.dictionaryId,
        activityType: activityType ?? this.activityType,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        score: score ?? this.score,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      dictionaryId: data.dictionaryId.present
          ? data.dictionaryId.value
          : this.dictionaryId,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      score: data.score.present ? data.score.value : this.score,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('activityType: $activityType, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, profileId, dictionaryId, activityType, startedAt, endedAt, score);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.dictionaryId == this.dictionaryId &&
          other.activityType == this.activityType &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.score == this.score);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<int> dictionaryId;
  final Value<String> activityType;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> score;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.dictionaryId = const Value.absent(),
    this.activityType = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.score = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required int dictionaryId,
    required String activityType,
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.score = const Value.absent(),
  })  : profileId = Value(profileId),
        dictionaryId = Value(dictionaryId),
        activityType = Value(activityType);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<int>? dictionaryId,
    Expression<String>? activityType,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? score,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (dictionaryId != null) 'dictionary_id': dictionaryId,
      if (activityType != null) 'activity_type': activityType,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (score != null) 'score': score,
    });
  }

  SessionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<int>? dictionaryId,
      Value<String>? activityType,
      Value<DateTime>? startedAt,
      Value<DateTime?>? endedAt,
      Value<int>? score}) {
    return SessionsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      activityType: activityType ?? this.activityType,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      score: score ?? this.score,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (dictionaryId.present) {
      map['dictionary_id'] = Variable<int>(dictionaryId.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(activityType.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('dictionaryId: $dictionaryId, ')
          ..write('activityType: $activityType, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }
}

class $WordAttemptsTable extends WordAttempts
    with TableInfo<$WordAttemptsTable, WordAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sessions (id)'));
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
      'word_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES words (id)'));
  static const VerificationMeta _successMeta =
      const VerificationMeta('success');
  @override
  late final GeneratedColumn<bool> success = GeneratedColumn<bool>(
      'success', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("success" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _firstTryMeta =
      const VerificationMeta('firstTry');
  @override
  late final GeneratedColumn<bool> firstTry = GeneratedColumn<bool>(
      'first_try', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("first_try" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _hintUsedMeta =
      const VerificationMeta('hintUsed');
  @override
  late final GeneratedColumn<bool> hintUsed = GeneratedColumn<bool>(
      'hint_used', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("hint_used" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _errorLettersMeta =
      const VerificationMeta('errorLetters');
  @override
  late final GeneratedColumn<String> errorLetters = GeneratedColumn<String>(
      'error_letters', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sessionId,
        wordId,
        success,
        firstTry,
        hintUsed,
        durationMs,
        errorLetters
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_attempts';
  @override
  VerificationContext validateIntegrity(Insertable<WordAttempt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('success')) {
      context.handle(_successMeta,
          success.isAcceptableOrUnknown(data['success']!, _successMeta));
    }
    if (data.containsKey('first_try')) {
      context.handle(_firstTryMeta,
          firstTry.isAcceptableOrUnknown(data['first_try']!, _firstTryMeta));
    }
    if (data.containsKey('hint_used')) {
      context.handle(_hintUsedMeta,
          hintUsed.isAcceptableOrUnknown(data['hint_used']!, _hintUsedMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('error_letters')) {
      context.handle(
          _errorLettersMeta,
          errorLetters.isAcceptableOrUnknown(
              data['error_letters']!, _errorLettersMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordAttempt(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_id'])!,
      success: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}success'])!,
      firstTry: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}first_try'])!,
      hintUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}hint_used'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      errorLetters: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_letters'])!,
    );
  }

  @override
  $WordAttemptsTable createAlias(String alias) {
    return $WordAttemptsTable(attachedDatabase, alias);
  }
}

class WordAttempt extends DataClass implements Insertable<WordAttempt> {
  final int id;

  /// Session parente.
  final int sessionId;

  /// Mot tenté.
  final int wordId;

  /// Résultat : vrai si réussi.
  final bool success;

  /// Réussite du premier coup (sans aide ni 2ème tentative).
  final bool firstTry;

  /// Indice utilisé pendant la tentative.
  final bool hintUsed;

  /// Durée de la tentative en millisecondes.
  final int durationMs;

  /// Lettres erronées en JSON (ex : ["a","e"]) pour analyse phonologique.
  final String errorLetters;
  const WordAttempt(
      {required this.id,
      required this.sessionId,
      required this.wordId,
      required this.success,
      required this.firstTry,
      required this.hintUsed,
      required this.durationMs,
      required this.errorLetters});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['word_id'] = Variable<int>(wordId);
    map['success'] = Variable<bool>(success);
    map['first_try'] = Variable<bool>(firstTry);
    map['hint_used'] = Variable<bool>(hintUsed);
    map['duration_ms'] = Variable<int>(durationMs);
    map['error_letters'] = Variable<String>(errorLetters);
    return map;
  }

  WordAttemptsCompanion toCompanion(bool nullToAbsent) {
    return WordAttemptsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      wordId: Value(wordId),
      success: Value(success),
      firstTry: Value(firstTry),
      hintUsed: Value(hintUsed),
      durationMs: Value(durationMs),
      errorLetters: Value(errorLetters),
    );
  }

  factory WordAttempt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordAttempt(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      wordId: serializer.fromJson<int>(json['wordId']),
      success: serializer.fromJson<bool>(json['success']),
      firstTry: serializer.fromJson<bool>(json['firstTry']),
      hintUsed: serializer.fromJson<bool>(json['hintUsed']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      errorLetters: serializer.fromJson<String>(json['errorLetters']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'wordId': serializer.toJson<int>(wordId),
      'success': serializer.toJson<bool>(success),
      'firstTry': serializer.toJson<bool>(firstTry),
      'hintUsed': serializer.toJson<bool>(hintUsed),
      'durationMs': serializer.toJson<int>(durationMs),
      'errorLetters': serializer.toJson<String>(errorLetters),
    };
  }

  WordAttempt copyWith(
          {int? id,
          int? sessionId,
          int? wordId,
          bool? success,
          bool? firstTry,
          bool? hintUsed,
          int? durationMs,
          String? errorLetters}) =>
      WordAttempt(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        wordId: wordId ?? this.wordId,
        success: success ?? this.success,
        firstTry: firstTry ?? this.firstTry,
        hintUsed: hintUsed ?? this.hintUsed,
        durationMs: durationMs ?? this.durationMs,
        errorLetters: errorLetters ?? this.errorLetters,
      );
  WordAttempt copyWithCompanion(WordAttemptsCompanion data) {
    return WordAttempt(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      success: data.success.present ? data.success.value : this.success,
      firstTry: data.firstTry.present ? data.firstTry.value : this.firstTry,
      hintUsed: data.hintUsed.present ? data.hintUsed.value : this.hintUsed,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      errorLetters: data.errorLetters.present
          ? data.errorLetters.value
          : this.errorLetters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordAttempt(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('wordId: $wordId, ')
          ..write('success: $success, ')
          ..write('firstTry: $firstTry, ')
          ..write('hintUsed: $hintUsed, ')
          ..write('durationMs: $durationMs, ')
          ..write('errorLetters: $errorLetters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessionId, wordId, success, firstTry,
      hintUsed, durationMs, errorLetters);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordAttempt &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.wordId == this.wordId &&
          other.success == this.success &&
          other.firstTry == this.firstTry &&
          other.hintUsed == this.hintUsed &&
          other.durationMs == this.durationMs &&
          other.errorLetters == this.errorLetters);
}

class WordAttemptsCompanion extends UpdateCompanion<WordAttempt> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> wordId;
  final Value<bool> success;
  final Value<bool> firstTry;
  final Value<bool> hintUsed;
  final Value<int> durationMs;
  final Value<String> errorLetters;
  const WordAttemptsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.success = const Value.absent(),
    this.firstTry = const Value.absent(),
    this.hintUsed = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.errorLetters = const Value.absent(),
  });
  WordAttemptsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int wordId,
    this.success = const Value.absent(),
    this.firstTry = const Value.absent(),
    this.hintUsed = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.errorLetters = const Value.absent(),
  })  : sessionId = Value(sessionId),
        wordId = Value(wordId);
  static Insertable<WordAttempt> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? wordId,
    Expression<bool>? success,
    Expression<bool>? firstTry,
    Expression<bool>? hintUsed,
    Expression<int>? durationMs,
    Expression<String>? errorLetters,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (wordId != null) 'word_id': wordId,
      if (success != null) 'success': success,
      if (firstTry != null) 'first_try': firstTry,
      if (hintUsed != null) 'hint_used': hintUsed,
      if (durationMs != null) 'duration_ms': durationMs,
      if (errorLetters != null) 'error_letters': errorLetters,
    });
  }

  WordAttemptsCompanion copyWith(
      {Value<int>? id,
      Value<int>? sessionId,
      Value<int>? wordId,
      Value<bool>? success,
      Value<bool>? firstTry,
      Value<bool>? hintUsed,
      Value<int>? durationMs,
      Value<String>? errorLetters}) {
    return WordAttemptsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      wordId: wordId ?? this.wordId,
      success: success ?? this.success,
      firstTry: firstTry ?? this.firstTry,
      hintUsed: hintUsed ?? this.hintUsed,
      durationMs: durationMs ?? this.durationMs,
      errorLetters: errorLetters ?? this.errorLetters,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (success.present) {
      map['success'] = Variable<bool>(success.value);
    }
    if (firstTry.present) {
      map['first_try'] = Variable<bool>(firstTry.value);
    }
    if (hintUsed.present) {
      map['hint_used'] = Variable<bool>(hintUsed.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (errorLetters.present) {
      map['error_letters'] = Variable<String>(errorLetters.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('wordId: $wordId, ')
          ..write('success: $success, ')
          ..write('firstTry: $firstTry, ')
          ..write('hintUsed: $hintUsed, ')
          ..write('durationMs: $durationMs, ')
          ..write('errorLetters: $errorLetters')
          ..write(')'))
        .toString();
  }
}

class $DailyStatsTable extends DailyStats
    with TableInfo<$DailyStatsTable, DailyStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profiles (id)'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _wordsSeenMeta =
      const VerificationMeta('wordsSeen');
  @override
  late final GeneratedColumn<int> wordsSeen = GeneratedColumn<int>(
      'words_seen', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _wordsSuccessMeta =
      const VerificationMeta('wordsSuccess');
  @override
  late final GeneratedColumn<int> wordsSuccess = GeneratedColumn<int>(
      'words_success', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _minutesPlayedMeta =
      const VerificationMeta('minutesPlayed');
  @override
  late final GeneratedColumn<int> minutesPlayed = GeneratedColumn<int>(
      'minutes_played', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileId, date, wordsSeen, wordsSuccess, minutesPlayed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_stats';
  @override
  VerificationContext validateIntegrity(Insertable<DailyStat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('words_seen')) {
      context.handle(_wordsSeenMeta,
          wordsSeen.isAcceptableOrUnknown(data['words_seen']!, _wordsSeenMeta));
    }
    if (data.containsKey('words_success')) {
      context.handle(
          _wordsSuccessMeta,
          wordsSuccess.isAcceptableOrUnknown(
              data['words_success']!, _wordsSuccessMeta));
    }
    if (data.containsKey('minutes_played')) {
      context.handle(
          _minutesPlayedMeta,
          minutesPlayed.isAcceptableOrUnknown(
              data['minutes_played']!, _minutesPlayedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {profileId, date},
      ];
  @override
  DailyStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyStat(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      wordsSeen: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}words_seen'])!,
      wordsSuccess: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}words_success'])!,
      minutesPlayed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}minutes_played'])!,
    );
  }

  @override
  $DailyStatsTable createAlias(String alias) {
    return $DailyStatsTable(attachedDatabase, alias);
  }
}

class DailyStat extends DataClass implements Insertable<DailyStat> {
  final int id;

  /// Profil concerné.
  final int profileId;

  /// Date du jour (stockée comme DateTime à minuit UTC).
  final DateTime date;

  /// Nombre de mots présentés dans la journée.
  final int wordsSeen;

  /// Nombre de mots réussis dans la journée.
  final int wordsSuccess;

  /// Temps de jeu total en minutes dans la journée.
  final int minutesPlayed;
  const DailyStat(
      {required this.id,
      required this.profileId,
      required this.date,
      required this.wordsSeen,
      required this.wordsSuccess,
      required this.minutesPlayed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['date'] = Variable<DateTime>(date);
    map['words_seen'] = Variable<int>(wordsSeen);
    map['words_success'] = Variable<int>(wordsSuccess);
    map['minutes_played'] = Variable<int>(minutesPlayed);
    return map;
  }

  DailyStatsCompanion toCompanion(bool nullToAbsent) {
    return DailyStatsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      date: Value(date),
      wordsSeen: Value(wordsSeen),
      wordsSuccess: Value(wordsSuccess),
      minutesPlayed: Value(minutesPlayed),
    );
  }

  factory DailyStat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyStat(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      date: serializer.fromJson<DateTime>(json['date']),
      wordsSeen: serializer.fromJson<int>(json['wordsSeen']),
      wordsSuccess: serializer.fromJson<int>(json['wordsSuccess']),
      minutesPlayed: serializer.fromJson<int>(json['minutesPlayed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'date': serializer.toJson<DateTime>(date),
      'wordsSeen': serializer.toJson<int>(wordsSeen),
      'wordsSuccess': serializer.toJson<int>(wordsSuccess),
      'minutesPlayed': serializer.toJson<int>(minutesPlayed),
    };
  }

  DailyStat copyWith(
          {int? id,
          int? profileId,
          DateTime? date,
          int? wordsSeen,
          int? wordsSuccess,
          int? minutesPlayed}) =>
      DailyStat(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        date: date ?? this.date,
        wordsSeen: wordsSeen ?? this.wordsSeen,
        wordsSuccess: wordsSuccess ?? this.wordsSuccess,
        minutesPlayed: minutesPlayed ?? this.minutesPlayed,
      );
  DailyStat copyWithCompanion(DailyStatsCompanion data) {
    return DailyStat(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      date: data.date.present ? data.date.value : this.date,
      wordsSeen: data.wordsSeen.present ? data.wordsSeen.value : this.wordsSeen,
      wordsSuccess: data.wordsSuccess.present
          ? data.wordsSuccess.value
          : this.wordsSuccess,
      minutesPlayed: data.minutesPlayed.present
          ? data.minutesPlayed.value
          : this.minutesPlayed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyStat(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('date: $date, ')
          ..write('wordsSeen: $wordsSeen, ')
          ..write('wordsSuccess: $wordsSuccess, ')
          ..write('minutesPlayed: $minutesPlayed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, profileId, date, wordsSeen, wordsSuccess, minutesPlayed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyStat &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.date == this.date &&
          other.wordsSeen == this.wordsSeen &&
          other.wordsSuccess == this.wordsSuccess &&
          other.minutesPlayed == this.minutesPlayed);
}

class DailyStatsCompanion extends UpdateCompanion<DailyStat> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<DateTime> date;
  final Value<int> wordsSeen;
  final Value<int> wordsSuccess;
  final Value<int> minutesPlayed;
  const DailyStatsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.date = const Value.absent(),
    this.wordsSeen = const Value.absent(),
    this.wordsSuccess = const Value.absent(),
    this.minutesPlayed = const Value.absent(),
  });
  DailyStatsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    required DateTime date,
    this.wordsSeen = const Value.absent(),
    this.wordsSuccess = const Value.absent(),
    this.minutesPlayed = const Value.absent(),
  })  : profileId = Value(profileId),
        date = Value(date);
  static Insertable<DailyStat> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<DateTime>? date,
    Expression<int>? wordsSeen,
    Expression<int>? wordsSuccess,
    Expression<int>? minutesPlayed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (date != null) 'date': date,
      if (wordsSeen != null) 'words_seen': wordsSeen,
      if (wordsSuccess != null) 'words_success': wordsSuccess,
      if (minutesPlayed != null) 'minutes_played': minutesPlayed,
    });
  }

  DailyStatsCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<DateTime>? date,
      Value<int>? wordsSeen,
      Value<int>? wordsSuccess,
      Value<int>? minutesPlayed}) {
    return DailyStatsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      date: date ?? this.date,
      wordsSeen: wordsSeen ?? this.wordsSeen,
      wordsSuccess: wordsSuccess ?? this.wordsSuccess,
      minutesPlayed: minutesPlayed ?? this.minutesPlayed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (wordsSeen.present) {
      map['words_seen'] = Variable<int>(wordsSeen.value);
    }
    if (wordsSuccess.present) {
      map['words_success'] = Variable<int>(wordsSuccess.value);
    }
    if (minutesPlayed.present) {
      map['minutes_played'] = Variable<int>(minutesPlayed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyStatsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('date: $date, ')
          ..write('wordsSeen: $wordsSeen, ')
          ..write('wordsSuccess: $wordsSuccess, ')
          ..write('minutesPlayed: $minutesPlayed')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'UNIQUE REFERENCES profiles (id)'));
  static const VerificationMeta _themeNameMeta =
      const VerificationMeta('themeName');
  @override
  late final GeneratedColumn<String> themeName = GeneratedColumn<String>(
      'theme_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('systeme'));
  static const VerificationMeta _childThemeNameMeta =
      const VerificationMeta('childThemeName');
  @override
  late final GeneratedColumn<String> childThemeName = GeneratedColumn<String>(
      'child_theme_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ocean'));
  static const VerificationMeta _fontSizeMeta =
      const VerificationMeta('fontSize');
  @override
  late final GeneratedColumn<double> fontSize = GeneratedColumn<double>(
      'font_size', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _ttsEnabledMeta =
      const VerificationMeta('ttsEnabled');
  @override
  late final GeneratedColumn<bool> ttsEnabled = GeneratedColumn<bool>(
      'tts_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("tts_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _ttsRateMeta =
      const VerificationMeta('ttsRate');
  @override
  late final GeneratedColumn<double> ttsRate = GeneratedColumn<double>(
      'tts_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.8));
  static const VerificationMeta _ttsVolumeMeta =
      const VerificationMeta('ttsVolume');
  @override
  late final GeneratedColumn<double> ttsVolume = GeneratedColumn<double>(
      'tts_volume', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _soundEnabledMeta =
      const VerificationMeta('soundEnabled');
  @override
  late final GeneratedColumn<bool> soundEnabled = GeneratedColumn<bool>(
      'sound_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("sound_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _sessionDurationLimitMinMeta =
      const VerificationMeta('sessionDurationLimitMin');
  @override
  late final GeneratedColumn<int> sessionDurationLimitMin =
      GeneratedColumn<int>('session_duration_limit_min', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(0));
  static const VerificationMeta _onboardingDoneMeta =
      const VerificationMeta('onboardingDone');
  @override
  late final GeneratedColumn<bool> onboardingDone = GeneratedColumn<bool>(
      'onboarding_done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("onboarding_done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _dyslexicFontMeta =
      const VerificationMeta('dyslexicFont');
  @override
  late final GeneratedColumn<bool> dyslexicFont = GeneratedColumn<bool>(
      'dyslexic_font', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("dyslexic_font" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _highContrastMeta =
      const VerificationMeta('highContrast');
  @override
  late final GeneratedColumn<bool> highContrast = GeneratedColumn<bool>(
      'high_contrast', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("high_contrast" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _colorBlindModeMeta =
      const VerificationMeta('colorBlindMode');
  @override
  late final GeneratedColumn<String> colorBlindMode = GeneratedColumn<String>(
      'color_blind_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _reduceAnimationsMeta =
      const VerificationMeta('reduceAnimations');
  @override
  late final GeneratedColumn<bool> reduceAnimations = GeneratedColumn<bool>(
      'reduce_animations', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("reduce_animations" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _largeTargetsMeta =
      const VerificationMeta('largeTargets');
  @override
  late final GeneratedColumn<String> largeTargets = GeneratedColumn<String>(
      'large_targets', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('normal'));
  static const VerificationMeta _hapticFeedbackMeta =
      const VerificationMeta('hapticFeedback');
  @override
  late final GeneratedColumn<bool> hapticFeedback = GeneratedColumn<bool>(
      'haptic_feedback', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("haptic_feedback" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _textSpacingMeta =
      const VerificationMeta('textSpacing');
  @override
  late final GeneratedColumn<bool> textSpacing = GeneratedColumn<bool>(
      'text_spacing', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("text_spacing" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _showCaptionsMeta =
      const VerificationMeta('showCaptions');
  @override
  late final GeneratedColumn<bool> showCaptions = GeneratedColumn<bool>(
      'show_captions', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_captions" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileId,
        themeName,
        childThemeName,
        fontSize,
        ttsEnabled,
        ttsRate,
        ttsVolume,
        soundEnabled,
        sessionDurationLimitMin,
        onboardingDone,
        dyslexicFont,
        highContrast,
        colorBlindMode,
        reduceAnimations,
        largeTargets,
        hapticFeedback,
        textSpacing,
        showCaptions
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('theme_name')) {
      context.handle(_themeNameMeta,
          themeName.isAcceptableOrUnknown(data['theme_name']!, _themeNameMeta));
    }
    if (data.containsKey('child_theme_name')) {
      context.handle(
          _childThemeNameMeta,
          childThemeName.isAcceptableOrUnknown(
              data['child_theme_name']!, _childThemeNameMeta));
    }
    if (data.containsKey('font_size')) {
      context.handle(_fontSizeMeta,
          fontSize.isAcceptableOrUnknown(data['font_size']!, _fontSizeMeta));
    }
    if (data.containsKey('tts_enabled')) {
      context.handle(
          _ttsEnabledMeta,
          ttsEnabled.isAcceptableOrUnknown(
              data['tts_enabled']!, _ttsEnabledMeta));
    }
    if (data.containsKey('tts_rate')) {
      context.handle(_ttsRateMeta,
          ttsRate.isAcceptableOrUnknown(data['tts_rate']!, _ttsRateMeta));
    }
    if (data.containsKey('tts_volume')) {
      context.handle(_ttsVolumeMeta,
          ttsVolume.isAcceptableOrUnknown(data['tts_volume']!, _ttsVolumeMeta));
    }
    if (data.containsKey('sound_enabled')) {
      context.handle(
          _soundEnabledMeta,
          soundEnabled.isAcceptableOrUnknown(
              data['sound_enabled']!, _soundEnabledMeta));
    }
    if (data.containsKey('session_duration_limit_min')) {
      context.handle(
          _sessionDurationLimitMinMeta,
          sessionDurationLimitMin.isAcceptableOrUnknown(
              data['session_duration_limit_min']!,
              _sessionDurationLimitMinMeta));
    }
    if (data.containsKey('onboarding_done')) {
      context.handle(
          _onboardingDoneMeta,
          onboardingDone.isAcceptableOrUnknown(
              data['onboarding_done']!, _onboardingDoneMeta));
    }
    if (data.containsKey('dyslexic_font')) {
      context.handle(
          _dyslexicFontMeta,
          dyslexicFont.isAcceptableOrUnknown(
              data['dyslexic_font']!, _dyslexicFontMeta));
    }
    if (data.containsKey('high_contrast')) {
      context.handle(
          _highContrastMeta,
          highContrast.isAcceptableOrUnknown(
              data['high_contrast']!, _highContrastMeta));
    }
    if (data.containsKey('color_blind_mode')) {
      context.handle(
          _colorBlindModeMeta,
          colorBlindMode.isAcceptableOrUnknown(
              data['color_blind_mode']!, _colorBlindModeMeta));
    }
    if (data.containsKey('reduce_animations')) {
      context.handle(
          _reduceAnimationsMeta,
          reduceAnimations.isAcceptableOrUnknown(
              data['reduce_animations']!, _reduceAnimationsMeta));
    }
    if (data.containsKey('large_targets')) {
      context.handle(
          _largeTargetsMeta,
          largeTargets.isAcceptableOrUnknown(
              data['large_targets']!, _largeTargetsMeta));
    }
    if (data.containsKey('haptic_feedback')) {
      context.handle(
          _hapticFeedbackMeta,
          hapticFeedback.isAcceptableOrUnknown(
              data['haptic_feedback']!, _hapticFeedbackMeta));
    }
    if (data.containsKey('text_spacing')) {
      context.handle(
          _textSpacingMeta,
          textSpacing.isAcceptableOrUnknown(
              data['text_spacing']!, _textSpacingMeta));
    }
    if (data.containsKey('show_captions')) {
      context.handle(
          _showCaptionsMeta,
          showCaptions.isAcceptableOrUnknown(
              data['show_captions']!, _showCaptionsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
      themeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_name'])!,
      childThemeName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}child_theme_name'])!,
      fontSize: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}font_size'])!,
      ttsEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}tts_enabled'])!,
      ttsRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tts_rate'])!,
      ttsVolume: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tts_volume'])!,
      soundEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}sound_enabled'])!,
      sessionDurationLimitMin: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}session_duration_limit_min'])!,
      onboardingDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}onboarding_done'])!,
      dyslexicFont: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dyslexic_font'])!,
      highContrast: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}high_contrast'])!,
      colorBlindMode: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}color_blind_mode'])!,
      reduceAnimations: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}reduce_animations'])!,
      largeTargets: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}large_targets'])!,
      hapticFeedback: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}haptic_feedback'])!,
      textSpacing: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}text_spacing'])!,
      showCaptions: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}show_captions'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;

  /// Profil concerné (clé unique : un seul réglage par profil).
  final int profileId;

  /// Nom du thème : 'clair' | 'sombre' | 'systeme'.
  final String themeName;

  /// Thème visuel enfant : 'espace' | 'foret' | 'ocean' | 'fantasy'.
  final String childThemeName;

  /// Taille de police relative : 1.0 = normale.
  final double fontSize;

  /// Synthèse vocale activée.
  final bool ttsEnabled;

  /// Vitesse TTS (0.5 = lent, 1.0 = normal). Défaut 0.8 pour les enfants.
  final double ttsRate;

  /// Volume TTS (0.0–1.0).
  final double ttsVolume;

  /// Sons de feedback activés.
  final bool soundEnabled;

  /// Durée maximale d'une session de jeu en minutes (0 = illimitée).
  final int sessionDurationLimitMin;

  /// L'utilisateur a terminé l'onboarding.
  final bool onboardingDone;

  /// Police adaptée dyslexie (OpenDyslexic) activée.
  final bool dyslexicFont;

  /// Mode contraste élevé activé.
  final bool highContrast;

  /// Mode daltonisme : 'none' | 'deuteranopia' | 'protanopia' | 'tritanopia'.
  final String colorBlindMode;

  /// Réduire les animations (surclasse MediaQuery.disableAnimations).
  final bool reduceAnimations;

  /// Taille des cibles tactiles : 'normal' | 'large' | 'xlarge'.
  final String largeTargets;

  /// Retour haptique activé.
  final bool hapticFeedback;

  /// Espacement texte dyslexie activé (letter-spacing + word-spacing accrus).
  final bool textSpacing;

  /// Afficher les sous-titres audio (pour les mots lus par TTS).
  final bool showCaptions;
  const AppSetting(
      {required this.id,
      required this.profileId,
      required this.themeName,
      required this.childThemeName,
      required this.fontSize,
      required this.ttsEnabled,
      required this.ttsRate,
      required this.ttsVolume,
      required this.soundEnabled,
      required this.sessionDurationLimitMin,
      required this.onboardingDone,
      required this.dyslexicFont,
      required this.highContrast,
      required this.colorBlindMode,
      required this.reduceAnimations,
      required this.largeTargets,
      required this.hapticFeedback,
      required this.textSpacing,
      required this.showCaptions});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_id'] = Variable<int>(profileId);
    map['theme_name'] = Variable<String>(themeName);
    map['child_theme_name'] = Variable<String>(childThemeName);
    map['font_size'] = Variable<double>(fontSize);
    map['tts_enabled'] = Variable<bool>(ttsEnabled);
    map['tts_rate'] = Variable<double>(ttsRate);
    map['tts_volume'] = Variable<double>(ttsVolume);
    map['sound_enabled'] = Variable<bool>(soundEnabled);
    map['session_duration_limit_min'] = Variable<int>(sessionDurationLimitMin);
    map['onboarding_done'] = Variable<bool>(onboardingDone);
    map['dyslexic_font'] = Variable<bool>(dyslexicFont);
    map['high_contrast'] = Variable<bool>(highContrast);
    map['color_blind_mode'] = Variable<String>(colorBlindMode);
    map['reduce_animations'] = Variable<bool>(reduceAnimations);
    map['large_targets'] = Variable<String>(largeTargets);
    map['haptic_feedback'] = Variable<bool>(hapticFeedback);
    map['text_spacing'] = Variable<bool>(textSpacing);
    map['show_captions'] = Variable<bool>(showCaptions);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      themeName: Value(themeName),
      childThemeName: Value(childThemeName),
      fontSize: Value(fontSize),
      ttsEnabled: Value(ttsEnabled),
      ttsRate: Value(ttsRate),
      ttsVolume: Value(ttsVolume),
      soundEnabled: Value(soundEnabled),
      sessionDurationLimitMin: Value(sessionDurationLimitMin),
      onboardingDone: Value(onboardingDone),
      dyslexicFont: Value(dyslexicFont),
      highContrast: Value(highContrast),
      colorBlindMode: Value(colorBlindMode),
      reduceAnimations: Value(reduceAnimations),
      largeTargets: Value(largeTargets),
      hapticFeedback: Value(hapticFeedback),
      textSpacing: Value(textSpacing),
      showCaptions: Value(showCaptions),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int>(json['profileId']),
      themeName: serializer.fromJson<String>(json['themeName']),
      childThemeName: serializer.fromJson<String>(json['childThemeName']),
      fontSize: serializer.fromJson<double>(json['fontSize']),
      ttsEnabled: serializer.fromJson<bool>(json['ttsEnabled']),
      ttsRate: serializer.fromJson<double>(json['ttsRate']),
      ttsVolume: serializer.fromJson<double>(json['ttsVolume']),
      soundEnabled: serializer.fromJson<bool>(json['soundEnabled']),
      sessionDurationLimitMin:
          serializer.fromJson<int>(json['sessionDurationLimitMin']),
      onboardingDone: serializer.fromJson<bool>(json['onboardingDone']),
      dyslexicFont: serializer.fromJson<bool>(json['dyslexicFont']),
      highContrast: serializer.fromJson<bool>(json['highContrast']),
      colorBlindMode: serializer.fromJson<String>(json['colorBlindMode']),
      reduceAnimations: serializer.fromJson<bool>(json['reduceAnimations']),
      largeTargets: serializer.fromJson<String>(json['largeTargets']),
      hapticFeedback: serializer.fromJson<bool>(json['hapticFeedback']),
      textSpacing: serializer.fromJson<bool>(json['textSpacing']),
      showCaptions: serializer.fromJson<bool>(json['showCaptions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int>(profileId),
      'themeName': serializer.toJson<String>(themeName),
      'childThemeName': serializer.toJson<String>(childThemeName),
      'fontSize': serializer.toJson<double>(fontSize),
      'ttsEnabled': serializer.toJson<bool>(ttsEnabled),
      'ttsRate': serializer.toJson<double>(ttsRate),
      'ttsVolume': serializer.toJson<double>(ttsVolume),
      'soundEnabled': serializer.toJson<bool>(soundEnabled),
      'sessionDurationLimitMin':
          serializer.toJson<int>(sessionDurationLimitMin),
      'onboardingDone': serializer.toJson<bool>(onboardingDone),
      'dyslexicFont': serializer.toJson<bool>(dyslexicFont),
      'highContrast': serializer.toJson<bool>(highContrast),
      'colorBlindMode': serializer.toJson<String>(colorBlindMode),
      'reduceAnimations': serializer.toJson<bool>(reduceAnimations),
      'largeTargets': serializer.toJson<String>(largeTargets),
      'hapticFeedback': serializer.toJson<bool>(hapticFeedback),
      'textSpacing': serializer.toJson<bool>(textSpacing),
      'showCaptions': serializer.toJson<bool>(showCaptions),
    };
  }

  AppSetting copyWith(
          {int? id,
          int? profileId,
          String? themeName,
          String? childThemeName,
          double? fontSize,
          bool? ttsEnabled,
          double? ttsRate,
          double? ttsVolume,
          bool? soundEnabled,
          int? sessionDurationLimitMin,
          bool? onboardingDone,
          bool? dyslexicFont,
          bool? highContrast,
          String? colorBlindMode,
          bool? reduceAnimations,
          String? largeTargets,
          bool? hapticFeedback,
          bool? textSpacing,
          bool? showCaptions}) =>
      AppSetting(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        themeName: themeName ?? this.themeName,
        childThemeName: childThemeName ?? this.childThemeName,
        fontSize: fontSize ?? this.fontSize,
        ttsEnabled: ttsEnabled ?? this.ttsEnabled,
        ttsRate: ttsRate ?? this.ttsRate,
        ttsVolume: ttsVolume ?? this.ttsVolume,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        sessionDurationLimitMin:
            sessionDurationLimitMin ?? this.sessionDurationLimitMin,
        onboardingDone: onboardingDone ?? this.onboardingDone,
        dyslexicFont: dyslexicFont ?? this.dyslexicFont,
        highContrast: highContrast ?? this.highContrast,
        colorBlindMode: colorBlindMode ?? this.colorBlindMode,
        reduceAnimations: reduceAnimations ?? this.reduceAnimations,
        largeTargets: largeTargets ?? this.largeTargets,
        hapticFeedback: hapticFeedback ?? this.hapticFeedback,
        textSpacing: textSpacing ?? this.textSpacing,
        showCaptions: showCaptions ?? this.showCaptions,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      themeName: data.themeName.present ? data.themeName.value : this.themeName,
      childThemeName: data.childThemeName.present
          ? data.childThemeName.value
          : this.childThemeName,
      fontSize: data.fontSize.present ? data.fontSize.value : this.fontSize,
      ttsEnabled:
          data.ttsEnabled.present ? data.ttsEnabled.value : this.ttsEnabled,
      ttsRate: data.ttsRate.present ? data.ttsRate.value : this.ttsRate,
      ttsVolume: data.ttsVolume.present ? data.ttsVolume.value : this.ttsVolume,
      soundEnabled: data.soundEnabled.present
          ? data.soundEnabled.value
          : this.soundEnabled,
      sessionDurationLimitMin: data.sessionDurationLimitMin.present
          ? data.sessionDurationLimitMin.value
          : this.sessionDurationLimitMin,
      onboardingDone: data.onboardingDone.present
          ? data.onboardingDone.value
          : this.onboardingDone,
      dyslexicFont: data.dyslexicFont.present
          ? data.dyslexicFont.value
          : this.dyslexicFont,
      highContrast: data.highContrast.present
          ? data.highContrast.value
          : this.highContrast,
      colorBlindMode: data.colorBlindMode.present
          ? data.colorBlindMode.value
          : this.colorBlindMode,
      reduceAnimations: data.reduceAnimations.present
          ? data.reduceAnimations.value
          : this.reduceAnimations,
      largeTargets: data.largeTargets.present
          ? data.largeTargets.value
          : this.largeTargets,
      hapticFeedback: data.hapticFeedback.present
          ? data.hapticFeedback.value
          : this.hapticFeedback,
      textSpacing:
          data.textSpacing.present ? data.textSpacing.value : this.textSpacing,
      showCaptions: data.showCaptions.present
          ? data.showCaptions.value
          : this.showCaptions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('themeName: $themeName, ')
          ..write('childThemeName: $childThemeName, ')
          ..write('fontSize: $fontSize, ')
          ..write('ttsEnabled: $ttsEnabled, ')
          ..write('ttsRate: $ttsRate, ')
          ..write('ttsVolume: $ttsVolume, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('sessionDurationLimitMin: $sessionDurationLimitMin, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('dyslexicFont: $dyslexicFont, ')
          ..write('highContrast: $highContrast, ')
          ..write('colorBlindMode: $colorBlindMode, ')
          ..write('reduceAnimations: $reduceAnimations, ')
          ..write('largeTargets: $largeTargets, ')
          ..write('hapticFeedback: $hapticFeedback, ')
          ..write('textSpacing: $textSpacing, ')
          ..write('showCaptions: $showCaptions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      profileId,
      themeName,
      childThemeName,
      fontSize,
      ttsEnabled,
      ttsRate,
      ttsVolume,
      soundEnabled,
      sessionDurationLimitMin,
      onboardingDone,
      dyslexicFont,
      highContrast,
      colorBlindMode,
      reduceAnimations,
      largeTargets,
      hapticFeedback,
      textSpacing,
      showCaptions);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.themeName == this.themeName &&
          other.childThemeName == this.childThemeName &&
          other.fontSize == this.fontSize &&
          other.ttsEnabled == this.ttsEnabled &&
          other.ttsRate == this.ttsRate &&
          other.ttsVolume == this.ttsVolume &&
          other.soundEnabled == this.soundEnabled &&
          other.sessionDurationLimitMin == this.sessionDurationLimitMin &&
          other.onboardingDone == this.onboardingDone &&
          other.dyslexicFont == this.dyslexicFont &&
          other.highContrast == this.highContrast &&
          other.colorBlindMode == this.colorBlindMode &&
          other.reduceAnimations == this.reduceAnimations &&
          other.largeTargets == this.largeTargets &&
          other.hapticFeedback == this.hapticFeedback &&
          other.textSpacing == this.textSpacing &&
          other.showCaptions == this.showCaptions);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<int> profileId;
  final Value<String> themeName;
  final Value<String> childThemeName;
  final Value<double> fontSize;
  final Value<bool> ttsEnabled;
  final Value<double> ttsRate;
  final Value<double> ttsVolume;
  final Value<bool> soundEnabled;
  final Value<int> sessionDurationLimitMin;
  final Value<bool> onboardingDone;
  final Value<bool> dyslexicFont;
  final Value<bool> highContrast;
  final Value<String> colorBlindMode;
  final Value<bool> reduceAnimations;
  final Value<String> largeTargets;
  final Value<bool> hapticFeedback;
  final Value<bool> textSpacing;
  final Value<bool> showCaptions;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.themeName = const Value.absent(),
    this.childThemeName = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.ttsEnabled = const Value.absent(),
    this.ttsRate = const Value.absent(),
    this.ttsVolume = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.sessionDurationLimitMin = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    this.dyslexicFont = const Value.absent(),
    this.highContrast = const Value.absent(),
    this.colorBlindMode = const Value.absent(),
    this.reduceAnimations = const Value.absent(),
    this.largeTargets = const Value.absent(),
    this.hapticFeedback = const Value.absent(),
    this.textSpacing = const Value.absent(),
    this.showCaptions = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    required int profileId,
    this.themeName = const Value.absent(),
    this.childThemeName = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.ttsEnabled = const Value.absent(),
    this.ttsRate = const Value.absent(),
    this.ttsVolume = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.sessionDurationLimitMin = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    this.dyslexicFont = const Value.absent(),
    this.highContrast = const Value.absent(),
    this.colorBlindMode = const Value.absent(),
    this.reduceAnimations = const Value.absent(),
    this.largeTargets = const Value.absent(),
    this.hapticFeedback = const Value.absent(),
    this.textSpacing = const Value.absent(),
    this.showCaptions = const Value.absent(),
  }) : profileId = Value(profileId);
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? themeName,
    Expression<String>? childThemeName,
    Expression<double>? fontSize,
    Expression<bool>? ttsEnabled,
    Expression<double>? ttsRate,
    Expression<double>? ttsVolume,
    Expression<bool>? soundEnabled,
    Expression<int>? sessionDurationLimitMin,
    Expression<bool>? onboardingDone,
    Expression<bool>? dyslexicFont,
    Expression<bool>? highContrast,
    Expression<String>? colorBlindMode,
    Expression<bool>? reduceAnimations,
    Expression<String>? largeTargets,
    Expression<bool>? hapticFeedback,
    Expression<bool>? textSpacing,
    Expression<bool>? showCaptions,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (themeName != null) 'theme_name': themeName,
      if (childThemeName != null) 'child_theme_name': childThemeName,
      if (fontSize != null) 'font_size': fontSize,
      if (ttsEnabled != null) 'tts_enabled': ttsEnabled,
      if (ttsRate != null) 'tts_rate': ttsRate,
      if (ttsVolume != null) 'tts_volume': ttsVolume,
      if (soundEnabled != null) 'sound_enabled': soundEnabled,
      if (sessionDurationLimitMin != null)
        'session_duration_limit_min': sessionDurationLimitMin,
      if (onboardingDone != null) 'onboarding_done': onboardingDone,
      if (dyslexicFont != null) 'dyslexic_font': dyslexicFont,
      if (highContrast != null) 'high_contrast': highContrast,
      if (colorBlindMode != null) 'color_blind_mode': colorBlindMode,
      if (reduceAnimations != null) 'reduce_animations': reduceAnimations,
      if (largeTargets != null) 'large_targets': largeTargets,
      if (hapticFeedback != null) 'haptic_feedback': hapticFeedback,
      if (textSpacing != null) 'text_spacing': textSpacing,
      if (showCaptions != null) 'show_captions': showCaptions,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? profileId,
      Value<String>? themeName,
      Value<String>? childThemeName,
      Value<double>? fontSize,
      Value<bool>? ttsEnabled,
      Value<double>? ttsRate,
      Value<double>? ttsVolume,
      Value<bool>? soundEnabled,
      Value<int>? sessionDurationLimitMin,
      Value<bool>? onboardingDone,
      Value<bool>? dyslexicFont,
      Value<bool>? highContrast,
      Value<String>? colorBlindMode,
      Value<bool>? reduceAnimations,
      Value<String>? largeTargets,
      Value<bool>? hapticFeedback,
      Value<bool>? textSpacing,
      Value<bool>? showCaptions}) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      themeName: themeName ?? this.themeName,
      childThemeName: childThemeName ?? this.childThemeName,
      fontSize: fontSize ?? this.fontSize,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      ttsRate: ttsRate ?? this.ttsRate,
      ttsVolume: ttsVolume ?? this.ttsVolume,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      sessionDurationLimitMin:
          sessionDurationLimitMin ?? this.sessionDurationLimitMin,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      dyslexicFont: dyslexicFont ?? this.dyslexicFont,
      highContrast: highContrast ?? this.highContrast,
      colorBlindMode: colorBlindMode ?? this.colorBlindMode,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      largeTargets: largeTargets ?? this.largeTargets,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      textSpacing: textSpacing ?? this.textSpacing,
      showCaptions: showCaptions ?? this.showCaptions,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (themeName.present) {
      map['theme_name'] = Variable<String>(themeName.value);
    }
    if (childThemeName.present) {
      map['child_theme_name'] = Variable<String>(childThemeName.value);
    }
    if (fontSize.present) {
      map['font_size'] = Variable<double>(fontSize.value);
    }
    if (ttsEnabled.present) {
      map['tts_enabled'] = Variable<bool>(ttsEnabled.value);
    }
    if (ttsRate.present) {
      map['tts_rate'] = Variable<double>(ttsRate.value);
    }
    if (ttsVolume.present) {
      map['tts_volume'] = Variable<double>(ttsVolume.value);
    }
    if (soundEnabled.present) {
      map['sound_enabled'] = Variable<bool>(soundEnabled.value);
    }
    if (sessionDurationLimitMin.present) {
      map['session_duration_limit_min'] =
          Variable<int>(sessionDurationLimitMin.value);
    }
    if (onboardingDone.present) {
      map['onboarding_done'] = Variable<bool>(onboardingDone.value);
    }
    if (dyslexicFont.present) {
      map['dyslexic_font'] = Variable<bool>(dyslexicFont.value);
    }
    if (highContrast.present) {
      map['high_contrast'] = Variable<bool>(highContrast.value);
    }
    if (colorBlindMode.present) {
      map['color_blind_mode'] = Variable<String>(colorBlindMode.value);
    }
    if (reduceAnimations.present) {
      map['reduce_animations'] = Variable<bool>(reduceAnimations.value);
    }
    if (largeTargets.present) {
      map['large_targets'] = Variable<String>(largeTargets.value);
    }
    if (hapticFeedback.present) {
      map['haptic_feedback'] = Variable<bool>(hapticFeedback.value);
    }
    if (textSpacing.present) {
      map['text_spacing'] = Variable<bool>(textSpacing.value);
    }
    if (showCaptions.present) {
      map['show_captions'] = Variable<bool>(showCaptions.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('themeName: $themeName, ')
          ..write('childThemeName: $childThemeName, ')
          ..write('fontSize: $fontSize, ')
          ..write('ttsEnabled: $ttsEnabled, ')
          ..write('ttsRate: $ttsRate, ')
          ..write('ttsVolume: $ttsVolume, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('sessionDurationLimitMin: $sessionDurationLimitMin, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('dyslexicFont: $dyslexicFont, ')
          ..write('highContrast: $highContrast, ')
          ..write('colorBlindMode: $colorBlindMode, ')
          ..write('reduceAnimations: $reduceAnimations, ')
          ..write('largeTargets: $largeTargets, ')
          ..write('hapticFeedback: $hapticFeedback, ')
          ..write('textSpacing: $textSpacing, ')
          ..write('showCaptions: $showCaptions')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $DictionariesTable dictionaries = $DictionariesTable(this);
  late final $DictionaryAssignmentsTable dictionaryAssignments =
      $DictionaryAssignmentsTable(this);
  late final $WordsTable words = $WordsTable(this);
  late final $WordMasteryTable wordMastery = $WordMasteryTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $WordAttemptsTable wordAttempts = $WordAttemptsTable(this);
  late final $DailyStatsTable dailyStats = $DailyStatsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final ProfilesDao profilesDao = ProfilesDao(this as AppDatabase);
  late final DictionariesDao dictionariesDao =
      DictionariesDao(this as AppDatabase);
  late final DictionaryAssignmentsDao dictionaryAssignmentsDao =
      DictionaryAssignmentsDao(this as AppDatabase);
  late final WordsDao wordsDao = WordsDao(this as AppDatabase);
  late final StatsDao statsDao = StatsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        profiles,
        dictionaries,
        dictionaryAssignments,
        words,
        wordMastery,
        sessions,
        wordAttempts,
        dailyStats,
        appSettings
      ];
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  required String prenom,
  Value<String?> nom,
  Value<String?> avatarPath,
  Value<String> type,
  Value<int?> parentId,
  Value<String?> pinHash,
  Value<bool> allowDiscoveryMode,
  Value<DateTime> createdAt,
  Value<DateTime?> archivedAt,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> prenom,
  Value<String?> nom,
  Value<String?> avatarPath,
  Value<String> type,
  Value<int?> parentId,
  Value<String?> pinHash,
  Value<bool> allowDiscoveryMode,
  Value<DateTime> createdAt,
  Value<DateTime?> archivedAt,
});

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DictionariesTable, List<Dictionary>>
      _dictionariesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.dictionaries,
          aliasName:
              $_aliasNameGenerator(db.profiles.id, db.dictionaries.profileId));

  $$DictionariesTableProcessedTableManager get dictionariesRefs {
    final manager = $$DictionariesTableTableManager($_db, $_db.dictionaries)
        .filter((f) => f.profileId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_dictionariesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DictionaryAssignmentsTable,
      List<DictionaryAssignment>> _dictionaryAssignmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.dictionaryAssignments,
          aliasName: $_aliasNameGenerator(
              db.profiles.id, db.dictionaryAssignments.childId));

  $$DictionaryAssignmentsTableProcessedTableManager
      get dictionaryAssignmentsRefs {
    final manager = $$DictionaryAssignmentsTableTableManager(
            $_db, $_db.dictionaryAssignments)
        .filter((f) => f.childId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_dictionaryAssignmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WordMasteryTable, List<WordMasteryData>>
      _wordMasteryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.wordMastery,
          aliasName:
              $_aliasNameGenerator(db.profiles.id, db.wordMastery.profileId));

  $$WordMasteryTableProcessedTableManager get wordMasteryRefs {
    final manager = $$WordMasteryTableTableManager($_db, $_db.wordMastery)
        .filter((f) => f.profileId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_wordMasteryRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.sessions,
          aliasName:
              $_aliasNameGenerator(db.profiles.id, db.sessions.profileId));

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.profileId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DailyStatsTable, List<DailyStat>>
      _dailyStatsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.dailyStats,
          aliasName:
              $_aliasNameGenerator(db.profiles.id, db.dailyStats.profileId));

  $$DailyStatsTableProcessedTableManager get dailyStatsRefs {
    final manager = $$DailyStatsTableTableManager($_db, $_db.dailyStats)
        .filter((f) => f.profileId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_dailyStatsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AppSettingsTable, List<AppSetting>>
      _appSettingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.appSettings,
          aliasName:
              $_aliasNameGenerator(db.profiles.id, db.appSettings.profileId));

  $$AppSettingsTableProcessedTableManager get appSettingsRefs {
    final manager = $$AppSettingsTableTableManager($_db, $_db.appSettings)
        .filter((f) => f.profileId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_appSettingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prenom => $composableBuilder(
      column: $table.prenom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pinHash => $composableBuilder(
      column: $table.pinHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get allowDiscoveryMode => $composableBuilder(
      column: $table.allowDiscoveryMode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> dictionariesRefs(
      Expression<bool> Function($$DictionariesTableFilterComposer f) f) {
    final $$DictionariesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dictionaries,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DictionariesTableFilterComposer(
              $db: $db,
              $table: $db.dictionaries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> dictionaryAssignmentsRefs(
      Expression<bool> Function($$DictionaryAssignmentsTableFilterComposer f)
          f) {
    final $$DictionaryAssignmentsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.dictionaryAssignments,
            getReferencedColumn: (t) => t.childId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DictionaryAssignmentsTableFilterComposer(
                  $db: $db,
                  $table: $db.dictionaryAssignments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> wordMasteryRefs(
      Expression<bool> Function($$WordMasteryTableFilterComposer f) f) {
    final $$WordMasteryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wordMastery,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordMasteryTableFilterComposer(
              $db: $db,
              $table: $db.wordMastery,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sessionsRefs(
      Expression<bool> Function($$SessionsTableFilterComposer f) f) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> dailyStatsRefs(
      Expression<bool> Function($$DailyStatsTableFilterComposer f) f) {
    final $$DailyStatsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dailyStats,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DailyStatsTableFilterComposer(
              $db: $db,
              $table: $db.dailyStats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> appSettingsRefs(
      Expression<bool> Function($$AppSettingsTableFilterComposer f) f) {
    final $$AppSettingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.appSettings,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AppSettingsTableFilterComposer(
              $db: $db,
              $table: $db.appSettings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prenom => $composableBuilder(
      column: $table.prenom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pinHash => $composableBuilder(
      column: $table.pinHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get allowDiscoveryMode => $composableBuilder(
      column: $table.allowDiscoveryMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get prenom =>
      $composableBuilder(column: $table.prenom, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<bool> get allowDiscoveryMode => $composableBuilder(
      column: $table.allowDiscoveryMode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => column);

  Expression<T> dictionariesRefs<T extends Object>(
      Expression<T> Function($$DictionariesTableAnnotationComposer a) f) {
    final $$DictionariesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dictionaries,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DictionariesTableAnnotationComposer(
              $db: $db,
              $table: $db.dictionaries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> dictionaryAssignmentsRefs<T extends Object>(
      Expression<T> Function($$DictionaryAssignmentsTableAnnotationComposer a)
          f) {
    final $$DictionaryAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.dictionaryAssignments,
            getReferencedColumn: (t) => t.childId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DictionaryAssignmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.dictionaryAssignments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> wordMasteryRefs<T extends Object>(
      Expression<T> Function($$WordMasteryTableAnnotationComposer a) f) {
    final $$WordMasteryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wordMastery,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordMasteryTableAnnotationComposer(
              $db: $db,
              $table: $db.wordMastery,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
      Expression<T> Function($$SessionsTableAnnotationComposer a) f) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> dailyStatsRefs<T extends Object>(
      Expression<T> Function($$DailyStatsTableAnnotationComposer a) f) {
    final $$DailyStatsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dailyStats,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DailyStatsTableAnnotationComposer(
              $db: $db,
              $table: $db.dailyStats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> appSettingsRefs<T extends Object>(
      Expression<T> Function($$AppSettingsTableAnnotationComposer a) f) {
    final $$AppSettingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.appSettings,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AppSettingsTableAnnotationComposer(
              $db: $db,
              $table: $db.appSettings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (Profile, $$ProfilesTableReferences),
    Profile,
    PrefetchHooks Function(
        {bool dictionariesRefs,
        bool dictionaryAssignmentsRefs,
        bool wordMasteryRefs,
        bool sessionsRefs,
        bool dailyStatsRefs,
        bool appSettingsRefs})> {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> prenom = const Value.absent(),
            Value<String?> nom = const Value.absent(),
            Value<String?> avatarPath = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            Value<String?> pinHash = const Value.absent(),
            Value<bool> allowDiscoveryMode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
          }) =>
              ProfilesCompanion(
            id: id,
            prenom: prenom,
            nom: nom,
            avatarPath: avatarPath,
            type: type,
            parentId: parentId,
            pinHash: pinHash,
            allowDiscoveryMode: allowDiscoveryMode,
            createdAt: createdAt,
            archivedAt: archivedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String prenom,
            Value<String?> nom = const Value.absent(),
            Value<String?> avatarPath = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            Value<String?> pinHash = const Value.absent(),
            Value<bool> allowDiscoveryMode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
          }) =>
              ProfilesCompanion.insert(
            id: id,
            prenom: prenom,
            nom: nom,
            avatarPath: avatarPath,
            type: type,
            parentId: parentId,
            pinHash: pinHash,
            allowDiscoveryMode: allowDiscoveryMode,
            createdAt: createdAt,
            archivedAt: archivedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProfilesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {dictionariesRefs = false,
              dictionaryAssignmentsRefs = false,
              wordMasteryRefs = false,
              sessionsRefs = false,
              dailyStatsRefs = false,
              appSettingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (dictionariesRefs) db.dictionaries,
                if (dictionaryAssignmentsRefs) db.dictionaryAssignments,
                if (wordMasteryRefs) db.wordMastery,
                if (sessionsRefs) db.sessions,
                if (dailyStatsRefs) db.dailyStats,
                if (appSettingsRefs) db.appSettings
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dictionariesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._dictionariesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .dictionariesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items),
                  if (dictionaryAssignmentsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._dictionaryAssignmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .dictionaryAssignmentsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.childId == item.id),
                        typedResults: items),
                  if (wordMasteryRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._wordMasteryRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .wordMasteryRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items),
                  if (sessionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._sessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .sessionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items),
                  if (dailyStatsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._dailyStatsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .dailyStatsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items),
                  if (appSettingsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._appSettingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .appSettingsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (Profile, $$ProfilesTableReferences),
    Profile,
    PrefetchHooks Function(
        {bool dictionariesRefs,
        bool dictionaryAssignmentsRefs,
        bool wordMasteryRefs,
        bool sessionsRefs,
        bool dailyStatsRefs,
        bool appSettingsRefs})>;
typedef $$DictionariesTableCreateCompanionBuilder = DictionariesCompanion
    Function({
  Value<int> id,
  required int profileId,
  required String nom,
  Value<String?> description,
  Value<String> couleur,
  Value<String> icon,
  Value<bool> active,
  Value<DateTime> createdAt,
});
typedef $$DictionariesTableUpdateCompanionBuilder = DictionariesCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> nom,
  Value<String?> description,
  Value<String> couleur,
  Value<String> icon,
  Value<bool> active,
  Value<DateTime> createdAt,
});

final class $$DictionariesTableReferences
    extends BaseReferences<_$AppDatabase, $DictionariesTable, Dictionary> {
  $$DictionariesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.dictionaries.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get profileId {
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id($_item.profileId));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$DictionaryAssignmentsTable,
      List<DictionaryAssignment>> _dictionaryAssignmentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.dictionaryAssignments,
          aliasName: $_aliasNameGenerator(
              db.dictionaries.id, db.dictionaryAssignments.dictionaryId));

  $$DictionaryAssignmentsTableProcessedTableManager
      get dictionaryAssignmentsRefs {
    final manager = $$DictionaryAssignmentsTableTableManager(
            $_db, $_db.dictionaryAssignments)
        .filter((f) => f.dictionaryId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_dictionaryAssignmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WordsTable, List<Word>> _wordsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.words,
          aliasName:
              $_aliasNameGenerator(db.dictionaries.id, db.words.dictionaryId));

  $$WordsTableProcessedTableManager get wordsRefs {
    final manager = $$WordsTableTableManager($_db, $_db.words)
        .filter((f) => f.dictionaryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_wordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.sessions,
          aliasName: $_aliasNameGenerator(
              db.dictionaries.id, db.sessions.dictionaryId));

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.dictionaryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DictionariesTableFilterComposer
    extends Composer<_$AppDatabase, $DictionariesTable> {
  $$DictionariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get couleur => $composableBuilder(
      column: $table.couleur, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> dictionaryAssignmentsRefs(
      Expression<bool> Function($$DictionaryAssignmentsTableFilterComposer f)
          f) {
    final $$DictionaryAssignmentsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.dictionaryAssignments,
            getReferencedColumn: (t) => t.dictionaryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DictionaryAssignmentsTableFilterComposer(
                  $db: $db,
                  $table: $db.dictionaryAssignments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> wordsRefs(
      Expression<bool> Function($$WordsTableFilterComposer f) f) {
    final $$WordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.dictionaryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableFilterComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> sessionsRefs(
      Expression<bool> Function($$SessionsTableFilterComposer f) f) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.dictionaryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DictionariesTableOrderingComposer
    extends Composer<_$AppDatabase, $DictionariesTable> {
  $$DictionariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nom => $composableBuilder(
      column: $table.nom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get couleur => $composableBuilder(
      column: $table.couleur, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DictionariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DictionariesTable> {
  $$DictionariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get couleur =>
      $composableBuilder(column: $table.couleur, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> dictionaryAssignmentsRefs<T extends Object>(
      Expression<T> Function($$DictionaryAssignmentsTableAnnotationComposer a)
          f) {
    final $$DictionaryAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.dictionaryAssignments,
            getReferencedColumn: (t) => t.dictionaryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$DictionaryAssignmentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.dictionaryAssignments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> wordsRefs<T extends Object>(
      Expression<T> Function($$WordsTableAnnotationComposer a) f) {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.dictionaryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableAnnotationComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
      Expression<T> Function($$SessionsTableAnnotationComposer a) f) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.dictionaryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DictionariesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DictionariesTable,
    Dictionary,
    $$DictionariesTableFilterComposer,
    $$DictionariesTableOrderingComposer,
    $$DictionariesTableAnnotationComposer,
    $$DictionariesTableCreateCompanionBuilder,
    $$DictionariesTableUpdateCompanionBuilder,
    (Dictionary, $$DictionariesTableReferences),
    Dictionary,
    PrefetchHooks Function(
        {bool profileId,
        bool dictionaryAssignmentsRefs,
        bool wordsRefs,
        bool sessionsRefs})> {
  $$DictionariesTableTableManager(_$AppDatabase db, $DictionariesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DictionariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DictionariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DictionariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<String> nom = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> couleur = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DictionariesCompanion(
            id: id,
            profileId: profileId,
            nom: nom,
            description: description,
            couleur: couleur,
            icon: icon,
            active: active,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int profileId,
            required String nom,
            Value<String?> description = const Value.absent(),
            Value<String> couleur = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              DictionariesCompanion.insert(
            id: id,
            profileId: profileId,
            nom: nom,
            description: description,
            couleur: couleur,
            icon: icon,
            active: active,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DictionariesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {profileId = false,
              dictionaryAssignmentsRefs = false,
              wordsRefs = false,
              sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (dictionaryAssignmentsRefs) db.dictionaryAssignments,
                if (wordsRefs) db.words,
                if (sessionsRefs) db.sessions
              ],
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
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$DictionariesTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$DictionariesTableReferences._profileIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dictionaryAssignmentsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$DictionariesTableReferences
                            ._dictionaryAssignmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DictionariesTableReferences(db, table, p0)
                                .dictionaryAssignmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.dictionaryId == item.id),
                        typedResults: items),
                  if (wordsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$DictionariesTableReferences._wordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DictionariesTableReferences(db, table, p0)
                                .wordsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.dictionaryId == item.id),
                        typedResults: items),
                  if (sessionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$DictionariesTableReferences
                            ._sessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DictionariesTableReferences(db, table, p0)
                                .sessionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.dictionaryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DictionariesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DictionariesTable,
    Dictionary,
    $$DictionariesTableFilterComposer,
    $$DictionariesTableOrderingComposer,
    $$DictionariesTableAnnotationComposer,
    $$DictionariesTableCreateCompanionBuilder,
    $$DictionariesTableUpdateCompanionBuilder,
    (Dictionary, $$DictionariesTableReferences),
    Dictionary,
    PrefetchHooks Function(
        {bool profileId,
        bool dictionaryAssignmentsRefs,
        bool wordsRefs,
        bool sessionsRefs})>;
typedef $$DictionaryAssignmentsTableCreateCompanionBuilder
    = DictionaryAssignmentsCompanion Function({
  Value<int> id,
  required int dictionaryId,
  required int childId,
  Value<DateTime> assignedAt,
});
typedef $$DictionaryAssignmentsTableUpdateCompanionBuilder
    = DictionaryAssignmentsCompanion Function({
  Value<int> id,
  Value<int> dictionaryId,
  Value<int> childId,
  Value<DateTime> assignedAt,
});

final class $$DictionaryAssignmentsTableReferences extends BaseReferences<
    _$AppDatabase, $DictionaryAssignmentsTable, DictionaryAssignment> {
  $$DictionaryAssignmentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DictionariesTable _dictionaryIdTable(_$AppDatabase db) =>
      db.dictionaries.createAlias($_aliasNameGenerator(
          db.dictionaryAssignments.dictionaryId, db.dictionaries.id));

  $$DictionariesTableProcessedTableManager get dictionaryId {
    final manager = $$DictionariesTableTableManager($_db, $_db.dictionaries)
        .filter((f) => f.id($_item.dictionaryId));
    final item = $_typedResult.readTableOrNull(_dictionaryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProfilesTable _childIdTable(_$AppDatabase db) =>
      db.profiles.createAlias($_aliasNameGenerator(
          db.dictionaryAssignments.childId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get childId {
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id($_item.childId));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DictionaryAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $DictionaryAssignmentsTable> {
  $$DictionaryAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get assignedAt => $composableBuilder(
      column: $table.assignedAt, builder: (column) => ColumnFilters(column));

  $$DictionariesTableFilterComposer get dictionaryId {
    final $$DictionariesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dictionaryId,
        referencedTable: $db.dictionaries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DictionariesTableFilterComposer(
              $db: $db,
              $table: $db.dictionaries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProfilesTableFilterComposer get childId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DictionaryAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DictionaryAssignmentsTable> {
  $$DictionaryAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get assignedAt => $composableBuilder(
      column: $table.assignedAt, builder: (column) => ColumnOrderings(column));

  $$DictionariesTableOrderingComposer get dictionaryId {
    final $$DictionariesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dictionaryId,
        referencedTable: $db.dictionaries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DictionariesTableOrderingComposer(
              $db: $db,
              $table: $db.dictionaries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProfilesTableOrderingComposer get childId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DictionaryAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DictionaryAssignmentsTable> {
  $$DictionaryAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get assignedAt => $composableBuilder(
      column: $table.assignedAt, builder: (column) => column);

  $$DictionariesTableAnnotationComposer get dictionaryId {
    final $$DictionariesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dictionaryId,
        referencedTable: $db.dictionaries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DictionariesTableAnnotationComposer(
              $db: $db,
              $table: $db.dictionaries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProfilesTableAnnotationComposer get childId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.childId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DictionaryAssignmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DictionaryAssignmentsTable,
    DictionaryAssignment,
    $$DictionaryAssignmentsTableFilterComposer,
    $$DictionaryAssignmentsTableOrderingComposer,
    $$DictionaryAssignmentsTableAnnotationComposer,
    $$DictionaryAssignmentsTableCreateCompanionBuilder,
    $$DictionaryAssignmentsTableUpdateCompanionBuilder,
    (DictionaryAssignment, $$DictionaryAssignmentsTableReferences),
    DictionaryAssignment,
    PrefetchHooks Function({bool dictionaryId, bool childId})> {
  $$DictionaryAssignmentsTableTableManager(
      _$AppDatabase db, $DictionaryAssignmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DictionaryAssignmentsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$DictionaryAssignmentsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DictionaryAssignmentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> dictionaryId = const Value.absent(),
            Value<int> childId = const Value.absent(),
            Value<DateTime> assignedAt = const Value.absent(),
          }) =>
              DictionaryAssignmentsCompanion(
            id: id,
            dictionaryId: dictionaryId,
            childId: childId,
            assignedAt: assignedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int dictionaryId,
            required int childId,
            Value<DateTime> assignedAt = const Value.absent(),
          }) =>
              DictionaryAssignmentsCompanion.insert(
            id: id,
            dictionaryId: dictionaryId,
            childId: childId,
            assignedAt: assignedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DictionaryAssignmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({dictionaryId = false, childId = false}) {
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
                if (dictionaryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.dictionaryId,
                    referencedTable: $$DictionaryAssignmentsTableReferences
                        ._dictionaryIdTable(db),
                    referencedColumn: $$DictionaryAssignmentsTableReferences
                        ._dictionaryIdTable(db)
                        .id,
                  ) as T;
                }
                if (childId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.childId,
                    referencedTable: $$DictionaryAssignmentsTableReferences
                        ._childIdTable(db),
                    referencedColumn: $$DictionaryAssignmentsTableReferences
                        ._childIdTable(db)
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

typedef $$DictionaryAssignmentsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $DictionaryAssignmentsTable,
        DictionaryAssignment,
        $$DictionaryAssignmentsTableFilterComposer,
        $$DictionaryAssignmentsTableOrderingComposer,
        $$DictionaryAssignmentsTableAnnotationComposer,
        $$DictionaryAssignmentsTableCreateCompanionBuilder,
        $$DictionaryAssignmentsTableUpdateCompanionBuilder,
        (DictionaryAssignment, $$DictionaryAssignmentsTableReferences),
        DictionaryAssignment,
        PrefetchHooks Function({bool dictionaryId, bool childId})>;
typedef $$WordsTableCreateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  required int dictionaryId,
  required String mot,
  Value<String?> definition,
  Value<String?> defCroises,
  Value<String?> defFleches,
  Value<String?> imagePath,
  Value<String?> audioPath,
  Value<String> tags,
  Value<int> difficulty,
  Value<DateTime> createdAt,
});
typedef $$WordsTableUpdateCompanionBuilder = WordsCompanion Function({
  Value<int> id,
  Value<int> dictionaryId,
  Value<String> mot,
  Value<String?> definition,
  Value<String?> defCroises,
  Value<String?> defFleches,
  Value<String?> imagePath,
  Value<String?> audioPath,
  Value<String> tags,
  Value<int> difficulty,
  Value<DateTime> createdAt,
});

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, Word> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DictionariesTable _dictionaryIdTable(_$AppDatabase db) =>
      db.dictionaries.createAlias(
          $_aliasNameGenerator(db.words.dictionaryId, db.dictionaries.id));

  $$DictionariesTableProcessedTableManager get dictionaryId {
    final manager = $$DictionariesTableTableManager($_db, $_db.dictionaries)
        .filter((f) => f.id($_item.dictionaryId));
    final item = $_typedResult.readTableOrNull(_dictionaryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$WordMasteryTable, List<WordMasteryData>>
      _wordMasteryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.wordMastery,
          aliasName: $_aliasNameGenerator(db.words.id, db.wordMastery.wordId));

  $$WordMasteryTableProcessedTableManager get wordMasteryRefs {
    final manager = $$WordMasteryTableTableManager($_db, $_db.wordMastery)
        .filter((f) => f.wordId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_wordMasteryRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WordAttemptsTable, List<WordAttempt>>
      _wordAttemptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.wordAttempts,
          aliasName: $_aliasNameGenerator(db.words.id, db.wordAttempts.wordId));

  $$WordAttemptsTableProcessedTableManager get wordAttemptsRefs {
    final manager = $$WordAttemptsTableTableManager($_db, $_db.wordAttempts)
        .filter((f) => f.wordId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_wordAttemptsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mot => $composableBuilder(
      column: $table.mot, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get definition => $composableBuilder(
      column: $table.definition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defCroises => $composableBuilder(
      column: $table.defCroises, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defFleches => $composableBuilder(
      column: $table.defFleches, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioPath => $composableBuilder(
      column: $table.audioPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$DictionariesTableFilterComposer get dictionaryId {
    final $$DictionariesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dictionaryId,
        referencedTable: $db.dictionaries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DictionariesTableFilterComposer(
              $db: $db,
              $table: $db.dictionaries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> wordMasteryRefs(
      Expression<bool> Function($$WordMasteryTableFilterComposer f) f) {
    final $$WordMasteryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wordMastery,
        getReferencedColumn: (t) => t.wordId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordMasteryTableFilterComposer(
              $db: $db,
              $table: $db.wordMastery,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> wordAttemptsRefs(
      Expression<bool> Function($$WordAttemptsTableFilterComposer f) f) {
    final $$WordAttemptsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wordAttempts,
        getReferencedColumn: (t) => t.wordId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordAttemptsTableFilterComposer(
              $db: $db,
              $table: $db.wordAttempts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mot => $composableBuilder(
      column: $table.mot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get definition => $composableBuilder(
      column: $table.definition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defCroises => $composableBuilder(
      column: $table.defCroises, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defFleches => $composableBuilder(
      column: $table.defFleches, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioPath => $composableBuilder(
      column: $table.audioPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$DictionariesTableOrderingComposer get dictionaryId {
    final $$DictionariesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dictionaryId,
        referencedTable: $db.dictionaries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DictionariesTableOrderingComposer(
              $db: $db,
              $table: $db.dictionaries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mot =>
      $composableBuilder(column: $table.mot, builder: (column) => column);

  GeneratedColumn<String> get definition => $composableBuilder(
      column: $table.definition, builder: (column) => column);

  GeneratedColumn<String> get defCroises => $composableBuilder(
      column: $table.defCroises, builder: (column) => column);

  GeneratedColumn<String> get defFleches => $composableBuilder(
      column: $table.defFleches, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DictionariesTableAnnotationComposer get dictionaryId {
    final $$DictionariesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dictionaryId,
        referencedTable: $db.dictionaries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DictionariesTableAnnotationComposer(
              $db: $db,
              $table: $db.dictionaries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> wordMasteryRefs<T extends Object>(
      Expression<T> Function($$WordMasteryTableAnnotationComposer a) f) {
    final $$WordMasteryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wordMastery,
        getReferencedColumn: (t) => t.wordId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordMasteryTableAnnotationComposer(
              $db: $db,
              $table: $db.wordMastery,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> wordAttemptsRefs<T extends Object>(
      Expression<T> Function($$WordAttemptsTableAnnotationComposer a) f) {
    final $$WordAttemptsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wordAttempts,
        getReferencedColumn: (t) => t.wordId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordAttemptsTableAnnotationComposer(
              $db: $db,
              $table: $db.wordAttempts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WordsTable,
    Word,
    $$WordsTableFilterComposer,
    $$WordsTableOrderingComposer,
    $$WordsTableAnnotationComposer,
    $$WordsTableCreateCompanionBuilder,
    $$WordsTableUpdateCompanionBuilder,
    (Word, $$WordsTableReferences),
    Word,
    PrefetchHooks Function(
        {bool dictionaryId, bool wordMasteryRefs, bool wordAttemptsRefs})> {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> dictionaryId = const Value.absent(),
            Value<String> mot = const Value.absent(),
            Value<String?> definition = const Value.absent(),
            Value<String?> defCroises = const Value.absent(),
            Value<String?> defFleches = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> audioPath = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<int> difficulty = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              WordsCompanion(
            id: id,
            dictionaryId: dictionaryId,
            mot: mot,
            definition: definition,
            defCroises: defCroises,
            defFleches: defFleches,
            imagePath: imagePath,
            audioPath: audioPath,
            tags: tags,
            difficulty: difficulty,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int dictionaryId,
            required String mot,
            Value<String?> definition = const Value.absent(),
            Value<String?> defCroises = const Value.absent(),
            Value<String?> defFleches = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String?> audioPath = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<int> difficulty = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              WordsCompanion.insert(
            id: id,
            dictionaryId: dictionaryId,
            mot: mot,
            definition: definition,
            defCroises: defCroises,
            defFleches: defFleches,
            imagePath: imagePath,
            audioPath: audioPath,
            tags: tags,
            difficulty: difficulty,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$WordsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {dictionaryId = false,
              wordMasteryRefs = false,
              wordAttemptsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (wordMasteryRefs) db.wordMastery,
                if (wordAttemptsRefs) db.wordAttempts
              ],
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
                if (dictionaryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.dictionaryId,
                    referencedTable:
                        $$WordsTableReferences._dictionaryIdTable(db),
                    referencedColumn:
                        $$WordsTableReferences._dictionaryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (wordMasteryRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$WordsTableReferences._wordMasteryRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WordsTableReferences(db, table, p0)
                                .wordMasteryRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.wordId == item.id),
                        typedResults: items),
                  if (wordAttemptsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$WordsTableReferences._wordAttemptsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WordsTableReferences(db, table, p0)
                                .wordAttemptsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.wordId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WordsTable,
    Word,
    $$WordsTableFilterComposer,
    $$WordsTableOrderingComposer,
    $$WordsTableAnnotationComposer,
    $$WordsTableCreateCompanionBuilder,
    $$WordsTableUpdateCompanionBuilder,
    (Word, $$WordsTableReferences),
    Word,
    PrefetchHooks Function(
        {bool dictionaryId, bool wordMasteryRefs, bool wordAttemptsRefs})>;
typedef $$WordMasteryTableCreateCompanionBuilder = WordMasteryCompanion
    Function({
  Value<int> id,
  required int profileId,
  required int wordId,
  Value<int> nbSeen,
  Value<int> nbSuccess,
  Value<int> nbFirstTry,
  Value<int> consecutiveOk,
  Value<int> leitnerBox,
  Value<DateTime?> nextReview,
  Value<DateTime?> lastSeen,
  Value<int> masteryLevel,
});
typedef $$WordMasteryTableUpdateCompanionBuilder = WordMasteryCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  Value<int> wordId,
  Value<int> nbSeen,
  Value<int> nbSuccess,
  Value<int> nbFirstTry,
  Value<int> consecutiveOk,
  Value<int> leitnerBox,
  Value<DateTime?> nextReview,
  Value<DateTime?> lastSeen,
  Value<int> masteryLevel,
});

final class $$WordMasteryTableReferences
    extends BaseReferences<_$AppDatabase, $WordMasteryTable, WordMasteryData> {
  $$WordMasteryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.wordMastery.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get profileId {
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id($_item.profileId));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) => db.words
      .createAlias($_aliasNameGenerator(db.wordMastery.wordId, db.words.id));

  $$WordsTableProcessedTableManager get wordId {
    final manager = $$WordsTableTableManager($_db, $_db.words)
        .filter((f) => f.id($_item.wordId));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WordMasteryTableFilterComposer
    extends Composer<_$AppDatabase, $WordMasteryTable> {
  $$WordMasteryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nbSeen => $composableBuilder(
      column: $table.nbSeen, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nbSuccess => $composableBuilder(
      column: $table.nbSuccess, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nbFirstTry => $composableBuilder(
      column: $table.nbFirstTry, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get consecutiveOk => $composableBuilder(
      column: $table.consecutiveOk, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get leitnerBox => $composableBuilder(
      column: $table.leitnerBox, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextReview => $composableBuilder(
      column: $table.nextReview, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSeen => $composableBuilder(
      column: $table.lastSeen, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get masteryLevel => $composableBuilder(
      column: $table.masteryLevel, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableFilterComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordMasteryTableOrderingComposer
    extends Composer<_$AppDatabase, $WordMasteryTable> {
  $$WordMasteryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nbSeen => $composableBuilder(
      column: $table.nbSeen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nbSuccess => $composableBuilder(
      column: $table.nbSuccess, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nbFirstTry => $composableBuilder(
      column: $table.nbFirstTry, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get consecutiveOk => $composableBuilder(
      column: $table.consecutiveOk,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get leitnerBox => $composableBuilder(
      column: $table.leitnerBox, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextReview => $composableBuilder(
      column: $table.nextReview, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSeen => $composableBuilder(
      column: $table.lastSeen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get masteryLevel => $composableBuilder(
      column: $table.masteryLevel,
      builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableOrderingComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordMasteryTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordMasteryTable> {
  $$WordMasteryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get nbSeen =>
      $composableBuilder(column: $table.nbSeen, builder: (column) => column);

  GeneratedColumn<int> get nbSuccess =>
      $composableBuilder(column: $table.nbSuccess, builder: (column) => column);

  GeneratedColumn<int> get nbFirstTry => $composableBuilder(
      column: $table.nbFirstTry, builder: (column) => column);

  GeneratedColumn<int> get consecutiveOk => $composableBuilder(
      column: $table.consecutiveOk, builder: (column) => column);

  GeneratedColumn<int> get leitnerBox => $composableBuilder(
      column: $table.leitnerBox, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReview => $composableBuilder(
      column: $table.nextReview, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<int> get masteryLevel => $composableBuilder(
      column: $table.masteryLevel, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableAnnotationComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordMasteryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WordMasteryTable,
    WordMasteryData,
    $$WordMasteryTableFilterComposer,
    $$WordMasteryTableOrderingComposer,
    $$WordMasteryTableAnnotationComposer,
    $$WordMasteryTableCreateCompanionBuilder,
    $$WordMasteryTableUpdateCompanionBuilder,
    (WordMasteryData, $$WordMasteryTableReferences),
    WordMasteryData,
    PrefetchHooks Function({bool profileId, bool wordId})> {
  $$WordMasteryTableTableManager(_$AppDatabase db, $WordMasteryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordMasteryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordMasteryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordMasteryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<int> wordId = const Value.absent(),
            Value<int> nbSeen = const Value.absent(),
            Value<int> nbSuccess = const Value.absent(),
            Value<int> nbFirstTry = const Value.absent(),
            Value<int> consecutiveOk = const Value.absent(),
            Value<int> leitnerBox = const Value.absent(),
            Value<DateTime?> nextReview = const Value.absent(),
            Value<DateTime?> lastSeen = const Value.absent(),
            Value<int> masteryLevel = const Value.absent(),
          }) =>
              WordMasteryCompanion(
            id: id,
            profileId: profileId,
            wordId: wordId,
            nbSeen: nbSeen,
            nbSuccess: nbSuccess,
            nbFirstTry: nbFirstTry,
            consecutiveOk: consecutiveOk,
            leitnerBox: leitnerBox,
            nextReview: nextReview,
            lastSeen: lastSeen,
            masteryLevel: masteryLevel,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int profileId,
            required int wordId,
            Value<int> nbSeen = const Value.absent(),
            Value<int> nbSuccess = const Value.absent(),
            Value<int> nbFirstTry = const Value.absent(),
            Value<int> consecutiveOk = const Value.absent(),
            Value<int> leitnerBox = const Value.absent(),
            Value<DateTime?> nextReview = const Value.absent(),
            Value<DateTime?> lastSeen = const Value.absent(),
            Value<int> masteryLevel = const Value.absent(),
          }) =>
              WordMasteryCompanion.insert(
            id: id,
            profileId: profileId,
            wordId: wordId,
            nbSeen: nbSeen,
            nbSuccess: nbSuccess,
            nbFirstTry: nbFirstTry,
            consecutiveOk: consecutiveOk,
            leitnerBox: leitnerBox,
            nextReview: nextReview,
            lastSeen: lastSeen,
            masteryLevel: masteryLevel,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WordMasteryTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false, wordId = false}) {
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
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$WordMasteryTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$WordMasteryTableReferences._profileIdTable(db).id,
                  ) as T;
                }
                if (wordId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.wordId,
                    referencedTable:
                        $$WordMasteryTableReferences._wordIdTable(db),
                    referencedColumn:
                        $$WordMasteryTableReferences._wordIdTable(db).id,
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

typedef $$WordMasteryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WordMasteryTable,
    WordMasteryData,
    $$WordMasteryTableFilterComposer,
    $$WordMasteryTableOrderingComposer,
    $$WordMasteryTableAnnotationComposer,
    $$WordMasteryTableCreateCompanionBuilder,
    $$WordMasteryTableUpdateCompanionBuilder,
    (WordMasteryData, $$WordMasteryTableReferences),
    WordMasteryData,
    PrefetchHooks Function({bool profileId, bool wordId})>;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required int profileId,
  required int dictionaryId,
  required String activityType,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int> score,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<int> profileId,
  Value<int> dictionaryId,
  Value<String> activityType,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int> score,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) => db.profiles
      .createAlias($_aliasNameGenerator(db.sessions.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get profileId {
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id($_item.profileId));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $DictionariesTable _dictionaryIdTable(_$AppDatabase db) =>
      db.dictionaries.createAlias(
          $_aliasNameGenerator(db.sessions.dictionaryId, db.dictionaries.id));

  $$DictionariesTableProcessedTableManager get dictionaryId {
    final manager = $$DictionariesTableTableManager($_db, $_db.dictionaries)
        .filter((f) => f.id($_item.dictionaryId));
    final item = $_typedResult.readTableOrNull(_dictionaryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$WordAttemptsTable, List<WordAttempt>>
      _wordAttemptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.wordAttempts,
          aliasName:
              $_aliasNameGenerator(db.sessions.id, db.wordAttempts.sessionId));

  $$WordAttemptsTableProcessedTableManager get wordAttemptsRefs {
    final manager = $$WordAttemptsTableTableManager($_db, $_db.wordAttempts)
        .filter((f) => f.sessionId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_wordAttemptsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityType => $composableBuilder(
      column: $table.activityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DictionariesTableFilterComposer get dictionaryId {
    final $$DictionariesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dictionaryId,
        referencedTable: $db.dictionaries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DictionariesTableFilterComposer(
              $db: $db,
              $table: $db.dictionaries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> wordAttemptsRefs(
      Expression<bool> Function($$WordAttemptsTableFilterComposer f) f) {
    final $$WordAttemptsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wordAttempts,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordAttemptsTableFilterComposer(
              $db: $db,
              $table: $db.wordAttempts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityType => $composableBuilder(
      column: $table.activityType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DictionariesTableOrderingComposer get dictionaryId {
    final $$DictionariesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dictionaryId,
        referencedTable: $db.dictionaries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DictionariesTableOrderingComposer(
              $db: $db,
              $table: $db.dictionaries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activityType => $composableBuilder(
      column: $table.activityType, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$DictionariesTableAnnotationComposer get dictionaryId {
    final $$DictionariesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dictionaryId,
        referencedTable: $db.dictionaries,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DictionariesTableAnnotationComposer(
              $db: $db,
              $table: $db.dictionaries,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> wordAttemptsRefs<T extends Object>(
      Expression<T> Function($$WordAttemptsTableAnnotationComposer a) f) {
    final $$WordAttemptsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.wordAttempts,
        getReferencedColumn: (t) => t.sessionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordAttemptsTableAnnotationComposer(
              $db: $db,
              $table: $db.wordAttempts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, $$SessionsTableReferences),
    Session,
    PrefetchHooks Function(
        {bool profileId, bool dictionaryId, bool wordAttemptsRefs})> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<int> dictionaryId = const Value.absent(),
            Value<String> activityType = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> score = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            profileId: profileId,
            dictionaryId: dictionaryId,
            activityType: activityType,
            startedAt: startedAt,
            endedAt: endedAt,
            score: score,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int profileId,
            required int dictionaryId,
            required String activityType,
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> score = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            profileId: profileId,
            dictionaryId: dictionaryId,
            activityType: activityType,
            startedAt: startedAt,
            endedAt: endedAt,
            score: score,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SessionsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {profileId = false,
              dictionaryId = false,
              wordAttemptsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (wordAttemptsRefs) db.wordAttempts],
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
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$SessionsTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$SessionsTableReferences._profileIdTable(db).id,
                  ) as T;
                }
                if (dictionaryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.dictionaryId,
                    referencedTable:
                        $$SessionsTableReferences._dictionaryIdTable(db),
                    referencedColumn:
                        $$SessionsTableReferences._dictionaryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (wordAttemptsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$SessionsTableReferences
                            ._wordAttemptsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SessionsTableReferences(db, table, p0)
                                .wordAttemptsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.sessionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, $$SessionsTableReferences),
    Session,
    PrefetchHooks Function(
        {bool profileId, bool dictionaryId, bool wordAttemptsRefs})>;
typedef $$WordAttemptsTableCreateCompanionBuilder = WordAttemptsCompanion
    Function({
  Value<int> id,
  required int sessionId,
  required int wordId,
  Value<bool> success,
  Value<bool> firstTry,
  Value<bool> hintUsed,
  Value<int> durationMs,
  Value<String> errorLetters,
});
typedef $$WordAttemptsTableUpdateCompanionBuilder = WordAttemptsCompanion
    Function({
  Value<int> id,
  Value<int> sessionId,
  Value<int> wordId,
  Value<bool> success,
  Value<bool> firstTry,
  Value<bool> hintUsed,
  Value<int> durationMs,
  Value<String> errorLetters,
});

final class $$WordAttemptsTableReferences
    extends BaseReferences<_$AppDatabase, $WordAttemptsTable, WordAttempt> {
  $$WordAttemptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias(
          $_aliasNameGenerator(db.wordAttempts.sessionId, db.sessions.id));

  $$SessionsTableProcessedTableManager get sessionId {
    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.id($_item.sessionId));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) => db.words
      .createAlias($_aliasNameGenerator(db.wordAttempts.wordId, db.words.id));

  $$WordsTableProcessedTableManager get wordId {
    final manager = $$WordsTableTableManager($_db, $_db.words)
        .filter((f) => f.id($_item.wordId));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WordAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $WordAttemptsTable> {
  $$WordAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get success => $composableBuilder(
      column: $table.success, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get firstTry => $composableBuilder(
      column: $table.firstTry, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hintUsed => $composableBuilder(
      column: $table.hintUsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorLetters => $composableBuilder(
      column: $table.errorLetters, builder: (column) => ColumnFilters(column));

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableFilterComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordAttemptsTable> {
  $$WordAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get success => $composableBuilder(
      column: $table.success, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get firstTry => $composableBuilder(
      column: $table.firstTry, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hintUsed => $composableBuilder(
      column: $table.hintUsed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorLetters => $composableBuilder(
      column: $table.errorLetters,
      builder: (column) => ColumnOrderings(column));

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableOrderingComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableOrderingComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordAttemptsTable> {
  $$WordAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<bool> get firstTry =>
      $composableBuilder(column: $table.firstTry, builder: (column) => column);

  GeneratedColumn<bool> get hintUsed =>
      $composableBuilder(column: $table.hintUsed, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<String> get errorLetters => $composableBuilder(
      column: $table.errorLetters, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sessionId,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.wordId,
        referencedTable: $db.words,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WordsTableAnnotationComposer(
              $db: $db,
              $table: $db.words,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WordAttemptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WordAttemptsTable,
    WordAttempt,
    $$WordAttemptsTableFilterComposer,
    $$WordAttemptsTableOrderingComposer,
    $$WordAttemptsTableAnnotationComposer,
    $$WordAttemptsTableCreateCompanionBuilder,
    $$WordAttemptsTableUpdateCompanionBuilder,
    (WordAttempt, $$WordAttemptsTableReferences),
    WordAttempt,
    PrefetchHooks Function({bool sessionId, bool wordId})> {
  $$WordAttemptsTableTableManager(_$AppDatabase db, $WordAttemptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
            Value<int> wordId = const Value.absent(),
            Value<bool> success = const Value.absent(),
            Value<bool> firstTry = const Value.absent(),
            Value<bool> hintUsed = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<String> errorLetters = const Value.absent(),
          }) =>
              WordAttemptsCompanion(
            id: id,
            sessionId: sessionId,
            wordId: wordId,
            success: success,
            firstTry: firstTry,
            hintUsed: hintUsed,
            durationMs: durationMs,
            errorLetters: errorLetters,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int sessionId,
            required int wordId,
            Value<bool> success = const Value.absent(),
            Value<bool> firstTry = const Value.absent(),
            Value<bool> hintUsed = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<String> errorLetters = const Value.absent(),
          }) =>
              WordAttemptsCompanion.insert(
            id: id,
            sessionId: sessionId,
            wordId: wordId,
            success: success,
            firstTry: firstTry,
            hintUsed: hintUsed,
            durationMs: durationMs,
            errorLetters: errorLetters,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WordAttemptsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({sessionId = false, wordId = false}) {
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
                if (sessionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sessionId,
                    referencedTable:
                        $$WordAttemptsTableReferences._sessionIdTable(db),
                    referencedColumn:
                        $$WordAttemptsTableReferences._sessionIdTable(db).id,
                  ) as T;
                }
                if (wordId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.wordId,
                    referencedTable:
                        $$WordAttemptsTableReferences._wordIdTable(db),
                    referencedColumn:
                        $$WordAttemptsTableReferences._wordIdTable(db).id,
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

typedef $$WordAttemptsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WordAttemptsTable,
    WordAttempt,
    $$WordAttemptsTableFilterComposer,
    $$WordAttemptsTableOrderingComposer,
    $$WordAttemptsTableAnnotationComposer,
    $$WordAttemptsTableCreateCompanionBuilder,
    $$WordAttemptsTableUpdateCompanionBuilder,
    (WordAttempt, $$WordAttemptsTableReferences),
    WordAttempt,
    PrefetchHooks Function({bool sessionId, bool wordId})>;
typedef $$DailyStatsTableCreateCompanionBuilder = DailyStatsCompanion Function({
  Value<int> id,
  required int profileId,
  required DateTime date,
  Value<int> wordsSeen,
  Value<int> wordsSuccess,
  Value<int> minutesPlayed,
});
typedef $$DailyStatsTableUpdateCompanionBuilder = DailyStatsCompanion Function({
  Value<int> id,
  Value<int> profileId,
  Value<DateTime> date,
  Value<int> wordsSeen,
  Value<int> wordsSuccess,
  Value<int> minutesPlayed,
});

final class $$DailyStatsTableReferences
    extends BaseReferences<_$AppDatabase, $DailyStatsTable, DailyStat> {
  $$DailyStatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.dailyStats.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get profileId {
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id($_item.profileId));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DailyStatsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wordsSeen => $composableBuilder(
      column: $table.wordsSeen, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wordsSuccess => $composableBuilder(
      column: $table.wordsSuccess, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minutesPlayed => $composableBuilder(
      column: $table.minutesPlayed, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DailyStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wordsSeen => $composableBuilder(
      column: $table.wordsSeen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wordsSuccess => $composableBuilder(
      column: $table.wordsSuccess,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minutesPlayed => $composableBuilder(
      column: $table.minutesPlayed,
      builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DailyStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get wordsSeen =>
      $composableBuilder(column: $table.wordsSeen, builder: (column) => column);

  GeneratedColumn<int> get wordsSuccess => $composableBuilder(
      column: $table.wordsSuccess, builder: (column) => column);

  GeneratedColumn<int> get minutesPlayed => $composableBuilder(
      column: $table.minutesPlayed, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DailyStatsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyStatsTable,
    DailyStat,
    $$DailyStatsTableFilterComposer,
    $$DailyStatsTableOrderingComposer,
    $$DailyStatsTableAnnotationComposer,
    $$DailyStatsTableCreateCompanionBuilder,
    $$DailyStatsTableUpdateCompanionBuilder,
    (DailyStat, $$DailyStatsTableReferences),
    DailyStat,
    PrefetchHooks Function({bool profileId})> {
  $$DailyStatsTableTableManager(_$AppDatabase db, $DailyStatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> wordsSeen = const Value.absent(),
            Value<int> wordsSuccess = const Value.absent(),
            Value<int> minutesPlayed = const Value.absent(),
          }) =>
              DailyStatsCompanion(
            id: id,
            profileId: profileId,
            date: date,
            wordsSeen: wordsSeen,
            wordsSuccess: wordsSuccess,
            minutesPlayed: minutesPlayed,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int profileId,
            required DateTime date,
            Value<int> wordsSeen = const Value.absent(),
            Value<int> wordsSuccess = const Value.absent(),
            Value<int> minutesPlayed = const Value.absent(),
          }) =>
              DailyStatsCompanion.insert(
            id: id,
            profileId: profileId,
            date: date,
            wordsSeen: wordsSeen,
            wordsSuccess: wordsSuccess,
            minutesPlayed: minutesPlayed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DailyStatsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$DailyStatsTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$DailyStatsTableReferences._profileIdTable(db).id,
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

typedef $$DailyStatsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyStatsTable,
    DailyStat,
    $$DailyStatsTableFilterComposer,
    $$DailyStatsTableOrderingComposer,
    $$DailyStatsTableAnnotationComposer,
    $$DailyStatsTableCreateCompanionBuilder,
    $$DailyStatsTableUpdateCompanionBuilder,
    (DailyStat, $$DailyStatsTableReferences),
    DailyStat,
    PrefetchHooks Function({bool profileId})>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<int> id,
  required int profileId,
  Value<String> themeName,
  Value<String> childThemeName,
  Value<double> fontSize,
  Value<bool> ttsEnabled,
  Value<double> ttsRate,
  Value<double> ttsVolume,
  Value<bool> soundEnabled,
  Value<int> sessionDurationLimitMin,
  Value<bool> onboardingDone,
  Value<bool> dyslexicFont,
  Value<bool> highContrast,
  Value<String> colorBlindMode,
  Value<bool> reduceAnimations,
  Value<String> largeTargets,
  Value<bool> hapticFeedback,
  Value<bool> textSpacing,
  Value<bool> showCaptions,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<int> id,
  Value<int> profileId,
  Value<String> themeName,
  Value<String> childThemeName,
  Value<double> fontSize,
  Value<bool> ttsEnabled,
  Value<double> ttsRate,
  Value<double> ttsVolume,
  Value<bool> soundEnabled,
  Value<int> sessionDurationLimitMin,
  Value<bool> onboardingDone,
  Value<bool> dyslexicFont,
  Value<bool> highContrast,
  Value<String> colorBlindMode,
  Value<bool> reduceAnimations,
  Value<String> largeTargets,
  Value<bool> hapticFeedback,
  Value<bool> textSpacing,
  Value<bool> showCaptions,
});

final class $$AppSettingsTableReferences
    extends BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting> {
  $$AppSettingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.appSettings.profileId, db.profiles.id));

  $$ProfilesTableProcessedTableManager get profileId {
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.id($_item.profileId));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeName => $composableBuilder(
      column: $table.themeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get childThemeName => $composableBuilder(
      column: $table.childThemeName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fontSize => $composableBuilder(
      column: $table.fontSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get ttsEnabled => $composableBuilder(
      column: $table.ttsEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get ttsRate => $composableBuilder(
      column: $table.ttsRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get ttsVolume => $composableBuilder(
      column: $table.ttsVolume, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get soundEnabled => $composableBuilder(
      column: $table.soundEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionDurationLimitMin => $composableBuilder(
      column: $table.sessionDurationLimitMin,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onboardingDone => $composableBuilder(
      column: $table.onboardingDone,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dyslexicFont => $composableBuilder(
      column: $table.dyslexicFont, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get highContrast => $composableBuilder(
      column: $table.highContrast, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorBlindMode => $composableBuilder(
      column: $table.colorBlindMode,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get reduceAnimations => $composableBuilder(
      column: $table.reduceAnimations,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get largeTargets => $composableBuilder(
      column: $table.largeTargets, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hapticFeedback => $composableBuilder(
      column: $table.hapticFeedback,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get textSpacing => $composableBuilder(
      column: $table.textSpacing, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showCaptions => $composableBuilder(
      column: $table.showCaptions, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeName => $composableBuilder(
      column: $table.themeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get childThemeName => $composableBuilder(
      column: $table.childThemeName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fontSize => $composableBuilder(
      column: $table.fontSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get ttsEnabled => $composableBuilder(
      column: $table.ttsEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get ttsRate => $composableBuilder(
      column: $table.ttsRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get ttsVolume => $composableBuilder(
      column: $table.ttsVolume, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get soundEnabled => $composableBuilder(
      column: $table.soundEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionDurationLimitMin => $composableBuilder(
      column: $table.sessionDurationLimitMin,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onboardingDone => $composableBuilder(
      column: $table.onboardingDone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dyslexicFont => $composableBuilder(
      column: $table.dyslexicFont,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get highContrast => $composableBuilder(
      column: $table.highContrast,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorBlindMode => $composableBuilder(
      column: $table.colorBlindMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get reduceAnimations => $composableBuilder(
      column: $table.reduceAnimations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get largeTargets => $composableBuilder(
      column: $table.largeTargets,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hapticFeedback => $composableBuilder(
      column: $table.hapticFeedback,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get textSpacing => $composableBuilder(
      column: $table.textSpacing, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showCaptions => $composableBuilder(
      column: $table.showCaptions,
      builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeName =>
      $composableBuilder(column: $table.themeName, builder: (column) => column);

  GeneratedColumn<String> get childThemeName => $composableBuilder(
      column: $table.childThemeName, builder: (column) => column);

  GeneratedColumn<double> get fontSize =>
      $composableBuilder(column: $table.fontSize, builder: (column) => column);

  GeneratedColumn<bool> get ttsEnabled => $composableBuilder(
      column: $table.ttsEnabled, builder: (column) => column);

  GeneratedColumn<double> get ttsRate =>
      $composableBuilder(column: $table.ttsRate, builder: (column) => column);

  GeneratedColumn<double> get ttsVolume =>
      $composableBuilder(column: $table.ttsVolume, builder: (column) => column);

  GeneratedColumn<bool> get soundEnabled => $composableBuilder(
      column: $table.soundEnabled, builder: (column) => column);

  GeneratedColumn<int> get sessionDurationLimitMin => $composableBuilder(
      column: $table.sessionDurationLimitMin, builder: (column) => column);

  GeneratedColumn<bool> get onboardingDone => $composableBuilder(
      column: $table.onboardingDone, builder: (column) => column);

  GeneratedColumn<bool> get dyslexicFont => $composableBuilder(
      column: $table.dyslexicFont, builder: (column) => column);

  GeneratedColumn<bool> get highContrast => $composableBuilder(
      column: $table.highContrast, builder: (column) => column);

  GeneratedColumn<String> get colorBlindMode => $composableBuilder(
      column: $table.colorBlindMode, builder: (column) => column);

  GeneratedColumn<bool> get reduceAnimations => $composableBuilder(
      column: $table.reduceAnimations, builder: (column) => column);

  GeneratedColumn<String> get largeTargets => $composableBuilder(
      column: $table.largeTargets, builder: (column) => column);

  GeneratedColumn<bool> get hapticFeedback => $composableBuilder(
      column: $table.hapticFeedback, builder: (column) => column);

  GeneratedColumn<bool> get textSpacing => $composableBuilder(
      column: $table.textSpacing, builder: (column) => column);

  GeneratedColumn<bool> get showCaptions => $composableBuilder(
      column: $table.showCaptions, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, $$AppSettingsTableReferences),
    AppSetting,
    PrefetchHooks Function({bool profileId})> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> profileId = const Value.absent(),
            Value<String> themeName = const Value.absent(),
            Value<String> childThemeName = const Value.absent(),
            Value<double> fontSize = const Value.absent(),
            Value<bool> ttsEnabled = const Value.absent(),
            Value<double> ttsRate = const Value.absent(),
            Value<double> ttsVolume = const Value.absent(),
            Value<bool> soundEnabled = const Value.absent(),
            Value<int> sessionDurationLimitMin = const Value.absent(),
            Value<bool> onboardingDone = const Value.absent(),
            Value<bool> dyslexicFont = const Value.absent(),
            Value<bool> highContrast = const Value.absent(),
            Value<String> colorBlindMode = const Value.absent(),
            Value<bool> reduceAnimations = const Value.absent(),
            Value<String> largeTargets = const Value.absent(),
            Value<bool> hapticFeedback = const Value.absent(),
            Value<bool> textSpacing = const Value.absent(),
            Value<bool> showCaptions = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            id: id,
            profileId: profileId,
            themeName: themeName,
            childThemeName: childThemeName,
            fontSize: fontSize,
            ttsEnabled: ttsEnabled,
            ttsRate: ttsRate,
            ttsVolume: ttsVolume,
            soundEnabled: soundEnabled,
            sessionDurationLimitMin: sessionDurationLimitMin,
            onboardingDone: onboardingDone,
            dyslexicFont: dyslexicFont,
            highContrast: highContrast,
            colorBlindMode: colorBlindMode,
            reduceAnimations: reduceAnimations,
            largeTargets: largeTargets,
            hapticFeedback: hapticFeedback,
            textSpacing: textSpacing,
            showCaptions: showCaptions,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int profileId,
            Value<String> themeName = const Value.absent(),
            Value<String> childThemeName = const Value.absent(),
            Value<double> fontSize = const Value.absent(),
            Value<bool> ttsEnabled = const Value.absent(),
            Value<double> ttsRate = const Value.absent(),
            Value<double> ttsVolume = const Value.absent(),
            Value<bool> soundEnabled = const Value.absent(),
            Value<int> sessionDurationLimitMin = const Value.absent(),
            Value<bool> onboardingDone = const Value.absent(),
            Value<bool> dyslexicFont = const Value.absent(),
            Value<bool> highContrast = const Value.absent(),
            Value<String> colorBlindMode = const Value.absent(),
            Value<bool> reduceAnimations = const Value.absent(),
            Value<String> largeTargets = const Value.absent(),
            Value<bool> hapticFeedback = const Value.absent(),
            Value<bool> textSpacing = const Value.absent(),
            Value<bool> showCaptions = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            id: id,
            profileId: profileId,
            themeName: themeName,
            childThemeName: childThemeName,
            fontSize: fontSize,
            ttsEnabled: ttsEnabled,
            ttsRate: ttsRate,
            ttsVolume: ttsVolume,
            soundEnabled: soundEnabled,
            sessionDurationLimitMin: sessionDurationLimitMin,
            onboardingDone: onboardingDone,
            dyslexicFont: dyslexicFont,
            highContrast: highContrast,
            colorBlindMode: colorBlindMode,
            reduceAnimations: reduceAnimations,
            largeTargets: largeTargets,
            hapticFeedback: hapticFeedback,
            textSpacing: textSpacing,
            showCaptions: showCaptions,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AppSettingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$AppSettingsTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$AppSettingsTableReferences._profileIdTable(db).id,
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

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, $$AppSettingsTableReferences),
    AppSetting,
    PrefetchHooks Function({bool profileId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$DictionariesTableTableManager get dictionaries =>
      $$DictionariesTableTableManager(_db, _db.dictionaries);
  $$DictionaryAssignmentsTableTableManager get dictionaryAssignments =>
      $$DictionaryAssignmentsTableTableManager(_db, _db.dictionaryAssignments);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$WordMasteryTableTableManager get wordMastery =>
      $$WordMasteryTableTableManager(_db, _db.wordMastery);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$WordAttemptsTableTableManager get wordAttempts =>
      $$WordAttemptsTableTableManager(_db, _db.wordAttempts);
  $$DailyStatsTableTableManager get dailyStats =>
      $$DailyStatsTableTableManager(_db, _db.dailyStats);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
