import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/providers/auth_provider.dart';

class CambiarPasswordPage extends ConsumerStatefulWidget {
  const CambiarPasswordPage({super.key});

  @override
  ConsumerState<CambiarPasswordPage> createState() =>
      _CambiarPasswordPageState();
}

class _CambiarPasswordPageState extends ConsumerState<CambiarPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nuevaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _verNueva = false;
  bool _verConfirmar = false;
  bool _cargando = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Indicadores de requisitos de contraseña
  bool get _tieneLongitud => _nuevaCtrl.text.length >= 8;
  bool get _tieneMayuscula => RegExp(r'[A-Z]').hasMatch(_nuevaCtrl.text);
  bool get _tieneNumero => RegExp(r'[0-9]').hasMatch(_nuevaCtrl.text);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
    _nuevaCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nuevaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _cambiar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    final error = await ref
        .read(authProvider.notifier)
        .cambiarPassword(_nuevaCtrl.text.trim());

    if (!mounted) return;
    setState(() => _cargando = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usuario = ref.watch(authProvider).asData?.value;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado superior
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1B5E20),
                  Color(0xFF2E7D32),
                  Color(0xFF388E3C),
                ],
              ),
            ),
          ),

          // Círculo decorativo
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // ── Encabezado ─────────────────────────────────
                      const SizedBox(height: 16),
                      const Icon(Icons.lock_reset,
                          size: 52, color: Colors.white),
                      const SizedBox(height: 12),
                      const Text(
                        'Cambio de contraseña',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (usuario != null)
                        Text(
                          'Bienvenido, ${usuario.nombres}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 24),

                      // ── Tarjeta principal ───────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Aviso primer ingreso
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.amber.shade200),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.amber.shade700,
                                      size: 20),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Es tu primer ingreso al sistema. '
                                      'Por seguridad, debes establecer '
                                      'una contraseña personal antes de continuar.',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            const Text(
                              'Nueva contraseña',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Campo nueva contraseña
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nuevaCtrl,
                                    obscureText: !_verNueva,
                                    decoration: InputDecoration(
                                      labelText: 'Nueva contraseña',
                                      prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          size: 20),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _verNueva
                                              ? Icons
                                                  .visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() =>
                                            _verNueva = !_verNueva),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Ingresa la nueva contraseña';
                                      }
                                      if (!_tieneLongitud) {
                                        return 'Mínimo 8 caracteres';
                                      }
                                      if (!_tieneMayuscula) {
                                        return 'Debe tener al menos una mayúscula';
                                      }
                                      if (!_tieneNumero) {
                                        return 'Debe tener al menos un número';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Indicadores de requisitos
                                  _RequisitoRow(
                                    cumple: _tieneLongitud,
                                    texto: 'Mínimo 8 caracteres',
                                  ),
                                  const SizedBox(height: 4),
                                  _RequisitoRow(
                                    cumple: _tieneMayuscula,
                                    texto: 'Al menos una letra mayúscula',
                                  ),
                                  const SizedBox(height: 4),
                                  _RequisitoRow(
                                    cumple: _tieneNumero,
                                    texto: 'Al menos un número',
                                  ),
                                  const SizedBox(height: 16),

                                  // Confirmar contraseña
                                  TextFormField(
                                    controller: _confirmarCtrl,
                                    obscureText: !_verConfirmar,
                                    decoration: InputDecoration(
                                      labelText: 'Confirmar contraseña',
                                      prefixIcon: const Icon(
                                          Icons.lock_outline,
                                          size: 20),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _verConfirmar
                                              ? Icons
                                                  .visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() =>
                                            _verConfirmar = !_verConfirmar),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    validator: (v) {
                                      if (v != _nuevaCtrl.text) {
                                        return 'Las contraseñas no coinciden';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 28),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: FilledButton(
                                      onPressed: _cargando ? null : _cambiar,
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF1B5E20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _cargando
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Guardar contraseña',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget de requisito ──────────────────────────────────────────────────────

class _RequisitoRow extends StatelessWidget {
  final bool cumple;
  final String texto;

  const _RequisitoRow({required this.cumple, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Icon(
            cumple ? Icons.check_circle : Icons.radio_button_unchecked,
            key: ValueKey(cumple),
            size: 16,
            color: cumple ? Colors.green : Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            color: cumple ? Colors.green.shade700 : Colors.grey.shade500,
            fontWeight:
                cumple ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}