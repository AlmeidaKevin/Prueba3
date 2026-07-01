// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$VacunacionesDaoMixin on DatabaseAccessor<AppDatabase> {
  $VacunacionesLocalTable get vacunacionesLocal =>
      attachedDatabase.vacunacionesLocal;
}
mixin _$SyncQueueDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncQueueTable get syncQueue => attachedDatabase.syncQueue;
}

class $VacunacionesLocalTable extends VacunacionesLocal
    with TableInfo<$VacunacionesLocalTable, VacunacionesLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VacunacionesLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vacunadorIdMeta = const VerificationMeta(
    'vacunadorId',
  );
  @override
  late final GeneratedColumn<String> vacunadorId = GeneratedColumn<String>(
    'vacunador_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectorIdMeta = const VerificationMeta(
    'sectorId',
  );
  @override
  late final GeneratedColumn<String> sectorId = GeneratedColumn<String>(
    'sector_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _propietarioNombreMeta = const VerificationMeta(
    'propietarioNombre',
  );
  @override
  late final GeneratedColumn<String> propietarioNombre =
      GeneratedColumn<String>(
        'propietario_nombre',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _propietarioCedulaMeta = const VerificationMeta(
    'propietarioCedula',
  );
  @override
  late final GeneratedColumn<String> propietarioCedula =
      GeneratedColumn<String>(
        'propietario_cedula',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _propietarioTelefonoMeta =
      const VerificationMeta('propietarioTelefono');
  @override
  late final GeneratedColumn<String> propietarioTelefono =
      GeneratedColumn<String>(
        'propietario_telefono',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tipoMascotaMeta = const VerificationMeta(
    'tipoMascota',
  );
  @override
  late final GeneratedColumn<String> tipoMascota = GeneratedColumn<String>(
    'tipo_mascota',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mascotaNombreMeta = const VerificationMeta(
    'mascotaNombre',
  );
  @override
  late final GeneratedColumn<String> mascotaNombre = GeneratedColumn<String>(
    'mascota_nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mascotaEdadAproxMeta = const VerificationMeta(
    'mascotaEdadAprox',
  );
  @override
  late final GeneratedColumn<String> mascotaEdadAprox = GeneratedColumn<String>(
    'mascota_edad_aprox',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mascotaSexoMeta = const VerificationMeta(
    'mascotaSexo',
  );
  @override
  late final GeneratedColumn<String> mascotaSexo = GeneratedColumn<String>(
    'mascota_sexo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vacunaAplicadaMeta = const VerificationMeta(
    'vacunaAplicada',
  );
  @override
  late final GeneratedColumn<String> vacunaAplicada = GeneratedColumn<String>(
    'vacuna_aplicada',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoUrlMeta = const VerificationMeta(
    'fotoUrl',
  );
  @override
  late final GeneratedColumn<String> fotoUrl = GeneratedColumn<String>(
    'foto_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoLocalPathMeta = const VerificationMeta(
    'fotoLocalPath',
  );
  @override
  late final GeneratedColumn<String> fotoLocalPath = GeneratedColumn<String>(
    'foto_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudMeta = const VerificationMeta(
    'latitud',
  );
  @override
  late final GeneratedColumn<double> latitud = GeneratedColumn<double>(
    'latitud',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudMeta = const VerificationMeta(
    'longitud',
  );
  @override
  late final GeneratedColumn<double> longitud = GeneratedColumn<double>(
    'longitud',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaVacunacionMeta = const VerificationMeta(
    'fechaVacunacion',
  );
  @override
  late final GeneratedColumn<DateTime> fechaVacunacion =
      GeneratedColumn<DateTime>(
        'fecha_vacunacion',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sincronizadoMeta = const VerificationMeta(
    'sincronizado',
  );
  @override
  late final GeneratedColumn<bool> sincronizado = GeneratedColumn<bool>(
    'sincronizado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sincronizado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vacunadorId,
    sectorId,
    propietarioNombre,
    propietarioCedula,
    propietarioTelefono,
    tipoMascota,
    mascotaNombre,
    mascotaEdadAprox,
    mascotaSexo,
    vacunaAplicada,
    observaciones,
    fotoUrl,
    fotoLocalPath,
    latitud,
    longitud,
    fechaVacunacion,
    sincronizado,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vacunaciones_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<VacunacionesLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vacunador_id')) {
      context.handle(
        _vacunadorIdMeta,
        vacunadorId.isAcceptableOrUnknown(
          data['vacunador_id']!,
          _vacunadorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vacunadorIdMeta);
    }
    if (data.containsKey('sector_id')) {
      context.handle(
        _sectorIdMeta,
        sectorId.isAcceptableOrUnknown(data['sector_id']!, _sectorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectorIdMeta);
    }
    if (data.containsKey('propietario_nombre')) {
      context.handle(
        _propietarioNombreMeta,
        propietarioNombre.isAcceptableOrUnknown(
          data['propietario_nombre']!,
          _propietarioNombreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_propietarioNombreMeta);
    }
    if (data.containsKey('propietario_cedula')) {
      context.handle(
        _propietarioCedulaMeta,
        propietarioCedula.isAcceptableOrUnknown(
          data['propietario_cedula']!,
          _propietarioCedulaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_propietarioCedulaMeta);
    }
    if (data.containsKey('propietario_telefono')) {
      context.handle(
        _propietarioTelefonoMeta,
        propietarioTelefono.isAcceptableOrUnknown(
          data['propietario_telefono']!,
          _propietarioTelefonoMeta,
        ),
      );
    }
    if (data.containsKey('tipo_mascota')) {
      context.handle(
        _tipoMascotaMeta,
        tipoMascota.isAcceptableOrUnknown(
          data['tipo_mascota']!,
          _tipoMascotaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoMascotaMeta);
    }
    if (data.containsKey('mascota_nombre')) {
      context.handle(
        _mascotaNombreMeta,
        mascotaNombre.isAcceptableOrUnknown(
          data['mascota_nombre']!,
          _mascotaNombreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mascotaNombreMeta);
    }
    if (data.containsKey('mascota_edad_aprox')) {
      context.handle(
        _mascotaEdadAproxMeta,
        mascotaEdadAprox.isAcceptableOrUnknown(
          data['mascota_edad_aprox']!,
          _mascotaEdadAproxMeta,
        ),
      );
    }
    if (data.containsKey('mascota_sexo')) {
      context.handle(
        _mascotaSexoMeta,
        mascotaSexo.isAcceptableOrUnknown(
          data['mascota_sexo']!,
          _mascotaSexoMeta,
        ),
      );
    }
    if (data.containsKey('vacuna_aplicada')) {
      context.handle(
        _vacunaAplicadaMeta,
        vacunaAplicada.isAcceptableOrUnknown(
          data['vacuna_aplicada']!,
          _vacunaAplicadaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vacunaAplicadaMeta);
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    }
    if (data.containsKey('foto_url')) {
      context.handle(
        _fotoUrlMeta,
        fotoUrl.isAcceptableOrUnknown(data['foto_url']!, _fotoUrlMeta),
      );
    }
    if (data.containsKey('foto_local_path')) {
      context.handle(
        _fotoLocalPathMeta,
        fotoLocalPath.isAcceptableOrUnknown(
          data['foto_local_path']!,
          _fotoLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('latitud')) {
      context.handle(
        _latitudMeta,
        latitud.isAcceptableOrUnknown(data['latitud']!, _latitudMeta),
      );
    }
    if (data.containsKey('longitud')) {
      context.handle(
        _longitudMeta,
        longitud.isAcceptableOrUnknown(data['longitud']!, _longitudMeta),
      );
    }
    if (data.containsKey('fecha_vacunacion')) {
      context.handle(
        _fechaVacunacionMeta,
        fechaVacunacion.isAcceptableOrUnknown(
          data['fecha_vacunacion']!,
          _fechaVacunacionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaVacunacionMeta);
    }
    if (data.containsKey('sincronizado')) {
      context.handle(
        _sincronizadoMeta,
        sincronizado.isAcceptableOrUnknown(
          data['sincronizado']!,
          _sincronizadoMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VacunacionesLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VacunacionesLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vacunadorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vacunador_id'],
      )!,
      sectorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector_id'],
      )!,
      propietarioNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}propietario_nombre'],
      )!,
      propietarioCedula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}propietario_cedula'],
      )!,
      propietarioTelefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}propietario_telefono'],
      ),
      tipoMascota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_mascota'],
      )!,
      mascotaNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mascota_nombre'],
      )!,
      mascotaEdadAprox: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mascota_edad_aprox'],
      ),
      mascotaSexo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mascota_sexo'],
      ),
      vacunaAplicada: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vacuna_aplicada'],
      )!,
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      ),
      fotoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_url'],
      ),
      fotoLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_local_path'],
      ),
      latitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitud'],
      ),
      longitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitud'],
      ),
      fechaVacunacion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_vacunacion'],
      )!,
      sincronizado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sincronizado'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VacunacionesLocalTable createAlias(String alias) {
    return $VacunacionesLocalTable(attachedDatabase, alias);
  }
}

class VacunacionesLocalData extends DataClass
    implements Insertable<VacunacionesLocalData> {
  final String id;
  final String vacunadorId;
  final String sectorId;
  final String propietarioNombre;
  final String propietarioCedula;
  final String? propietarioTelefono;
  final String tipoMascota;
  final String mascotaNombre;
  final String? mascotaEdadAprox;
  final String? mascotaSexo;
  final String vacunaAplicada;
  final String? observaciones;
  final String? fotoUrl;
  final String? fotoLocalPath;
  final double? latitud;
  final double? longitud;
  final DateTime fechaVacunacion;
  final bool sincronizado;
  final DateTime createdAt;
  const VacunacionesLocalData({
    required this.id,
    required this.vacunadorId,
    required this.sectorId,
    required this.propietarioNombre,
    required this.propietarioCedula,
    this.propietarioTelefono,
    required this.tipoMascota,
    required this.mascotaNombre,
    this.mascotaEdadAprox,
    this.mascotaSexo,
    required this.vacunaAplicada,
    this.observaciones,
    this.fotoUrl,
    this.fotoLocalPath,
    this.latitud,
    this.longitud,
    required this.fechaVacunacion,
    required this.sincronizado,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vacunador_id'] = Variable<String>(vacunadorId);
    map['sector_id'] = Variable<String>(sectorId);
    map['propietario_nombre'] = Variable<String>(propietarioNombre);
    map['propietario_cedula'] = Variable<String>(propietarioCedula);
    if (!nullToAbsent || propietarioTelefono != null) {
      map['propietario_telefono'] = Variable<String>(propietarioTelefono);
    }
    map['tipo_mascota'] = Variable<String>(tipoMascota);
    map['mascota_nombre'] = Variable<String>(mascotaNombre);
    if (!nullToAbsent || mascotaEdadAprox != null) {
      map['mascota_edad_aprox'] = Variable<String>(mascotaEdadAprox);
    }
    if (!nullToAbsent || mascotaSexo != null) {
      map['mascota_sexo'] = Variable<String>(mascotaSexo);
    }
    map['vacuna_aplicada'] = Variable<String>(vacunaAplicada);
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    if (!nullToAbsent || fotoUrl != null) {
      map['foto_url'] = Variable<String>(fotoUrl);
    }
    if (!nullToAbsent || fotoLocalPath != null) {
      map['foto_local_path'] = Variable<String>(fotoLocalPath);
    }
    if (!nullToAbsent || latitud != null) {
      map['latitud'] = Variable<double>(latitud);
    }
    if (!nullToAbsent || longitud != null) {
      map['longitud'] = Variable<double>(longitud);
    }
    map['fecha_vacunacion'] = Variable<DateTime>(fechaVacunacion);
    map['sincronizado'] = Variable<bool>(sincronizado);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VacunacionesLocalCompanion toCompanion(bool nullToAbsent) {
    return VacunacionesLocalCompanion(
      id: Value(id),
      vacunadorId: Value(vacunadorId),
      sectorId: Value(sectorId),
      propietarioNombre: Value(propietarioNombre),
      propietarioCedula: Value(propietarioCedula),
      propietarioTelefono: propietarioTelefono == null && nullToAbsent
          ? const Value.absent()
          : Value(propietarioTelefono),
      tipoMascota: Value(tipoMascota),
      mascotaNombre: Value(mascotaNombre),
      mascotaEdadAprox: mascotaEdadAprox == null && nullToAbsent
          ? const Value.absent()
          : Value(mascotaEdadAprox),
      mascotaSexo: mascotaSexo == null && nullToAbsent
          ? const Value.absent()
          : Value(mascotaSexo),
      vacunaAplicada: Value(vacunaAplicada),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      fotoUrl: fotoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoUrl),
      fotoLocalPath: fotoLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoLocalPath),
      latitud: latitud == null && nullToAbsent
          ? const Value.absent()
          : Value(latitud),
      longitud: longitud == null && nullToAbsent
          ? const Value.absent()
          : Value(longitud),
      fechaVacunacion: Value(fechaVacunacion),
      sincronizado: Value(sincronizado),
      createdAt: Value(createdAt),
    );
  }

  factory VacunacionesLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VacunacionesLocalData(
      id: serializer.fromJson<String>(json['id']),
      vacunadorId: serializer.fromJson<String>(json['vacunadorId']),
      sectorId: serializer.fromJson<String>(json['sectorId']),
      propietarioNombre: serializer.fromJson<String>(json['propietarioNombre']),
      propietarioCedula: serializer.fromJson<String>(json['propietarioCedula']),
      propietarioTelefono: serializer.fromJson<String?>(
        json['propietarioTelefono'],
      ),
      tipoMascota: serializer.fromJson<String>(json['tipoMascota']),
      mascotaNombre: serializer.fromJson<String>(json['mascotaNombre']),
      mascotaEdadAprox: serializer.fromJson<String?>(json['mascotaEdadAprox']),
      mascotaSexo: serializer.fromJson<String?>(json['mascotaSexo']),
      vacunaAplicada: serializer.fromJson<String>(json['vacunaAplicada']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      fotoUrl: serializer.fromJson<String?>(json['fotoUrl']),
      fotoLocalPath: serializer.fromJson<String?>(json['fotoLocalPath']),
      latitud: serializer.fromJson<double?>(json['latitud']),
      longitud: serializer.fromJson<double?>(json['longitud']),
      fechaVacunacion: serializer.fromJson<DateTime>(json['fechaVacunacion']),
      sincronizado: serializer.fromJson<bool>(json['sincronizado']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vacunadorId': serializer.toJson<String>(vacunadorId),
      'sectorId': serializer.toJson<String>(sectorId),
      'propietarioNombre': serializer.toJson<String>(propietarioNombre),
      'propietarioCedula': serializer.toJson<String>(propietarioCedula),
      'propietarioTelefono': serializer.toJson<String?>(propietarioTelefono),
      'tipoMascota': serializer.toJson<String>(tipoMascota),
      'mascotaNombre': serializer.toJson<String>(mascotaNombre),
      'mascotaEdadAprox': serializer.toJson<String?>(mascotaEdadAprox),
      'mascotaSexo': serializer.toJson<String?>(mascotaSexo),
      'vacunaAplicada': serializer.toJson<String>(vacunaAplicada),
      'observaciones': serializer.toJson<String?>(observaciones),
      'fotoUrl': serializer.toJson<String?>(fotoUrl),
      'fotoLocalPath': serializer.toJson<String?>(fotoLocalPath),
      'latitud': serializer.toJson<double?>(latitud),
      'longitud': serializer.toJson<double?>(longitud),
      'fechaVacunacion': serializer.toJson<DateTime>(fechaVacunacion),
      'sincronizado': serializer.toJson<bool>(sincronizado),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VacunacionesLocalData copyWith({
    String? id,
    String? vacunadorId,
    String? sectorId,
    String? propietarioNombre,
    String? propietarioCedula,
    Value<String?> propietarioTelefono = const Value.absent(),
    String? tipoMascota,
    String? mascotaNombre,
    Value<String?> mascotaEdadAprox = const Value.absent(),
    Value<String?> mascotaSexo = const Value.absent(),
    String? vacunaAplicada,
    Value<String?> observaciones = const Value.absent(),
    Value<String?> fotoUrl = const Value.absent(),
    Value<String?> fotoLocalPath = const Value.absent(),
    Value<double?> latitud = const Value.absent(),
    Value<double?> longitud = const Value.absent(),
    DateTime? fechaVacunacion,
    bool? sincronizado,
    DateTime? createdAt,
  }) => VacunacionesLocalData(
    id: id ?? this.id,
    vacunadorId: vacunadorId ?? this.vacunadorId,
    sectorId: sectorId ?? this.sectorId,
    propietarioNombre: propietarioNombre ?? this.propietarioNombre,
    propietarioCedula: propietarioCedula ?? this.propietarioCedula,
    propietarioTelefono: propietarioTelefono.present
        ? propietarioTelefono.value
        : this.propietarioTelefono,
    tipoMascota: tipoMascota ?? this.tipoMascota,
    mascotaNombre: mascotaNombre ?? this.mascotaNombre,
    mascotaEdadAprox: mascotaEdadAprox.present
        ? mascotaEdadAprox.value
        : this.mascotaEdadAprox,
    mascotaSexo: mascotaSexo.present ? mascotaSexo.value : this.mascotaSexo,
    vacunaAplicada: vacunaAplicada ?? this.vacunaAplicada,
    observaciones: observaciones.present
        ? observaciones.value
        : this.observaciones,
    fotoUrl: fotoUrl.present ? fotoUrl.value : this.fotoUrl,
    fotoLocalPath: fotoLocalPath.present
        ? fotoLocalPath.value
        : this.fotoLocalPath,
    latitud: latitud.present ? latitud.value : this.latitud,
    longitud: longitud.present ? longitud.value : this.longitud,
    fechaVacunacion: fechaVacunacion ?? this.fechaVacunacion,
    sincronizado: sincronizado ?? this.sincronizado,
    createdAt: createdAt ?? this.createdAt,
  );
  VacunacionesLocalData copyWithCompanion(VacunacionesLocalCompanion data) {
    return VacunacionesLocalData(
      id: data.id.present ? data.id.value : this.id,
      vacunadorId: data.vacunadorId.present
          ? data.vacunadorId.value
          : this.vacunadorId,
      sectorId: data.sectorId.present ? data.sectorId.value : this.sectorId,
      propietarioNombre: data.propietarioNombre.present
          ? data.propietarioNombre.value
          : this.propietarioNombre,
      propietarioCedula: data.propietarioCedula.present
          ? data.propietarioCedula.value
          : this.propietarioCedula,
      propietarioTelefono: data.propietarioTelefono.present
          ? data.propietarioTelefono.value
          : this.propietarioTelefono,
      tipoMascota: data.tipoMascota.present
          ? data.tipoMascota.value
          : this.tipoMascota,
      mascotaNombre: data.mascotaNombre.present
          ? data.mascotaNombre.value
          : this.mascotaNombre,
      mascotaEdadAprox: data.mascotaEdadAprox.present
          ? data.mascotaEdadAprox.value
          : this.mascotaEdadAprox,
      mascotaSexo: data.mascotaSexo.present
          ? data.mascotaSexo.value
          : this.mascotaSexo,
      vacunaAplicada: data.vacunaAplicada.present
          ? data.vacunaAplicada.value
          : this.vacunaAplicada,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      fotoUrl: data.fotoUrl.present ? data.fotoUrl.value : this.fotoUrl,
      fotoLocalPath: data.fotoLocalPath.present
          ? data.fotoLocalPath.value
          : this.fotoLocalPath,
      latitud: data.latitud.present ? data.latitud.value : this.latitud,
      longitud: data.longitud.present ? data.longitud.value : this.longitud,
      fechaVacunacion: data.fechaVacunacion.present
          ? data.fechaVacunacion.value
          : this.fechaVacunacion,
      sincronizado: data.sincronizado.present
          ? data.sincronizado.value
          : this.sincronizado,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VacunacionesLocalData(')
          ..write('id: $id, ')
          ..write('vacunadorId: $vacunadorId, ')
          ..write('sectorId: $sectorId, ')
          ..write('propietarioNombre: $propietarioNombre, ')
          ..write('propietarioCedula: $propietarioCedula, ')
          ..write('propietarioTelefono: $propietarioTelefono, ')
          ..write('tipoMascota: $tipoMascota, ')
          ..write('mascotaNombre: $mascotaNombre, ')
          ..write('mascotaEdadAprox: $mascotaEdadAprox, ')
          ..write('mascotaSexo: $mascotaSexo, ')
          ..write('vacunaAplicada: $vacunaAplicada, ')
          ..write('observaciones: $observaciones, ')
          ..write('fotoUrl: $fotoUrl, ')
          ..write('fotoLocalPath: $fotoLocalPath, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('fechaVacunacion: $fechaVacunacion, ')
          ..write('sincronizado: $sincronizado, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vacunadorId,
    sectorId,
    propietarioNombre,
    propietarioCedula,
    propietarioTelefono,
    tipoMascota,
    mascotaNombre,
    mascotaEdadAprox,
    mascotaSexo,
    vacunaAplicada,
    observaciones,
    fotoUrl,
    fotoLocalPath,
    latitud,
    longitud,
    fechaVacunacion,
    sincronizado,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VacunacionesLocalData &&
          other.id == this.id &&
          other.vacunadorId == this.vacunadorId &&
          other.sectorId == this.sectorId &&
          other.propietarioNombre == this.propietarioNombre &&
          other.propietarioCedula == this.propietarioCedula &&
          other.propietarioTelefono == this.propietarioTelefono &&
          other.tipoMascota == this.tipoMascota &&
          other.mascotaNombre == this.mascotaNombre &&
          other.mascotaEdadAprox == this.mascotaEdadAprox &&
          other.mascotaSexo == this.mascotaSexo &&
          other.vacunaAplicada == this.vacunaAplicada &&
          other.observaciones == this.observaciones &&
          other.fotoUrl == this.fotoUrl &&
          other.fotoLocalPath == this.fotoLocalPath &&
          other.latitud == this.latitud &&
          other.longitud == this.longitud &&
          other.fechaVacunacion == this.fechaVacunacion &&
          other.sincronizado == this.sincronizado &&
          other.createdAt == this.createdAt);
}

class VacunacionesLocalCompanion
    extends UpdateCompanion<VacunacionesLocalData> {
  final Value<String> id;
  final Value<String> vacunadorId;
  final Value<String> sectorId;
  final Value<String> propietarioNombre;
  final Value<String> propietarioCedula;
  final Value<String?> propietarioTelefono;
  final Value<String> tipoMascota;
  final Value<String> mascotaNombre;
  final Value<String?> mascotaEdadAprox;
  final Value<String?> mascotaSexo;
  final Value<String> vacunaAplicada;
  final Value<String?> observaciones;
  final Value<String?> fotoUrl;
  final Value<String?> fotoLocalPath;
  final Value<double?> latitud;
  final Value<double?> longitud;
  final Value<DateTime> fechaVacunacion;
  final Value<bool> sincronizado;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VacunacionesLocalCompanion({
    this.id = const Value.absent(),
    this.vacunadorId = const Value.absent(),
    this.sectorId = const Value.absent(),
    this.propietarioNombre = const Value.absent(),
    this.propietarioCedula = const Value.absent(),
    this.propietarioTelefono = const Value.absent(),
    this.tipoMascota = const Value.absent(),
    this.mascotaNombre = const Value.absent(),
    this.mascotaEdadAprox = const Value.absent(),
    this.mascotaSexo = const Value.absent(),
    this.vacunaAplicada = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.fotoUrl = const Value.absent(),
    this.fotoLocalPath = const Value.absent(),
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.fechaVacunacion = const Value.absent(),
    this.sincronizado = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VacunacionesLocalCompanion.insert({
    required String id,
    required String vacunadorId,
    required String sectorId,
    required String propietarioNombre,
    required String propietarioCedula,
    this.propietarioTelefono = const Value.absent(),
    required String tipoMascota,
    required String mascotaNombre,
    this.mascotaEdadAprox = const Value.absent(),
    this.mascotaSexo = const Value.absent(),
    required String vacunaAplicada,
    this.observaciones = const Value.absent(),
    this.fotoUrl = const Value.absent(),
    this.fotoLocalPath = const Value.absent(),
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    required DateTime fechaVacunacion,
    this.sincronizado = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vacunadorId = Value(vacunadorId),
       sectorId = Value(sectorId),
       propietarioNombre = Value(propietarioNombre),
       propietarioCedula = Value(propietarioCedula),
       tipoMascota = Value(tipoMascota),
       mascotaNombre = Value(mascotaNombre),
       vacunaAplicada = Value(vacunaAplicada),
       fechaVacunacion = Value(fechaVacunacion);
  static Insertable<VacunacionesLocalData> custom({
    Expression<String>? id,
    Expression<String>? vacunadorId,
    Expression<String>? sectorId,
    Expression<String>? propietarioNombre,
    Expression<String>? propietarioCedula,
    Expression<String>? propietarioTelefono,
    Expression<String>? tipoMascota,
    Expression<String>? mascotaNombre,
    Expression<String>? mascotaEdadAprox,
    Expression<String>? mascotaSexo,
    Expression<String>? vacunaAplicada,
    Expression<String>? observaciones,
    Expression<String>? fotoUrl,
    Expression<String>? fotoLocalPath,
    Expression<double>? latitud,
    Expression<double>? longitud,
    Expression<DateTime>? fechaVacunacion,
    Expression<bool>? sincronizado,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vacunadorId != null) 'vacunador_id': vacunadorId,
      if (sectorId != null) 'sector_id': sectorId,
      if (propietarioNombre != null) 'propietario_nombre': propietarioNombre,
      if (propietarioCedula != null) 'propietario_cedula': propietarioCedula,
      if (propietarioTelefono != null)
        'propietario_telefono': propietarioTelefono,
      if (tipoMascota != null) 'tipo_mascota': tipoMascota,
      if (mascotaNombre != null) 'mascota_nombre': mascotaNombre,
      if (mascotaEdadAprox != null) 'mascota_edad_aprox': mascotaEdadAprox,
      if (mascotaSexo != null) 'mascota_sexo': mascotaSexo,
      if (vacunaAplicada != null) 'vacuna_aplicada': vacunaAplicada,
      if (observaciones != null) 'observaciones': observaciones,
      if (fotoUrl != null) 'foto_url': fotoUrl,
      if (fotoLocalPath != null) 'foto_local_path': fotoLocalPath,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if (fechaVacunacion != null) 'fecha_vacunacion': fechaVacunacion,
      if (sincronizado != null) 'sincronizado': sincronizado,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VacunacionesLocalCompanion copyWith({
    Value<String>? id,
    Value<String>? vacunadorId,
    Value<String>? sectorId,
    Value<String>? propietarioNombre,
    Value<String>? propietarioCedula,
    Value<String?>? propietarioTelefono,
    Value<String>? tipoMascota,
    Value<String>? mascotaNombre,
    Value<String?>? mascotaEdadAprox,
    Value<String?>? mascotaSexo,
    Value<String>? vacunaAplicada,
    Value<String?>? observaciones,
    Value<String?>? fotoUrl,
    Value<String?>? fotoLocalPath,
    Value<double?>? latitud,
    Value<double?>? longitud,
    Value<DateTime>? fechaVacunacion,
    Value<bool>? sincronizado,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VacunacionesLocalCompanion(
      id: id ?? this.id,
      vacunadorId: vacunadorId ?? this.vacunadorId,
      sectorId: sectorId ?? this.sectorId,
      propietarioNombre: propietarioNombre ?? this.propietarioNombre,
      propietarioCedula: propietarioCedula ?? this.propietarioCedula,
      propietarioTelefono: propietarioTelefono ?? this.propietarioTelefono,
      tipoMascota: tipoMascota ?? this.tipoMascota,
      mascotaNombre: mascotaNombre ?? this.mascotaNombre,
      mascotaEdadAprox: mascotaEdadAprox ?? this.mascotaEdadAprox,
      mascotaSexo: mascotaSexo ?? this.mascotaSexo,
      vacunaAplicada: vacunaAplicada ?? this.vacunaAplicada,
      observaciones: observaciones ?? this.observaciones,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      fotoLocalPath: fotoLocalPath ?? this.fotoLocalPath,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fechaVacunacion: fechaVacunacion ?? this.fechaVacunacion,
      sincronizado: sincronizado ?? this.sincronizado,
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
    if (vacunadorId.present) {
      map['vacunador_id'] = Variable<String>(vacunadorId.value);
    }
    if (sectorId.present) {
      map['sector_id'] = Variable<String>(sectorId.value);
    }
    if (propietarioNombre.present) {
      map['propietario_nombre'] = Variable<String>(propietarioNombre.value);
    }
    if (propietarioCedula.present) {
      map['propietario_cedula'] = Variable<String>(propietarioCedula.value);
    }
    if (propietarioTelefono.present) {
      map['propietario_telefono'] = Variable<String>(propietarioTelefono.value);
    }
    if (tipoMascota.present) {
      map['tipo_mascota'] = Variable<String>(tipoMascota.value);
    }
    if (mascotaNombre.present) {
      map['mascota_nombre'] = Variable<String>(mascotaNombre.value);
    }
    if (mascotaEdadAprox.present) {
      map['mascota_edad_aprox'] = Variable<String>(mascotaEdadAprox.value);
    }
    if (mascotaSexo.present) {
      map['mascota_sexo'] = Variable<String>(mascotaSexo.value);
    }
    if (vacunaAplicada.present) {
      map['vacuna_aplicada'] = Variable<String>(vacunaAplicada.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (fotoUrl.present) {
      map['foto_url'] = Variable<String>(fotoUrl.value);
    }
    if (fotoLocalPath.present) {
      map['foto_local_path'] = Variable<String>(fotoLocalPath.value);
    }
    if (latitud.present) {
      map['latitud'] = Variable<double>(latitud.value);
    }
    if (longitud.present) {
      map['longitud'] = Variable<double>(longitud.value);
    }
    if (fechaVacunacion.present) {
      map['fecha_vacunacion'] = Variable<DateTime>(fechaVacunacion.value);
    }
    if (sincronizado.present) {
      map['sincronizado'] = Variable<bool>(sincronizado.value);
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
    return (StringBuffer('VacunacionesLocalCompanion(')
          ..write('id: $id, ')
          ..write('vacunadorId: $vacunadorId, ')
          ..write('sectorId: $sectorId, ')
          ..write('propietarioNombre: $propietarioNombre, ')
          ..write('propietarioCedula: $propietarioCedula, ')
          ..write('propietarioTelefono: $propietarioTelefono, ')
          ..write('tipoMascota: $tipoMascota, ')
          ..write('mascotaNombre: $mascotaNombre, ')
          ..write('mascotaEdadAprox: $mascotaEdadAprox, ')
          ..write('mascotaSexo: $mascotaSexo, ')
          ..write('vacunaAplicada: $vacunaAplicada, ')
          ..write('observaciones: $observaciones, ')
          ..write('fotoUrl: $fotoUrl, ')
          ..write('fotoLocalPath: $fotoLocalPath, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('fechaVacunacion: $fechaVacunacion, ')
          ..write('sincronizado: $sincronizado, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tablaMeta = const VerificationMeta('tabla');
  @override
  late final GeneratedColumn<String> tabla = GeneratedColumn<String>(
    'tabla',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _datosMeta = const VerificationMeta('datos');
  @override
  late final GeneratedColumn<String> datos = GeneratedColumn<String>(
    'datos',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _intentosMeta = const VerificationMeta(
    'intentos',
  );
  @override
  late final GeneratedColumn<int> intentos = GeneratedColumn<int>(
    'intentos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _procesadoMeta = const VerificationMeta(
    'procesado',
  );
  @override
  late final GeneratedColumn<bool> procesado = GeneratedColumn<bool>(
    'procesado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("procesado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tipo,
    tabla,
    datos,
    creadoEn,
    intentos,
    procesado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('tabla')) {
      context.handle(
        _tablaMeta,
        tabla.isAcceptableOrUnknown(data['tabla']!, _tablaMeta),
      );
    } else if (isInserting) {
      context.missing(_tablaMeta);
    }
    if (data.containsKey('datos')) {
      context.handle(
        _datosMeta,
        datos.isAcceptableOrUnknown(data['datos']!, _datosMeta),
      );
    } else if (isInserting) {
      context.missing(_datosMeta);
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    if (data.containsKey('intentos')) {
      context.handle(
        _intentosMeta,
        intentos.isAcceptableOrUnknown(data['intentos']!, _intentosMeta),
      );
    }
    if (data.containsKey('procesado')) {
      context.handle(
        _procesadoMeta,
        procesado.isAcceptableOrUnknown(data['procesado']!, _procesadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      tabla: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tabla'],
      )!,
      datos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datos'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      intentos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intentos'],
      )!,
      procesado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}procesado'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final String id;
  final String tipo;
  final String tabla;
  final String datos;
  final DateTime creadoEn;
  final int intentos;
  final bool procesado;
  const SyncQueueData({
    required this.id,
    required this.tipo,
    required this.tabla,
    required this.datos,
    required this.creadoEn,
    required this.intentos,
    required this.procesado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tipo'] = Variable<String>(tipo);
    map['tabla'] = Variable<String>(tabla);
    map['datos'] = Variable<String>(datos);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['intentos'] = Variable<int>(intentos);
    map['procesado'] = Variable<bool>(procesado);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      tipo: Value(tipo),
      tabla: Value(tabla),
      datos: Value(datos),
      creadoEn: Value(creadoEn),
      intentos: Value(intentos),
      procesado: Value(procesado),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<String>(json['id']),
      tipo: serializer.fromJson<String>(json['tipo']),
      tabla: serializer.fromJson<String>(json['tabla']),
      datos: serializer.fromJson<String>(json['datos']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      intentos: serializer.fromJson<int>(json['intentos']),
      procesado: serializer.fromJson<bool>(json['procesado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tipo': serializer.toJson<String>(tipo),
      'tabla': serializer.toJson<String>(tabla),
      'datos': serializer.toJson<String>(datos),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'intentos': serializer.toJson<int>(intentos),
      'procesado': serializer.toJson<bool>(procesado),
    };
  }

  SyncQueueData copyWith({
    String? id,
    String? tipo,
    String? tabla,
    String? datos,
    DateTime? creadoEn,
    int? intentos,
    bool? procesado,
  }) => SyncQueueData(
    id: id ?? this.id,
    tipo: tipo ?? this.tipo,
    tabla: tabla ?? this.tabla,
    datos: datos ?? this.datos,
    creadoEn: creadoEn ?? this.creadoEn,
    intentos: intentos ?? this.intentos,
    procesado: procesado ?? this.procesado,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      tabla: data.tabla.present ? data.tabla.value : this.tabla,
      datos: data.datos.present ? data.datos.value : this.datos,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      intentos: data.intentos.present ? data.intentos.value : this.intentos,
      procesado: data.procesado.present ? data.procesado.value : this.procesado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('tabla: $tabla, ')
          ..write('datos: $datos, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('intentos: $intentos, ')
          ..write('procesado: $procesado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tipo, tabla, datos, creadoEn, intentos, procesado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.tipo == this.tipo &&
          other.tabla == this.tabla &&
          other.datos == this.datos &&
          other.creadoEn == this.creadoEn &&
          other.intentos == this.intentos &&
          other.procesado == this.procesado);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> id;
  final Value<String> tipo;
  final Value<String> tabla;
  final Value<String> datos;
  final Value<DateTime> creadoEn;
  final Value<int> intentos;
  final Value<bool> procesado;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.tipo = const Value.absent(),
    this.tabla = const Value.absent(),
    this.datos = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.intentos = const Value.absent(),
    this.procesado = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    required String tipo,
    required String tabla,
    required String datos,
    this.creadoEn = const Value.absent(),
    this.intentos = const Value.absent(),
    this.procesado = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tipo = Value(tipo),
       tabla = Value(tabla),
       datos = Value(datos);
  static Insertable<SyncQueueData> custom({
    Expression<String>? id,
    Expression<String>? tipo,
    Expression<String>? tabla,
    Expression<String>? datos,
    Expression<DateTime>? creadoEn,
    Expression<int>? intentos,
    Expression<bool>? procesado,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipo != null) 'tipo': tipo,
      if (tabla != null) 'tabla': tabla,
      if (datos != null) 'datos': datos,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (intentos != null) 'intentos': intentos,
      if (procesado != null) 'procesado': procesado,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith({
    Value<String>? id,
    Value<String>? tipo,
    Value<String>? tabla,
    Value<String>? datos,
    Value<DateTime>? creadoEn,
    Value<int>? intentos,
    Value<bool>? procesado,
    Value<int>? rowid,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      tabla: tabla ?? this.tabla,
      datos: datos ?? this.datos,
      creadoEn: creadoEn ?? this.creadoEn,
      intentos: intentos ?? this.intentos,
      procesado: procesado ?? this.procesado,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (tabla.present) {
      map['tabla'] = Variable<String>(tabla.value);
    }
    if (datos.present) {
      map['datos'] = Variable<String>(datos.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (intentos.present) {
      map['intentos'] = Variable<int>(intentos.value);
    }
    if (procesado.present) {
      map['procesado'] = Variable<bool>(procesado.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('tabla: $tabla, ')
          ..write('datos: $datos, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('intentos: $intentos, ')
          ..write('procesado: $procesado, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VacunacionesLocalTable vacunacionesLocal =
      $VacunacionesLocalTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final VacunacionesDao vacunacionesDao = VacunacionesDao(
    this as AppDatabase,
  );
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vacunacionesLocal,
    syncQueue,
  ];
}

typedef $$VacunacionesLocalTableCreateCompanionBuilder =
    VacunacionesLocalCompanion Function({
      required String id,
      required String vacunadorId,
      required String sectorId,
      required String propietarioNombre,
      required String propietarioCedula,
      Value<String?> propietarioTelefono,
      required String tipoMascota,
      required String mascotaNombre,
      Value<String?> mascotaEdadAprox,
      Value<String?> mascotaSexo,
      required String vacunaAplicada,
      Value<String?> observaciones,
      Value<String?> fotoUrl,
      Value<String?> fotoLocalPath,
      Value<double?> latitud,
      Value<double?> longitud,
      required DateTime fechaVacunacion,
      Value<bool> sincronizado,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$VacunacionesLocalTableUpdateCompanionBuilder =
    VacunacionesLocalCompanion Function({
      Value<String> id,
      Value<String> vacunadorId,
      Value<String> sectorId,
      Value<String> propietarioNombre,
      Value<String> propietarioCedula,
      Value<String?> propietarioTelefono,
      Value<String> tipoMascota,
      Value<String> mascotaNombre,
      Value<String?> mascotaEdadAprox,
      Value<String?> mascotaSexo,
      Value<String> vacunaAplicada,
      Value<String?> observaciones,
      Value<String?> fotoUrl,
      Value<String?> fotoLocalPath,
      Value<double?> latitud,
      Value<double?> longitud,
      Value<DateTime> fechaVacunacion,
      Value<bool> sincronizado,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$VacunacionesLocalTableFilterComposer
    extends Composer<_$AppDatabase, $VacunacionesLocalTable> {
  $$VacunacionesLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vacunadorId => $composableBuilder(
    column: $table.vacunadorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sectorId => $composableBuilder(
    column: $table.sectorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get propietarioNombre => $composableBuilder(
    column: $table.propietarioNombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get propietarioCedula => $composableBuilder(
    column: $table.propietarioCedula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get propietarioTelefono => $composableBuilder(
    column: $table.propietarioTelefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoMascota => $composableBuilder(
    column: $table.tipoMascota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mascotaNombre => $composableBuilder(
    column: $table.mascotaNombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mascotaEdadAprox => $composableBuilder(
    column: $table.mascotaEdadAprox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mascotaSexo => $composableBuilder(
    column: $table.mascotaSexo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vacunaAplicada => $composableBuilder(
    column: $table.vacunaAplicada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoUrl => $composableBuilder(
    column: $table.fotoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoLocalPath => $composableBuilder(
    column: $table.fotoLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaVacunacion => $composableBuilder(
    column: $table.fechaVacunacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sincronizado => $composableBuilder(
    column: $table.sincronizado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VacunacionesLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $VacunacionesLocalTable> {
  $$VacunacionesLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vacunadorId => $composableBuilder(
    column: $table.vacunadorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sectorId => $composableBuilder(
    column: $table.sectorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get propietarioNombre => $composableBuilder(
    column: $table.propietarioNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get propietarioCedula => $composableBuilder(
    column: $table.propietarioCedula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get propietarioTelefono => $composableBuilder(
    column: $table.propietarioTelefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoMascota => $composableBuilder(
    column: $table.tipoMascota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mascotaNombre => $composableBuilder(
    column: $table.mascotaNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mascotaEdadAprox => $composableBuilder(
    column: $table.mascotaEdadAprox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mascotaSexo => $composableBuilder(
    column: $table.mascotaSexo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vacunaAplicada => $composableBuilder(
    column: $table.vacunaAplicada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoUrl => $composableBuilder(
    column: $table.fotoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoLocalPath => $composableBuilder(
    column: $table.fotoLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaVacunacion => $composableBuilder(
    column: $table.fechaVacunacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sincronizado => $composableBuilder(
    column: $table.sincronizado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VacunacionesLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $VacunacionesLocalTable> {
  $$VacunacionesLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vacunadorId => $composableBuilder(
    column: $table.vacunadorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sectorId =>
      $composableBuilder(column: $table.sectorId, builder: (column) => column);

  GeneratedColumn<String> get propietarioNombre => $composableBuilder(
    column: $table.propietarioNombre,
    builder: (column) => column,
  );

  GeneratedColumn<String> get propietarioCedula => $composableBuilder(
    column: $table.propietarioCedula,
    builder: (column) => column,
  );

  GeneratedColumn<String> get propietarioTelefono => $composableBuilder(
    column: $table.propietarioTelefono,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoMascota => $composableBuilder(
    column: $table.tipoMascota,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mascotaNombre => $composableBuilder(
    column: $table.mascotaNombre,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mascotaEdadAprox => $composableBuilder(
    column: $table.mascotaEdadAprox,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mascotaSexo => $composableBuilder(
    column: $table.mascotaSexo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vacunaAplicada => $composableBuilder(
    column: $table.vacunaAplicada,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fotoUrl =>
      $composableBuilder(column: $table.fotoUrl, builder: (column) => column);

  GeneratedColumn<String> get fotoLocalPath => $composableBuilder(
    column: $table.fotoLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitud =>
      $composableBuilder(column: $table.latitud, builder: (column) => column);

  GeneratedColumn<double> get longitud =>
      $composableBuilder(column: $table.longitud, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaVacunacion => $composableBuilder(
    column: $table.fechaVacunacion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sincronizado => $composableBuilder(
    column: $table.sincronizado,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VacunacionesLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VacunacionesLocalTable,
          VacunacionesLocalData,
          $$VacunacionesLocalTableFilterComposer,
          $$VacunacionesLocalTableOrderingComposer,
          $$VacunacionesLocalTableAnnotationComposer,
          $$VacunacionesLocalTableCreateCompanionBuilder,
          $$VacunacionesLocalTableUpdateCompanionBuilder,
          (
            VacunacionesLocalData,
            BaseReferences<
              _$AppDatabase,
              $VacunacionesLocalTable,
              VacunacionesLocalData
            >,
          ),
          VacunacionesLocalData,
          PrefetchHooks Function()
        > {
  $$VacunacionesLocalTableTableManager(
    _$AppDatabase db,
    $VacunacionesLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VacunacionesLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VacunacionesLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VacunacionesLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vacunadorId = const Value.absent(),
                Value<String> sectorId = const Value.absent(),
                Value<String> propietarioNombre = const Value.absent(),
                Value<String> propietarioCedula = const Value.absent(),
                Value<String?> propietarioTelefono = const Value.absent(),
                Value<String> tipoMascota = const Value.absent(),
                Value<String> mascotaNombre = const Value.absent(),
                Value<String?> mascotaEdadAprox = const Value.absent(),
                Value<String?> mascotaSexo = const Value.absent(),
                Value<String> vacunaAplicada = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
                Value<String?> fotoUrl = const Value.absent(),
                Value<String?> fotoLocalPath = const Value.absent(),
                Value<double?> latitud = const Value.absent(),
                Value<double?> longitud = const Value.absent(),
                Value<DateTime> fechaVacunacion = const Value.absent(),
                Value<bool> sincronizado = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VacunacionesLocalCompanion(
                id: id,
                vacunadorId: vacunadorId,
                sectorId: sectorId,
                propietarioNombre: propietarioNombre,
                propietarioCedula: propietarioCedula,
                propietarioTelefono: propietarioTelefono,
                tipoMascota: tipoMascota,
                mascotaNombre: mascotaNombre,
                mascotaEdadAprox: mascotaEdadAprox,
                mascotaSexo: mascotaSexo,
                vacunaAplicada: vacunaAplicada,
                observaciones: observaciones,
                fotoUrl: fotoUrl,
                fotoLocalPath: fotoLocalPath,
                latitud: latitud,
                longitud: longitud,
                fechaVacunacion: fechaVacunacion,
                sincronizado: sincronizado,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vacunadorId,
                required String sectorId,
                required String propietarioNombre,
                required String propietarioCedula,
                Value<String?> propietarioTelefono = const Value.absent(),
                required String tipoMascota,
                required String mascotaNombre,
                Value<String?> mascotaEdadAprox = const Value.absent(),
                Value<String?> mascotaSexo = const Value.absent(),
                required String vacunaAplicada,
                Value<String?> observaciones = const Value.absent(),
                Value<String?> fotoUrl = const Value.absent(),
                Value<String?> fotoLocalPath = const Value.absent(),
                Value<double?> latitud = const Value.absent(),
                Value<double?> longitud = const Value.absent(),
                required DateTime fechaVacunacion,
                Value<bool> sincronizado = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VacunacionesLocalCompanion.insert(
                id: id,
                vacunadorId: vacunadorId,
                sectorId: sectorId,
                propietarioNombre: propietarioNombre,
                propietarioCedula: propietarioCedula,
                propietarioTelefono: propietarioTelefono,
                tipoMascota: tipoMascota,
                mascotaNombre: mascotaNombre,
                mascotaEdadAprox: mascotaEdadAprox,
                mascotaSexo: mascotaSexo,
                vacunaAplicada: vacunaAplicada,
                observaciones: observaciones,
                fotoUrl: fotoUrl,
                fotoLocalPath: fotoLocalPath,
                latitud: latitud,
                longitud: longitud,
                fechaVacunacion: fechaVacunacion,
                sincronizado: sincronizado,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VacunacionesLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VacunacionesLocalTable,
      VacunacionesLocalData,
      $$VacunacionesLocalTableFilterComposer,
      $$VacunacionesLocalTableOrderingComposer,
      $$VacunacionesLocalTableAnnotationComposer,
      $$VacunacionesLocalTableCreateCompanionBuilder,
      $$VacunacionesLocalTableUpdateCompanionBuilder,
      (
        VacunacionesLocalData,
        BaseReferences<
          _$AppDatabase,
          $VacunacionesLocalTable,
          VacunacionesLocalData
        >,
      ),
      VacunacionesLocalData,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      required String id,
      required String tipo,
      required String tabla,
      required String datos,
      Value<DateTime> creadoEn,
      Value<int> intentos,
      Value<bool> procesado,
      Value<int> rowid,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<String> id,
      Value<String> tipo,
      Value<String> tabla,
      Value<String> datos,
      Value<DateTime> creadoEn,
      Value<int> intentos,
      Value<bool> procesado,
      Value<int> rowid,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tabla => $composableBuilder(
    column: $table.tabla,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datos => $composableBuilder(
    column: $table.datos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intentos => $composableBuilder(
    column: $table.intentos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get procesado => $composableBuilder(
    column: $table.procesado,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tabla => $composableBuilder(
    column: $table.tabla,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datos => $composableBuilder(
    column: $table.datos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intentos => $composableBuilder(
    column: $table.intentos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get procesado => $composableBuilder(
    column: $table.procesado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get tabla =>
      $composableBuilder(column: $table.tabla, builder: (column) => column);

  GeneratedColumn<String> get datos =>
      $composableBuilder(column: $table.datos, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<int> get intentos =>
      $composableBuilder(column: $table.intentos, builder: (column) => column);

  GeneratedColumn<bool> get procesado =>
      $composableBuilder(column: $table.procesado, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> tabla = const Value.absent(),
                Value<String> datos = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<int> intentos = const Value.absent(),
                Value<bool> procesado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                tipo: tipo,
                tabla: tabla,
                datos: datos,
                creadoEn: creadoEn,
                intentos: intentos,
                procesado: procesado,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tipo,
                required String tabla,
                required String datos,
                Value<DateTime> creadoEn = const Value.absent(),
                Value<int> intentos = const Value.absent(),
                Value<bool> procesado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                tipo: tipo,
                tabla: tabla,
                datos: datos,
                creadoEn: creadoEn,
                intentos: intentos,
                procesado: procesado,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VacunacionesLocalTableTableManager get vacunacionesLocal =>
      $$VacunacionesLocalTableTableManager(_db, _db.vacunacionesLocal);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
