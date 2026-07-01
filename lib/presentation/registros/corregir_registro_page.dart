import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../presentation/shared/providers/auth_provider.dart';

class CorregirRegistroPage extends ConsumerStatefulWidget {
  final String vacunacionId;
  const CorregirRegistroPage({super.key, required this.vacunacionId});

  @override
  ConsumerState<CorregirRegistroPage> createState() =>
      _CorregirRegistroPageState();
}

class _CorregirRegistroPageState extends ConsumerState<CorregirRegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _propNombreCtrl = TextEditingController();
  final _propCedulaCtrl = TextEditingController();
  final _propTelefonoCtrl = TextEditingController();
  final _mascNombreCtrl = TextEditingController();
  final _mascEdadCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();

  String? _vacunaSeleccionada;
  String? _tipoMascota;
  String? _mascotaSexo;
  File? _nuevaFoto;
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
    _propNombreCtrl.dispose();
    _propCedulaCtrl.dispose();
    _propTelefonoCtrl.dispose();
    _mascNombreCtrl.dispose();
    _mascEdadCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final data = await ref
          .read(supabaseProvider)
          .from('vacunaciones')
          .select()
          .eq('id', widget.vacunacionId)
          .single();
      setState(() {
        _datos = data;
        _propNombreCtrl.text = data['propietario_nombre'] as String? ?? '';
        _propCedulaCtrl.text = data['propietario_cedula'] as String? ?? '';
        _propTelefonoCtrl.text = data['propietario_telefono'] as String? ?? '';
        _mascNombreCtrl.text = data['mascota_nombre'] as String? ?? '';
        _mascEdadCtrl.text = data['mascota_edad_aprox'] as String? ?? '';
        _observacionesCtrl.text = data['observaciones'] as String? ?? '';
        _tipoMascota = data['tipo_mascota'] as String?;
        _mascotaSexo = data['mascota_sexo'] as String?;
        final vacuna = data['vacuna_aplicada'] as String?;
        _vacunaSeleccionada =
            AppConstants.vacunas.contains(vacuna) ? vacuna : null;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _tomarFoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 75, maxWidth: 1280,
    );
    if (picked != null) setState(() => _nuevaFoto = File(picked.path));
  }

  Future<void> _elegirGaleria() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75, maxWidth: 1280,
    );
    if (picked != null) setState(() => _nuevaFoto = File(picked.path));
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final supabase = ref.read(supabaseProvider);
      final userId = supabase.auth.currentUser?.id;

      String? fotoUrl = _datos?['foto_url'] as String?;

      // Subir nueva foto si se seleccionó una
      if (_nuevaFoto != null) {
        final fotoBytes = await _nuevaFoto!.readAsBytes();
        final fotoPath = 'vacunaciones/${widget.vacunacionId}_edit.jpg';
        await supabase.storage.from('fotos').uploadBinary(
          fotoPath, fotoBytes,
          fileOptions: const FileOptions(
              contentType: 'image/jpeg', upsert: true),
        );
        fotoUrl = supabase.storage.from('fotos').getPublicUrl(fotoPath);
      }

      await supabase.from('vacunaciones').update({
        'propietario_nombre': _propNombreCtrl.text.trim(),
        'propietario_cedula': _propCedulaCtrl.text.trim(),
        'propietario_telefono': _propTelefonoCtrl.text.trim(),
        'mascota_nombre': _mascNombreCtrl.text.trim(),
        'mascota_edad_aprox': _mascEdadCtrl.text.trim(),
        'mascota_sexo': _mascotaSexo,
        'tipo_mascota': _tipoMascota,
        'vacuna_aplicada': _vacunaSeleccionada,
        'observaciones': _observacionesCtrl.text.trim(),
        if (fotoUrl != null) 'foto_url': fotoUrl,
        'editado_por': userId,
        'ultima_edicion': DateTime.now().toIso8601String(),
      }).eq('id', widget.vacunacionId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Registro corregido exitosamente'),
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
    // Determinar rol y colores
    final rol = ref.watch(authProvider).asData?.value?.rol ?? '';
    final esBrigada = rol == Roles.coordinadorBrigada;
    final primary = esBrigada
        ? RolColors.brigadaPrimary
        : RolColors.vacunadorPrimary;
    final gradient = esBrigada
        ? RolColors.brigadaGradient
        : RolColors.vacunadorGradient;
    final titulo = esBrigada ? 'Corregir registro' : 'Editar mi registro';
    final aviso = esBrigada
        ? 'Coordinador de brigada — puedes corregir todos los campos del registro.'
        : 'Vacunador — puedes editar todos los campos de tu propio registro.';

    if (_cargando) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: primary),
        ),
      );
    }

    if (_datos == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(titulo, style: const TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              const Text('No se encontró el registro'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar con color por rol ─────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: Text(titulo, style: const TextStyle(color: Colors.white)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(titulo,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            _datos!['mascota_nombre'] as String? ?? '',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Foto actual / nueva ──────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _nuevaFoto != null
                          ? Image.file(_nuevaFoto!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover)
                          : _datos!['foto_url'] != null
                              ? CachedNetworkImage(
                                  imageUrl: _datos!['foto_url'] as String,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    height: 180,
                                    color: Colors.grey.shade100,
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    height: 80,
                                    color: Colors.grey.shade100,
                                    child: const Icon(Icons.broken_image,
                                        size: 48, color: Colors.grey),
                                  ),
                                )
                              : Container(
                                  height: 100,
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                      child: Icon(Icons.image_not_supported,
                                          color: Colors.grey, size: 40)),
                                ),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _tomarFoto,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: BorderSide(color: primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: const Text('Nueva foto'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _elegirGaleria,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: BorderSide(color: primary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.photo_library, size: 16),
                          label: const Text('Galería'),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // ── Aviso de rol ─────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit_note, color: primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(aviso,
                                style: TextStyle(
                                    fontSize: 12, color: primary)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Propietario ──────────────────────────────
                    _SectionLabel(label: 'Propietario',
                        icon: Icons.person_outline, color: primary),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _propNombreCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nombre completo *',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _propCedulaCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Cédula *',
                        prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo obligatorio';
                        if (v.length != 10) return 'Debe tener 10 dígitos';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _propTelefonoCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Mascota ──────────────────────────────────
                    _SectionLabel(label: 'Mascota',
                        icon: Icons.pets_outlined, color: primary),
                    const SizedBox(height: 10),

                    // Toggle tipo mascota
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _tipoMascota = 'perro'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _tipoMascota == 'perro'
                                      ? primary : Colors.transparent,
                                  borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(11)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.pets, size: 16,
                                        color: _tipoMascota == 'perro'
                                            ? Colors.white : Colors.grey),
                                    const SizedBox(width: 6),
                                    Text('Perro',
                                        style: TextStyle(
                                            color: _tipoMascota == 'perro'
                                                ? Colors.white : Colors.grey,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _tipoMascota = 'gato'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _tipoMascota == 'gato'
                                      ? primary : Colors.transparent,
                                  borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(11)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.pets, size: 16,
                                        color: _tipoMascota == 'gato'
                                            ? Colors.white : Colors.grey),
                                    const SizedBox(width: 6),
                                    Text('Gato',
                                        style: TextStyle(
                                            color: _tipoMascota == 'gato'
                                                ? Colors.white : Colors.grey,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _mascNombreCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la mascota *',
                        prefixIcon: const Icon(Icons.pets, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _mascEdadCtrl,
                          decoration: InputDecoration(
                            labelText: 'Edad aprox.',
                            hintText: 'Ej: 2 años',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            filled: true, fillColor: Colors.grey.shade50,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _mascotaSexo,
                          decoration: InputDecoration(
                            labelText: 'Sexo',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            filled: true, fillColor: Colors.grey.shade50,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'macho', child: Text('Macho')),
                            DropdownMenuItem(value: 'hembra', child: Text('Hembra')),
                          ],
                          onChanged: (v) => setState(() => _mascotaSexo = v),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // ── Vacunación ───────────────────────────────
                    _SectionLabel(label: 'Vacunación',
                        icon: Icons.vaccines_outlined, color: primary),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _vacunaSeleccionada,
                      decoration: InputDecoration(
                        labelText: 'Vacuna aplicada *',
                        prefixIcon: const Icon(Icons.vaccines_outlined, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                      ),
                      items: AppConstants.vacunas
                          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() => _vacunaSeleccionada = v),
                      validator: (v) =>
                          v == null ? 'Selecciona la vacuna' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _observacionesCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Observaciones',
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.notes_outlined, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _guardando ? null : _guardar,
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _guardando
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save_outlined),
                        label: Text(
                            _guardando ? 'Guardando...' : 'Guardar corrección',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SectionLabel(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1.1)),
        const SizedBox(width: 8),
        Expanded(
            child: Divider(
                color: color.withValues(alpha: 0.3), thickness: 1)),
      ],
    );
  }
}