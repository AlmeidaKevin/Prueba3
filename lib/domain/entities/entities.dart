// ═══════════════════════════════════════════
// ENTIDAD: Usuario
// ═══════════════════════════════════════════
class Usuario {
  final String id;
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;
  final String rol;
  final bool primerLogin;
  final String? creadoPor;
  final DateTime createdAt;

  const Usuario({
    required this.id,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
    required this.rol,
    required this.primerLogin,
    this.creadoPor,
    required this.createdAt,
  });

  String get nombreCompleto => '$nombres $apellidos';

  Usuario copyWith({
    String? id, String? cedula, String? nombres, String? apellidos,
    String? telefono, String? correo, String? rol, bool? primerLogin,
    String? creadoPor, DateTime? createdAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      cedula: cedula ?? this.cedula,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      rol: rol ?? this.rol,
      primerLogin: primerLogin ?? this.primerLogin,
      creadoPor: creadoPor ?? this.creadoPor,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ═══════════════════════════════════════════
// ENTIDAD: Sector
// ═══════════════════════════════════════════
class Sector {
  final String id;
  final String nombre;
  final String ciudad;
  final String? descripcion;
  final DateTime createdAt;

  const Sector({
    required this.id,
    required this.nombre,
    required this.ciudad,
    this.descripcion,
    required this.createdAt,
  });
}

// ═══════════════════════════════════════════
// ENTIDAD: Vacunacion
// ═══════════════════════════════════════════
class Vacunacion {
  final String id;
  final String vacunadorId;
  final String sectorId;
  final String propietarioNombre;
  final String propietarioCedula;
  final String? propietarioTelefono;
  final String tipoMascota; // 'perro' | 'gato'
  final String mascotaNombre;
  final String? mascotaEdadAprox;
  final String? mascotaSexo; // 'macho' | 'hembra'
  final String vacunaAplicada;
  final String? observaciones;
  final String? fotoUrl;
  final double? latitud;
  final double? longitud;
  final DateTime fechaVacunacion;
  final String? editadoPor;
  final DateTime? ultimaEdicion;
  final bool sincronizado;

  const Vacunacion({
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
    this.latitud,
    this.longitud,
    required this.fechaVacunacion,
    this.editadoPor,
    this.ultimaEdicion,
    this.sincronizado = true,
  });

  Vacunacion copyWith({
    String? id, String? vacunadorId, String? sectorId,
    String? propietarioNombre, String? propietarioCedula,
    String? propietarioTelefono, String? tipoMascota,
    String? mascotaNombre, String? mascotaEdadAprox, String? mascotaSexo,
    String? vacunaAplicada, String? observaciones, String? fotoUrl,
    double? latitud, double? longitud, DateTime? fechaVacunacion,
    String? editadoPor, DateTime? ultimaEdicion, bool? sincronizado,
  }) {
    return Vacunacion(
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
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fechaVacunacion: fechaVacunacion ?? this.fechaVacunacion,
      editadoPor: editadoPor ?? this.editadoPor,
      ultimaEdicion: ultimaEdicion ?? this.ultimaEdicion,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }
}

// ═══════════════════════════════════════════
// ENTIDAD: DashboardStats
// ═══════════════════════════════════════════
class DashboardStats {
  final int totalVacunaciones;
  final int perrosVacunados;
  final int gatosVacunados;
  final int pendientesSincronizacion;
  final Map<String, int> porSector;
  final Map<String, int> porVacunador;

  const DashboardStats({
    required this.totalVacunaciones,
    required this.perrosVacunados,
    required this.gatosVacunados,
    required this.pendientesSincronizacion,
    required this.porSector,
    required this.porVacunador,
  });
}
