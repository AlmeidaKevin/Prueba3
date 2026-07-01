import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/network/connectivity_service.dart';
import 'data/local/database/app_database.dart';
import 'presentation/shared/providers/router_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(AppDatabase()),
      ],
      child: const VacunacionApp(),
    ),
  );
}

class VacunacionApp extends ConsumerWidget {
  const VacunacionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Iniciar listener de conectividad para sincronización automática
    ref.listen(connectivityStreamProvider, (_, next) {
      next.whenData((isConnected) {
        if (isConnected) {
          ref.read(syncServiceProvider).sincronizarPendientes();
        }
      });
    });

    return MaterialApp.router(
      title: 'Vacunación Canina y Felina',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
        ),
      ),
      routerConfig: router,
    );
  }
}