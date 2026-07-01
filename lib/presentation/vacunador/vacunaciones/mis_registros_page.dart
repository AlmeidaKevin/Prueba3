import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/providers/auth_provider.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final misRegistrosProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];

  return supabase
      .from('vacunaciones')
      .select('id, propietario_nombre, propietario_cedula, mascota_nombre, tipo_mascota, vacuna_aplicada, fecha_vacunacion, foto_url, observaciones, latitud, longitud, sectores(nombre)')
      .eq('vacunador_id', userId)
      .order('fecha_vacunacion', ascending: false);
});

// ─── Página ───────────────────────────────────────────────────────────────────

class MisRegistrosPage extends ConsumerWidget {
  const MisRegistrosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrosAsync = ref.watch(misRegistrosProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: RolColors.vacunadorPrimary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Mis registros',
                style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => ref.invalidate(misRegistrosProvider),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: RolColors.vacunadorGradient,
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
                          const Text('Mis vacunaciones',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text('Toca un registro para editar o eliminar',
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
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 12),
                    Text('Error: $e', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(misRegistrosProvider),
                      style: FilledButton.styleFrom(
                          backgroundColor: RolColors.vacunadorPrimary),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
            data: (registros) => registros.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.vaccines_outlined,
                              size: 72, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No tienes registros aún',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          SizedBox(height: 8),
                          Text('Registra tu primera vacunación',
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
                        (context, i) => _RegistroCard(
                          registro: registros[i],
                          onTap: () => _mostrarOpciones(
                              context, ref, registros[i]),
                        ),
                        childCount: registros.length,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _mostrarOpciones(BuildContext context, WidgetRef ref,
      Map<String, dynamic> registro) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OpcionesSheet(
        registro: registro,
        onEditado: () => ref.invalidate(misRegistrosProvider),
        onEliminado: () => ref.invalidate(misRegistrosProvider),
      ),
    );
  }
}

// ─── Card de registro ─────────────────────────────────────────────────────────

class _RegistroCard extends StatelessWidget {
  final Map<String, dynamic> registro;
  final VoidCallback onTap;
  const _RegistroCard({required this.registro, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final esPero = registro['tipo_mascota'] == 'perro';
    final sector = (registro['sectores'] as Map?)?['nombre'] ?? '';
    final fecha = DateTime.tryParse(registro['fecha_vacunacion'] as String? ?? '');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Foto
              if (registro['foto_url'] != null)
                CachedNetworkImage(
                  imageUrl: registro['foto_url'] as String,
                  height: 130, width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 130, color: Colors.grey.shade100,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 60, color: Colors.grey.shade100,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
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
                    if (sector.isNotEmpty)
                      _InfoRow(icon: Icons.location_on_outlined, text: sector),
                    const SizedBox(height: 8),
                    // Indicador de toque
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Toca para editar o eliminar',
                            style: TextStyle(
                                fontSize: 11,
                                color: RolColors.vacunadorPrimary,
                                fontStyle: FontStyle.italic)),
                        const SizedBox(width: 4),
                        Icon(Icons.touch_app_outlined,
                            size: 14, color: RolColors.vacunadorPrimary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}

// ─── Sheet de opciones ────────────────────────────────────────────────────────

class _OpcionesSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> registro;
  final VoidCallback onEditado;
  final VoidCallback onEliminado;

  const _OpcionesSheet({
    required this.registro,
    required this.onEditado,
    required this.onEliminado,
  });

  @override
  ConsumerState<_OpcionesSheet> createState() => _OpcionesSheetState();
}

class _OpcionesSheetState extends ConsumerState<_OpcionesSheet> {
  bool _modoEdicion = false;
  late TextEditingController _obsCtrl;
  late TextEditingController _edadCtrl;
  bool _guardando = false;
  bool _eliminando = false;

  @override
  void initState() {
    super.initState();
    _obsCtrl = TextEditingController(
        text: widget.registro['observaciones'] as String? ?? '');
    _edadCtrl = TextEditingController(
        text: widget.registro['mascota_edad_aprox'] as String? ?? '');
  }

  @override
  void dispose() {
    _obsCtrl.dispose();
    _edadCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      final userId = ref.read(supabaseProvider).auth.currentUser?.id;
      await ref.read(supabaseProvider).from('vacunaciones').update({
        'observaciones': _obsCtrl.text.trim(),
        'mascota_edad_aprox': _edadCtrl.text.trim(),
        'editado_por': userId,
        'ultima_edicion': DateTime.now().toIso8601String(),
      }).eq('id', widget.registro['id'] as String);

      if (!mounted) return;
      widget.onEditado();
      setState(() => _modoEdicion = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro actualizado'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar registro'),
          ],
        ),
        content: Text(
          '¿Estás seguro de eliminar el registro de '
          '"${widget.registro['mascota_nombre']}"?',
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

    if (confirmar != true || !mounted) return;
    setState(() => _eliminando = true);

    try {
      await ref.read(supabaseProvider)
          .from('vacunaciones')
          .delete()
          .eq('id', widget.registro['id'] as String);

      if (!mounted) return;
      widget.onEliminado();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro eliminado'),
            backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: RolColors.vacunadorGradient,
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
                  child: Icon(
                    widget.registro['tipo_mascota'] == 'perro'
                        ? Icons.pets
                        : Icons.pets,
                    color: Colors.white, size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.registro['mascota_nombre'] as String,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Propietario: ${widget.registro['propietario_nombre']}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _modoEdicion
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Editar registro',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _edadCtrl,
                        decoration: InputDecoration(
                          labelText: 'Edad aproximada',
                          hintText: 'Ej: 2 años',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true, fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _obsCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Observaciones',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true, fillColor: Colors.grey.shade50,
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
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _guardando ? null : _guardar,
                              style: FilledButton.styleFrom(
                                backgroundColor: RolColors.vacunadorPrimary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: _guardando
                                  ? const SizedBox(width: 16, height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.save_outlined),
                              label: Text(_guardando ? 'Guardando...' : 'Guardar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      // Info de solo lectura
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _InfoFila(label: 'Vacuna',
                                valor: widget.registro['vacuna_aplicada'] as String),
                            _InfoFila(label: 'Observaciones',
                                valor: (widget.registro['observaciones'] as String?)
                                    ?.isNotEmpty == true
                                    ? widget.registro['observaciones'] as String
                                    : 'Sin observaciones'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                context.push(
                                    '/editar-vacunacion/${widget.registro['id']}');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: RolColors.vacunadorPrimary,
                                side: const BorderSide(
                                    color: RolColors.vacunadorPrimary),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Editar',
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _eliminando ? null : _eliminar,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: _eliminando
                                  ? const SizedBox(width: 16, height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.delete_outline, size: 18),
                              label: Text(
                                  _eliminando ? 'Eliminando...' : 'Eliminar'),
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

class _InfoFila extends StatelessWidget {
  final String label;
  final String valor;
  const _InfoFila({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
              child: Text(valor,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}