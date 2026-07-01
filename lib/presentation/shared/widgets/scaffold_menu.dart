import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/entities.dart';
import '../providers/auth_provider.dart';
import '../../../data/local/database/app_database.dart';

class ScaffoldMenu extends ConsumerWidget {
  final Widget child;
  final Usuario? usuario;

  const ScaffoldMenu({super.key, required this.usuario, required this.child});

  // Devuelve los colores según el rol
  List<Color> _gradiente(String? rol) {
    switch (rol) {
      case Roles.coordinadorBrigada:
        return RolColors.brigadaGradient;
      case Roles.vacunador:
        return RolColors.vacunadorGradient;
      default:
        return RolColors.campaniaGradient;
    }
  }

  Color _primary(String? rol) {
    switch (rol) {
      case Roles.coordinadorBrigada:
        return RolColors.brigadaPrimary;
      case Roles.vacunador:
        return RolColors.vacunadorPrimary;
      default:
        return RolColors.campaniaPrimary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientesAsync = ref.watch(pendientesSyncProvider);
    final rol = usuario?.rol;
    final primary = _primary(rol);
    final gradiente = _gradiente(rol);

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            // ── Header del drawer ────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradiente,
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                bottom: 24,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (usuario?.nombres.isNotEmpty == true)
                            ? usuario!.nombres[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    usuario?.nombreCompleto ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario?.correo ?? '',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _labelRol(rol ?? ''),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Badge offline ────────────────────────────────────
            pendientesAsync.when(
              data: (count) => count > 0
                  ? Container(
                      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.cloud_off,
                              color: Colors.orange.shade700, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$count registro(s) sin sincronizar',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade800),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // ── Items de navegación ──────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8),
                children: [
                  if (rol == Roles.coordinadorCampania) ...[
                    _SectionLabel(label: 'Principal'),
                    _DrawerItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard,
                      label: 'Dashboard',
                      route: AppRoutes.dashboard,
                      primary: primary,
                    ),
                    _SectionLabel(label: 'Gestión'),
                    _DrawerItem(
                      icon: Icons.map_outlined,
                      activeIcon: Icons.map,
                      label: 'Ver sectores',
                      route: AppRoutes.sectores,
                      primary: primary,
                    ),
                    _DrawerItem(
                      icon: Icons.add_location_alt_outlined,
                      activeIcon: Icons.add_location_alt,
                      label: 'Crear sector',
                      route: AppRoutes.crearSector,
                      primary: primary,
                    ),
                    _DrawerItem(
                      icon: Icons.people_outline,
                      activeIcon: Icons.people,
                      label: 'Coordinadores de brigada',
                      route: AppRoutes.coordinadores,
                      primary: primary,
                    ),
                    _DrawerItem(
                      icon: Icons.person_add_outlined,
                      activeIcon: Icons.person_add,
                      label: 'Agregar coordinador',
                      route: AppRoutes.crearCoordinador,
                      primary: primary,
                    ),
                  ],
                  if (rol == Roles.coordinadorBrigada) ...[
                    _SectionLabel(label: 'Principal'),
                    _DrawerItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard,
                      label: 'Dashboard',
                      route: '/dashboard-brigada',
                      primary: primary,
                    ),
                    _SectionLabel(label: 'Gestión'),
                    _DrawerItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Ver vacunadores',
                      route: AppRoutes.vacunadores,
                      primary: primary,
                    ),
                    _DrawerItem(
                      icon: Icons.person_add_outlined,
                      activeIcon: Icons.person_add,
                      label: 'Crear vacunador',
                      route: AppRoutes.crearVacunador,
                      primary: primary,
                    ),
                    _DrawerItem(
                      icon: Icons.assignment_ind_outlined,
                      activeIcon: Icons.assignment_ind,
                      label: 'Asignar vacunadores',
                      route: '/asignar-vacunadores',
                      primary: primary,
                    ),
                    _DrawerItem(
                      icon: Icons.list_alt_outlined,
                      activeIcon: Icons.list_alt,
                      label: 'Registros del sector',
                      route: '/registros-sector',
                      primary: primary,
                    ),
                  ],
                  if (rol == Roles.vacunador) ...[
                    _SectionLabel(label: 'Principal'),
                    _DrawerItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard,
                      label: 'Dashboard',
                      route: '/dashboard-vacunador',
                      primary: primary,
                    ),
                    _SectionLabel(label: 'Vacunación'),
                    _DrawerItem(
                      icon: Icons.map_outlined,
                      activeIcon: Icons.map,
                      label: 'Mis sectores',
                      route: '/sectores-asignados',
                      primary: primary,
                    ),
                    _DrawerItem(
                      icon: Icons.list_alt_outlined,
                      activeIcon: Icons.list_alt,
                      label: 'Ver registros',
                      route: '/mis-registros',
                      primary: primary,
                    ),
                  ],
                ],
              ),
            ),

            // ── Cerrar sesión ────────────────────────────────────
            const Divider(height: 1),
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.logout,
                    color: Colors.red.shade600, size: 20),
              ),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).logout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      body: child,
    );
  }

  String _labelRol(String rol) {
    switch (rol) {
      case Roles.coordinadorCampania:
        return 'Coordinador de campaña';
      case Roles.coordinadorBrigada:
        return 'Coordinador de brigada';
      case Roles.vacunador:
        return 'Vacunador';
      default:
        return rol;
    }
  }
}

// ─── Etiqueta de sección ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Item del drawer ──────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final Color primary;

  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive;
    try {
      isActive = GoRouterState.of(context).matchedLocation == route;
    } catch (_) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? primary.withValues(alpha: 0.15)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isActive ? activeIcon : icon,
            size: 20,
            color: isActive ? primary : Colors.grey.shade600,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? primary : Colors.grey.shade800,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          context.push(route);
        },
      ),
    );
  }
}

// ─── Provider pendientes ──────────────────────────────────────────────────────

final pendientesSyncProvider = FutureProvider<int>((ref) async {
  final dao = ref.watch(vacunacionesDaoProvider);
  return dao.cantidadPendientes();
});