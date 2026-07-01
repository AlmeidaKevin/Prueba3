import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/shared/providers/auth_provider.dart';
import '../../../presentation/shared/widgets/scaffold_menu.dart';
import 'sectores_list_page.dart';

class CrearSectorPage extends ConsumerStatefulWidget {
  const CrearSectorPage({super.key});

  @override
  ConsumerState<CrearSectorPage> createState() => _CrearSectorPageState();
}

class _CrearSectorPageState extends ConsumerState<CrearSectorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  String _ciudad = 'Quito';
  bool _guardando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final supabase = ref.read(supabaseProvider);
      final nombre = _nombreCtrl.text.trim();

      final existente = await supabase
          .from('sectores')
          .select('id')
          .ilike('nombre', nombre)
          .maybeSingle();

      if (existente != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ya existe un sector llamado "$nombre"'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _guardando = false);
        return;
      }

      await supabase.from('sectores').insert({
        'nombre': nombre,
        'ciudad': _ciudad,
        'descripcion': _descripcionCtrl.text.trim().isEmpty
            ? null
            : _descripcionCtrl.text.trim(),
      });

      if (!mounted) return;
      ref.invalidate(sectoresCampaniaProvider);
      _nombreCtrl.clear();
      _descripcionCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sector "$nombre" creado exitosamente'),
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

  void _verSector(Map<String, dynamic> sector) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetalleSectorSheet(
        sector: sector,
        onActualizado: () => ref.invalidate(sectoresCampaniaProvider),
      ),
    );
    // Refrescar después de cerrar el sheet
    ref.invalidate(sectoresCampaniaProvider);
  }

  @override
  Widget build(BuildContext context) {
    final sectoresAsync = ref.watch(sectoresCampaniaProvider);

    final usuario = ref.watch(authProvider).asData?.value;

    return Scaffold(
      drawer: ScaffoldMenu(usuario: usuario, child: const SizedBox.shrink()),
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar con degradado ─────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go(AppRoutes.sectores),
            ),
            title: const Text(
              'Crear sector',
              style: TextStyle(color: Colors.white),
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
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.add_location_alt,
                              color: Colors.white, size: 28),
                          const SizedBox(height: 6),
                          const Text(
                            'Nuevo sector',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Registra un nuevo sector o barrio',
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
            ),
          ),

          // ── Formulario ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nombre del sector *',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Campo obligatorio';
                        }
                        if (v.trim().length < 3) return 'El nombre es muy corto';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: _ciudad,
                      decoration: InputDecoration(
                        labelText: 'Ciudad',
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (v) => _ciudad = v,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descripcionCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Descripción (opcional)',
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.notes_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: _guardando ? null : _crear,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.add_location_alt),
                        label: Text(
                            _guardando ? 'Creando...' : 'Crear sector'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Divisor ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.list_alt,
                      size: 16, color: Color(0xFF1B5E20)),
                  const SizedBox(width: 6),
                  const Text(
                    'Sectores registrados',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const Spacer(),
                  sectoresAsync.when(
                    data: (s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${s.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // ── Lista ──────────────────────────────────────────────
          sectoresAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $e'),
              ),
            ),
            data: (sectores) => sectores.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.map_outlined,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No hay sectores registrados aún',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final s = sectores[sectores.length - 1 - i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _SectorTile(
                              sector: s,
                              onTap: () => _verSector(s),
                            ),
                          );
                        },
                        childCount: sectores.length,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Tile de sector ───────────────────────────────────────────────────────────

class _SectorTile extends StatelessWidget {
  final Map<String, dynamic> sector;
  final VoidCallback onTap;
  const _SectorTile({required this.sector, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final desc = sector['descripcion'] as String?;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on,
                    color: Color(0xFF1B5E20), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sector['nombre'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (desc != null && desc.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        desc,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom sheet: detalle + editar + eliminar ────────────────────────────────

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
  final _formKey = GlobalKey<FormState>();
  bool _guardando = false;
  bool _eliminando = false;
  // Descripción local para reflejar cambios inmediatamente
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

      // Actualizar estado local para mostrar cambio inmediatamente
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Eliminar sector'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar el sector '
          '"${widget.sector['nombre']}"?\n\n'
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
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    setState(() => _eliminando = true);

    try {
      await ref.read(supabaseProvider)
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
          // Handle
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

          // Cabecera del sheet con degradado
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
                ? Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Editar descripción',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
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
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Descripción actual
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
                          border:
                              Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          (_descripcionActual?.isNotEmpty == true)
                              ? _descripcionActual!
                              : 'Sin descripción',
                          style: TextStyle(
                            color: (_descripcionActual?.isNotEmpty ==
                                    true)
                                ? null
                                : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botones Editar y Eliminar
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
                              label: const Text(
                                'Editar',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
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