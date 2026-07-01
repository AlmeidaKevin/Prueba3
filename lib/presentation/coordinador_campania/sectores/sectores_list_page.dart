import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../shared/providers/auth_provider.dart';

final sectoresCampaniaProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref
      .watch(supabaseProvider)
      .from('sectores')
      .select('id, nombre, ciudad, descripcion, created_at')
      .order('nombre');
});

class SectoresListPage extends ConsumerWidget {
  const SectoresListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectoresAsync = ref.watch(sectoresCampaniaProvider);

    return Scaffold(
      body: sectoresAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 8),
              Text('Error: $e'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(sectoresCampaniaProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (sectores) => CustomScrollView(
          slivers: [
            // ── SliverAppBar con degradado ───────────────────────
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              title: const Text('Sectores', style: TextStyle(color: Colors.white)),
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
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
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
                              'Sectores',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${sectores.length} sector(es) registrado(s)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
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

            // ── Lista de sectores ────────────────────────────────
            sectores.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            'No hay sectores registrados',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final s = sectores[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _SectorCard(
                              sector: s,
                              onTap: () async {
                                await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => _DetalleSectorSheet(
                                    sector: s,
                                    onActualizado: () => ref.invalidate(
                                        sectoresCampaniaProvider),
                                  ),
                                );
                                ref.invalidate(sectoresCampaniaProvider);
                              },
                            ),
                          );
                        },
                        childCount: sectores.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.crearSector),
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text(
          'Nuevo sector',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─── Card de sector ───────────────────────────────────────────────────────────

class _SectorCard extends StatelessWidget {
  final Map<String, dynamic> sector;
  final VoidCallback onTap;
  const _SectorCard({required this.sector, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final desc = sector['descripcion'] as String?;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.location_on,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sector['nombre'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      desc?.isNotEmpty == true
                          ? desc!
                          : sector['ciudad'] as String? ?? 'Quito',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chevron_right,
                    color: Color(0xFF1B5E20), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom sheet compartido ──────────────────────────────────────────────────

class _DetalleSectorSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> sector;
  final VoidCallback onActualizado;

  const _DetalleSectorSheet({
    required this.sector,
    required this.onActualizado,
  });

  @override
  ConsumerState<_DetalleSectorSheet> createState() =>
      _DetalleSectorSheetState();
}

class _DetalleSectorSheetState
    extends ConsumerState<_DetalleSectorSheet> {
  bool _modoEdicion = false;
  late TextEditingController _descripcionCtrl;
  bool _guardando = false;
  bool _eliminando = false;
  late String? _descripcionActual;

  @override
  void initState() {
    super.initState();
    _descripcionActual = widget.sector['descripcion'] as String?;
    _descripcionCtrl =
        TextEditingController(text: _descripcionActual ?? '');
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      final nuevaDesc = _descripcionCtrl.text.trim();
      await ref.read(supabaseProvider).from('sectores').update({
        'descripcion': nuevaDesc.isEmpty ? null : nuevaDesc,
      }).eq('id', widget.sector['id'] as String);

      setState(() {
        _descripcionActual = nuevaDesc.isEmpty ? null : nuevaDesc;
        _modoEdicion = false;
      });
      widget.onActualizado();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descripción actualizada'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar sector'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar el sector '
          '"${widget.sector['nombre']}"?\n\nEsta acción no se puede deshacer.',
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

    if (confirmar != true) return;
    setState(() => _eliminando = true);

    try {
      await ref
          .read(supabaseProvider)
          .from('sectores')
          .delete()
          .eq('id', widget.sector['id'] as String);

      if (!mounted) return;
      widget.onActualizado();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Sector "${widget.sector['nombre']}" eliminado'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _eliminando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Cabecera
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.sector['nombre'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.sector['ciudad'] as String? ?? 'Quito',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _modoEdicion
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Editar descripción',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descripcionCtrl,
                        maxLines: 4,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  setState(() => _modoEdicion = false),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed:
                                  _guardando ? null : _guardar,
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF1B5E20),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              icon: _guardando
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Icon(Icons.save_outlined),
                              label: Text(_guardando
                                  ? 'Guardando...'
                                  : 'Guardar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey.shade200),
                        ),
                        child: Text(
                          (_descripcionActual?.isNotEmpty == true)
                              ? _descripcionActual!
                              : 'Sin descripción',
                          style: TextStyle(
                            color:
                                (_descripcionActual?.isNotEmpty == true)
                                    ? null
                                    : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  setState(() => _modoEdicion = true),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    const Color(0xFF1B5E20),
                                side: const BorderSide(
                                    color: Color(0xFF1B5E20)),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              icon: const Icon(Icons.edit_outlined,
                                  size: 18),
                              label: const Text('Editar',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed:
                                  _eliminando ? null : _eliminar,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              icon: _eliminando
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Icon(Icons.delete_outline,
                                      size: 18),
                              label: Text(_eliminando
                                  ? 'Eliminando...'
                                  : 'Eliminar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}