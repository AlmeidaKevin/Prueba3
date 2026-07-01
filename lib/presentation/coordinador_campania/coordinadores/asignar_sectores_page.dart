import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../presentation/shared/providers/auth_provider.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

// Sectores actualmente asignados al coordinador
final sectoresAsignadosCoordProvider =
    FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>(
        (ref, coordinadorId) async {
  return ref
      .watch(supabaseProvider)
      .from('asignaciones')
      .select('id, activo, sectores(id, nombre, ciudad)')
      .eq('usuario_id', coordinadorId)
      .order('created_at');
});

// Todos los sectores disponibles
final todosLosSectoresProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref
      .watch(supabaseProvider)
      .from('sectores')
      .select('id, nombre, ciudad')
      .order('nombre');
});

// ─── Página ───────────────────────────────────────────────────────────────────

class AsignarSectoresPage extends ConsumerWidget {
  final Map<String, dynamic> coordinador;

  const AsignarSectoresPage({super.key, required this.coordinador});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinadorId = coordinador['id'] as String;
    final asignadosAsync =
        ref.watch(sectoresAsignadosCoordProvider(coordinadorId));
    final todosAsync = ref.watch(todosLosSectoresProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: RolColors.campaniaPrimary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Asignar sectores',
                style: TextStyle(color: Colors.white)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: RolColors.campaniaGradient,
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
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    (coordinador['nombres'] as String)[0]
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${coordinador['nombres']} ${coordinador['apellidos']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Coordinador de brigada',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Sectores asignados ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: RolColors.campaniaPrimary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.map_outlined,
                        color: RolColors.campaniaPrimary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Sectores asignados',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  asignadosAsync.when(
                    data: (list) {
                      final activos = list
                          .where((a) => a['activo'] == true)
                          .length;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: RolColors.campaniaPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$activos activo(s)',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // Lista de asignaciones actuales
          asignadosAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $e'),
              ),
            ),
            data: (asignaciones) => asignaciones.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Sin sectores asignados aún',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final a = asignaciones[i];
                          final sector = a['sectores'] as Map;
                          final activo = a['activo'] as bool? ?? true;
                          return _AsignacionTile(
                            asignacionId: a['id'] as String,
                            sectorNombre: sector['nombre'] as String,
                            sectorCiudad:
                                sector['ciudad'] as String? ?? 'Quito',
                            activo: activo,
                            onToggle: () async {
                              await _toggleAsignacion(
                                  context, ref, a['id'] as String, activo);
                              ref.invalidate(
                                  sectoresAsignadosCoordProvider(
                                      coordinadorId));
                            },
                            onEliminar: () async {
                              await _eliminarAsignacion(
                                  context, ref, a['id'] as String);
                              ref.invalidate(
                                  sectoresAsignadosCoordProvider(
                                      coordinadorId));
                            },
                          );
                        },
                        childCount: asignaciones.length,
                      ),
                    ),
                  ),
          ),

          // ── Agregar nuevo sector ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_location_alt_outlined,
                        color: Colors.teal, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Asignar nuevo sector',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          todosAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Text('Error: $e'),
            ),
            data: (todos) {
              // Filtrar sectores que ya están asignados y activos
              final asignadosList = asignadosAsync.asData?.value ?? [];
              final yaAsignados = asignadosList
                      .where((a) => a['activo'] == true)
                      .map((a) =>
                          (a['sectores'] as Map)['id'] as String)
                      .toSet();

              final disponibles = todos
                  .where((s) => !yaAsignados.contains(s['id']))
                  .toList();

              if (disponibles.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Todos los sectores ya están asignados',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final s = disponibles[i];
                      return _SectorDisponibleTile(
                        sector: s,
                        onAsignar: () async {
                          await _asignarSector(
                              context, ref, coordinadorId, s['id'] as String);
                          ref.invalidate(
                              sectoresAsignadosCoordProvider(coordinadorId));
                          ref.invalidate(todosLosSectoresProvider);
                        },
                      );
                    },
                    childCount: disponibles.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _asignarSector(BuildContext context, WidgetRef ref,
      String coordinadorId, String sectorId) async {
    try {
      final supabase = ref.read(supabaseProvider);
      final creadorId = supabase.auth.currentUser!.id;

      // Verificar si ya existía una asignación inactiva para reactivarla
      final existente = await supabase
          .from('asignaciones')
          .select('id')
          .eq('usuario_id', coordinadorId)
          .eq('sector_id', sectorId)
          .maybeSingle();

      if (existente != null) {
        await supabase
            .from('asignaciones')
            .update({'activo': true})
            .eq('id', existente['id'] as String);
      } else {
        await supabase.from('asignaciones').insert({
          'usuario_id': coordinadorId,
          'sector_id': sectorId,
          'asignado_por': creadorId,
          'activo': true,
        });
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sector asignado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _toggleAsignacion(BuildContext context, WidgetRef ref,
      String asignacionId, bool activo) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('asignaciones')
          .update({'activo': !activo})
          .eq('id', asignacionId);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(activo ? 'Sector desactivado' : 'Sector reactivado'),
          backgroundColor: activo ? Colors.orange : Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _eliminarAsignacion(BuildContext context, WidgetRef ref,
      String asignacionId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.link_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Quitar sector'),
          ],
        ),
        content: const Text(
            '¿Estás seguro de que deseas quitar este sector del coordinador?'),
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
            child: const Text('Quitar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !context.mounted) return;

    try {
      await ref
          .read(supabaseProvider)
          .from('asignaciones')
          .delete()
          .eq('id', asignacionId);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sector eliminado de la asignación'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

// ─── Tile de asignación existente ─────────────────────────────────────────────

class _AsignacionTile extends StatelessWidget {
  final String asignacionId;
  final String sectorNombre;
  final String sectorCiudad;
  final bool activo;
  final VoidCallback onToggle;
  final VoidCallback onEliminar;

  const _AsignacionTile({
    required this.asignacionId,
    required this.sectorNombre,
    required this.sectorCiudad,
    required this.activo,
    required this.onToggle,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: activo
              ? RolColors.campaniaPrimary.withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: activo
                ? RolColors.campaniaPrimary.withValues(alpha: 0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.location_on,
            color: activo
                ? RolColors.campaniaPrimary
                : Colors.grey,
            size: 22,
          ),
        ),
        title: Text(
          sectorNombre,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: activo ? null : Colors.grey,
          ),
        ),
        subtitle: Row(
          children: [
            Text(sectorCiudad,
                style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: activo
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                activo ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: activo
                      ? Colors.green.shade700
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle activo/inactivo
            IconButton(
              onPressed: onToggle,
              tooltip: activo ? 'Desactivar' : 'Reactivar',
              icon: Icon(
                activo
                    ? Icons.toggle_on_outlined
                    : Icons.toggle_off_outlined,
                color: activo ? Colors.green : Colors.grey,
                size: 28,
              ),
            ),
            // Eliminar
            IconButton(
              onPressed: onEliminar,
              tooltip: 'Quitar sector',
              icon: Icon(Icons.link_off,
                  color: Colors.red.shade400, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tile de sector disponible para asignar ───────────────────────────────────

class _SectorDisponibleTile extends StatelessWidget {
  final Map<String, dynamic> sector;
  final VoidCallback onAsignar;

  const _SectorDisponibleTile(
      {required this.sector, required this.onAsignar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.location_on_outlined,
              color: Colors.grey.shade500, size: 22),
        ),
        title: Text(
          sector['nombre'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          sector['ciudad'] as String? ?? 'Quito',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: FilledButton.icon(
          onPressed: onAsignar,
          style: FilledButton.styleFrom(
            backgroundColor: RolColors.campaniaPrimary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          icon: const Icon(Icons.add_link, size: 16),
          label: const Text('Asignar',
              style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}