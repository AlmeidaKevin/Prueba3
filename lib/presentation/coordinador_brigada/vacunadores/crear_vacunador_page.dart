import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../presentation/shared/providers/auth_provider.dart';
import 'vacunadores_list_page.dart';

class CrearVacunadorPage extends ConsumerStatefulWidget {
  const CrearVacunadorPage({super.key});

  @override
  ConsumerState<CrearVacunadorPage> createState() => _CrearVacunadorPageState();
}

class _CrearVacunadorPageState extends ConsumerState<CrearVacunadorPage> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();

  String? _errorCedula;
  String? _errorNombres;
  String? _errorApellidos;
  String? _errorTelefono;
  String? _sectorSeleccionado;
  bool _cargando = false;

  late final _sectoresProvider =
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

  @override
  void initState() {
    super.initState();
    _cedulaCtrl.addListener(_validarCedula);
    _nombresCtrl.addListener(_validarNombres);
    _apellidosCtrl.addListener(_validarApellidos);
    _telefonoCtrl.addListener(_validarTelefono);
  }

  void _validarCedula() {
    final v = _cedulaCtrl.text;
    setState(() {
      if (v.isEmpty) _errorCedula = null;
      else if (RegExp(r'[^0-9]').hasMatch(v)) _errorCedula = 'Solo se aceptan valores numéricos';
      else if (v.length > 10) _errorCedula = 'Máximo 10 dígitos permitidos';
      else _errorCedula = null;
    });
  }

  void _validarNombres() {
    final v = _nombresCtrl.text;
    setState(() {
      _errorNombres = (v.isNotEmpty && RegExp(r'[0-9]').hasMatch(v))
          ? 'No se aceptan valores numéricos' : null;
    });
  }

  void _validarApellidos() {
    final v = _apellidosCtrl.text;
    setState(() {
      _errorApellidos = (v.isNotEmpty && RegExp(r'[0-9]').hasMatch(v))
          ? 'No se aceptan valores numéricos' : null;
    });
  }

  void _validarTelefono() {
    final v = _telefonoCtrl.text;
    setState(() {
      if (v.isEmpty) _errorTelefono = null;
      else if (RegExp(r'[^0-9]').hasMatch(v)) _errorTelefono = 'Solo se aceptan valores numéricos';
      else if (v.length > 10) _errorTelefono = 'Máximo 10 dígitos permitidos';
      else _errorTelefono = null;
    });
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    if (_errorCedula != null || _errorNombres != null ||
        _errorApellidos != null || _errorTelefono != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Corrige los errores antes de continuar'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_sectorSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona un sector')));
      return;
    }

    setState(() => _cargando = true);
    try {
      final supabase = ref.read(supabaseProvider);
      final creadorId = supabase.auth.currentUser!.id;
      final correo = _correoCtrl.text.trim();

      String? nuevoUserId;
      try {
        final resp = await supabase.auth.signUp(
          email: correo,
          password: AppConstants.passwordInicial,
        );
        nuevoUserId = resp.user?.id;
      } on AuthException catch (e) {
        if (e.message.toLowerCase().contains('seconds')) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Espera unos segundos antes de crear otro usuario.'),
            backgroundColor: Colors.orange,
          ));
          setState(() => _cargando = false);
          return;
        }
        rethrow;
      }

      if (nuevoUserId == null) throw Exception('No se pudo crear el usuario');

      await supabase.from('perfiles').insert({
        'id': nuevoUserId,
        'cedula': _cedulaCtrl.text.trim(),
        'nombres': _nombresCtrl.text.trim(),
        'apellidos': _apellidosCtrl.text.trim(),
        'telefono': _telefonoCtrl.text.trim(),
        'correo': correo,
        'rol': Roles.vacunador,
        'primer_login': true,
        'creado_por': creadorId,
      });

      await supabase.from('asignaciones').insert({
        'usuario_id': nuevoUserId,
        'sector_id': _sectorSeleccionado,
        'asignado_por': creadorId,
      });

      if (!mounted) return;
      ref.invalidate(vacunadoresBrigadaProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${_nombresCtrl.text} creado exitosamente. '
            'Contraseña: ${AppConstants.passwordInicial}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ));
      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}'), backgroundColor: Colors.red));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectoresAsync = ref.watch(_sectoresProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: RolColors.brigadaPrimary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Nuevo vacunador',
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
                          const Text('Nuevo vacunador',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text('Completa los datos del nuevo vacunador',
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

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(label: 'Identificación', icon: Icons.badge_outlined),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _cedulaCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Cédula de identidad *',
                        prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                        errorText: _errorCedula,
                        helperText: '10 dígitos exactos',
                        counterText: '${_cedulaCtrl.text.length}/10',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo obligatorio';
                        if (v.length != 10) return 'Debe tener exactamente 10 dígitos';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _SectionLabel(label: 'Datos personales', icon: Icons.person_outline),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nombresCtrl,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Nombres *',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                        errorText: _errorNombres,
                        helperText: 'Solo letras y espacios',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
                        if (v.trim().length < 2) return 'Nombre muy corto';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apellidosCtrl,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Apellidos *',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                        errorText: _errorApellidos,
                        helperText: 'Solo letras y espacios',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
                        if (v.trim().length < 2) return 'Apellidos muy cortos';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _SectionLabel(label: 'Contacto', icon: Icons.contact_phone_outlined),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _telefonoCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Teléfono *',
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                        errorText: _errorTelefono,
                        helperText: '10 dígitos exactos',
                        counterText: '${_telefonoCtrl.text.length}/10',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo obligatorio';
                        if (v.length != 10) return 'Debe tener exactamente 10 dígitos';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico *',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo obligatorio';
                        if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(v)) return 'Correo inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _SectionLabel(label: 'Sector asignado', icon: Icons.map_outlined),
                    const SizedBox(height: 10),
                    sectoresAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Error: $e'),
                      data: (asignaciones) => DropdownButtonFormField<String>(
                        value: _sectorSeleccionado,
                        decoration: InputDecoration(
                          labelText: 'Sector *',
                          prefixIcon: const Icon(Icons.map_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true, fillColor: Colors.grey.shade50,
                        ),
                        items: asignaciones.map((a) {
                          final sector = a['sectores'] as Map;
                          return DropdownMenuItem(
                            value: sector['id'] as String,
                            child: Text(sector['nombre'] as String),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _sectorSeleccionado = v),
                        validator: (v) => v == null ? 'Selecciona un sector' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Contraseña inicial: ${AppConstants.passwordInicial}\n'
                              'El vacunador deberá cambiarla en su primer ingreso.',
                              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _cargando ? null : _crear,
                        style: FilledButton.styleFrom(
                          backgroundColor: RolColors.brigadaPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _cargando
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.person_add),
                        label: Text(_cargando ? 'Creando...' : 'Crear vacunador',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: RolColors.brigadaPrimary),
        const SizedBox(width: 6),
        Text(label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: RolColors.brigadaPrimary,
              letterSpacing: 1.1,
            )),
        const SizedBox(width: 8),
        Expanded(child: Divider(
            color: RolColors.brigadaPrimary.withValues(alpha: 0.3),
            thickness: 1)),
      ],
    );
  }
}