import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/login_page.dart';
import '../../auth/cambiar_password_page.dart';
import '../../auth/recuperar_password_page.dart';
import '../../coordinador_campania/dashboard_campania_page.dart';
import '../../coordinador_campania/sectores/sectores_list_page.dart';
import '../../coordinador_campania/sectores/crear_sector_page.dart';
import '../../coordinador_campania/coordinadores/coordinadores_list_page.dart';
import '../../coordinador_campania/coordinadores/crear_coordinador_page.dart';
import '../../coordinador_brigada/dashboard_brigada_page.dart';
import '../../coordinador_brigada/vacunadores/vacunadores_list_page.dart';
import '../../coordinador_brigada/vacunadores/crear_vacunador_page.dart';
import '../../registros/corregir_registro_page.dart';
import '../../registros/registros_sector_page.dart';
import '../../coordinador_brigada/vacunadores/asignar_vacunadores_page.dart';
import '../../vacunador/dashboard_vacunador_page.dart';
import '../../vacunador/sectores_asignados_page.dart';
import '../../vacunador/vacunaciones/mis_registros_page.dart';
import '../../vacunador/vacunaciones/registrar_vacunacion_page.dart';
import '../widgets/scaffold_menu.dart';
import 'auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoginRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.recuperarPassword;

      return authAsync.when(
        loading: () => null,
        error: (_, __) => AppRoutes.login,
        data: (usuario) {
          if (usuario == null) {
            return isLoginRoute ? null : AppRoutes.login;
          }
          if (usuario.primerLogin &&
              state.matchedLocation != AppRoutes.cambiarPassword) {
            return AppRoutes.cambiarPassword;
          }
          if (isLoginRoute) {
            return _dashboardParaRol(usuario.rol);
          }
          return null;
        },
      );
    },
    routes: [
      // ─── Sin menú (auth) ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.cambiarPassword,
        builder: (_, __) => const CambiarPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.recuperarPassword,
        builder: (_, __) => const RecuperarPasswordPage(),
      ),

      // ─── Páginas secundarias SIN drawer ──────────────────────
      GoRoute(
        path: AppRoutes.crearVacunador,
        builder: (_, __) => const CrearVacunadorPage(),
      ),
      GoRoute(
        path: '/corregir-registro/:id',
        builder: (_, state) => CorregirRegistroPage(
          vacunacionId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.registrarVacunacion,
        builder: (_, state) => RegistrarVacunacionPage(
          sectorId: state.uri.queryParameters['sectorId']!,
        ),
      ),
      GoRoute(
        path: '/editar-vacunacion/:id',
        builder: (_, state) => CorregirRegistroPage(
          vacunacionId: state.pathParameters['id']!,
        ),
      ),

      GoRoute(
        path: '/registros-sector',
        builder: (_, __) => const RegistrosSectorPage(),
      ),
      GoRoute(
        path: '/asignar-vacunadores',
        builder: (_, __) => const AsignarVacunadoresPage(),
      ),

      GoRoute(
        path: '/mis-registros',
        builder: (_, __) => const MisRegistrosPage(),
      ),

      // ─── Páginas principales CON drawer ──────────────────────
      ShellRoute(
        builder: (context, state, child) {
          final usuario = ref.read(authProvider).asData?.value;
          return ScaffoldMenu(usuario: usuario, child: child);
        },
        routes: [
          // Coordinador de campaña
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, __) => const DashboardCampaniaPage(),
          ),
          GoRoute(
            path: AppRoutes.sectores,
            builder: (_, __) => const SectoresListPage(),
          ),
          GoRoute(
            path: AppRoutes.crearSector,
            builder: (_, __) => const CrearSectorPage(),
          ),
          GoRoute(
            path: AppRoutes.coordinadores,
            builder: (_, __) => const CoordinadoresListPage(),
          ),
          GoRoute(
            path: AppRoutes.crearCoordinador,
            builder: (_, __) => const CrearCoordinadorPage(),
          ),

          // Coordinador de brigada
          GoRoute(
            path: '/dashboard-brigada',
            builder: (_, __) => const DashboardBrigadaPage(),
          ),
          GoRoute(
            path: AppRoutes.vacunadores,
            builder: (_, __) => const VacunadoresListPage(),
          ),

          GoRoute(
            path: '/dashboard-vacunador',
            builder: (_, __) => const DashboardVacunadorPage(),
          ),
          GoRoute(
            path: '/sectores-asignados',
            builder: (_, __) => const SectoresAsignadosPage(),
          ),
          GoRoute(
            path: AppRoutes.listaVacunaciones,
            builder: (_, __) => const SectoresAsignadosPage(),
          ),
        ],
      ),
    ],
  );
});

String _dashboardParaRol(String rol) {
  switch (rol) {
    case Roles.coordinadorCampania:
      return AppRoutes.dashboard;
    case Roles.coordinadorBrigada:
      return '/dashboard-brigada';
    case Roles.vacunador:
      return '/dashboard-vacunador';
    default:
      return AppRoutes.login;
  }
}