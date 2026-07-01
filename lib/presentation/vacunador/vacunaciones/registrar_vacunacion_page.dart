import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../data/local/database/app_database.dart';
import '../../shared/providers/auth_provider.dart';

class RegistrarVacunacionPage extends ConsumerStatefulWidget {
  final String sectorId;
  const RegistrarVacunacionPage({super.key, required this.sectorId});

  @override
  ConsumerState<RegistrarVacunacionPage> createState() =>
      _RegistrarVacunacionPageState();
}

class _RegistrarVacunacionPageState
    extends ConsumerState<RegistrarVacunacionPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final _propNombreCtrl = TextEditingController();
  final _propCedulaCtrl = TextEditingController();
  final _propTelefonoCtrl = TextEditingController();
  final _mascNombreCtrl = TextEditingController();
  final _mascEdadCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();

  String _tipoMascota = 'perro';
  String? _mascotaSexo;
  String? _vacunaSeleccionada;
  File? _foto;
  Position? _posicion;
  bool _cargandoGps = false;
  bool _guardando = false;

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

  Future<void> _capturarGPS() async {
    setState(() => _cargandoGps = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _mostrarError('Permiso de ubicación denegado');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _mostrarError('Permiso denegado permanentemente. Habilítalo en Configuración.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      setState(() => _posicion = pos);
    } catch (e) {
      _mostrarError('No se pudo obtener ubicación: $e');
    } finally {
      setState(() => _cargandoGps = false);
    }
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
      maxWidth: 1280,
    );
    if (picked != null) setState(() => _foto = File(picked.path));
  }

  Future<void> _elegirDeGaleria() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1280,
    );
    if (picked != null) setState(() => _foto = File(picked.path));
  }

  void _mostrarError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_foto == null) { _mostrarError('La fotografía es obligatoria'); return; }
    if (_posicion == null) { _mostrarError('La ubicación GPS es obligatoria'); return; }
    if (_vacunaSeleccionada == null) { _mostrarError('Selecciona la vacuna aplicada'); return; }

    setState(() => _guardando = true);
    try {
      final supabase = ref.read(supabaseProvider);
      final usuario = ref.read(authProvider).asData?.value;
      final isConnected = await ref.read(isConnectedProvider.future);
      final id = _uuid.v4();

      if (isConnected) {
        final fotoBytes = await _foto!.readAsBytes();
        final fotoPath = 'vacunaciones/$id.jpg';
        await supabase.storage.from('fotos').uploadBinary(
          fotoPath, fotoBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        final fotoUrl = supabase.storage.from('fotos').getPublicUrl(fotoPath);

        await supabase.from('vacunaciones').insert({
          'id': id,
          'vacunador_id': usuario?.id,
          'sector_id': widget.sectorId,
          'propietario_nombre': _propNombreCtrl.text.trim(),
          'propietario_cedula': _propCedulaCtrl.text.trim(),
          'propietario_telefono': _propTelefonoCtrl.text.trim(),
          'tipo_mascota': _tipoMascota,
          'mascota_nombre': _mascNombreCtrl.text.trim(),
          'mascota_edad_aprox': _mascEdadCtrl.text.trim(),
          'mascota_sexo': _mascotaSexo,
          'vacuna_aplicada': _vacunaSeleccionada,
          'observaciones': _observacionesCtrl.text.trim(),
          'foto_url': fotoUrl,
          'latitud': _posicion!.latitude,
          'longitud': _posicion!.longitude,
          'fecha_vacunacion': DateTime.now().toIso8601String(),
          'sincronizado': true,
        });

        await ref.read(vacunacionesDaoProvider).insertar(
          VacunacionesLocalCompanion(
            id: Value(id),
            vacunadorId: Value(usuario?.id ?? ''),
            sectorId: Value(widget.sectorId),
            propietarioNombre: Value(_propNombreCtrl.text.trim()),
            propietarioCedula: Value(_propCedulaCtrl.text.trim()),
            propietarioTelefono: Value(_propTelefonoCtrl.text.trim()),
            tipoMascota: Value(_tipoMascota),
            mascotaNombre: Value(_mascNombreCtrl.text.trim()),
            mascotaEdadAprox: Value(_mascEdadCtrl.text.trim()),
            mascotaSexo: Value(_mascotaSexo),
            vacunaAplicada: Value(_vacunaSeleccionada!),
            observaciones: Value(_observacionesCtrl.text.trim()),
            fotoUrl: Value(fotoUrl),
            latitud: Value(_posicion!.latitude),
            longitud: Value(_posicion!.longitude),
            fechaVacunacion: Value(DateTime.now()),
            sincronizado: const Value(true),
          ),
        );
      } else {
        await ref.read(vacunacionesDaoProvider).insertar(
          VacunacionesLocalCompanion(
            id: Value(id),
            vacunadorId: Value(usuario?.id ?? ''),
            sectorId: Value(widget.sectorId),
            propietarioNombre: Value(_propNombreCtrl.text.trim()),
            propietarioCedula: Value(_propCedulaCtrl.text.trim()),
            propietarioTelefono: Value(_propTelefonoCtrl.text.trim()),
            tipoMascota: Value(_tipoMascota),
            mascotaNombre: Value(_mascNombreCtrl.text.trim()),
            mascotaEdadAprox: Value(_mascEdadCtrl.text.trim()),
            mascotaSexo: Value(_mascotaSexo),
            vacunaAplicada: Value(_vacunaSeleccionada!),
            observaciones: Value(_observacionesCtrl.text.trim()),
            fotoLocalPath: Value(_foto!.path),
            latitud: Value(_posicion!.latitude),
            longitud: Value(_posicion!.longitude),
            fechaVacunacion: Value(DateTime.now()),
            sincronizado: const Value(false),
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isConnected
              ? 'Vacunación registrada exitosamente'
              : 'Guardado localmente. Se sincronizará cuando haya conexión.'),
          backgroundColor: isConnected ? Colors.green : Colors.orange,
        ),
      );
      context.pop();
    } catch (e) {
      _mostrarError('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar teal ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: RolColors.vacunadorPrimary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: const Text('Registrar vacunación',
                style: TextStyle(color: Colors.white)),
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
                          const Text('Nueva vacunación',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text('Completa todos los campos obligatorios',
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

          // ── Formulario ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─ Propietario ──────────────────────────────
                    _SectionLabel(label: 'Propietario', icon: Icons.person_outline),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _propNombreCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nombre completo *',
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _propCedulaCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Cédula *',
                        prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo obligatorio';
                        if (v.length != 10) return 'La cédula debe tener 10 dígitos';
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─ Mascota ──────────────────────────────────
                    _SectionLabel(label: 'Mascota', icon: Icons.pets_outlined),
                    const SizedBox(height: 10),

                    // Tipo mascota
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
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _tipoMascota == 'perro'
                                      ? RolColors.vacunadorPrimary
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(11)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.pets,
                                        size: 18,
                                        color: _tipoMascota == 'perro'
                                            ? Colors.white
                                            : Colors.grey),
                                    const SizedBox(width: 6),
                                    Text('Perro',
                                        style: TextStyle(
                                            color: _tipoMascota == 'perro'
                                                ? Colors.white
                                                : Colors.grey,
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
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _tipoMascota == 'gato'
                                      ? RolColors.vacunadorPrimary
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(11)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.pets,
                                        size: 18,
                                        color: _tipoMascota == 'gato'
                                            ? Colors.white
                                            : Colors.grey),
                                    const SizedBox(width: 6),
                                    Text('Gato',
                                        style: TextStyle(
                                            color: _tipoMascota == 'gato'
                                                ? Colors.white
                                                : Colors.grey,
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 12),

                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _mascEdadCtrl,
                          decoration: InputDecoration(
                            labelText: 'Edad aprox.',
                            hintText: 'Ej: 2 años',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _vacunaSeleccionada,
                      decoration: InputDecoration(
                        labelText: 'Vacuna aplicada *',
                        prefixIcon: const Icon(Icons.vaccines_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                      ),
                      items: AppConstants.vacunas
                          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() => _vacunaSeleccionada = v),
                      validator: (v) => v == null ? 'Selecciona la vacuna' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _observacionesCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Observaciones',
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.notes_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─ Fotografía ───────────────────────────────
                    _SectionLabel(label: 'Fotografía *', icon: Icons.camera_alt_outlined),
                    const SizedBox(height: 10),
                    _FotoWidget(
                      foto: _foto,
                      onTomarFoto: _tomarFoto,
                      onGaleria: _elegirDeGaleria,
                    ),
                    const SizedBox(height: 20),

                    // ─ GPS ──────────────────────────────────────
                    _SectionLabel(label: 'Ubicación GPS *', icon: Icons.location_on_outlined),
                    const SizedBox(height: 10),
                    _GpsWidget(
                      posicion: _posicion,
                      cargando: _cargandoGps,
                      onCapturar: _capturarGPS,
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _guardando ? null : _guardar,
                        style: FilledButton.styleFrom(
                          backgroundColor: RolColors.vacunadorPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _guardando
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.vaccines),
                        label: Text(
                            _guardando ? 'Guardando...' : 'Registrar vacunación',
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

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: RolColors.vacunadorPrimary),
        const SizedBox(width: 6),
        Text(label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: RolColors.vacunadorPrimary,
              letterSpacing: 1.1,
            )),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
              color: RolColors.vacunadorPrimary.withValues(alpha: 0.3),
              thickness: 1),
        ),
      ],
    );
  }
}

class _FotoWidget extends StatelessWidget {
  final File? foto;
  final VoidCallback onTomarFoto;
  final VoidCallback onGaleria;
  const _FotoWidget({required this.foto, required this.onTomarFoto, required this.onGaleria});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (foto != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(foto!,
                height: 200, width: double.infinity, fit: BoxFit.cover),
          )
        else
          Container(
            height: 150, width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: RolColors.vacunadorPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      size: 36, color: RolColors.vacunadorPrimary),
                ),
                const SizedBox(height: 8),
                Text('Sin fotografía',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onTomarFoto,
                style: OutlinedButton.styleFrom(
                  foregroundColor: RolColors.vacunadorPrimary,
                  side: const BorderSide(color: RolColors.vacunadorPrimary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Cámara'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onGaleria,
                style: OutlinedButton.styleFrom(
                  foregroundColor: RolColors.vacunadorPrimary,
                  side: const BorderSide(color: RolColors.vacunadorPrimary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.photo_library, size: 18),
                label: const Text('Galería'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GpsWidget extends StatelessWidget {
  final Position? posicion;
  final bool cargando;
  final VoidCallback onCapturar;
  const _GpsWidget({required this.posicion, required this.cargando, required this.onCapturar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: posicion != null ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: posicion != null
              ? Colors.green.shade200
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (posicion != null) ...[
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                const SizedBox(width: 6),
                Text('Ubicación capturada',
                    style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Lat: ${posicion!.latitude.toStringAsFixed(6)}\n'
              'Lng: ${posicion!.longitude.toStringAsFixed(6)}',
              style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.grey.shade700),
            ),
          ] else
            Row(
              children: [
                Icon(Icons.location_off, color: Colors.grey.shade400, size: 18),
                const SizedBox(width: 6),
                Text('Sin ubicación GPS',
                    style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: cargando ? null : onCapturar,
              style: OutlinedButton.styleFrom(
                foregroundColor: RolColors.vacunadorPrimary,
                side: const BorderSide(color: RolColors.vacunadorPrimary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: cargando
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location, size: 18),
              label: Text(cargando
                  ? 'Obteniendo ubicación...'
                  : posicion != null
                      ? 'Actualizar ubicación'
                      : 'Capturar ubicación'),
            ),
          ),
        ],
      ),
    );
  }
}