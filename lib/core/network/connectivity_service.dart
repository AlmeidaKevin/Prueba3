import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/local/database/app_database.dart';

// ═══════════════════════════════════════════
// CONNECTIVITY
// ═══════════════════════════════════════════

final connectivityStreamProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (result) => result != ConnectivityResult.none,
  );
});

final isConnectedProvider = FutureProvider<bool>((ref) async {
  final result = await Connectivity().checkConnectivity();
  return result != ConnectivityResult.none;
});

// ═══════════════════════════════════════════
// SYNC SERVICE
// ═══════════════════════════════════════════

class SyncService {
  final VacunacionesDao _vacunacionesDao;
  final SupabaseClient _supabase;

  SyncService({
    required VacunacionesDao vacunacionesDao,
    required SupabaseClient supabase,
  })  : _vacunacionesDao = vacunacionesDao,
        _supabase = supabase;

  Future<void> sincronizarPendientes() async {
    final pendientes = await _vacunacionesDao.obtenerNoPendientes();

    for (final vac in pendientes) {
      try {
        String? fotoUrl;

        // Si hay foto local, subirla primero
        if (vac.fotoLocalPath != null && vac.fotoUrl == null) {
          final file = File(vac.fotoLocalPath!);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final path = 'vacunaciones/${vac.id}.jpg';
            await _supabase.storage.from('fotos').uploadBinary(
              path, bytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
            fotoUrl = _supabase.storage.from('fotos').getPublicUrl(path);
          }
        }

        // Insertar o actualizar en Supabase
        await _supabase.from('vacunaciones').upsert({
          'id': vac.id,
          'vacunador_id': vac.vacunadorId,
          'sector_id': vac.sectorId,
          'propietario_nombre': vac.propietarioNombre,
          'propietario_cedula': vac.propietarioCedula,
          'propietario_telefono': vac.propietarioTelefono,
          'tipo_mascota': vac.tipoMascota,
          'mascota_nombre': vac.mascotaNombre,
          'mascota_edad_aprox': vac.mascotaEdadAprox,
          'mascota_sexo': vac.mascotaSexo,
          'vacuna_aplicada': vac.vacunaAplicada,
          'observaciones': vac.observaciones,
          'foto_url': fotoUrl ?? vac.fotoUrl,
          'latitud': vac.latitud,
          'longitud': vac.longitud,
          'fecha_vacunacion': vac.fechaVacunacion.toIso8601String(),
        });

        await _vacunacionesDao.marcarSincronizado(vac.id);
      } catch (_) {
        // Continuar con el siguiente, se reintentará después
      }
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    vacunacionesDao: ref.watch(vacunacionesDaoProvider),
    supabase: Supabase.instance.client,
  );
});