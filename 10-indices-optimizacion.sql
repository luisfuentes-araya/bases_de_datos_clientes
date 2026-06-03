--| #  | Concepto                  | Qué hace                                   | Ejemplo                                                      | Para qué sirve                                      |
--| -- | ------------------------- | ------------------------------------------ | ------------------------------------------------------------ | --------------------------------------------------- |
--| 1  | ÍNDICE                   | Acelera búsquedas en columnas              | CREATE INDEX idx_nombre ON cliente(nombre)                  | WHERE, JOIN, ORDER BY más rápidos                   |
--| 2  | ÍNDICE COMPUESTO         | Índice en varias columnas                  | CREATE INDEX idx_compuesto ON cliente(id_comuna, activo)    | WHERE con múltiples columnas                        |
--| 3  | ÍNDICE ÚNICO             | Evita valores duplicados                   | CREATE UNIQUE INDEX idx_email ON cliente(email)             | RUT, email únicos                                   |
--| 4  | ÍNDICE CLUSTERED         | Ordena físicamente la tabla                | PRIMARY KEY (en algunos motores)                            | Datos ordenados físicamente                         |
--| 5  | ÍNDICE NO CLUSTERED      | No ordena la tabla                         | Índices comunes                                             | Búsquedas rápidas sin reordenar tabla               |
--| 6  | EXPLAIN                  | Muestra cómo ejecuta MySQL una consulta    | EXPLAIN SELECT * FROM cliente WHERE rut = '...'             | Ver si usa índices                                  |
--| 7  | KEY_LEN                  | Muestra cuántos bytes usa el índice        | key_len en EXPLAIN                                          | Analizar índices compuestos                         |
--| 8  | ROWS                     | Filas estimadas que revisa MySQL           | rows en EXPLAIN                                             | Medir eficiencia                                    |
--| 9  | SELECT_TYPE              | Tipo de consulta                           | SIMPLE, PRIMARY, SUBQUERY                                   | Entender complejidad                                |
--| 10 | TYPE                     | Tipo de acceso                             | ALL, index, range, ref, eq_ref                              | Me
-- ============================================
-- PARTE 10: ÍNDICES AVANZADOS + OPTIMIZACIÓN
-- ============================================

USE clientes_previsional;

-- ============================================
-- QUÉ ES UN ÍNDICE
-- ============================================

SELECT '=== PARTE 10: ÍNDICES AVANZADOS + OPTIMIZACIÓN ===' AS categoria;
SELECT 'Un índice es como un directorio que acelera la búsqueda de datos en una tabla.' AS descripcion;
SELECT 'Sin índice, MySQL revisa fila por fila (full table scan); con índice, encuentra rápido.' AS descripcion;

-- ============================================
-- CONCEPTOS DE ÍNDICES Y OPTIMIZACIÓN
-- ============================================

SELECT 'ÍNDICE' AS concepto, 'Acelera búsquedas en columnas' AS que_hace, 'WHERE, JOIN, ORDER BY' AS para_que_sirve;
SELECT 'ÍNDICE COMPUESTO' AS concepto, 'Índice en varias columnas' AS que_hace, 'WHERE con múltiples columnas' AS para_que_sirve;
SELECT 'ÍNDICE ÚNICO' AS concepto, 'Evita valores duplicados' AS que_hace, 'RUT, email' AS para_que_sirve;
SELECT 'ÍNDICE CLUSTERED (agrupado)' AS concepto, 'Ordena físicamente la tabla' AS que_hace, 'PK en algunos motores' AS para_que_sirve;
SELECT 'ÍNDICE NO CLUSTERED' AS concepto, 'No ordena la tabla' AS que_hace, 'Índices comunes' AS para_que_sirve;
SELECT 'EXPLAIN' AS concepto, 'Muestra cómo ejecuta MySQL una consulta' AS que_hace, 'Ver si usa índices' AS para_que_sirve;
SELECT 'KEY_LEN' AS concepto, 'Muestra cuántos bytes usa el índice' AS que_hace, 'Analizar índices compuestos' AS para_que_sirve;
SELECT 'ROWS' AS concepto, 'Filas estimadas que revisa MySQL' AS que_hace, 'Medir eficiencia' AS para_que_sirve;
SELECT 'SELECT_TYPE' AS concepto, 'Tipo de consulta (SIMPLE, PRIMARY, SUBQUERY)' AS que_hace, 'Entender complejidad' AS para_que_sirve;
SELECT 'TYPE' AS concepto, 'Tipo de acceso (ALL, index, range, ref, eq_ref)' AS que_hace, 'Mejor que ALL' AS para_que_sirve;
SELECT 'ALL' AS concepto, 'Full table scan (peor)' AS que_hace, 'Revisa todas las filas' AS para_que_sirve;
SELECT 'INDEX' AS concepto, 'Full index scan' AS que_hace, 'Revisa todo el índice' AS para_que_sirve;
SELECT 'RANGE' AS concepto, 'Rango de valores (BETWEEN, <, >)' AS que_hace, 'Buen para filtros' AS para_que_sirve;
SELECT 'REF' AS concepto, 'Búsqueda por índice con valor' AS que_hace, 'Bueno en JOINs' AS para_que_sirve;
SELECT 'EQ_REF' AS concepto, 'Une con PRIMARY KEY o UNIQUE' AS que_hace, 'Mejor opción' AS para_que_sirve;
SELECT 'INDEX_METHOD' AS concepto, 'Hash o B-Tree (MySQL usa B-Tree)' AS que_hace, 'Estructura del índice' AS para_que_sirve;

-- ============================================
-- SEMEJANZA: BIBLIOTECA
-- ============================================

SELECT 'SEMEJANZA: BIBLIOTECA' AS analogia;
SELECT 'Sin índice: buscar libro estante por estante' AS descripcion;
SELECT 'Con índice: ir directo al número de estante' AS descripcion;

-- ============================================
-- ÍNDICES EXISTENTES EN TU BASE
-- ============================================

-- Ver todos los índices de la tabla cliente
SHOW INDEX FROM cliente;

-- Ver índices de comuna
SHOW INDEX FROM comuna;

-- Ver índices de region
SHOW INDEX FROM region;

-- ============================================
-- CREAR ÍNDICE SIMPLE
-- ============================================

CREATE INDEX idx_cliente_apellido ON cliente(apellido_paterno);

-- Ver Índice nuevo
SHOW INDEX FROM cliente WHERE Key_name = 'idx_cliente_apellido';

-- ============================================
-- ÍNDICE ÚNICO
-- ============================================

-- Email debe ser único (si no existe)
CREATE UNIQUE INDEX idx_cliente_email_unique ON cliente(email);

-- ============================================
-- ÍNDICE COMPUESTO
-- ============================================

-- ÍÍndice en varias columnas (común + activo)
CREATE INDEX idx_cliente_comuna_activo ON cliente(id_comuna, activo);

-- Índice para busc
</think>
