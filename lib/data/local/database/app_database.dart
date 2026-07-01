import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

// ═══════════════════════════════════════════
// TABLAS LOCALES
// ═══════════════════════════════════════════

class VacunacionesLocal extends Table {
  TextColumn get id => text()();
  TextColumn get vacunadorId => text()();
  TextColumn get sectorId => text()();
  TextColumn get propietarioNombre => text()();
  TextColumn get propietarioCedula => text()();
  TextColumn get propietarioTelefono => text().nullable()();
  TextColumn get tipoMascota => text()();
  TextColumn get mascotaNombre => text()();
  TextColumn get mascotaEdadAprox => text().nullable()();
  TextColumn get mascotaSexo => text().nullable()();
  TextColumn get vacunaAplicada => text()();
  TextColumn get observaciones => text().nullable()();
  TextColumn get fotoUrl => text().nullable()();
  TextColumn get fotoLocalPath => text().nullable()();
  RealColumn get latitud => real().nullable()();
  RealColumn get longitud => real().nullable()();
  DateTimeColumn get fechaVacunacion => dateTime()();
  BoolColumn get sincronizado => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get tipo => text()(); // 'insert' | 'update'
  TextColumn get tabla => text()();
  TextColumn get datos => text()(); // JSON string
  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
  IntColumn get intentos => integer().withDefault(const Constant(0))();
  BoolColumn get procesado => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ═══════════════════════════════════════════
// DAOs
// ═══════════════════════════════════════════

@DriftAccessor(tables: [VacunacionesLocal])
class VacunacionesDao extends DatabaseAccessor<AppDatabase>
    with _$VacunacionesDaoMixin {
  VacunacionesDao(super.db);

  Future<List<VacunacionesLocalData>> obtenerPorSector(String sectorId) =>
      (select(vacunacionesLocal)
        ..where((t) => t.sectorId.equals(sectorId))
        ..orderBy([(t) => OrderingTerm.desc(t.fechaVacunacion)]))
          .get();

  Future<List<VacunacionesLocalData>> obtenerPorVacunador(String vacunadorId) =>
      (select(vacunacionesLocal)
        ..where((t) => t.vacunadorId.equals(vacunadorId))
        ..orderBy([(t) => OrderingTerm.desc(t.fechaVacunacion)]))
          .get();

  Future<List<VacunacionesLocalData>> obtenerNoPendientes() =>
      (select(vacunacionesLocal)
        ..where((t) => t.sincronizado.equals(false)))
          .get();

  Future<int> insertar(VacunacionesLocalCompanion v) =>
      into(vacunacionesLocal).insert(v, mode: InsertMode.insertOrReplace);

  Future<bool> actualizar(VacunacionesLocalCompanion v) =>
      update(vacunacionesLocal).replace(v);

  Future<int> marcarSincronizado(String id) =>
      (update(vacunacionesLocal)..where((t) => t.id.equals(id)))
          .write(const VacunacionesLocalCompanion(
            sincronizado: Value(true),
          ));

  Future<int> cantidadPendientes() async {
    final count = vacunacionesLocal.id.count();
    final query = selectOnly(vacunacionesLocal)
      ..addColumns([count])
      ..where(vacunacionesLocal.sincronizado.equals(false));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<List<SyncQueueData>> obtenerPendientes() =>
      (select(syncQueue)..where((t) => t.procesado.equals(false))).get();

  Future<int> agregar(SyncQueueCompanion entry) =>
      into(syncQueue).insert(entry);

  Future<int> marcarProcesado(String id) =>
      (update(syncQueue)..where((t) => t.id.equals(id)))
          .write(const SyncQueueCompanion(procesado: Value(true)));

  Future<int> incrementarIntentos(String id) async {
    final item = await (select(syncQueue)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return (update(syncQueue)..where((t) => t.id.equals(id)))
        .write(SyncQueueCompanion(intentos: Value(item.intentos + 1)));
  }
}

// ═══════════════════════════════════════════
// BASE DE DATOS
// ═══════════════════════════════════════════

@DriftDatabase(
  tables: [VacunacionesLocal, SyncQueue],
  daos: [VacunacionesDao, SyncQueueDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vacunacion.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// ═══════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Override in main()');
});

final vacunacionesDaoProvider = Provider<VacunacionesDao>((ref) {
  return ref.watch(appDatabaseProvider).vacunacionesDao;
});

final syncQueueDaoProvider = Provider<SyncQueueDao>((ref) {
  return ref.watch(appDatabaseProvider).syncQueueDao;
});
