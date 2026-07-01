# 🐾 Sistema de Vacunación Canina y Felina

Aplicación móvil Flutter para la gestión de campañas de vacunación municipal de mascotas. Permite registrar vacunaciones con fotografía y GPS, gestionar sectores, coordinadores y vacunadores, con soporte offline.

---

## 📋 Requisitos previos

Antes de comenzar, asegúrate de tener instalado:

| Herramienta | Versión mínima | Descarga |
|---|---|---|
| Flutter | 3.44.1 | https://flutter.dev/docs/get-started/install |
| Dart | 3.12.1 | (incluido con Flutter) |
| Android Studio | Cualquier versión reciente | https://developer.android.com/studio |
| Git | Cualquier versión | https://git-scm.com |

Verifica la instalación de Flutter con:
```bash
flutter doctor
```
Todos los ítems deben estar en verde ✓ (excepto Xcode si no tienes Mac).

---

## 📥 Paso 1 — Clonar el repositorio

```bash
git clone https://github.com/AlmeidaKevin/Prueba3.git 
cd vacunacion_flutter
```

---

## 🔑 Paso 2 — Configurar credenciales de Supabase

### 2.1 Crear proyecto en Supabase

1. Ve a https://supabase.com y crea una cuenta gratuita
2. Crea un nuevo proyecto
3. Espera a que el proyecto termine de inicializarse (~2 minutos)

### 2.2 Obtener las credenciales

En el panel de Supabase, ve a:
**Project Settings → API**

Copia estos dos valores:
- **Project URL** → algo como `https://abcdefgh.supabase.co`
- **anon public key** → una clave larga que empieza con `eyJ...`

### 2.3 Agregar las credenciales al proyecto

Abre el archivo `lib/main.dart` y reemplaza los valores:

```dart
await Supabase.initialize(
  url: 'https://TU_PROJECT_URL.supabase.co',   // ← pega tu URL aquí
  anonKey: 'eyJTU_ANON_KEY...',                 // ← pega tu anon key aquí
);
```

> ⚠️ **Nunca subas este archivo con credenciales reales a un repositorio público.**
> Considera usar un archivo `.env` o `flutter_dotenv` para producción.

---

## 🗄️ Paso 3 — Configurar la base de datos en Supabase

### 3.1 Ejecutar el SQL de creación de tablas

En el panel de Supabase, ve a **SQL Editor** y ejecuta el contenido del archivo:

```
supabase_setup.sql
```

Este archivo crea las tablas `perfiles`, `sectores`, `asignaciones` y `vacunaciones`, junto con las políticas RLS y los sectores de Quito precargados.

### 3.2 Configurar el bucket de fotos

1. En Supabase ve a **Storage**
2. Crea un bucket llamado exactamente: `fotos`
3. En la configuración del bucket, activa **Public bucket**

### 3.3 Configurar Auth

En Supabase ve a **Authentication → Providers → Email**:
- Desactiva **"Confirm email"** (para que los usuarios creados puedan iniciar sesión inmediatamente sin verificar email)

### 3.4 Crear el primer usuario (Coordinador de campaña)

En **Authentication → Users**, haz clic en **Add user** y crea:
- Email: `admin@vacunacion.com` (o el que prefieras)
- Password: `Vacuna2024` (la contraseña inicial definida en `AppConstants`)

Luego en **SQL Editor** ejecuta:

```sql
INSERT INTO perfiles (id, cedula, nombres, apellidos, telefono, correo, rol, primer_login)
VALUES (
  -- Reemplaza con el UUID del usuario que acabas de crear en Auth
  'UUID_DEL_USUARIO_CREADO',
  '0000000001',
  'Admin',
  'Sistema',
  '0999999999',
  'admin@vacunacion.com',
  'coordinador_campania',
  false
);
```

Para obtener el UUID, ve a **Authentication → Users** y copia el ID del usuario.

---

## 📦 Paso 4 — Instalar dependencias

```bash
flutter pub get
```

### 4.1 Generar código de Drift (base de datos local)

```bash
dart run build_runner build --delete-conflicting-outputs
```

> Este paso es **obligatorio**. Genera el archivo `app_database.g.dart` necesario para la base de datos local offline.

---

## ▶️ Paso 5 — Ejecutar la aplicación

### En un emulador Android
```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en modo debug
flutter run
```

### En un dispositivo físico Android
1. Activa **Opciones de desarrollador** en tu teléfono
2. Activa **Depuración USB**
3. Conecta el teléfono por USB
4. Ejecuta `flutter devices` para verificar que aparece
5. Ejecuta `flutter run`

### Generar APK para instalar directamente
```bash
flutter build apk --debug
```
El APK se genera en: `build/app/outputs/flutter-apk/app-debug.apk`

---

## 🔒 Paso 6 — Políticas RLS necesarias en Supabase

Ejecuta estas políticas en el **SQL Editor** de Supabase para que la aplicación funcione correctamente:

```sql
-- ── Perfiles ──────────────────────────────────────────────────────────────────
CREATE POLICY "lectura_perfiles" ON perfiles
  FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "campania_inserta_perfiles" ON perfiles
  FOR INSERT WITH CHECK (
    (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_campania'
    OR (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_brigada'
  );

-- ── Sectores ──────────────────────────────────────────────────────────────────
CREATE POLICY "lectura_sectores" ON sectores
  FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "campania_inserta_sectores" ON sectores
  FOR INSERT WITH CHECK (
    (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_campania'
  );

CREATE POLICY "campania_actualiza_sectores" ON sectores
  FOR UPDATE USING (
    (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_campania'
  );

CREATE POLICY "campania_elimina_sectores" ON sectores
  FOR DELETE USING (
    (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_campania'
  );

-- ── Asignaciones ──────────────────────────────────────────────────────────────
CREATE POLICY "lectura_asignaciones" ON asignaciones
  FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "campania_inserta_asignaciones" ON asignaciones
  FOR INSERT WITH CHECK (
    (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_campania'
  );

CREATE POLICY "campania_actualiza_asignaciones" ON asignaciones
  FOR UPDATE USING (
    (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_campania'
  );

CREATE POLICY "campania_elimina_asignaciones" ON asignaciones
  FOR DELETE USING (
    (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_campania'
  );

CREATE POLICY "brigada_inserta_asignaciones" ON asignaciones
  FOR INSERT WITH CHECK (
    (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_brigada'
  );

CREATE POLICY "brigada_actualiza_asignaciones" ON asignaciones
  FOR UPDATE USING (
    (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_brigada'
  );

-- ── Vacunaciones ──────────────────────────────────────────────────────────────
CREATE POLICY "lectura_vacunaciones" ON vacunaciones
  FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "vacunador_inserta_vacunaciones" ON vacunaciones
  FOR INSERT WITH CHECK (
    (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'vacunador'
  );

CREATE POLICY "vacunador_actualiza_propias" ON vacunaciones
  FOR UPDATE USING (vacunador_id = auth.uid());

CREATE POLICY "brigada_actualiza_vacunaciones" ON vacunaciones
  FOR UPDATE USING (
    (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_brigada'
  );

CREATE POLICY "vacunador_elimina_propias" ON vacunaciones
  FOR DELETE USING (vacunador_id = auth.uid());

-- ── Storage (bucket fotos) ─────────────────────────────────────────────────
INSERT INTO storage.buckets (id, name, public) VALUES ('fotos', 'fotos', true)
  ON CONFLICT DO NOTHING;

CREATE POLICY "lectura_publica_fotos" ON storage.objects
  FOR SELECT USING (bucket_id = 'fotos');

CREATE POLICY "vacunador_sube_fotos" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'fotos' AND auth.uid() IS NOT NULL
  );

CREATE POLICY "vacunador_actualiza_fotos" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'fotos' AND auth.uid() IS NOT NULL
  );
```

---

## 👥 Flujo de uso

```
Coordinador de campaña
  └── Crea sectores
  └── Crea coordinadores de brigada
  └── Asigna coordinadores a sectores

Coordinador de brigada
  └── Crea vacunadores
  └── Asigna vacunadores a sectores
  └── Corrige registros de su sector

Vacunador
  └── Ve sus sectores asignados
  └── Registra vacunaciones (foto + GPS)
  └── Edita sus propios registros
```

**Contraseña inicial para todos los usuarios creados:** `Vacuna2024`
Al primer ingreso, el sistema obliga a cambiar la contraseña.

---

## 🗂️ Estructura del proyecto

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart    # Rutas, roles, contraseña inicial, vacunas
│   │   └── app_colors.dart       # Colores por rol (verde/azul/teal)
│   └── network/
│       └── connectivity_service.dart
├── data/
│   ├── local/database/
│   │   └── app_database.dart     # Drift/SQLite (offline)
│   └── models/
├── domain/entities/
│   └── entities.dart
└── presentation/
    ├── auth/                     # Login, cambio y recuperación de contraseña
    ├── coordinador_campania/     # Dashboard, sectores, coordinadores
    ├── coordinador_brigada/      # Dashboard, vacunadores, registros
    ├── vacunador/                # Dashboard, sectores, registrar, mis registros
    └── shared/
        ├── providers/            # Auth provider, router
        └── widgets/              # ScaffoldMenu (drawer por rol)
```

---

## ⚠️ Solución de problemas comunes

**Error `app_database.g.dart not found`**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Error de memoria en Gradle**
Agrega en `android/gradle.properties`:
```
org.gradle.jvmargs=-Xmx2g
```

**Error de permisos de cámara o GPS en Android**
Verifica que `android/app/src/main/AndroidManifest.xml` tenga:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

**Error RLS `42501`**
Ejecuta las políticas del Paso 6 en el SQL Editor de Supabase.

**Error de autenticación tras crear usuario**
Verifica que en **Authentication → Email** esté desactivada la confirmación de email.
