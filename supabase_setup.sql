-- ═══════════════════════════════════════════════════════════════
-- SCRIPT DE CONFIGURACIÓN SUPABASE
-- Sistema de Vacunación Canina y Felina
-- Ejecutar en: Supabase Dashboard → SQL Editor
-- ═══════════════════════════════════════════════════════════════

-- ── 1. TABLA: perfiles ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS perfiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  cedula VARCHAR(13) UNIQUE NOT NULL,
  nombres VARCHAR(100) NOT NULL,
  apellidos VARCHAR(100) NOT NULL,
  telefono VARCHAR(15) NOT NULL,
  correo VARCHAR(255) UNIQUE NOT NULL,
  rol VARCHAR(30) NOT NULL CHECK (rol IN (
    'coordinador_campania',
    'coordinador_brigada',
    'vacunador'
  )),
  primer_login BOOLEAN DEFAULT TRUE,
  creado_por UUID REFERENCES perfiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── 2. TABLA: sectores ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sectores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre VARCHAR(100) NOT NULL,
  ciudad VARCHAR(100) DEFAULT 'Quito',
  descripcion TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── 3. TABLA: asignaciones ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS asignaciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID NOT NULL REFERENCES perfiles(id) ON DELETE CASCADE,
  sector_id UUID NOT NULL REFERENCES sectores(id) ON DELETE CASCADE,
  asignado_por UUID REFERENCES perfiles(id),
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(usuario_id, sector_id)
);

-- ── 4. TABLA: vacunaciones ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS vacunaciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vacunador_id UUID REFERENCES perfiles(id),
  sector_id UUID REFERENCES sectores(id),
  propietario_nombre VARCHAR(150) NOT NULL,
  propietario_cedula VARCHAR(13) NOT NULL,
  propietario_telefono VARCHAR(15),
  tipo_mascota VARCHAR(10) NOT NULL CHECK (tipo_mascota IN ('perro', 'gato')),
  mascota_nombre VARCHAR(100) NOT NULL,
  mascota_edad_aprox VARCHAR(30),
  mascota_sexo VARCHAR(15) CHECK (mascota_sexo IN ('macho', 'hembra')),
  vacuna_aplicada VARCHAR(100) NOT NULL,
  observaciones TEXT,
  foto_url TEXT,
  latitud DECIMAL(10,8),
  longitud DECIMAL(11,8),
  fecha_vacunacion TIMESTAMPTZ DEFAULT NOW(),
  editado_por UUID REFERENCES perfiles(id),
  ultima_edicion TIMESTAMPTZ,
  sincronizado BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── 5. SECTORES PRECARGADOS (Quito) ────────────────────────────
INSERT INTO sectores (nombre, ciudad) VALUES
  ('La Mariscal', 'Quito'),
  ('El Ejido', 'Quito'),
  ('La Floresta', 'Quito'),
  ('Iñaquito', 'Quito'),
  ('Cotocollao', 'Quito'),
  ('Calderón', 'Quito'),
  ('Quitumbe', 'Quito'),
  ('Solanda', 'Quito'),
  ('El Condado', 'Quito'),
  ('Guamaní', 'Quito'),
  ('Turubamba', 'Quito'),
  ('La Magdalena', 'Quito'),
  ('Centro Histórico', 'Quito'),
  ('La Vicentina', 'Quito'),
  ('Chillogallo', 'Quito')
ON CONFLICT DO NOTHING;

-- ── 6. ROW LEVEL SECURITY ───────────────────────────────────────
ALTER TABLE perfiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sectores ENABLE ROW LEVEL SECURITY;
ALTER TABLE asignaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE vacunaciones ENABLE ROW LEVEL SECURITY;

-- Perfiles: cada usuario lee su propio perfil
CREATE POLICY "perfil_propio" ON perfiles
  FOR SELECT USING (auth.uid() = id);

-- Coordinador de campaña lee todos los perfiles
CREATE POLICY "campania_lee_todos" ON perfiles
  FOR SELECT USING (
    (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_campania'
  );

-- Coordinador de brigada lee su propio perfil y vacunadores de su sector
CREATE POLICY "brigada_lee_vacunadores" ON perfiles
  FOR SELECT USING (
    auth.uid() = id
    OR (
      (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_brigada'
      AND rol = 'vacunador'
      AND id IN (
        SELECT usuario_id FROM asignaciones
        WHERE sector_id IN (
          SELECT sector_id FROM asignaciones WHERE usuario_id = auth.uid() AND activo = TRUE
        )
      )
    )
  );

-- Sectores: todos los autenticados pueden leer
CREATE POLICY "sectores_lectura" ON sectores
  FOR SELECT USING (auth.role() = 'authenticated');

-- Solo coordinador de campaña puede crear sectores
CREATE POLICY "sectores_insertar" ON sectores
  FOR INSERT WITH CHECK (
    (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_campania'
  );

-- Asignaciones: lectura según rol
CREATE POLICY "asignaciones_lectura" ON asignaciones
  FOR SELECT USING (
    usuario_id = auth.uid()
    OR (SELECT rol FROM perfiles WHERE id = auth.uid()) IN (
      'coordinador_campania', 'coordinador_brigada'
    )
  );

-- Vacunaciones: vacunador ve solo las suyas
CREATE POLICY "vacunador_sus_registros" ON vacunaciones
  FOR SELECT USING (
    vacunador_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM asignaciones a
      WHERE a.usuario_id = auth.uid()
        AND a.sector_id = vacunaciones.sector_id
        AND a.activo = TRUE
    )
    OR (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'coordinador_campania'
  );

-- Vacunaciones: insertar solo si es vacunador
CREATE POLICY "vacunador_insertar" ON vacunaciones
  FOR INSERT WITH CHECK (
    (SELECT rol FROM perfiles WHERE id = auth.uid()) = 'vacunador'
    AND vacunador_id = auth.uid()
  );

-- Vacunaciones: actualizar el propio registro (vacunador) o cualquiera del sector (brigada)
CREATE POLICY "actualizar_vacunacion" ON vacunaciones
  FOR UPDATE USING (
    vacunador_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM asignaciones a
      WHERE a.usuario_id = auth.uid()
        AND a.sector_id = vacunaciones.sector_id
        AND a.activo = TRUE
    )
  );

-- ── 7. STORAGE: bucket fotos ────────────────────────────────────
INSERT INTO storage.buckets (id, name, public)
VALUES ('fotos', 'fotos', true)
ON CONFLICT DO NOTHING;

CREATE POLICY "fotos_subir" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'fotos'
    AND auth.role() = 'authenticated'
  );

CREATE POLICY "fotos_leer" ON storage.objects
  FOR SELECT USING (bucket_id = 'fotos');

-- ── 8. COORDINADOR INICIAL (Ejecutar manualmente después) ───────
-- Primero crear el usuario en Authentication → Users con correo y
-- contraseña Ecuador2026, luego insertar su perfil:
--
-- INSERT INTO perfiles (id, cedula, nombres, apellidos, telefono, correo, rol)
-- VALUES (
--   'UUID_DEL_USUARIO_CREADO',
--   '1234567890',
--   'Juan',
--   'Pérez',
--   '0991234567',
--   'coordinador@vacunacion.gob.ec',
--   'coordinador_campania'
-- );
