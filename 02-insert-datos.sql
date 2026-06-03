--| #  | Concepto         | Qué hace                | Ejemplo                                       | Para qué sirve                    |
--| -- | ---------------- | ----------------------- | --------------------------------------------- | --------------------------------- |
--| 15 | INSERT INTO      | Agrega registros        | INSERT INTO cliente VALUES (...);             | Cargar datos en tablas            |
--| 16 | INSERT múltiple  | Varias filas en 1 query | INSERT INTO tabla VALUES (...), (...), (...); | Insertar 30 clientes en 1 comando |
--| 17 | STRINGS          | Textos con comillas     | 'Juan Pérez', '+56912345678'                  | Datos de texto                    |
--| 18 | DATE             | Formato YYYY-MM-DD      | '1985-03-15'                                  | Fechas de nacimiento, registro    |
--| 19 | BOOLEAN          | TRUE/FALSE              | activo = TRUE                                 | Estado activo/inactivo            |
--| 20 | DECIMAL          | Números con decimales   | salario_uf DECIMAL(10,2)                      | Salarios con 2 decimales (UF)     |
--| 21 | SELECT 'mensaje' | Mostrar información     | SELECT '✅ Insertado' AS mensaje;              | Confirmar operaciones             |
-- ============================================
-- PARTE 2: INSERTAR DATOS
-- ============================================

USE clientes_previsional;

-- ============================================
-- 1. INSERTAR REGIONES DE CHILE
-- ============================================
INSERT INTO region (nombre, capital, poblacion) VALUES
('I - Tarapacá', 'Iquique', 330558),
('II - Antofagasta', 'Antofagasta', 607534),
('III - Atacama', 'Copiapó', 286168),
('IV - Coquimbo', 'La Serena', 752374),
('V - Valparaíso', 'Valparaíso', 1 849 471),
('VI - O\'Higgins', 'Rancagua', 914555),
('VII - Maule', 'Talca', 1 044 950),
('VIII - Biobío', 'Concepción', 1 556 793),
('IX - Araucanía', 'Temuco', 957 416),
('X - Los Lagos', 'Puerto Montt', 829 471),
('XI - Aysén', 'Coyhaique', 103 351),
('XII - Magallanes', 'Punta Arenas', 166 533),
('XIII - Metropolitana', 'Santiago', 7 112 808),
('XIV - Los Ríos', 'Valdivia', 384 837),
('XV - Arica y Parinacota', 'Arica', 226 068),
('XVI - Ñuble', 'Chillán', 480 609);

SELECT '✅ 16 regiones insertadas' AS mensaje;

-- ============================================
-- 2. INSERTAR COMUNAS (ejemplos por región)
-- ============================================
-- Metropolitana
INSERT INTO comuna (nombre, id_region, poblacion) VALUES
('Santiago', 13, 206 097),
('Providencia', 13, 131 753),
('Las Condes', 13, 294 495),
('Ñuñoa', 13, 208 237),
('Maipú', 13, 521 773),
('La Florida', 13, 365 973),
('Puente Alto', 13, 540 119),
('San Bernardo', 13, 290 894),
('Quilicura', 13, 188 234),
('Peñalolén', 13, 213 478);

-- Valparaíso
INSERT INTO comuna (nombre, id_region, poblacion) VALUES
('Valparaíso', 5, 282 448),
('Viña del Mar', 5, 334 248),
('Concón', 5, 55 502),
('Quillota', 5, 85 748),
('San Antonio', 5, 85 093);

-- Biobío
INSERT INTO comuna (nombre, id_region, poblacion) VALUES
('Concepción', 8, 223 574),
('Talcahuano', 8, 152 835),
('San Pedro de la Paz', 8, 115 632),
('Chiguayante', 8, 82 312),
('Los Ángeles', 8, 166 852);

-- O\'Higgins
INSERT INTO comuna (nombre, id_region, poblacion) VALUES
('Rancagua', 6, 214 344),
('Codegua', 6, 11 508),
('Machalí', 6, 31 565),
('O\'Higgins', 6, 10 310),
('Graneros', 6, 25 411);

-- Maule
INSERT INTO comuna (nombre, id_region, poblacion) VALUES
('Talca', 7, 197 219),
('Curicó', 7, 131 507),
('Linares', 7, 84 180),
('Cauquenes', 7, 41 130),
('Pelarco', 7, 8 700);

-- Araucanía
INSERT INTO comuna (nombre, id_region, poblacion) VALUES
('Temuco', 9, 282 415),
('Pucón', 9, 23 695),
('Villarrica', 9, 30 536),
('Angol', 9, 49 197),
('Tirúa', 9, 12 943);

-- Los Lagos
INSERT INTO comuna (nombre, id_region, poblacion) VALUES
('Puerto Montt', 10, 187 181),
('Puerto Varas', 10, 40 223),
('Osorno', 10, 145 475),
('Castro', 10, 35 975),
('Ancud', 10, 39 349);

-- Antofagasta
INSERT INTO comuna (nombre, id_region, poblacion) VALUES
('Antofagasta', 2, 361 873),
('Calama', 2, 165 731),
('Tocopilla', 2, 23 174),
('Mejillones', 2, 13 235),
('Sierra Gorda', 2, 1 821);

-- Coquimbo
INSERT INTO comuna (nombre, id_region, poblacion) VALUES
('La Serena', 4, 222 632),
('Coquimbo', 4, 181 097),
('Ovalle', 4, 103 402),
('Limache', 4, 39 029),
('Quilpue', 4, 138 053);

-- Arica y Parinacota
INSERT INTO comuna (nombre, id_region, poblacion) VALUES
('Arica', 15, 199 961),
('Putre', 15, 1 346),
('General Lagos', 15, 130);

-- Tarapacá
INSERT INTO comuna (nombre, id_region, poblacion) VALUES
('Iquique', 1, 191 468),
('Alto Hospicio', 1, 85 536),
('Pozo Almonte', 1, 18 060),
('Camiña', 1, 1 343);

-- Ñuble
INSERT INTO comuna (nombre, id_region, poblacion) VALUES
('Chillán', 16, 165 113),
('Chillán Viejo', 16, 34 266),
('Bulnes', 16, 22 425),
('San Carlos', 16, 53 667),
('Cobquecura', 16, 5 766);

SELECT ' 70+ comunas insertadas' AS mensaje;

-- ============================================
-- 3. INSERTAR TIPOS DE PREVISIÓN
-- ============================================
INSERT INTO tipo_prevision (nombre, descripcion, tasa_contribucion) VALUES
('AFP', 'Administradora de Fondos de Pensiones - sistema privado', 10.00),
('FONASA', 'Fondo Nacional de Salud - sistema público', 7.00),
('ISAPRE', 'Instituto de Salud Previsional - sistema privado', 7.00),
('NO_ASIGNADO', 'Cliente sin asignación previsional definida', 0.00);

SELECT '✅ 4 tipos de previsión insertados' AS mensaje;

-- ============================================
-- 4. INSERTAR CLIENTES (30 clientes de ejemplo)
-- ============================================
INSERT INTO cliente (rut, nombre, apellido_paterno, apellido_materno, 
                     fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, 
                     salario_uf, activo) VALUES
-- Santiago Metropolitana
('12.345.678-9', 'Juan', 'Pérez', 'González', '1985-03-15', '+56912345678', 'juan.perez@email.com', 1, 1, 25.5, TRUE),
('15.678.901-2', 'María', 'Sánchez', 'Ruiz', '1990-07-22', '+56923456789', 'maria.sanchez@email.com', 2, 2, 32.0, TRUE),
('18.901.234-5', 'Carlos', 'Muñoz', 'Torres', '1988-11-30', '+56934567890', 'carlos.munoz@email.com', 3, 1, 45.8, TRUE),
('21.234.567-8', 'Ana', 'Ramírez', 'Vargas', '1992-05-18', '+56945678901', 'ana.ramirez@email.com', 4, 3, 38.2, TRUE),
('8.765.432-1', 'Luis', 'Fuentes', 'Araya', '1995-09-10', '+56956789012', 'luis.fuentes@email.com', 5, 2, 28.5, TRUE),

('22.345.678-9', 'Patricia', 'Castro', 'Morales', '1987-02-28', '+56967890123', 'patricia.castro@email.com', 6, 1, 52.3, TRUE),
('19.456.789-0', 'Roberto', 'Jiménez', 'Ossa', '1991-12-05', '+56978901234', 'roberto.jimenez@email.com', 7, 2, 30.0, TRUE),
('16.567.890-1', 'Carmen', 'Aguirre', 'Venegas', '1989-08-14', '+56989012345', 'carmen.aguirre@email.com', 8, 3, 41.7, TRUE),
('23.678.901-2', 'Diego', 'Acuña', 'Salinas', '1993-04-20', '+56990123456', 'diego.acuna@email.com', 9, 1, 35.5, TRUE),
('17.789.012-3', 'Verónica', 'Núñez', 'Campos', '1986-06-25', '+56901234567', 'veronica.nunez@email.com', 10, 2, 29.8, TRUE),

-- Valparaíso
('14.890.123-4', 'Fernando', 'Rojas', 'Contreras', '1984-10-12', '+56912340000', 'fernando.rojas@email.com', 11, 1, 48.0, TRUE),
('20.901.234-5', 'Silvia', 'Martínez', 'Suárez', '1994-01-08', '+56923450000', 'silvia.martinez@email.com', 12, 3, 33.2, TRUE),
('13.012.345-6', 'Andrés', 'Garrido', 'Paredes', '1988-09-17', '+56934560000', 'andres.garrido@email.com', 13, 2, 37.5, TRUE),
('24.123.456-7', 'Claudia', 'Henríquez', 'Bravo', '1991-03-29', '+56945670000', 'claudia.henriquez@email.com', 14, 1, 42.0, TRUE),
('11.234.567-8', 'Gustavo**, **'Ibarra', 'López', '1987-07-03', '+56956780000', 'gustavo.ibarra@email.com', 15, 2, 31.5, TRUE),

-- Concepción
('25.345.678-9', 'Vanessa', 'Poblete', 'Sepúlveda', '1990-11-21', '+56967890000', 'vanessa.poblete@email.com', 16, 1, 39.8, TRUE),
('12.456.789-0', 'Eduardo', 'Vásquez', 'Cortés', '1986-04-14', '+56978900000', 'eduardo.vasquez@email.com', 17, 3, 44.5, TRUE),
('26.567.890-1', 'Daniela**, **'Suazo', 'Reyes', '1993-08-07', '+56989010000', 'daniela.suazo@email.com', 18, 2, 36.0, TRUE),
('10.678.901-2', 'Miguel', 'Araya', 'Herrera', '1989-02-19', '+56990120000', 'miguel.araya@email.com', 19, 1, 47.2, TRUE),
('27.789.012-3', 'Pamela**, **'Vidal', 'Gajardo', '1992-06-30', '+56901230000', 'pamela.vidal@email.com', 20, 2, 34.8, TRUE),

-- Rancagua
('18.890.123-4', 'Sergio', 'Maldonado', 'Espinoza', '1985-12-09', '+56912341111', 'sergio.maldonado@email.com', 21, 1, 50.0, TRUE),
('28.901.234-5', 'Lorena**, **'Carrasco', 'Beltrán', '1991-05-26', '+56923451111', 'lorena.carrasco@email.com', 23, 2, 38.5, TRUE),
('15.012.345-6', 'Ricardo**, **'Paredes', 'Gutiérrez', '1988-10-03', '+56934561111', 'ricardo.paredes@email.com', 22, 3, 41.0, TRUE),

-- Talca
('29.123.456-7', 'Gabriela**, **'Medina', 'Navarro', '1990-07-15', '+56945671111', 'gabriela.medina@email.com', 26, 1, 35.0, TRUE),
('14.234.567-8', 'Héctor**, **'González', 'Parra', '1987-03-22', '+56956781111', 'hector.gonzalez@email.com', 27, 2, 43.5, TRUE),
('30.345.678-9', 'Karina**, **'Pino**, **'Soto', '1994-01-11', '+56967891111', 'karina.pino@email.com', 28, 1, 32.8, TRUE),

-- Temuco
('19.456.789-1', 'Benjamín**, **'Viveros', 'Carrasco', '1989-09-28', '+56978901111', 'benjamin.viveros@email.com', 31, 3, 37.2, TRUE),
('20.567.890-2', 'Francisca**, **'Ascarza', 'Lam', '1992-12-04', '+56989011111', 'francisca.ascarza@email.com', 32, 2, 33.5, TRUE),

-- Puerto Montt
('21.678.901-3', 'Rodrigo**, **'Saavedra', 'Mardones', '1986-06-17', '+56990121111', 'rodrigo.saavedra@email.com', 36, 1, 46.0, TRUE),
('22.789.012-4', 'Ximena**, **'Díaz', 'Riquelme', '1993-04-09', '+56901231111', 'ximena.diaz@email.com', 37, 2, 39.0, TRUE),

-- Inactivo (para probar filtros)
('31.890.123-5', 'Pedro**, **'Navarro', 'Rojas', '1980-02-14', '+56912342222', 'pedro.navarro@email.com', 1, 2, 25.0, FALSE),
('32.901.234-6', '一款', **'Molina', 'San Martín', '1978-11-20', '+56923452222', 'emma.molina@email.com', 3, 1, 28.0, FALSE);

SELECT '✅ 30 clientes insertados (28 activos, 2 inactivos)' AS mensaje;

-- ============================================
-- 5. INSERTAR HISTORIAL DE AFILIACIONES
-- ============================================
INSERT INTO afiliacion_historica (id_cliente, nombre_afiliadora, fecha_afiliacion, 
                                   tipo_afiliacion, folio_contrato) VALUES
(1, 'AFP Provida', '2005-03-01', 'AFP', 'AFP-001-2005'),
(1, 'FONASA', '2015-06-15', 'FONASA', 'FON-001-2015'),
(2, 'FONASA', '2010-07-01', 'FONASA', 'FON-002-2010'),
(3, 'AFP Cuprum', '2008-01-15', 'AFP', 'AFP-003-2008'),
(4, 'ISAPRE Banmédica', '2012-05-20', 'ISAPRE', 'ISAP-004-2012'),
(5, 'FONASA', '2018-09-01', 'FONASA', 'FON-005-2018'),
(6, 'AFP Modelo', '2007-02-10', 'AFP', 'AFP-006-2007'),
(7, 'FONASA', '2013-11-25', 'FONASA', 'FON-007-2013'),
(8, 'ISAPRE Consalud', '2011-08-30', 'ISAPRE', 'ISAP-008-2011'),
(9, 'AFP Kapital', '2014-04-12', 'AFP', 'AFP-009-2014'),
(10, 'FONASA', '2010-06-18', 'FONASA', 'FON-010-2010'),
(11, 'AFP Habitat', '2006-10-05', 'AFP', 'AFP-011-2006'),
(12, 'ISAPRE Cruz Blanca', '2016-01-22', 'ISAPRE', 'ISAP-012-2016'),
(13, 'FONASA', '2012-03-08', 'FONASA', 'FON-013-2012'),
(14, 'AFP Continuidad', '2015-07-30', 'AFP', 'AFP-014-2015'),
(15, 'FONASA', '2009-12-14', 'FONASA', 'FON-015-2009'),
(16, 'AFP Uno', '2011-05-25', 'AFP', 'AFP-016-2011'),
(17, 'ISAPRE Bielmed', '2014-09-10', 'ISAPRE', 'ISAP-017-2014'),
(18, 'FONASA', '2017-02-28', 'FONASA', 'FON-018-2017'),
(19, 'AFP Búho', '2008-11-19', 'AFP', 'AFP-019-2008'),
(20, 'FONASA', '2013-04-05', 'FONASA', 'FON-020-2013'),
(21, 'AFP Provida', '2004-01-10', 'AFP', 'AFP-021-2004'),
(22, 'FONASA', '2016-08-15', 'FONASA', 'FON-022-2016'),
(23, 'ISAPRE Masvida', '2010-10-20', 'ISAPRE', 'ISAP-023-2010'),
(24, 'AFP Cuprum', '2012-06-08', 'AFP', 'AFP-024-2012'),
(25, 'FONASA', '2011-03-22', 'FONASA', 'FON-025-2011'),
(26, 'AFP Modelo', '2015-12-01', 'AFP', 'AFP-026-2015'),
(27, 'FONASA', '2018-05-14', 'FONASA', 'FON-027-2018'),
(28, 'AFP Kapital', '2013-09-27', 'AFP', 'AFP-028-2013'),
(29, 'FONASA', '2014-07-19', 'FONASA', 'FON-029-2014'),
(30, 'ISAPRE Banmédica', '2016-11-05', 'ISAPRE', 'ISAP-030-2016');

SELECT '30 afiliaciones históricas insertadas' AS mensaje;

-- ============================================
-- 6. VERIFICAR DATOS INSERTADOS
-- ============================================
SELECT '--- Resumen de datos insertados ---' AS informacion;
SELECT 'Regiones: ' || COUNT(*) FROM region;
SELECT 'Comunas: ' || COUNT(*) FROM comuna;
SELECT 'Tipos de previsión: ' || COUNT(*) FROM tipo_prevision;
SELECT 'Clientes activos: ' || COUNT(*) FROM cliente WHERE activo = TRUE;
SELECT 'Clientes inactivos: ' || COUNT(*) FROM cliente WHERE activo = FALSE;
SELECT 'Total clientes: ' || COUNT(*) FROM cliente;
SELECT 'Afiliaciones: ' || COUNT(*) FROM afiliacion_historica;
SELECT '--- Fin del resumen ---' AS informacion;
