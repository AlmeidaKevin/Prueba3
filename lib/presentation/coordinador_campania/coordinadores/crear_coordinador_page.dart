import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/widgets/scaffold_menu.dart';

class CrearUsuarioForm extends ConsumerStatefulWidget {
  final String titulo;
  final String rol;
  final String? sectorIdFijo;

  const CrearUsuarioForm({
    super.key,
    required this.titulo,
    required this.rol,
    this.sectorIdFijo,
  });

  @override
  ConsumerState<CrearUsuarioForm> createState() => _CrearUsuarioFormState();
}

class _CrearUsuarioFormState extends ConsumerState<CrearUsuarioForm> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();

  // Errores en tiempo real por campo
  String? _errorCedula;
  String? _errorNombres;
  String? _errorApellidos;
  String? _errorTelefono;

  String? _sectorSeleccionado;
  bool _cargando = false;

  final _sectoresProvider =
      FutureProvider<List<Map<String, dynamic>>>((ref) {
    return ref
        .watch(supabaseProvider)
        .from('sectores')
        .select('id, nombre')
        .order('nombre');
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
      if (v.isEmpty) {
        _errorCedula = null;
      } else if (RegExp(r'[^0-9]').hasMatch(v)) {
        _errorCedula = 'Solo se aceptan valores numéricos';
      } else if (v.length > 10) {
        _errorCedula = 'Máximo 10 dígitos permitidos';
      } else {
        _errorCedula = null;
      }
    });
  }

  void _validarNombres() {
    final v = _nombresCtrl.text;
    setState(() {
      if (v.isNotEmpty && RegExp(r'[0-9]').hasMatch(v)) {
        _errorNombres = 'No se aceptan valores numéricos en el nombre';
      } else {
        _errorNombres = null;
      }
    });
  }

  void _validarApellidos() {
    final v = _apellidosCtrl.text;
    setState(() {
      if (v.isNotEmpty && RegExp(r'[0-9]').hasMatch(v)) {
        _errorApellidos = 'No se aceptan valores numéricos en el apellido';
      } else {
        _errorApellidos = null;
      }
    });
  }

  void _validarTelefono() {
    final v = _telefonoCtrl.text;
    setState(() {
      if (v.isEmpty) {
        _errorTelefono = null;
      } else if (RegExp(r'[^0-9]').hasMatch(v)) {
        _errorTelefono = 'Solo se aceptan valores numéricos';
      } else if (v.length > 10) {
        _errorTelefono = 'Máximo 10 dígitos permitidos';
      } else {
        _errorTelefono = null;
      }
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
    // Validar errores en tiempo real primero
    if (_errorCedula != null || _errorNombres != null ||
        _errorApellidos != null || _errorTelefono != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Corrige los errores antes de continuar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (widget.sectorIdFijo == null && _sectorSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un sector')),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final supabase = ref.read(supabaseProvider);
      final creadorId = supabase.auth.currentUser!.id;
      final correo = _correoCtrl.text.trim();

      String? nuevoUserId;
      try {
        final authResponse = await supabase.auth.signUp(
          email: correo,
          password: AppConstants.passwordInicial,
        );
        nuevoUserId = authResponse.user?.id;
      } on AuthException catch (e) {
        if (e.message.toLowerCase().contains('seconds')) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Espera unos segundos antes de crear otro usuario.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 6),
            ),
          );
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
        'rol': widget.rol,
        'primer_login': true,
        'creado_por': creadorId,
      });

      final sectorId = widget.sectorIdFijo ?? _sectorSeleccionado;
      await supabase.from('asignaciones').insert({
        'usuario_id': nuevoUserId,
        'sector_id': sectorId,
        'asignado_por': creadorId,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_nombresCtrl.text} creado exitosamente. '
            'Contraseña inicial: ${AppConstants.passwordInicial}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
      context.go(AppRoutes.coordinadores);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error Auth: ${e.message}'),
            backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectoresAsync = ref.watch(_sectoresProvider);
    final usuario = ref.watch(authProvider).asData?.value;

    return Scaffold(
      drawer: ScaffoldMenu(usuario: usuario, child: const SizedBox.shrink()),
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            title: const Text('Nuevo coordinador', style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go(AppRoutes.coordinadores),
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
                            'Nuevo coordinador de brigada',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Completa los datos del nuevo coordinador',
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

          // ── Formulario ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─ Sección: Identificación ──────────────────
                    _SectionLabel(
                        label: 'Identificación',
                        icon: Icons.badge_outlined),
                    const SizedBox(height: 10),

                    // Cédula
                    TextFormField(
                      controller: _cedulaCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        // Solo permite dígitos, sin límite de longitud aquí
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Cédula de identidad *',
                        prefixIcon:
                            const Icon(Icons.badge_outlined, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        errorText: _errorCedula,
                        helperText: '10 dígitos exactos',
                        counterText: '${_cedulaCtrl.text.length}/10',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Campo obligatorio';
                        }
                        if (v.length != 10) {
                          return 'La cédula debe tener exactamente 10 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ─ Sección: Datos personales ─────────────────
                    _SectionLabel(
                        label: 'Datos personales',
                        icon: Icons.person_outline),
                    const SizedBox(height: 10),

                    // Nombres
                    TextFormField(
                      controller: _nombresCtrl,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Nombres *',
                        prefixIcon:
                            const Icon(Icons.person_outline, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        errorText: _errorNombres,
                        helperText: 'Solo letras y espacios',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Campo obligatorio';
                        }
                        if (v.trim().length < 2) {
                          return 'Ingresa el nombre completo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Apellidos
                    TextFormField(
                      controller: _apellidosCtrl,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Apellidos *',
                        prefixIcon:
                            const Icon(Icons.person_outline, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        errorText: _errorApellidos,
                        helperText: 'Solo letras y espacios',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Campo obligatorio';
                        }
                        if (v.trim().length < 2) {
                          return 'Ingresa los apellidos completos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ─ Sección: Contacto ─────────────────────────
                    _SectionLabel(
                        label: 'Contacto', icon: Icons.contact_phone_outlined),
                    const SizedBox(height: 10),

                    // Teléfono
                    TextFormField(
                      controller: _telefonoCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Teléfono *',
                        prefixIcon:
                            const Icon(Icons.phone_outlined, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        errorText: _errorTelefono,
                        helperText: '10 dígitos exactos',
                        counterText: '${_telefonoCtrl.text.length}/10',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Campo obligatorio';
                        }
                        if (v.length != 10) {
                          return 'El teléfono debe tener exactamente 10 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Correo
                    TextFormField(
                      controller: _correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico *',
                        prefixIcon:
                            const Icon(Icons.email_outlined, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo obligatorio';
                        if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$')
                            .hasMatch(v)) {
                          return 'Correo inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ─ Sección: Asignación ───────────────────────
                    if (widget.sectorIdFijo == null) ...[
                      _SectionLabel(
                          label: 'Asignación de sector',
                          icon: Icons.map_outlined),
                      const SizedBox(height: 10),
                      sectoresAsync.when(
                        loading: () =>
                            const LinearProgressIndicator(),
                        error: (e, _) =>
                            Text('Error cargando sectores: $e'),
                        data: (sectores) =>
                            DropdownButtonFormField<String>(
                          value: _sectorSeleccionado,
                          decoration: InputDecoration(
                            labelText: 'Sector asignado *',
                            prefixIcon: const Icon(Icons.map_outlined,
                                size: 20),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          items: sectores
                              .map((s) => DropdownMenuItem(
                                    value: s['id'] as String,
                                    child:
                                        Text(s['nombre'] as String),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _sectorSeleccionado = v),
                          validator: (v) =>
                              v == null ? 'Selecciona un sector' : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Info contraseña inicial
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue.shade600, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Contraseña inicial: ${AppConstants.passwordInicial}\n'
                              'El usuario deberá cambiarla en su primer ingreso.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700),
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
                          backgroundColor: const Color(0xFF1B5E20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _cargando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Icon(Icons.person_add),
                        label: Text(
                            _cargando ? 'Creando...' : 'Crear coordinador',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
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
        Icon(icon, size: 16, color: const Color(0xFF1B5E20)),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
              thickness: 1),
        ),
      ],
    );
  }
}

class CrearCoordinadorPage extends StatelessWidget {
  const CrearCoordinadorPage({super.key});

  @override
  Widget build(BuildContext context) => const CrearUsuarioForm(
        titulo: 'Nuevo coordinador de brigada',
        rol: Roles.coordinadorBrigada,
      );
}