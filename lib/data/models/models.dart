import '../../domain/entities/entities.dart';

// ═══════════════════════════════════════════
// MODEL: UsuarioModel
// ═══════════════════════════════════════════
class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.cedula,
    required super.nombres,
    required super.apellidos,
    required super.telefono,
    required super.correo,
    required super.rol,
    required super.primerLogin,
    super.creadoPor,
    required super.createdAt,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      cedula: json['cedula'] as String,
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
      telefono: json['telefono'] as String,
      correo: json['correo'] as String,
      rol: json['rol'] as String,
      primerLogin: json['primer_login'] as bool? ?? true,
      creadoPor: json['creado_por'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cedula': cedula,
    'nombres': nombres,
    'apellidos': apellidos,
    'telefono': telefono,
    'correo': correo,
    'rol': rol,
    'primer_login': primerLogin,
    'creado_por': creadoPor,
  };
}

// ═══════════════════════════════════════════
// MODEL: SectorModel
// ═══════════════════════════════════════════
class SectorModel extends Sector {
  const SectorModel({
    required super.id,
    required super.nombre,
    required super.ciudad,
    super.descripcion,
    required super.createdAt,
  });

  factory SectorModel.fromJson(Map<String, dynamic> json) {
    return SectorModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      ciudad: json['ciudad'] as String? ?? 'Quito',
      descripcion: json['descripcion'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'ciudad': ciudad,
    'descripcion': descripcion,
  };
}

// ═══════════════════════════════════════════
// MODEL: VacunacionModel
// ═══════════════════════════════════════════
class VacunacionModel extends Vacunacion {
  const VacunacionModel({
    required super.id,
    required super.vacunadorId,
    required super.sectorId,
    required super.propietarioNombre,
    required super.propietarioCedula,
    super.propietarioTelefono,
    required super.tipoMascota,
    required super.mascotaNombre,
    super.mascotaEdadAprox,
    super.mascotaSexo,
    required super.vacunaAplicada,
    super.observaciones,
    super.fotoUrl,
    super.latitud,
    super.longitud,
    required super.fechaVacunacion,
    super.editadoPor,
    super.ultimaEdicion,
    super.sincronizado,
  });

  factory VacunacionModel.fromJson(Map<String, dynamic> json) {
    return VacunacionModel(
      id: json['id'] as String,
      vacunadorId: json['vacunador_id'] as String,
      sectorId: json['sector_id'] as String,
      propietarioNombre: json['propietario_nombre'] as String,
      propietarioCedula: json['propietario_cedula'] as String,
      propietarioTelefono: json['propietario_telefono'] as String?,
      tipoMascota: json['tipo_mascota'] as String,
      mascotaNombre: json['mascota_nombre'] as String,
      mascotaEdadAprox: json['mascota_edad_aprox'] as String?,
      mascotaSexo: json['mascota_sexo'] as String?,
      vacunaAplicada: json['vacuna_aplicada'] as String,
      observaciones: json['observaciones'] as String?,
      fotoUrl: json['foto_url'] as String?,
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      fechaVacunacion: DateTime.parse(json['fecha_vacunacion'] as String),
      editadoPor: json['editado_por'] as String?,
      ultimaEdicion: json['ultima_edicion'] != null
          ? DateTime.parse(json['ultima_edicion'] as String)
          : null,
      sincronizado: json['sincronizado'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vacunador_id': vacunadorId,
    'sector_id': sectorId,
    'propietario_nombre': propietarioNombre,
    'propietario_cedula': propietarioCedula,
    'propietario_telefono': propietarioTelefono,
    'tipo_mascota': tipoMascota,
    'mascota_nombre': mascotaNombre,
    'mascota_edad_aprox': mascotaEdadAprox,
    'mascota_sexo': mascotaSexo,
    'vacuna_aplicada': vacunaAplicada,
    'observaciones': observaciones,
    'foto_url': fotoUrl,
    'latitud': latitud,
    'longitud': longitud,
    'fecha_vacunacion': fechaVacunacion.toIso8601String(),
    'editado_por': editadoPor,
    'ultima_edicion': ultimaEdicion?.toIso8601String(),
    'sincronizado': sincronizado,
  };
}
