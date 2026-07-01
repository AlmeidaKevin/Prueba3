import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../presentation/shared/providers/auth_provider.dart';

final vacunadoresBrigadaProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;

  // 1. Sectores del coordinador
  final asignacionesCoord = await supabase
      .from('asignaciones')
      .select('sector_id')
      .eq('usuario_id', userId!)
      .eq('activo', true);

  final sectorIds = (asignacionesCoord as List)
      .map((a) => a['sector_id'] as String)
      .toList();

  if (sectorIds.isEmpty) return [];

  // 2. IDs de vacunadores (perfiles con rol vacunador)
  final perfilesVacunadores = await supabase
      .from('perfiles')
      .select('id')
      .eq('rol', Roles.vacunador);

  final vacunadorIds = (perfilesVacunadores as List)
      .map((p) => p['id'] as String)
      .toList();

  if (vacunadorIds.isEmpty) return [];

  // 3. Asignaciones de esos vacunadores en esos sectores
  final data = await supabase
      .from('asignaciones')
      .select('id, usuario_id, activo, sector_id, sectores(id, nombre), perfiles!asignaciones_usuario_id_fkey(id, nombres, apellidos, cedula, correo, telefono)')
      .inFilter('sector_id', sectorIds)
      .inFilter('usuario_id', vacunadorIds);

  return (data as List).cast<Map<String, dynamic>>();
});

class VacunadoresListPage extends ConsumerWidget {
  const VacunadoresListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(vacunadoresBrigadaProvider);

    return Scaffold(
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error_outline,
                      size: 48, color: Colors.red.shade400),
                ),
                const SizedBox(height: 16),
                const Text('Error al cargar vacunadores',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('$e',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(vacunadoresBrigadaProvider),
                  style: FilledButton.styleFrom(
                      backgroundColor: RolColors.brigadaPrimary),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (lista) => CustomScrollView(
          slivers: [
            // ── SliverAppBar ─────────────────────────────────────
            SliverAppBar(
              expandedHeight: 150,
              pinned: true,
              backgroundColor: RolColors.brigadaPrimary,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Vacunadores',
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
                          width: 130, height: 130,
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
                            const Text('Vacunadores',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              '${lista.length} vacunador(es) registrado(s)',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Contenido ─────────────────────────────────────────
            lista.isEmpty
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
                          Text('Usa el botón para agregar uno',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final item = lista[i];
                          final perfil = item['perfiles'] as Map<String, dynamic>?;
                          if (perfil == null) return const SizedBox.shrink();
                          final sector = item['sectores'] as Map<String, dynamic>?;
                          final activo = item['activo'] as bool? ?? true;
                          return _VacunadorCard(
                            perfil: perfil,
                            sectorNombre: sector?['nombre'] as String? ?? 'Sin sector',
                            activo: activo,
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
        onPressed: () => context.push(AppRoutes.crearVacunador),
        backgroundColor: RolColors.brigadaPrimary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Agregar vacunador',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _VacunadorCard extends StatelessWidget {
  final Map<String, dynamic> perfil;
  final String sectorNombre;
  final bool activo;

  const _VacunadorCard({
    required this.perfil,
    required this.sectorNombre,
    required this.activo,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = (perfil['nombres'] as String)[0].toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: activo
                      ? RolColors.brigadaGradient
                      : [Colors.grey.shade300, Colors.grey.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(inicial,
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
                  Text(
                    '${perfil['nombres']} ${perfil['apellidos']}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: activo ? null : Colors.grey),
                  ),
                  const SizedBox(height: 3),
                  Text('Cédula: ${perfil['cedula']}',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 12, color: RolColors.brigadaPrimary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(sectorNombre,
                            style: const TextStyle(
                                fontSize: 11,
                                color: RolColors.brigadaPrimary,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: activo ? Colors.green.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                activo ? 'Activo' : 'Inactivo',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: activo ? Colors.green.shade700 : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}