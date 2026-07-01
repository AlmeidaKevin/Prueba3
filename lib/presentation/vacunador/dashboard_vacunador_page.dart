import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../shared/providers/auth_provider.dart';
import '../../data/local/database/app_database.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final dashboardVacunadorProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return {};

  final vacunaciones = await supabase
      .from('vacunaciones')
      .select('id, tipo_mascota, fecha_vacunacion')
      .eq('vacunador_id', userId)
      .order('fecha_vacunacion', ascending: false);

  int perros = 0, gatos = 0;
  for (final v in vacunaciones as List) {
    if (v['tipo_mascota'] == 'perro') perros++;
    if (v['tipo_mascota'] == 'gato') gatos++;
  }

  final pendientes =
      await ref.watch(vacunacionesDaoProvider).cantidadPendientes();

  return {
    'total': (vacunaciones).length,
    'perros': perros,
    'gatos': gatos,
    'pendientes': pendientes,
  };
});

final registrosVacunadorProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];

  return supabase
      .from('vacunaciones')
      .select('id, propietario_nombre, mascota_nombre, tipo_mascota, vacuna_aplicada, fecha_vacunacion, foto_url, sectores(nombre)')
      .eq('vacunador_id', userId)
      .order('fecha_vacunacion', ascending: false);
});

// ─── Página ───────────────────────────────────────────────────────────────────

class DashboardVacunadorPage extends ConsumerWidget {
  const DashboardVacunadorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardVacunadorProvider);
    final usuarioAsync = ref.watch(authProvider);

    return statsAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 8),
              Text('Error: $e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(dashboardVacunadorProvider),
                style: FilledButton.styleFrom(
                    backgroundColor: RolColors.vacunadorPrimary),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      data: (stats) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardVacunadorProvider),
        child: CustomScrollView(
          slivers: [
            // ── SliverAppBar teal ──────────────────────────────────
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: RolColors.vacunadorPrimary,
              foregroundColor: Colors.white,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => ref.invalidate(dashboardVacunadorProvider),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: RolColors.vacunadorGradient,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -20, right: -20,
                        child: Container(
                          width: 140, height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10, left: -30,
                        child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                      ),
                      usuarioAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (usuario) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                          child: Row(
                            children: [
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    usuario?.nombres.isNotEmpty == true
                                        ? usuario!.nombres[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: RolColors.vacunadorPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Bienvenido,\n${usuario?.nombreCompleto ?? ''}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      usuario?.correo ?? '',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.75),
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                        'Vacunador',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Offline banner ────────────────────────────
                  if ((stats['pendientes'] as int) > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.cloud_off, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Text(
                            '${stats['pendientes']} registro(s) pendientes de sincronización',
                            style: TextStyle(color: Colors.orange.shade800),
                          ),
                        ],
                      ),
                    ),

                  // ── Tarjetas de resumen ───────────────────────
                  Row(children: [
                    Expanded(child: _StatCard(
                      label: 'Total', valor: stats['total'] as int,
                      icon: Icons.vaccines,
                      color: RolColors.vacunadorPrimary,
                      bgColor: const Color(0xFFE0F2F1),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(
                      label: 'Perros', valor: stats['perros'] as int,
                      icon: Icons.pets,
                      color: Colors.brown.shade600,
                      bgColor: Colors.brown.shade50,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(
                      label: 'Gatos', valor: stats['gatos'] as int,
                      icon: Icons.pets,
                      color: Colors.orange.shade700,
                      bgColor: Colors.orange.shade50,
                    )),
                  ]),
                  const SizedBox(height: 24),

                  // ── Acciones rápidas ─────────────────────────
                  _SectionTitle(icon: Icons.bolt, title: 'Acciones rápidas'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _AccionBtn(
                      label: 'Mis sectores',
                      icon: Icons.map_outlined,
                      color: RolColors.vacunadorPrimary,
                      onTap: () => context.push('/sectores-asignados'),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _AccionBtn(
                      label: 'Ver registros',
                      icon: Icons.list_alt_outlined,
                      color: RolColors.vacunadorSecondary,
                      onTap: () => context.push('/mis-registros'),
                    )),
                  ]),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: RolColors.vacunadorPrimary),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: RolColors.vacunadorPrimary)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int valor;
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _StatCard({required this.label, required this.valor,
      required this.icon, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text('$valor',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _AccionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AccionBtn({required this.label, required this.icon,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

