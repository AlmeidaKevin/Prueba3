import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/providers/auth_provider.dart';
import 'asignar_sectores_page.dart';

final coordinadoresBrigadaProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref
      .watch(supabaseProvider)
      .from('perfiles')
      .select('id, nombres, apellidos, cedula, correo, telefono')
      .eq('rol', Roles.coordinadorBrigada)
      .order('apellidos');
});

// Provider para obtener sector asignado de un usuario
final sectorUsuarioProvider =
    FutureProvider.family<String?, String>((ref, userId) async {
  try {
    final data = await ref
        .watch(supabaseProvider)
        .from('asignaciones')
        .select('sectores(nombre)')
        .eq('usuario_id', userId)
        .eq('activo', true)
        .maybeSingle();
    if (data == null) return null;
    return (data['sectores'] as Map?)?['nombre'] as String?;
  } catch (_) {
    return 'No disponible';
  }
});

class CoordinadoresListPage extends ConsumerWidget {
  const CoordinadoresListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(coordinadoresBrigadaProvider);

    return Scaffold(
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Colors.red.shade300),
              const SizedBox(height: 8),
              Text('Error: $e'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(coordinadoresBrigadaProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (lista) => CustomScrollView(
          slivers: [
            // ── SliverAppBar ──────────────────────────────────────
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              title: const Text('Coordinadores', style: TextStyle(color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go(AppRoutes.dashboard),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -30,
                        right: -30,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 60, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Coordinadores de brigada',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${lista.length} coordinador(es) registrado(s)',
                              style: TextStyle(
                                color:
                                    Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Lista ─────────────────────────────────────────────
            lista.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline,
                                size: 72, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Sin coordinadores registrados',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Aún no hay coordinadores de brigada.\nUsa el botón de abajo para registrar el primero.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final u = lista[i];
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: 10),
                            child: _CoordinadorCard(
                              usuario: u,
                              onVer: () => _verUsuario(
                                  context, ref, u),
                              onAsignar: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AsignarSectoresPage(
                                    coordinador: u,
                                  ),
                                ),
                              ),
                              onEliminar: () => _eliminarUsuario(
                                  context, ref, u),
                            ),
                          );
                        },
                        childCount: lista.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.crearCoordinador),
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Agregar coordinador',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _verUsuario(
      BuildContext context, WidgetRef ref, Map<String, dynamic> u) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetalleUsuarioSheet(usuario: u),
    );
  }

  Future<void> _eliminarUsuario(BuildContext context, WidgetRef ref,
      Map<String, dynamic> u) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar coordinador'),
          ],
        ),
        content: Text(
          '¿Estás seguro de eliminar a '
          '"${u['nombres']} ${u['apellidos']}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !context.mounted) return;

    try {
      // Eliminar asignaciones primero
      await ref.read(supabaseProvider)
          .from('asignaciones')
          .delete()
          .eq('usuario_id', u['id'] as String);

      // Eliminar perfil
      await ref.read(supabaseProvider)
          .from('perfiles')
          .delete()
          .eq('id', u['id'] as String);

      ref.invalidate(coordinadoresBrigadaProvider);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Coordinador "${u['nombres']}" eliminado'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ─── Card de coordinador ──────────────────────────────────────────────────────

class _CoordinadorCard extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback onVer;
  final VoidCallback onAsignar;
  final VoidCallback onEliminar;

  const _CoordinadorCard({
    required this.usuario,
    required this.onVer,
    required this.onAsignar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final inicial =
        (usuario['nombres'] as String)[0].toUpperCase();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: RolColors.campaniaGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  inicial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${usuario['nombres']} ${usuario['apellidos']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    usuario['cedula'] as String,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            // Botones Ver, Asignar sectores y Eliminar
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ver
                IconButton(
                  onPressed: onVer,
                  icon: const Icon(Icons.visibility_outlined),
                  color: RolColors.campaniaPrimary,
                  tooltip: 'Ver usuario',
                  style: IconButton.styleFrom(
                    backgroundColor: RolColors.campaniaPrimary
                        .withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 6),
                // Asignar sectores
                IconButton(
                  onPressed: onAsignar,
                  icon: const Icon(Icons.map_outlined),
                  color: Colors.teal,
                  tooltip: 'Gestionar sectores',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Colors.teal.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 6),
                // Eliminar
                IconButton(
                  onPressed: onEliminar,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: 'Eliminar usuario',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Colors.red.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom sheet detalle usuario ────────────────────────────────────────────

class _DetalleUsuarioSheet extends ConsumerWidget {
  final Map<String, dynamic> usuario;
  const _DetalleUsuarioSheet({required this.usuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectorAsync =
        ref.watch(sectorUsuarioProvider(usuario['id'] as String));

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Cabecera con degradado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (usuario['nombres'] as String)[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${usuario['nombres']} ${usuario['apellidos']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Coordinador de brigada',
                          style: TextStyle(
                              color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Datos del usuario
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              children: [
                _InfoFila(
                  icon: Icons.badge_outlined,
                  label: 'Cédula',
                  valor: usuario['cedula'] as String,
                ),
                _InfoFila(
                  icon: Icons.phone_outlined,
                  label: 'Teléfono',
                  valor: usuario['telefono'] as String,
                ),
                _InfoFila(
                  icon: Icons.email_outlined,
                  label: 'Correo electrónico',
                  valor: usuario['correo'] as String,
                ),
                sectorAsync.when(
                  loading: () => const _InfoFila(
                    icon: Icons.map_outlined,
                    label: 'Sector asignado',
                    valor: 'Cargando...',
                  ),
                  error: (_, __) => const _InfoFila(
                    icon: Icons.map_outlined,
                    label: 'Sector asignado',
                    valor: 'No disponible',
                  ),
                  data: (sector) => _InfoFila(
                    icon: Icons.map_outlined,
                    label: 'Sector asignado',
                    valor: sector ?? 'Sin asignación',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoFila extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  const _InfoFila(
      {required this.icon, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                size: 18, color: const Color(0xFF1B5E20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
                Text(
                  valor,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}