import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/providers/auth_provider.dart';

class RecuperarPasswordPage extends ConsumerStatefulWidget {
  const RecuperarPasswordPage({super.key});

  @override
  ConsumerState<RecuperarPasswordPage> createState() =>
      _RecuperarPasswordPageState();
}

class _RecuperarPasswordPageState
    extends ConsumerState<RecuperarPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  bool _cargando = false;
  bool _enviado = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    final error = await ref
        .read(authProvider.notifier)
        .recuperarPassword(_correoCtrl.text.trim());

    if (!mounted) return;
    setState(() {
      _cargando = false;
      if (error == null) _enviado = true;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            height: size.height * 0.42,
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

          // Círculos decorativos
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 80,
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

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ── Encabezado ──────────────────────────────
                      SizedBox(
                        height: size.height * 0.34,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Botón volver
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8, 8, 0, 0),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.white),
                                  onPressed: () => context.pop(),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.2),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lock_reset_outlined,
                                size: 42,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Recuperar contraseña',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40),
                              child: Text(
                                'Te enviaremos un enlace para\nrestablecer tu contraseña',
                                style: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),

                      // ── Tarjeta ─────────────────────────────────
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: _enviado
                            ? Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.mark_email_read_outlined,
                                      size: 52,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    '¡Correo enviado!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Revisa tu bandeja de entrada en\n${_correoCtrl.text}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Si no lo encuentras, revisa la carpeta de spam.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 11),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: OutlinedButton.icon(
                                      onPressed: () => context.pop(),
                                      icon: const Icon(
                                          Icons.arrow_back_outlined),
                                      label: const Text(
                                          'Volver al inicio de sesión'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xFF1B5E20),
                                        side: const BorderSide(
                                            color: Color(0xFF1B5E20)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Ingresa tu correo',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Te enviaremos un enlace para restablecer tu contraseña',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500),
                                    ),
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      controller: _correoCtrl,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      autocorrect: false,
                                      decoration: InputDecoration(
                                        labelText: 'Correo electrónico',
                                        prefixIcon: const Icon(
                                            Icons.email_outlined,
                                            size: 20),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Ingresa tu correo';
                                        }
                                        if (!v.contains('@')) {
                                          return 'Correo inválido';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: FilledButton.icon(
                                        onPressed:
                                            _cargando ? null : _enviar,
                                        style: FilledButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF1B5E20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    12),
                                          ),
                                        ),
                                        icon: _cargando
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ))
                                            : const Icon(Icons.send_outlined),
                                        label: Text(
                                          _cargando
                                              ? 'Enviando...'
                                              : 'Enviar enlace',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: TextButton.icon(
                                        onPressed: () => context.pop(),
                                        icon: const Icon(
                                            Icons.arrow_back_outlined,
                                            size: 16),
                                        label: const Text(
                                            'Volver al inicio de sesión'),
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
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

