import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/shared/providers/auth_provider.dart';


class EditarVacunacionPage extends ConsumerStatefulWidget {
  final String vacunacionId;
  const EditarVacunacionPage({super.key, required this.vacunacionId});

  @override
  ConsumerState<EditarVacunacionPage> createState() =>
      _EditarVacunacionPageState();
}

class _EditarVacunacionPageState
    extends ConsumerState<EditarVacunacionPage> {
  final _formKey = GlobalKey<FormState>();
  final _observacionesCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  bool _cargando = true;
  bool _guardando = false;
  Map<String, dynamic>? _datos;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _observacionesCtrl.dispose();
    _edadCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final supabase = ref.read(supabaseProvider);
      final userId = supabase.auth.currentUser?.id;

      // El vacunador solo puede editar sus propios registros (RLS lo refuerza en Supabase)
      final data = await supabase
          .from('vacunaciones')
          .select()
          .eq('id', widget.vacunacionId)
          .eq('vacunador_id', userId!)
          .single();

      setState(() {
        _datos = data;
        _observacionesCtrl.text = data['observaciones'] as String? ?? '';
        _edadCtrl.text = data['mascota_edad_aprox'] as String? ?? '';
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final userId = ref.read(supabaseProvider).auth.currentUser?.id;
      await ref.read(supabaseProvider).from('vacunaciones').update({
        'mascota_edad_aprox': _edadCtrl.text.trim(),
        'observaciones': _observacionesCtrl.text.trim(),
        'editado_por': userId,
        'ultima_edicion': DateTime.now().toIso8601String(),
      }).eq('id', widget.vacunacionId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Registro actualizado exitosamente'),
            backgroundColor: Colors.green),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_datos == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar registro')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text('Registro no encontrado o sin permisos'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar mi registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto del registro
              if (_datos!['foto_url'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: _datos!['foto_url'] as String,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 48),
                  ),
                ),
              const SizedBox(height: 16),

              // Resumen (solo lectura)
              Card(
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Información del registro',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      _InfoRow(
                          label: 'Propietario',
                          valor: _datos!['propietario_nombre'] as String),
                      _InfoRow(
                          label: 'Mascota',
                          valor: '${_datos!['mascota_nombre']} (${_datos!['tipo_mascota']})'),
                      _InfoRow(
                          label: 'Vacuna',
                          valor: _datos!['vacuna_aplicada'] as String),
                      if (_datos!['latitud'] != null)
                        _InfoRow(
                            label: 'GPS',
                            valor:
                                '${(_datos!['latitud'] as num).toStringAsFixed(5)}, '
                                '${(_datos!['longitud'] as num).toStringAsFixed(5)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Solo puedes editar la edad aproximada y las observaciones.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _edadCtrl,
                decoration: const InputDecoration(
                    labelText: 'Edad aproximada',
                    hintText: 'Ej: 2 años, 6 meses'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observacionesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    alignLabelWithHint: true),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: Text(_guardando ? 'Guardando...' : 'Guardar cambios'),
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
  final String label;
  final String valor;
  const _InfoRow({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:',
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey)),
          ),
          Expanded(
              child: Text(valor, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
