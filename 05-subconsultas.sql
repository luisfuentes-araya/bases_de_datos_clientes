-- ============================================
-- PARTE 5: SUBCONSULTAS (Subqueries anidadas)
-- ============================================

USE clientes_previsional;

-- ============================================
-- 1. SUBCONSULTA EN WHERE (la más común)
-- ============================================

-- Clientes con salario MAYOR al promedio
SELECT 
    rut,
    nombre,
    apellido_paterno,
    salario_uf
FROM cliente
WHERE salario_uf > (
    SELECT AVG(salario_uf) 
    FROM cliente
);

-- Clientes de AFP con salario mayor al promedio general
SELECT 
    c.rut,
    c.nombre,
    c.salario_uf
FROM cliente c
WHERE c.salario_uf > (
    SELECT AVG(salario_uf) 
    FROM cliente
)
AND c.id_tipo_prev = (
    SELECT id_tipo 
    FROM tipo_prevision 
    WHERE nombre = 'AFP'
);

-- Clientes de la comuna con MÁS clientes (comuna más poblada)
SELECT 
    c.rut,
    c.nombre,
    c.id_comuna
FROM cliente c
WHERE c.id_comuna = (
    SELECT id_comuna
    FROM (
        SELECT id_comuna, COUNT(*) AS total
        FROM cliente
        GROUP BY id_comuna
        ORDER BY total DESC
        LIMIT 1
    ) AS subconsulta
);

-- Clientes con salario menor al MÍNIMO de AFP
SELECT 
    rut,
    nombre,
    salario_uf,
    id_tipo_prev
FROM cliente
WHERE salario_uf < (
    SELECT MIN(salario_uf)
    FROM cliente
    WHERE id_tipo_prev = (
        SELECT id_tipo 
        FROM tipo_prevision 
        WHERE nombre = 'AFP'
    )
);

SELECT '✅ Subconsultas en WHERE completadas' AS mensaje;

-- ============================================
-- 2. SUBCONSULTA EN FROM (tabla derivada)
-- ============================================

-- Promedio de salarios por tipo de previsión (como tabla temporal)
SELECT 
    sub.`Tipo de Previsión`,
    sub.total_clientes,
    sub.promedio_salario
FROM (
    SELECT 
        tp.nombre AS `Tipo de Previsión`,
        COUNT(*) AS total_clientes,
        AVG(c.salario_uf) AS promedio_salario
    FROM cliente c
    INNER JOIN tipo_prevision tp ON c.id_tipo_prev = tp.id_tipo
    GROUP BY tp.id_tipo, tp.nombre
) AS sub
WHERE sub.promedio_salario > 35;

-- Comunas con más de 2 clientes y su promedio salarial
SELECT 
    sub.comuna,
    sub.total_clientes,
    sub.promedio_salario,
    sub.region
FROM (
    SELECT 
        cm.nombre AS comuna,
        r.nombre AS region,
        COUNT(*) AS total_clientes,
        AVG(c.salario_uf) AS promedio_salario
    FROM cliente c
    INNER JOIN comuna cm ON c.id_comuna = cm.id_comuna
    INNER JOIN region r ON cm.id_region = r.id_region
    GROUP BY cm.id_comuna, cm.nombre, r.nombre
    HAVING total_clientes > 2
) AS sub
ORDER BY sub.total_clientes DESC;

SELECT '✅ Subconsultas en FROM completadas' AS mensaje;

-- ============================================
-- 3. SUBCONSULTA CORRELACIONADA (depende de la consulta externa)
-- ============================================

-- Clientes con salario mayor al promedio de SU tipo de previsión
SELECT 
    c1.rut,
    c1.nombre,
    c1.salario_uf,
    c1.id_tipo_prev,
    (
        SELECT AVG(c2.salario_uf)
        FROM cliente c2
        WHERE c2.id_tipo_prev = c1.id_tipo_prev
    ) AS promedio_tipo,
    CASE 
        WHEN c1.salario_uf > (
            SELECT AVG(c2.salario_uf)
            FROM cliente c2
            WHERE c2.id_tipo_prev = c1.id_tipo_prev
        ) THEN 'Sobre promedio'
        ELSE 'Bajo promedio'
    END AS comparacion
FROM cliente c1
ORDER BY c1.id_tipo_prev, c1.salario_uf DESC;

-- Para cada cliente, mostrar cuántos tienen mayor salario en SU región
SELECT 
    c1.rut,
    c1.nombre,
    cm1.nombre AS comuna,
    c1.salario_uf,
    (
        SELECT COUNT(*)
        FROM cliente c2
        INNER JOIN comuna cm2 ON c2.id_comuna = cm2.id_comuna
        WHERE cm2.id_region = cm1.id_region
          AND c2.salario_uf > c1.salario_uf
    ) AS personas_con_mayor_salario_en_region
FROM cliente c1
INNER JOIN comuna cm1 ON c1.id_comuna = cm1.id_comuna
ORDER BY cm1.nombre, c1.salario_uf DESC;

SELECT '✅ Subconsultas correlacionadas completadas' AS mensaje;

-- ============================================
-- 4. OPERADORES IN, EXISTS, ANY, ALL con Subconsultas
-- ============================================

-- IN: Clientes de comunas de la Región Metropolitana
SELECT 
    rut,
    nombre,
    id_comuna
FROM cliente
WHERE id_comuna IN (
    SELECT id_comuna
    FROM comuna
    WHERE id_region = (
        SELECT id_region
        FROM region
        WHERE nombre = 'XIII - Metropolitana'
    )
);

-- IN: Clientes con tipo de previsión AFP o ISAPRE
SELECT 
    rut,
    nombre,
    id_tipo_prev
FROM cliente
WHERE id_tipo_prev IN (
    SELECT id_tipo
    FROM tipo_prevision
    WHERE nombre IN ('AFP', 'ISAPRE')
);

-- NOT IN: Clientes NO de Fonasa
SELECT 
    rut,
    nombre,
    id_tipo_prev
FROM cliente
WHERE id_tipo_prev NOT IN (
    SELECT id_tipo
    FROM tipo_prevision
    WHERE nombre = 'FONASA'
);

-- EXISTS: Clientes que TIENEN afiliación histórica
SELECT 
    c.rut,
    c.nombre,
    c.email
FROM cliente c
WHERE EXISTS (
    SELECT 1
    FROM afiliacion_historica ah
    WHERE ah.id_cliente = c.id_cliente
);

-- NOT EXISTS: Clientes que NO TIENEN afiliación
SELECT 
    c.rut,
    c.nombre,
    c.email
FROM cliente c
WHERE NOT EXISTS (
    SELECT 1
    FROM afiliacion_historica ah
    WHERE ah.id_cliente = c.id_cliente
);

-- ANY: Clientes con salario mayor al salario de ALGÚN cliente de AFP
SELECT 
    rut,
    nombre,
    salario_uf
FROM cliente
WHERE salario_uf > ANY (
    SELECT salario_uf
    FROM cliente
    WHERE id_tipo_prev = (
        SELECT id_tipo 
        FROM tipo_prevision 
        WHERE nombre = 'AFP'
    )
);

-- ALL: Clientes con salario mayor al SALARIO MÁS ALTO de AFP
SELECT 
    rut,
    nombre,
    salario_uf
FROM cliente
WHERE salario_uf > ALL (
    SELECT salario_uf
    FROM cliente
    WHERE id_tipo_prev = (
        SELECT id_tipo 
        FROM tipo_prevision 
        WHERE nombre = 'AFP'
    )
);

SELECT '✅ IN, EXISTS, ANY, ALL completados' AS mensaje;

-- ============================================
-- 5. SUBCONSULTAS EN SELECT (columna calculada)
-- ============================================

-- Para cada cliente, mostrar el promedio de su tipo de previsión
SELECT 
    c.rut,
    c.nombre,
    c.salario_uf,
    tp.nombre AS "Tipo",
    (
        SELECT AVG(c2.salario_uf)
        FROM cliente c2
        WHERE c2.id_tipo_prev = c.id_tipo_prev
    ) AS promedio_tipo,
    c.salario_uf - (
        SELECT AVG(c2.salario_uf)
        FROM cliente c2
        WHERE c2.id_tipo_prev = c.id_tipo_prev
    ) AS diferencia_vs_promedio
FROM cliente c
INNER JOIN tipo_prevision tp ON c.id_tipo_prev = tp.id_tipo
ORDER BY tp.nombre, c.salario_uf DESC;

-- Para cada comuna, mostrar cuántos clientes tiene
SELECT 
    cm.nombre AS comuna,
    r.nombre AS region,
    (
        SELECT COUNT(*)
        FROM cliente c
        WHERE c.id_comuna = cm.id_comuna
    ) AS total_clientes
FROM comuna cm
INNER JOIN region r ON cm.id_region = r.id_region
WHERE (
    SELECT COUNT(*)
    FROM cliente c
    WHERE c.id_comuna = cm.id_comuna
) > 0
ORDER BY total_clientes DESC;

SELECT '✅ Subconsultas en SELECT completadas' AS mensaje;

-- ============================================
-- 6. SUBCONSULTAS ANIDADAS MÚLTIPLES (3+ niveles)
-- ============================================

-- Cliente con MAYOR salario de la región con MÁS clientes
SELECT 
    c.rut,
    c.nombre,
    cm.nombre AS comuna,
    r.nombre AS region,
    c.salario_uf
FROM cliente c
INNER JOIN comuna cm ON c.id_comuna = cm.id_comuna
INNER JOIN region r ON cm.id_region = r.id_region
WHERE c.salario_uf = (
    SELECT MAX(c2.salario_uf)
    FROM cliente c2
    INNER JOIN comuna cm2 ON c2.id_comuna = cm2.id_comuna
    INNER JOIN region r2 ON cm2.id_region = r2.id_region
    WHERE r2.id_region = (
        SELECT r3.id_region
        FROM region r3
        INNER JOIN comuna cm3 ON r3.id_region = cm3.id_region
        INNER JOIN cliente c3 ON cm3.id_comuna = c3.id_comuna
        GROUP BY r3.id_region
        ORDER BY COUNT(*) DESC
        LIMIT 1
    )
);

-- Clientes que ganan más que el promedio de SU región y SU tipo
SELECT 
    c.rut,
    c.nombre,
    c.salario_uf,
    r.nombre AS region,
    tp.nombre AS tipo,
    (
        SELECT AVG(c2.salario_uf)
        FROM cliente c2
        INNER JOIN comuna cm2 ON c2.id_comuna = cm2.id_comuna
        WHERE cm2.id_region = cm.id_region
    ) AS promedio_region,
    (
        SELECT AVG(c2.salario_uf)
        FROM cliente c2
        WHERE c2.id_tipo_prev = c.id_tipo_prev
    ) AS promedio_tipo
FROM cliente c
INNER JOIN comuna cm ON c.id_comuna = cm.id_comuna
INNER JOIN region r ON cm.id_region = r.id_region
INNER JOIN tipo_prevision tp ON c.id_tipo_prev = tp.id_tipo
WHERE c.salario_uf > (
    SELECT AVG(c2.salario_uf)
    FROM cliente c2
    INNER JOIN comuna cm2 ON c2.id_comuna = cm2.id_comuna
    WHERE cm2.id_region = cm.id_region
)
AND c.salario_uf > (
    SELECT AVG(c2.salario_uf)
    FROM cliente c2
    WHERE c2.id_tipo_prev = c.id_tipo_prev
);

SELECT '✅ Subconsultas anidadas múltiples completadas' AS mensaje;

-- ============================================
-- 7. COMPARACIÓN: SUBCONSULTA vs JOIN (mismo resultado, diferente enfoque)
-- ============================================

-- Enfoque 1: CON SUBCONSULTA
SELECT 
    rut,
    nombre,
    salario_uf
FROM cliente
WHERE salario_uf > (
    SELECT AVG(salario_uf) 
    FROM cliente
);

-- Enfoque 2: CON JOIN (misma información)
SELECT 
    c.rut,
    c.nombre,
    c.salario_uf
FROM cliente c
CROSS JOIN (
    SELECT AVG(salario_uf) AS promedio
    FROM cliente
) AS promedio
WHERE c.salario_uf > promedio.promedio;

SELECT '✅ Comparación SUBCONSULTA vs JOIN completada' AS mensaje;

-- ============================================
-- 8. RESUMEN DE LO QUE APRENDISTE
-- ============================================

SELECT '=== RESUMEN APRENDIZAJE PARTE 5 ===' AS categoria;
SELECT 'Subconsulta en WHERE (filtrar por valor calculado)' AS tema;
SELECT 'Subconsulta en FROM (tabla derivada)' AS tema;
SELECT 'Subconsulta correlacionada (depende de consulta externa)' AS tema;
SELECT 'IN / NOT IN con subconsultas' AS tema;
SELECT 'EXISTS / NOT EXISTS (verificar existencia)' AS tema;
SELECT 'ANY / ALL (comparar con múltiples valores)' AS tema;
SELECT 'Subconsulta en SELECT (columna calculada)' AS tema;
SELECT 'Subconsultas anidadas múltiples niveles' AS tema;
SELECT 'Subconsulta vs JOIN (enfoques diferentes)' AS tema;
SELECT '=== FIN PARTE 5 ===' AS categoria;

-- Ejemplo práctico final: Reporte completo con subconsultas
SELECT 
    c.rut,
    CONCAT(c.nombre, ' ', c.apellido_paterno) AS "Nombre",
    tp.nombre AS "Previsión",
    c.salario_uf,
    (
        SELECT AVG(c2.salario_uf)
        FROM cliente c2
        WHERE c2.id_tipo_prev = c.id_tipo_prev
    ) AS promedio_tipo,
    CASE 
        WHEN c.salario_uf > (
            SELECT AVG(c2.salario_uf)
            FROM cliente c2
            WHERE c2.id_tipo_prev = c.id_tipo_prev
        ) THEN 'Sobre promedio'
        ELSE 'Bajo promedio'
    END AS comparacion,
    (
        SELECT COUNT(*)
        FROM afiliacion_historica ah
        WHERE ah.id_cliente = c.id_cliente
    ) AS numero_afiliaciones
FROM cliente c
INNER JOIN tipo_prevision tp ON c.id_tipo_prev = tp.id_tipo
WHERE c.salario_uf > (
    SELECT AVG(salario_uf)
    FROM cliente
)
ORDER BY c.salario_uf DESC;
