
-- ============================================
-- PARTE 4: JOINs (INNER, LEFT, RIGHT múltiple)
-- ============================================

USE clientes_previsional;

-- ============================================
-- 1. INNER JOIN (solo registros que coinciden en AMBAS tablas)
-- ============================================

-- Cliente + Tipo de Previsión (nombre legible)
SELECT 
    c.rut,
    c.nombre,
    c.apellido_paterno,
    tp.nombre AS "Tipo de Previsión"
FROM cliente c
INNER JOIN tipo_prevision tp ON c.id_tipo_prev = tp.id_tipo;

-- Inner JOIN con WHERE (filtrar solo AFP)
SELECT 
    c.rut,
    c.nombre,
    c.apellido_paterno,
    tp.nombre AS "Previsión",
    c.salario_uf
FROM cliente c
INNER JOIN tipo_prevision tp ON c.id_tipo_prev = tp.id_tipo
WHERE tp.nombre = 'AFP';

-- Cliente + Comuna (mostrar nombre de comuna en vez de ID)
SELECT 
    c.rut,
    c.nombre,
    c.apellido_paterno,
    cm.nombre AS "Comuna"
FROM cliente c
INNER JOIN comuna cm ON c.id_comuna = cm.id_comuna;

-- 3 TABLAS: Cliente + Comuna + Región
SELECT 
    c.rut,
    c.nombre,
    c.apellido_paterno,
    cm.nombre AS "Comuna",
    r.nombre AS "Región"
FROM cliente c
INNER JOIN comuna cm ON c.id_comuna = cm.id_comuna
INNER JOIN region r ON cm.id_region = r.id_region;

-- 3 TABLAS con filtro de región
SELECT 
    c.rut,
    c.nombre,
    cm.nombre AS "Comuna",
    r.nombre AS "Región",
    c.salario_uf
FROM cliente c
INNER JOIN comuna cm ON c.id_comuna = cm.id_comuna
INNER JOIN region r ON cm.id_region = r.id_region
WHERE r.nombre = 'XIII - Metropolitana';

-- INNER JOIN con GROUP BY (contar clientes por región)
SELECT 
    r.nombre AS "Región",
    COUNT(*) AS total_clientes,
    AVG(c.salario_uf) AS promedio_salario_uf
FROM cliente c
INNER JOIN comuna cm ON c.id_comuna = cm.id_comuna
INNER JOIN region r ON cm.id_region = r.id_region
GROUP BY r.nombre, r.id_region
ORDER BY total_clientes DESC;

-- INNER JOIN con cliente y su afiliación histórica
SELECT 
    c.rut,
    c.nombre,
    c.apellido_paterno,
    ah.nombre_afiliadora,
    ah.tipo_afiliacion,
    ah.fecha_afiliacion
FROM cliente c
INNER JOIN afiliacion_historica ah ON c.id_cliente = ah.id_cliente
ORDER BY c.id_cliente, ah.fecha_afiliacion;

SELECT '✅ INNER JOIN completado' AS mensaje;

-- ============================================
-- 2. LEFT JOIN (todos los de la izq + coincidencias de la der)
-- ============================================

-- Todos los clientes, incluso si NO tienen afiliación
SELECT 
    c.rut,
    c.nombre,
    c.apellido_paterno,
    ah.nombre_afiliadora,
    ah.tipo_afiliacion
FROM cliente c
LEFT JOIN afiliacion_historica ah ON c.id_cliente = ah.id_cliente
ORDER BY c.id_cliente;

-- Clientes sin afiliación (WHERE ... IS NULL)
SELECT 
    c.rut,
    c.nombre,
    c.apellido_paterno,
    c.email
FROM cliente c
LEFT JOIN afiliacion_historica ah ON c.id_cliente = ah.id_cliente
WHERE ah.id_afiliacion IS NULL;  -- Solo clientes SIN afiliación

-- Todos las regiones, incluso si NO tienen comunas (para probar)
SELECT 
    r.nombre AS "Región",
    cm.nombre AS "Comuna",
    COUNT(c.id_cliente) AS total_clientes
FROM region r
LEFT JOIN comuna cm ON r.id_region = cm.id_region
LEFT JOIN cliente c ON cm.id_comuna = c.id_comuna
GROUP BY r.nombre, cm.nombre
ORDER BY r.nombre, total_clientes DESC;

-- LEFT JOIN con CASE (mark si tiene afiliación)
SELECT 
    c.rut,
    c.nombre,
    CASE 
        WHEN ah.id_afiliacion IS NOT NULL THEN 'Tiene afiliación'
        ELSE 'Sin afiliación'
    END AS "Estado"
FROM cliente c
LEFT JOIN afiliacion_historica ah ON c.id_cliente = ah.id_cliente
GROUP BY c.id_cliente, ah.id_afiliacion;

SELECT '✅ LEFT JOIN completado' AS mensaje;

-- ============================================
-- 3. RIGHT JOIN (todos los de la der + coincidencias de la izq)
-- ============================================

-- Todas las tipos de previsión, incluso si NO tienen clientes
SELECT 
    tp.nombre AS "Tipo de Previsión",
    c.rut,
    c.nombre
FROM cliente c
RIGHT JOIN tipo_prevision tp ON c.id_tipo_prev = tp.id_tipo
ORDER BY tp.nombre;

-- Todas las afiliaciones, incluso si el cliente fue eliminado (teórico)
SELECT 
    ah.nombre_afiliadora,
    ah.tipo_afiliacion,
    c.rut,
    c.nombre
FROM cliente c
RIGHT JOIN afiliacion_historica ah ON c.id_cliente = ah.id_cliente
ORDER BY ah.id_afiliacion;

SELECT '✅ RIGHT JOIN completado' AS mensaje;

-- ============================================
-- 4. JOINs COMPLEJOS (múltiples condiciones)
-- ============================================

-- Cliente + Comuna + Región + Tipo de Previsión (4 tablas)
SELECT 
    c.rut AS "RUT",
    CONCAT(c.nombre, ' ', c.apellido_paterno) AS "Nombre Completo",
    cm.nombre AS "Comuna",
    r.nombre AS "Región",
    tp.nombre AS "Previsión",
    c.salario_uf AS "Salario (UF)",
    c.telefono AS "Teléfono",
    c.email AS "Email"
FROM cliente c
INNER JOIN comuna cm ON c.id_comuna = cm.id_comuna
INNER JOIN region r ON cm.id_region = r.id_region
INNER JOIN tipo_prevision tp ON c.id_tipo_prev = tp.id_tipo
WHERE r.nombre = 'XIII - Metropolitana'
  AND tp.nombre = 'FONASA'
ORDER BY c.salario_uf DESC
LIMIT 20;

-- Contar afiliaciones por cliente (cada cliente puede tener varias)
SELECT 
    c.rut,
    c.nombre,
    c.apellido_paterno,
    COUNT(ah.id_afiliacion) AS numero_afiliaciones,
    GROUP_CONCAT(ah.nombre_afiliadora SEPARATOR ', ') AS "Afiliaciones"
FROM cliente c
LEFT JOIN afiliacion_historica ah ON c.id_cliente = ah.id_cliente
GROUP BY c.id_cliente, c.rut, c.nombre, c.apellido_paterno
HAVING numero_afiliaciones >= 1
ORDER BY numero_afiliaciones DESC;

-- Clientes con más afiliaciones que el promedio
SELECT 
    c.rut,
    c.nombre,
    COUNT(ah.id_afiliacion) AS numero_afiliaciones
FROM cliente c
LEFT JOIN afiliacion_historica ah ON c.id_cliente = ah.id_cliente
GROUP BY c.id_cliente, c.rut, c.nombre
HAVING numero_afiliaciones > (
    SELECT AVG(numero_afiliaciones)
    FROM (
        SELECT COUNT(*) AS numero_afiliaciones
        FROM cliente
        LEFT JOIN afiliacion_historica ON cliente.id_cliente = afiliacion_historica.id_cliente
        GROUP BY cliente.id_cliente
    ) AS subconsulta
);

SELECT '✅ JOINs complejos completados' AS mensaje;

-- ============================================
-- 5. RESUMEN DE LO QUE APRENDISTE
-- ============================================

SELECT '=== RESUMEN APRENDIZAJE PARTE 4 ===' AS categoria;
SELECT 'INNER JOIN (coincidencias en AMBAS)' AS tema;
SELECT 'LEFT JOIN (todos de la izq + coincidencias der)' AS tema;
SELECT 'RIGHT JOIN (todos de la der + coincidencias izq)' AS tema;
SELECT 'Múltiples JOINs (3+ tablas)' AS tema;
SELECT 'JOIN + WHERE + GROUP BY + HAVING combinados' AS tema;
SELECT 'JOIN + CASE para lógica condicional' AS tema;
SELECT 'GROUP_CONCAT para listas concatenadas' AS tema;
SELECT '=== FIN PARTE 4 ===' AS categoria;

-- Ejemplo práctico final: Reporte completo de clientes
SELECT 
    c.rut,
    CONCAT(c.nombre, ' ', c.apellido_paterno, ' ', c.apellido_materno) AS "Nombre Completo",
    cm.nombre AS "Comuna",
    r.nombre AS "Región",
    tp.nombre AS "Previsión",
    c.salario_uf,
    c.telefono,
    c.email,
    CASE 
        WHEN c.activo = TRUE THEN 'Activo'
        ELSE 'Inactivo'
    END AS "Estado",
    COUNT(ah.id_afiliacion) AS "Nª Afiliaciones"
FROM cliente c
INNER JOIN comuna cm ON c.id_comuna = cm.id_comuna
INNER JOIN region r ON cm.id_region = r.id_region
INNER JOIN tipo_prevision tp ON c.id_tipo_prev = tp.id_tipo
LEFT JOIN afiliacion_historica ah ON c.id_cliente = ah.id_cliente
GROUP BY c.id_cliente, cm.nombre, r.nombre, tp.nombre
ORDER BY r.nombre, cm.nombre, c.apellido_paterno;


--| Tipo JOIN       | Qué hace                                                      | Ejemplo de uso                                                                          |
--| --------------- | ------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
--| INNER JOIN      | Solo registros que coinciden en AMBAS tablas                  | cliente INNER JOIN tipo_prevision youtube                                               |
--| LEFT JOIN       | Todos los de la tabla izquierda + coincidencias de la derecha | cliente LEFT JOIN afiliacion (todos los clientes, incluso sin afiliación) youtube       |
--| RIGHT JOIN      | Todos los de la tabla derecha + coincidencias de la izquierda | cliente RIGHT JOIN tipo_prevision (todas las previsiones, incluso sin clientes) youtube |
--| Múltiples JOINs | Unir 3+ tablas                                                | cliente → comuna → región youtube                                                       |
