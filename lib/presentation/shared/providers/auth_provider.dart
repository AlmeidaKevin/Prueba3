import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/entities.dart';
import '../../../data/models/models.dart';

// ═══════════════════════════════════════════
// SUPABASE CLIENT PROVIDER
// ═══════════════════════════════════════════

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ═══════════════════════════════════════════
// AUTH NOTIFIER
// ═══════════════════════════════════════════

class AuthNotifier extends AsyncNotifier<Usuario?> {
  @override
  Future<Usuario?> build() async {
    final supabase = ref.watch(supabaseProvider);
    final session = supabase.auth.currentSession;
    if (session == null) return null;
    return _cargarPerfil(session.user.id);
  }

  Future<Usuario?> _cargarPerfil(String userId) async {
    final supabase = ref.read(supabaseProvider);
    try {
      final data = await supabase
          .from('perfiles')
          .select()
          .eq('id', userId)
          .single();
      return UsuarioModel.fromJson(data);
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando perfil para $userId: $e');
      return null;
    }
  }

  /// Retorna null si ok, o mensaje de error si falla.
  /// NO modifica state hasta tener el resultado — así el router
  /// no redirige antes de que la LoginPage muestre el error.
  Future<String?> login(String correo, String password) async {
    try {
      final supabase = ref.read(supabaseProvider);
      final response = await supabase.auth.signInWithPassword(
        email: correo,
        password: password,
      );
      if (response.user == null) return 'Credenciales invalidas';
      final usuario = await _cargarPerfil(response.user!.id);
      if (usuario == null) {
        // Autenticado en Supabase Auth pero sin perfil en la tabla perfiles
        await supabase.auth.signOut();
        return 'Usuario no tiene perfil asignado. Contacta al administrador.';
      }
      // Solo aqui actualizamos el state — el router redirige despues de esto
      state = AsyncData(usuario);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error de conexion. Verifica tu internet.';
    }
  }

  Future<String?> cambiarPassword(String nuevaPassword) async {
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.auth.updateUser(
        UserAttributes(password: nuevaPassword),
      );
      final userId = supabase.auth.currentUser!.id;
      await supabase
          .from('perfiles')
          .update({'primer_login': false}).eq('id', userId);

      final usuario = await _cargarPerfil(userId);
      state = AsyncData(usuario);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error al cambiar la contrasena';
    }
  }

  Future<String?> recuperarPassword(String correo) async {
    try {
      final supabase = ref.read(supabaseProvider);
      await supabase.auth.resetPasswordForEmail(correo);
      return null;
    } catch (e) {
      return 'Error al enviar el correo de recuperacion';
    }
  }

  Future<void> logout() async {
    final supabase = ref.read(supabaseProvider);
    await supabase.auth.signOut();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, Usuario?>(
  AuthNotifier.new,
);