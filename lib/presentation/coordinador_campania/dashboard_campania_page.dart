import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/entities.dart';
import '../../presentation/shared/providers/auth_provider.dart';
import '../../../data/local/database/app_database.dart';

// ─── Provider de estadísticas ────────────────────────────────────────────────

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final supabase = ref.watch(supabaseProvider);

  final data = await supabase
      .from('vacunaciones')
      .select(
          'tipo_mascota, sector_id, vacunador_id, sectores(nombre), perfiles!vacunaciones_vacunador_id_fkey(nombres, apellidos)');

  final localPendientes =
      await ref.watch(vacunacionesDaoProvider).cantidadPendientes();

  int perros = 0, gatos = 0;
  final Map<String, int> porSector = {};
  final Map<String, int> porVacunador = {};

  for (final v in data as List) {
    if (v['tipo_mascota'] == 'perro') perros++;
    if (v['tipo_mascota'] == 'gato') gatos++;

    final sectorNombre =
        (v['sectores'] as Map?)?['nombre'] as String? ?? 'Sin sector';
    porSector[sectorNombre] = (porSector[sectorNombre] ?? 0) + 1;

    final perfil = v['perfiles'] as Map?;
    final vacunadorNombre = perfil != null
        ? '${perfil['nombres']} ${perfil['apellidos']}'
        : 'Desconocido';
    porVacunador[vacunadorNombre] =
        (porVacunador[vacunadorNombre] ?? 0) + 1;
  }

  return DashboardStats(
    totalVacunaciones: (data).length,
    perrosVacunados: perros,
    gatosVacunados: gatos,
    pendientesSincronizacion: localPendientes,
    porSector: porSector,
    porVacunador: porVacunador,
  );
});

// ─── Página ──────────────────────────────────────────────────────────────────

class DashboardCampaniaPage extends ConsumerWidget {
  const DashboardCampaniaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final usuarioAsync = ref.watch(authProvider);

    return statsAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          body: Center(
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
                const Text(
                  'Error al cargar estadísticas',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '$e',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(dashboardStatsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        ),
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardStatsProvider),
          child: CustomScrollView(
            slivers: [
              // ── AppBar con degradado ─────────────────────────────
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF1B5E20),
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
                    onPressed: () => ref.invalidate(dashboardStatsProvider),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1B5E20),
                          Color(0xFF2E7D32),
                          Color(0xFF43A047),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Círculos decorativos
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: -30,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                        // Contenido del header
                        usuarioAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (usuario) => Padding(
                            padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      usuario?.nombres.isNotEmpty == true
                                          ? usuario!.nombres[0]
                                              .toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B5E20),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Bienvenido, \n${usuario?.nombreCompleto ?? ''}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        usuario?.correo ?? '',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.75),
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
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'Coordinador de campaña',
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
                    // ── Alerta offline ─────────────────────────────
                    if (stats.pendientesSincronizacion > 0)
                      _OfflineBanner(
                          cantidad: stats.pendientesSincronizacion),

                    // ── Tarjetas de resumen ────────────────────────
                    Row(children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total',
                          valor: stats.totalVacunaciones,
                          icon: Icons.vaccines,
                          color: const Color(0xFF1B5E20),
                          bgColor: const Color(0xFFE8F5E9),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Perros',
                          valor: stats.perrosVacunados,
                          icon: Icons.pets,
                          color: Colors.brown.shade600,
                          bgColor: Colors.brown.shade50,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          label: 'Gatos',
                          valor: stats.gatosVacunados,
                          icon: Icons.pets,
                          color: Colors.orange.shade700,
                          bgColor: Colors.orange.shade50,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // ── Acciones rápidas ───────────────────────────
                    _SectionTitle(
                        icon: Icons.bolt, title: 'Acciones rápidas'),
                    const SizedBox(height: 10),

                    // Fila 1: Sectores
                    Row(
                      children: [
                        Expanded(
                          child: _AccionBtn(
                            label: 'Ver sectores',
                            icon: Icons.map_outlined,
                            color: const Color(0xFF1B5E20),
                            onTap: () =>
                                context.push(AppRoutes.sectores),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _AccionBtn(
                            label: 'Crear sector',
                            icon: Icons.add_location_alt_outlined,
                            color: const Color(0xFF2E7D32),
                            onTap: () =>
                                context.push(AppRoutes.crearSector),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Fila 2: Coordinadores
                    Row(
                      children: [
                        Expanded(
                          child: _AccionBtn(
                            label: 'Ver coordinadores',
                            icon: Icons.people_outline,
                            color: Colors.teal.shade700,
                            onTap: () =>
                                context.push(AppRoutes.coordinadores),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _AccionBtn(
                            label: 'Crear coordinador',
                            icon: Icons.person_add_outlined,
                            color: Colors.teal.shade800,
                            onTap: () => context
                                .push(AppRoutes.crearCoordinador),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Gráfico por sector ─────────────────────────
                    if (stats.porSector.isNotEmpty) ...[
                      _SectionTitle(
                          icon: Icons.bar_chart,
                          title: 'Por sector'),
                      const SizedBox(height: 8),
                      _BarChart(
                          datos: stats.porSector,
                          color: const Color(0xFF1B5E20)),
                      const SizedBox(height: 24),
                    ],

                    // ── Gráfico por vacunador ──────────────────────
                    if (stats.porVacunador.isNotEmpty) ...[
                      _SectionTitle(
                          icon: Icons.person_outline,
                          title: 'Por vacunador'),
                      const SizedBox(height: 8),
                      _BarChart(
                          datos: stats.porVacunador,
                          color: Colors.teal.shade600),
                      const SizedBox(height: 24),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1B5E20)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
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

  const _StatCard({
    required this.label,
    required this.valor,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            '$valor',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AccionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

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
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final Map<String, int> datos;
  final Color color;

  const _BarChart({required this.datos, required this.color});

  @override
  Widget build(BuildContext context) {
    final entries = datos.entries.toList();
    final maxVal =
        entries.fold<int>(0, (prev, e) => e.value > prev ? e.value : prev);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxVal + 2).toDouble(),
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles:
                      SideTitles(showTitles: true, reservedSize: 28),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= entries.length) {
                        return const SizedBox.shrink();
                      }
                      final label = entries[idx].key;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          label.length > 8
                              ? '${label.substring(0, 7)}...'
                              : label,
                          style: const TextStyle(fontSize: 9),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(
                entries.length,
                (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: entries[i].value.toDouble(),
                      color: color,
                      width: 18,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6)),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: (maxVal + 2).toDouble(),
                        color: color.withValues(alpha: 0.07),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final int cantidad;
  const _OfflineBanner({required this.cantidad});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Expanded(
            child: Text(
              '$cantidad registro(s) pendientes de sincronización',
              style: TextStyle(color: Colors.orange.shade800),
            ),
          ),
        ],
      ),
    );
  }
}