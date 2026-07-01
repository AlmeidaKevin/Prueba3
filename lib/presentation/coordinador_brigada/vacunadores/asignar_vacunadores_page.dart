import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../presentation/shared/providers/auth_provider.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final vacunadoresConAsignacionProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;

  // 1. Sectores del coordinador
  final mis = await supabase
      .from('asignaciones')
      .select('sector_id')
      .eq('usuario_id', userId!)
      .eq('activo', true);

  final sectorIds =
      (mis as List).map((a) => a['sector_id'] as String).toList();
  if (sectorIds.isEmpty) return [];

  // 2. IDs de vacunadores
  final perfilesVac = await supabase
      .from('perfiles')
      .select('id')
      .eq('rol', Roles.vacunador);

  final vacunadorIds =
      (perfilesVac as List).map((p) => p['id'] as String).toList();
  if (vacunadorIds.isEmpty) return [];

  // 3. Asignaciones cruzadas
  final data = await supabase
      .from('asignaciones')
      .select('id, activo, sector_id, sectores(id, nombre), perfiles!asignaciones_usuario_id_fkey(id, nombres, apellidos, cedula)')
      .inFilter('sector_id', sectorIds)
      .inFilter('usuario_id', vacunadorIds);

  return (data as List).cast<Map<String, dynamic>>();
});

final sectoresBrigadaProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;
  final data = await supabase
      .from('asignaciones')
      .select('sector_id, sectores(id, nombre)')
      .eq('usuario_id', userId!)
      .eq('activo', true);
  return (data as List).cast<Map<String, dynamic>>();
});

// ─── Página ───────────────────────────────────────────────────────────────────

class AsignarVacunadoresPage extends ConsumerWidget {
  const AsignarVacunadoresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaAsync = ref.watch(vacunadoresConAsignacionProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: RolColors.brigadaPrimary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Asignar vacunadores',
                style: TextStyle(color: Colors.white)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: RolColors.brigadaGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30, right: -30,
                      child: Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10, left: -20,
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.assignment_ind,
                              color: Colors.white, size: 28),
                          const SizedBox(height: 6),
                          const Text('Gestión de vacunadores',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text('Asigna o reasigna sectores a vacunadores',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenido ─────────────────────────────────────────
          listaAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 12),
                      Text('Error: $e', textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () =>
                            ref.invalidate(vacunadoresConAsignacionProvider),
                        style: FilledButton.styleFrom(
                            backgroundColor: RolColors.brigadaPrimary),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (lista) => lista.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_off_outlined,
                              size: 72, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No hay vacunadores registrados',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(height: 8),
                          Text('Crea vacunadores primero desde el menú',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final item = lista[i];
                          final perfil =
                              item['perfiles'] as Map<String, dynamic>?;
                          if (perfil == null) return const SizedBox.shrink();
                          final sector =
                              item['sectores'] as Map<String, dynamic>?;
                          final activo = item['activo'] as bool? ?? true;
                          return _VacunadorAsignacionCard(
                            asignacionId: item['id'] as String,
                            nombres:
                                '${perfil['nombres']} ${perfil['apellidos']}',
                            cedula: perfil['cedula'] as String,
                            sectorActual:
                                sector?['nombre'] as String? ?? 'Sin sector',
                            activo: activo,
                            onReasignar: () => _mostrarReasignacion(
                              context, ref,
                              item['id'] as String,
                              '${perfil['nombres']} ${perfil['apellidos']}',
                            ),
                            onToggle: () async {
                              await _toggleAsignacion(
                                  context, ref, item['id'] as String, activo);
                              ref.invalidate(vacunadoresConAsignacionProvider);
                            },
                          );
                        },
                        childCount: lista.length,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _mostrarReasignacion(BuildContext context, WidgetRef ref,
      String asignacionId, String nombre) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReasignarSheet(
        asignacionId: asignacionId,
        nombreVacunador: nombre,
        onReasignado: () => ref.invalidate(vacunadoresConAsignacionProvider),
      ),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(activo ? 'Vacunador desactivado' : 'Vacunador reactivado'),
        backgroundColor: activo ? Colors.orange : Colors.green,
      ));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }
}

// ─── Card de vacunador ────────────────────────────────────────────────────────

class _VacunadorAsignacionCard extends StatelessWidget {
  final String asignacionId;
  final String nombres;
  final String cedula;
  final String sectorActual;
  final bool activo;
  final VoidCallback onReasignar;
  final VoidCallback onToggle;

  const _VacunadorAsignacionCard({
    required this.asignacionId, required this.nombres,
    required this.cedula, required this.sectorActual,
    required this.activo, required this.onReasignar, required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activo
              ? RolColors.brigadaPrimary.withValues(alpha: 0.25)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: activo
                          ? RolColors.brigadaGradient
                          : [Colors.grey.shade300, Colors.grey.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(nombres[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombres,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: activo ? null : Colors.grey)),
                      Text('Cédula: $cedula',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:
                        activo ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    activo ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color:
                            activo ? Colors.green.shade700 : Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: RolColors.brigadaPrimary),
                  const SizedBox(width: 6),
                  Text('Sector: ',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                  Expanded(
                    child: Text(sectorActual,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReasignar,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RolColors.brigadaPrimary,
                      side: const BorderSide(color: RolColors.brigadaPrimary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Reasignar sector',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onToggle,
                  tooltip: activo ? 'Desactivar' : 'Reactivar',
                  icon: Icon(
                    activo ? Icons.toggle_on : Icons.toggle_off,
                    color: activo ? Colors.green : Colors.grey,
                    size: 32,
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

// ─── Sheet de reasignación ────────────────────────────────────────────────────

class _ReasignarSheet extends ConsumerWidget {
  final String asignacionId;
  final String nombreVacunador;
  final VoidCallback onReasignado;

  const _ReasignarSheet({
    required this.asignacionId,
    required this.nombreVacunador,
    required this.onReasignado,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectoresAsync = ref.watch(sectoresBrigadaProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: RolColors.brigadaGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reasignar sector',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Vacunador: $nombreVacunador',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: sectoresAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (sectores) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selecciona el nuevo sector:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...sectores.map((a) {
                    final sector = a['sectores'] as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: RolColors.brigadaPrimary
                                .withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: RolColors.brigadaPrimary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_on,
                              color: RolColors.brigadaPrimary, size: 20),
                        ),
                        title: Text(sector['nombre'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: RolColors.brigadaPrimary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                          ),
                          onPressed: () async {
                            try {
                              await ref
                                  .read(supabaseProvider)
                                  .from('asignaciones')
                                  .update({'sector_id': sector['id']})
                                  .eq('id', asignacionId);
                              if (!context.mounted) return;
                              onReasignado();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sector reasignado exitosamente'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red));
                            }
                          },
                          child: const Text('Asignar',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}