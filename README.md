# Vacunación Canina y Felina — Flutter App

## Requisitos previos
- Flutter 3.x instalado
- Cuenta en [supabase.com](https://supabase.com)
- Android Studio o VS Code con extensiones Flutter

---

## Configuración paso a paso

### 1. Supabase
1. Crear nuevo proyecto en Supabase
2. Ir a **SQL Editor** y ejecutar todo el contenido de `supabase_setup.sql`
3. En **Authentication → URL Configuration**, agregar redirect URL:
   ```
   io.supabase.vacunacion://login-callback/
   ```
4. Copiar **Project URL** y **anon public key** desde **Settings → API**

### 2. Flutter — Variables de entorno
Abrir `lib/core/constants/app_constants.dart` y reemplazar:

```dart
static const String supabaseUrl = 'https://TU_PROYECTO.supabase.co';
static const String supabaseAnonKey = 'TU_ANON_KEY';
```

### 3. Generar código de Drift (base de datos local)
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 4. Correr la app
```bash
flutter run
```

---

## Crear el coordinador inicial

1. En Supabase → **Authentication → Users** → **Add user**:
   - Email: `coordinador@vacunacion.gob.ec`
   - Password: `Ecuador2026`
   - Auto confirm email: ✓

2. Copiar el UUID del usuario creado

3. En **SQL Editor** ejecutar (reemplazando el UUID):
```sql
INSERT INTO perfiles (id, cedula, nombres, apellidos, telefono, correo, rol)
VALUES (
  'UUID_COPIADO_AQUI',
  '1700000001',
  'Admin',
  'Coordinador',
  '0990000001',
  'coordinador@vacunacion.gob.ec',
  'coordinador_campania'
);
```

4. Ingresar a la app con esas credenciales y cambiar la contraseña

---

## Estructura de roles

| Rol | Acciones |
|-----|---------|
| `coordinador_campania` | Crear sectores, crear coordinadores de brigada, asignar, ver dashboard general |
| `coordinador_brigada` | Ver sus sectores, crear vacunadores, corregir registros del sector, ver dashboard de brigada |
| `vacunador` | Registrar vacunaciones (foto + GPS), editar sus propios registros |

---

## Funcionamiento offline

- Las vacunaciones se guardan localmente en **SQLite** (Drift) cuando no hay conexión
- La foto se guarda en la ruta local del dispositivo
- Al recuperar la conexión, el `SyncService` sube automáticamente todos los registros pendientes a Supabase

---

## Archivos clave

| Archivo | Descripción |
|---------|-------------|
| `lib/main.dart` | Punto de entrada, inicialización Supabase + Riverpod |
| `lib/core/constants/app_constants.dart` | URLs, contraseña inicial, lista de vacunas |
| `lib/data/local/database/app_database.dart` | Base de datos local Drift |
| `lib/core/network/connectivity_service.dart` | Detección de red y sincronización |
| `lib/presentation/shared/providers/auth_provider.dart` | Autenticación con Supabase |
| `lib/presentation/shared/providers/router_provider.dart` | Navegación por rol con GoRouter |
| `lib/presentation/vacunador/vacunaciones/registrar_vacunacion_page.dart` | Formulario con cámara y GPS |
| `supabase_setup.sql` | Script SQL completo para configurar Supabase |
"# Prueba3" 
