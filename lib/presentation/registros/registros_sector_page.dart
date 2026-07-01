import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../presentation/shared/providers/auth_provider.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final registrosSectorProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;

  final mis = await supabase
      .from('asignaciones')
      .select('sector_id')
      .eq('usuario_id', userId!)
      .eq('activo', true);

  final sectorIds =
      (mis as List).map((a) => a['sector_id'] as String).toList();
  if (sectorIds.isEmpty) return [];

  return supabase
      .from('vacunaciones')
      .select('id, propietario_nombre, mascota_nombre, tipo_mascota, vacuna_aplicada, fecha_vacunacion, foto_url, sectores(nombre), perfiles!vacunaciones_vacunador_id_fkey(nombres, apellidos)')
      .inFilter('sector_id', sectorIds)
      .order('fecha_vacunacion', ascending: false);
});

// ─── Página ───────────────────────────────────────────────────────────────────

class RegistrosSectorPage extends ConsumerWidget {
  const RegistrosSectorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrosAsync = ref.watch(registrosSectorProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: RolColors.brigadaPrimary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Registros del sector',
                style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => ref.invalidate(registrosSectorProvider),
              ),
            ],
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
                          const Text('Registros de vacunación',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text('Toca un registro para corregirlo',
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

          registrosAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (registros) => registros.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.vaccines_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('Sin registros de vacunación',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Aún no hay vacunaciones en tu sector',
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
                          final r = registros[i];
                          return _RegistroCard(
                            registro: r,
                            onCorregir: () => context.push(
                              '/corregir-registro/${r['id']}',
                            ),
                          );
                        },
                        childCount: registros.length,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Card de registro ─────────────────────────────────────────────────────────

class _RegistroCard extends StatelessWidget {
  final Map<String, dynamic> registro;
  final VoidCallback onCorregir;

  const _RegistroCard({required this.registro, required this.onCorregir});

  @override
  Widget build(BuildContext context) {
    final esPero = registro['tipo_mascota'] == 'perro';
    final perfil = registro['perfiles'] as Map?;
    final vacunador = perfil != null
        ? '${perfil['nombres']} ${perfil['apellidos']}'
        : 'Desconocido';
    final sector = (registro['sectores'] as Map?)?['nombre'] ?? '';
    final fecha = DateTime.tryParse(
            registro['fecha_vacunacion'] as String? ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Foto si existe
            if (registro['foto_url'] != null)
              CachedNetworkImage(
                imageUrl: registro['foto_url'] as String,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 130,
                  color: Colors.grey.shade100,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 60,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: esPero
                              ? Colors.brown.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pets,
                                size: 12,
                                color: esPero
                                    ? Colors.brown
                                    : Colors.orange.shade700),
                            const SizedBox(width: 4),
                            Text(
                              esPero ? 'Perro' : 'Gato',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: esPero
                                      ? Colors.brown
                                      : Colors.orange.shade700),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          registro['mascota_nombre'] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      if (fecha != null)
                        Text(
                          '${fecha.day}/${fecha.month}/${fecha.year}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.person_outline,
                      text: registro['propietario_nombre'] as String),
                  _InfoRow(icon: Icons.medical_services_outlined,
                      text: registro['vacuna_aplicada'] as String),
                  _InfoRow(icon: Icons.location_on_outlined, text: sector),
                  _InfoRow(icon: Icons.badge_outlined, text: vacunador),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onCorregir,
                      style: FilledButton.styleFrom(
                        backgroundColor: RolColors.brigadaPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Corregir registro',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}