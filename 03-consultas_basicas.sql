--| #  | Concepto                   | Qué hace                                 | Ejemplo                                           | Para qué sirve                       |
--| -- | -------------------------- | ---------------------------------------- | ------------------------------------------------- | ------------------------------------ |
--| 22 | SELECT                     | Ver datos                                | SELECT rut, nombre FROM cliente;                  | Consultar columnas específicas       |
--| 23 | SELECT *                   | Todas las columnas                       | SELECT * FROM cliente;                            | Ver todo el registro                 |
--| 24 | AS (alias)                 | Nombre temporal                          | SELECT nombre AS "Nombre Completo";               | Nombres más legibles en resultados   |
--| 25 | CONCAT()                   | Unir textos                              | CONCAT(nombre, ' ', apellido)                     | Crear nombre completo                |
--| 26 | WHERE                      | Filtrar filas                            | WHERE salario_uf > 30;                            | Solo registros que cumplen condición |
--| 27 | AND                        | Todas las condiciones verdaderas         | WHERE tipo = 1 AND activo = TRUE                  | Múltiples filtros juntos             |
--| 28 | OR                         | Al menos una condición verdadera         | WHERE tipo = 2 OR tipo = 3                        | Filtrar por varios valores           |
--| 29 | NOT                        | Negar condición                          | WHERE tipo != 1                                   | Excluir valores                      |
--| 30 | BETWEEN                    | Rango de valores                         | WHERE salario BETWEEN 30 AND 45                   | Rango numérico o de fecha            |
--| 31 | IN                         | Lista de valores                         | WHERE id_comuna IN (1, 2, 3)                      | Múltiples valores específicos        |
--| 32 | LIKE                       | Patrón de texto                          | WHERE nombre LIKE 'J%'                            | Búsqueda por patrón (J*)             |
--| 33 | IS NULL                    | Valor nulo                               | WHERE apellido_materno IS NULL                    | Campos vacíos                        |
--| 34 | IS NOT NULL                | Valor no nulo                            | WHERE email IS NOT NULL                           | Campos con datos                     |
--| 35 | ORDER BY ASC               | Orden ascendente                         | ORDER BY salario_uf ASC                           | Del menor al mayor                   |
--| 36 | ORDER BY DESC              | Orden descendente                        | ORDER BY salario_uf DESC                          | Del mayor al menor                   |
--| 37 | ORDER BY múltiple          | Orden por varias columnas                | ORDER BY tipo ASC, salario DESC                   | Primero por tipo, luego por salario  |
--| 38 | LIMIT                      | Limitar resultados                       | LIMIT 10                                          | Solo los primeros 10 registros       |
--| 39 | LIMIT OFFSET               | Paginación                               | LIMIT 10 OFFSET 5                                 | Mostrar página 2 (saltar 5)          |
--| 40 | GROUP BY                   | Agrupar por columna                      | GROUP BY id_tipo_prev                             | Agrupar para agregar                 |
--| 41 | COUNT(*)                   | Contar filas                             | COUNT(*) AS total                                 | Número de registros por grupo        |
--| 42 | SUM()                      | Sumar valores                            | SUM(salario_uf)                                   | Total de salarios                    |
--| 43 | AVG()                      | Promedio                                 | AVG(salario_uf)                                   | Salario promedio                     |
--| 44 | MIN()                      | Valor mínimo                             | MIN(salario_uf)                                   | Salario más bajo                     |
--| 45 | MAX()                      | Valor máximo                             | MAX(salario_uf)                                   | Salario más alto                     |
--| 46 | HAVING                     | Filtrar grupos                           | HAVING COUNT(*) > 5                               | Grupos con más de 5 clientes         |
--| 47 | Diferencia WHERE vs HAVING | WHERE filtra filas, HAVING filtra grupos | WHERE activo=TRUE GROUP BY tipo HAVING COUNT(*)>5 | Filtrar antes y después de agrupar   |
--| 48 | CASE                       | Condicional en SELECT                    | CASE WHEN salario > 30 THEN 'Alto' END            | Clasificar datos en consulta         |
--| 49 | DISTINCT                   | Valores únicos                           | SELECT DISTINCT id_tipo_prev                      | Eliminar duplicados                  |
-- ============================================
-- PARTE 3: SELECT BÁSICO + WHERE + ORDER BY + GROUP BY + HAVING
-- ============================================

USE clientes_previsional;

-- ============================================
-- 1. SELECT BÁSICO (sin filtros)
-- ============================================

-- Ver todos los clientes
SELECT * FROM cliente;

-- Ver solo columnas específicas
SELECT id_cliente, rut, nombre, apellido_paterno, email, telefono 
FROM cliente;

-- Usar alias (nombres temporales para columnas)
SELECT 
    id_cliente AS "ID",
    rut AS "RUT",
    CONCAT(nombre, ' ', apellido_paterno, ' ', apellido_materno) AS "Nombre Completo",
    email AS "Correo Electrónico",
    telefono AS "Teléfono"
FROM cliente;

SELECT '✅ SELECT básico completado' AS mensaje;

-- ============================================
-- 2. WHERE - FILTRAR REGISTROS
-- ============================================

-- Filtrar por tipo de previsión (AFP)
SELECT rut, nombre, apellido_paterno, email 
FROM cliente 
WHERE id_tipo_prev = 1;

-- Filtrar por comuna (Santiago)
SELECT rut, nombre, apellido_paterno, id_comuna 
FROM cliente 
WHERE id_comuna = 1;

-- Filtrar por activo = TRUE
SELECT rut, nombre, email, activo 
FROM cliente 
WHERE activo = TRUE;

-- Filtrar por salario (más de 40 UF)
SELECT rut, nombre, salario_uf 
FROM cliente 
WHERE salario_uf > 40;

-- Filtrar por fecha de nacimiento (nacidos después de 1990)
SELECT rut, nombre, fecha_nacimiento 
FROM cliente 
WHERE fecha_nacimiento > '1990-01-01';

-- Múltiples condiciones (AND)
SELECT rut, nombre, id_tipo_prev, salario_uf
FROM cliente
WHERE id_tipo_prev = 1  -- AFP
  AND salario_uf > 35   -- Salario mayor a 35 UF
  AND activo = TRUE;    -- Y activo

-- Múltiples condiciones (OR)
SELECT rut, nombre, id_tipo_prev
FROM cliente
WHERE id_tipo_prev = 2  -- FONASA
   OR id_tipo_prev = 3; -- ISAPRE

-- NOT para excluir
SELECT rut, nombre, id_tipo_prev
FROM cliente
WHERE id_tipo_prev != 1;  -- Todo excepto AFP

-- BETWEEN (rango de valores)
SELECT rut, nombre, salario_uf
FROM cliente
WHERE salario_uf BETWEEN 30 AND 45;

-- IN (múltiples valores específicos)
SELECT rut, nombre, id_comuna
FROM cliente
WHERE id_comuna IN (1, 2, 3, 4, 5);  -- Solo comunas 1-5 (Santiago, Providencia, Las Condes, Ñuñoa, Maipú)

-- LIKE (búsqueda por patrón de texto)
SELECT rut, nombre, email
FROM cliente
WHERE nombre LIKE 'J%';  -- Names que empiezan con J

SELECT rut, nombre, email
FROM cliente
WHERE email LIKE '%@email.com';  -- Todos los emails con @email.com

SELECT rut, nombre, apellido_paterno
FROM cliente
WHERE apellido_paterno LIKE '%ez';  -- Apellidos que terminan en "ez"

-- IS NULL y IS NOT NULL
SELECT rut, nombre, apellido_materno
FROM cliente
WHERE apellido_materno IS NOT NULL;  -- Clientes con apellido materno

SELECT '✅ WHERE completado - múltiples filtros' AS mensaje;

-- ============================================
-- 3. ORDER BY - ORDENAR RESULTADOS
-- ============================================

-- Ordenar ascendente (por defecto)
SELECT rut, nombre, salario_uf
FROM cliente
ORDER BY salario_uf ASC;

-- Ordenar descendente
SELECT rut, nombre, salario_uf
FROM cliente
ORDER BY salario_uf DESC;

-- Ordenar por nombre
SELECT rut, nombre, apellido_paterno
FROM cliente
ORDER BY nombre ASC;

-- Ordenar por múltiples columnas
SELECT rut, nombre, id_tipo_prev, salario_uf
FROM cliente
ORDER BY id_tipo_prev ASC, salario_uf DESC;  -- Primero por tipo, dentro de cada tipo por salario descendente

-- Ordenar por fecha (más recientes primero)
SELECT rut, nombre, fecha_registro
FROM cliente
ORDER BY fecha_registro DESC;

SELECT '✅ ORDER BY completado' AS mensaje;

-- ============================================
-- 4. LIMIT - LIMITAR RESULTADOS
-- ============================================

-- Ver solo los primeros 10 clientes
SELECT rut, nombre, email
FROM cliente
LIMIT 10;

-- Ver los 5 clientes con mayor salario
SELECT rut, nombre, salario_uf
FROM cliente
ORDER BY salario_uf DESC
LIMIT 5;

-- Paginación: primeros 10, saltando 5 (OFFSET)
SELECT rut, nombre, email
FROM cliente
LIMIT 10 OFFSET 5;  -- Mostr

-- ============================================
-- 5. GROUP BY + HAVING (AGREGACIÓN Y FILTRO DE GRUPOS)
-- ============================================

-- CONTAR clientes por tipo de previsión
SELECT 
    id_tipo_prev,
    COUNT(*) AS total_clientes
FROM cliente
GROUP BY id_tipo_prev;

-- CONTAR clientes por tipo de previsión + mostrar nombre
SELECT 
    tp.nombre AS "Tipo de Previsión",
    COUNT(*) AS total_clientes
FROM cliente c
JOIN tipo_prevision tp ON c.id_tipo_prev = tp.id_tipo
GROUP BY tp.nombre, tp.id_tipo;

-- SUMAR salarios por tipo de previsión
SELECT 
    id_tipo_prev,
    COUNT(*) AS total_clientes,
    SUM(salario_uf) AS suma_salarios_uf,
    AVG(salario_uf) AS promedio_salario_uf,
    MIN(salario_uf) AS minimo_salario_uf,
    MAX(salario_uf) AS maximo_salario_uf
FROM cliente
GROUP BY id_tipo_prev;

-- Agrupar por comuna (mostrar top 5 comunas con más clientes)
SELECT 
    id_comuna,
    COUNT(*) AS total_clientes,
    AVG(salario_uf) AS promedio_salario
FROM cliente
GROUP BY id_comuna
ORDER BY total_clientes DESC
LIMIT 5;

-- ============================================
-- HAVING - FILTRAR GRUPOS (¡AQUÍ ESTÁ!)
-- ============================================

-- Grupos con MÁS DE 5 clientes
SELECT 
    id_tipo_prev,
    COUNT(*) AS total_clientes
FROM cliente
GROUP BY id_tipo_prev
HAVING COUNT(*) > 5;

-- Tipos de previsión con promedio de salario mayor a 35 UF
SELECT 
    id_tipo_prev,
    COUNT(*) AS total_clientes,
    AVG(salario_uf) AS promedio_salario_uf
FROM cliente
GROUP BY id_tipo_prev
HAVING AVG(salario_uf) > 35;

-- COMBINAR WHERE + HAVING (ejemplo clásico)
-- Primero filtras filas con WHERE, luego filtras grupos con HAVING
SELECT 
    id_comuna,
    COUNT(*) AS total_clientes,
    AVG(salario_uf) AS promedio_salario
FROM cliente
WHERE activo = TRUE  -- WHERE: filtra solo clientes activos (antes de agrupar)
GROUP BY id_comuna
HAVING COUNT(*) >= 2  -- HAVING: filtra grupos con 2+ clientes (después de agrupar)
ORDER BY total_clientes DESC;

-- HAVING con múltiples condiciones
SELECT 
    id_tipo_prev,
    COUNT(*) AS total_clientes,
    SUM(salario_uf) AS suma_salarios
FROM cliente
GROUP BY id_tipo_prev
HAVING COUNT(*) >= 5 
   AND SUM(salario_uf) > 500;

-- Agrupar por región (necesita JOIN)
SELECT 
    r.nombre AS "Región",
    COUNT(*) AS total_clientes,
    AVG(c.salario_uf) AS promedio_salario_uf
FROM cliente c
JOIN comuna cm ON c.id_comuna = cm.id_comuna
JOIN region r ON cm.id_region = r.id_region
GROUP BY r.nombre, r.id_region
HAVING COUNT(*) >= 2
ORDER BY total_clientes DESC;

-- HAVING con SUM (clientes con salario total mayor a cierto valor)
SELECT 
    id_tipo_prev,
    COUNT(*) AS clientes,
    SUM(salario_uf) AS total_salario_uf
FROM cliente
GROUP BY id_tipo_prev
HAVING SUM(salario_uf) > 800;

SELECT '✅ GROUP BY + HAVING completados' AS mensaje;

-- ============================================
-- 6. FUNCIÓN CONCAT + CASE (BÁSICO)
-- ============================================

-- CONCAT para unir textos
SELECT 
    CONCAT(nombre, ' ', apellido_paterno, ' ', apellido_materno) AS "Nombre Completo",
    CONCAT(email, ' | ', telefono) AS "Contacto"
FROM cliente
LIMIT 10;

-- CASE básico (condicional en SELECT)
SELECT 
    rut,
    nombre,
    id_tipo_prev,
    CASE 
        WHEN id_tipo_prev = 1 THEN 'AFP'
        WHEN id_tipo_prev = 2 THEN 'FONASA'
        WHEN id_tipo_prev = 3 THEN 'ISAPRE'
        ELSE 'No asignado'
    END AS "Tipo de Previsión"
FROM cliente
LIMIT 15;

-- CASE con condiciones numéricas
SELECT 
    rut,
    nombre,
    salario_uf,
    CASE 
        WHEN salario_uf < 30 THEN 'Bajo'
        WHEN salario_uf BETWEEN 30 AND 45 THEN 'Medio'
        WHEN salario_uf > 45 THEN 'Alto'
        ELSE 'Desconocido'
    END AS "Nivel Salarial"
FROM cliente
ORDER BY salario_uf DESC
LIMIT 15;

SELECT '✅ CONCAT + CASE completados' AS mensaje;

-- ============================================
-- 7. DISTINTO + RESUMEN FINAL
-- ============================================

-- DISTINCT para valores únicos
SELECT DISTINCT id_tipo_prev FROM cliente;
SELECT DISTINCT id_comuna FROM cliente;
SELECT DISTINCT nombre FROM region ORDER BY nombre;

-- Resumen completo de aprendizaje PARTE 3
SELECT '=== RESUMEN APRENDIZAJE PARTE 3 ===' AS categoria;
SELECT 'SELECT básico' AS tema;
SELECT 'WHERE (filas individuales)' AS tema;
SELECT 'ORDER BY (ordenamiento)' AS tema;
SELECT 'LIMIT (paginación)' AS tema;
SELECT 'GROUP BY (agrupamiento)' AS tema;
SELECT 'HAVING (filtra grupos con agregadas)' AS tema;
SELECT 'COUNT, SUM, AVG, MIN, MAX' AS tema;
SELECT 'CONCAT, CASE' AS tema;
SELECT 'DISTINCT' AS tema;
SELECT '=== FIN PARTE 3 ===' AS categoria;


// WHERE DESPUES DE GROUP BY FILTRA FILAS INDIVIDUALES
// HAVING DESPUES DE GROUP BY FILTRA GRUPOS 
