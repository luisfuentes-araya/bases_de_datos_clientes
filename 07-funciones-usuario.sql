--| #   | Concepto                            | Qué hace                                                                      | Ejemplo                                         | Para qué sirve                      |
--| --- | ----------------------------------- | ----------------------------------------------------------------------------- | ----------------------------------------------- | ----------------------------------- |
--| 91  | CREATE FUNCTION                     | Crea función definida por usuario                                             | CREATE FUNCTION calcular_edad(...)              | Guardar lógica reutilizable         |
--| 92  | RETURNS tipo                        | Define tipo de valor devuelto                                                 | RETURNS INT                                     | La función siempre devuelve 1 valor |
--| 93  | DETERMINISTIC                       | Modificador de función                                                        | DETERMINISTIC                                   | Mismo input = mismo output siempre  |
--| 94  | Función sin parámetros              | Función que no recibe nada                                                    | CREATE FUNCTION obtener_fecha_actual()          | Devuelve fecha actual               |
--| 95  | Función con 1 parámetro             | Recibe un valor                                                               | CREATE FUNCTION calcular_edad(fecha DATE)       | Calcula edad desde fecha            |
--| 96  | Función con múltiples parámetros    | Recibe varios valores                                                         | CREATE FUNCTION calc_desc(salario UF, tipo INT) | Cálculos complejos                  |
--| 97  | IF/ELSE en función                  | Condicional dentro de función                                                 | IF salario > 30 THEN ... END IF                 | Clasificación en función            |
--| 98  | CASE en función                     | Condicional múltiple                                                          | CASE id WHEN 1 THEN ... END CASE                | Múltiples opciones en función       |
--| 99  | RETURN                              | Devolver valor desde función                                                  | RETURN calculo;                                 | Retorna el resultado final          |
--| 100 | Función en SELECT                   | Llamar función en consulta                                                    | SELECT calcular_edad(fecha)                     | Usar función como columna           |
--| 101 | Función en WHERE                    | Filtrar con función                                                           | WHERE clasificar_salario(salario) = 'Alto'      | Filtrar por clasificación           |
--| 102 | Función en GROUP BY                 | Agrupar por función                                                           | GROUP BY clasificar_salario(salario)            | Agrupar por nivel salarial          |
--| 103 | Función en ORDER BY                 | Ordenar por función                                                           | ORDER BY calcular_edad(fecha) DESC              | Ordenar por edad calculada          |
--| 104 | Función compuesta                   | Múltiples operaciones                                                         | generar_reporte_cliente(id)                     | Reporte completo en 1 función       |
--| 105 | SHOW FUNCTION STATUS                | Listar funciones                                                              | SHOW FUNCTION STATUS WHERE Db = 'bd'            | Ver todas las funciones             |
--| 106 | SHOW CREATE FUNCTION                | Ver código función                                                            | SHOW CREATE FUNCTION calcular_edad              | Revisar función creada              |
--| 107 | DROP FUNCTION                       | Borrar función                                                                | DROP FUNCTION IF EXISTS nombre                  | Eliminar función obsoleta           |
--| 108 | DIFERENCIA FUNCIÓN vs PROCEDIMIENTO | Función devuelve 1 valor en SELECT, procedimiento usa CALL y puede hacer CRUD | SELECT func() vs CALL proc()                    | Elegir según necesidad              |
-- ============================================
-- PARTE 7: FUNCIONES DEFINIDAS POR USUARIO (UDF)
-- ============================================

USE clientes_previsional;

-- ============================================
-- 1. DIFERENCIA: FUNCIÓN vs PROCEDIMIENTO
-- ============================================

-- FUNCIÓN:
-- - Siempre devuelve un valor (RETURNS)
-- - Se llama dentro de SELECT: SELECT mi_funcion(parametro)
-- - No puede hacer INSERT/UPDATE/DELETE (en modo STRICT)
-- - Se usa para cálculos y transformaciones

-- PROCEDIMIENTO:
-- - Puede devolver 0 o más valores (OUT parámetros)
-- - Se llama con CALL: CALL mi_procedimiento(parametro)
-- - Puede hacer INSERT/UPDATE/DELETE
-- - Se usa para operaciones CRUD y lógica compleja

SELECT '=== DIFERENCIA FUNCIÓN vs PROCEDIMIENTO ===' AS informacion;

-- ============================================
-- 2. FUNCIÓN BÁSICA (sin parámetros, devuelve valor simple)
-- ============================================

DELIMITER $$

CREATE FUNCTION obtener_fecha_actual()
RETURNS DATE
DETERMINISTIC
BEGIN
    RETURN CURDATE();
END$$

DELIMITER ;

-- Ejecutar función en SELECT
SELECT obtener_fecha_actual() AS "Fecha Actual";

SELECT '✅ Función básica creada' AS mensaje;

-- ============================================
-- 3. FUNCIÓN CON PARÁMETRO (calcula edad)
-- ============================================

DELIMITER $$

CREATE FUNCTION calcular_edad(fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE());
END$$

DELIMITER ;

-- Usar función en SELECT
SELECT 
    rut,
    nombre,
    apellido_paterno,
    fecha_nacimiento,
    calcular_edad(fecha_nacimiento) AS edad
FROM cliente
ORDER BY edad DESC
LIMIT 15;

SELECT '✅ Función con parámetro creada (calcular edad)' AS mensaje;

-- ============================================
-- 4. FUNCIÓN QUE RECIBE ID Y DEVUELVE NOMBRE
-- ============================================

DELIMITER $$

CREATE FUNCTION obtener_nombre_tipo_prevision(id_tipo INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE nombre_tipo VARCHAR(50);
    
    SELECT nombre INTO nombre_tipo
    FROM tipo_prevision
    WHERE id_tipo = id_tipo;
    
    RETURN IFNULL(nombre_tipo, 'No asignado');
END$$

DELIMITER ;

-- Usar función
SELECT 
    rut,
    nombre,
    id_tipo_prev,
    obtener_nombre_tipo_prevision(id_tipo_prev) AS "Tipo de Previsión"
FROM cliente
LIMIT 20;

SELECT '✅ Función que recibe ID y devuelve nombre creada' AS mensaje;

-- ============================================
-- 5. FUNCIÓN CON CONDICIONAL (IF/ELSE)
-- ============================================

DELIMITER $$

CREATE FUNCTION clasificar_salario(salario_uf DECIMAL(10,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE clasificacion VARCHAR(20);
    
    IF salario_uf < 30 THEN
        SET clasificacion = 'Bajo';
    ELSEIF salario_uf BETWEEN 30 AND 45 THEN
        SET clasificacion = 'Medio';
    ELSEIF salario_uf > 45 THEN
        SET clasificacion = 'Alto';
    ELSE
        SET clasificacion = 'Desconocido';
    END IF;
    
    RETURN clasificacion;
END$$

DELIMITER ;

-- Usar función con CASE
SELECT 
    rut,
    nombre,
    salario_uf,
    clasificar_salario(salario_uf) AS "Nivel Salarial"
FROM cliente
ORDER BY salario_uf DESC
LIMIT 20;

SELECT '✅ Función con IF/ELSE creada (clasificar salario)' AS mensaje;

-- ============================================
-- 6. FUNCIÓN CON CASE (alternativa a IF)
-- ============================================

DELIMITER $$

CREATE FUNCTION obtener_nivel_cliente(salario_uf DECIMAL(10,2), numero_afiliaciones INT)
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    DECLARE nivel VARCHAR(30);
    
    CASE 
        WHEN salario_uf > 50 AND numero_afiliaciones >= 3 THEN SET nivel = 'Premium';
        WHEN salario_uf > 40 AND numero_afiliaciones >= 2 THEN SET nivel = 'Gold';
        WHEN salario_uf > 30 AND numero_afiliaciones >= 1 THEN SET nivel = 'Standard';
        ELSE SET nivel = 'Bronze';
    END CASE;
    
    RETURN nivel;
END$$

DELIMITER ;

-- Usar función con subconsulta para obtener número de afiliaciones
SELECT 
    c.rut,
    c.nombre,
    c.salario_uf,
    (SELECT COUNT(*) FROM afiliacion_historica ah WHERE ah.id_cliente = c.id_cliente) AS afiliaciones,
    obtener_nivel_cliente(c.salario_uf, 
        (SELECT COUNT(*) FROM afiliacion_historica ah WHERE ah.id_cliente = c.id_cliente)
    ) AS "Nivel Cliente"
FROM cliente c
ORDER BY c.salario_uf DESC
LIMIT 20;

SELECT '✅ Función con CASE creada (nivel cliente)' AS mensaje;

-- ============================================
-- 7. FUNÇÃO QUE FORMATEA TEXTO
-- ============================================

DELIMITER $$

CREATE FUNCTION formatear_nombre_completo(
    nombre VARCHAR(100),
    apellido_paterno VARCHAR(100),
    apellido_materno VARCHAR(100)
)
RETURNS VARCHAR(250)
DETERMINISTIC
BEGIN
    DECLARE nombre_completo VARCHAR(250);
    
    SET nombre_completo = CONCAT(
        nombre,
        ' ',
        apellido_paterno,
        IF(apellido_materno IS NOT NULL, ' ', ''),
        IF(apellido_materno IS NOT NULL, apellido_materno, '')
    );
    
    RETURN nombre_completo;
END$$

DELIMITER ;

-- Usar función
SELECT 
    rut,
    formatear_nombre_completo(nombre, apellido_paterno, apellido_materno) AS "Nombre Completo Formateado"
FROM cliente
LIMIT 15;

SELECT '✅ Función de formateo de texto creada' AS mensaje;

-- ============================================
-- 8. FUNCIÓN QUE VALIDA RUT (simple)
-- ============================================

DELIMITER $$

CREATE FUNCTION validar_rut(rut VARCHAR(12))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE rut_valido BOOLEAN;
    
    -- Validación simple: RUT debe tener formato XXXXXXXX-X
    IF rut LIKE '_______-%' AND LENGTH(rut) = 9 THEN
        SET rut_valido = TRUE;
    ELSE
        SET rut_valido = FALSE;
    END IF;
    
    RETURN rut_valido;
END$$

DELIMITER ;

-- Usar función de validación
SELECT 
    rut,
    nombre,
    validar_rut(rut) AS "RUT Validado"
FROM cliente
WHERE validar_rut(rut) = FALSE
LIMIT 10;

-- Clientes con RUT válido
SELECT 
    rut,
    nombre,
    validar_rut(rut) AS "RUT Validado"
FROM cliente
WHERE validar_rut(rut) = TRUE
LIMIT 10;

SELECT '✅ Función de validación de RUT creada' AS mensaje;

-- ============================================
-- 9. FUNCIÓN QUE CALCULA DESCUENTO
-- ============================================

DELIMITER $$

CREATE FUNCTION calcular_descuento_salario(
    salario_uf DECIMAL(10,2),
    id_tipo INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE tasa DECIMAL(5,2);
    DECLARE descuento DECIMAL(10,2);
    
    -- Obtener tasa según tipo de previsión
    CASE id_tipo
        WHEN 1 THEN SET tasa = 10.00;  -- AFP
        WHEN 2 THEN SET tasa = 7.00;   -- FONASA
        WHEN 3 THEN SET tasa = 7.00;   -- ISAPRE
        ELSE SET tasa = 0.00;
    END CASE;
    
    -- Calcular descuento
    SET descuento = salario_uf * (tasa / 100);
    
    RETURN ROUND(descuento, 2);
END$$

DELIMITER ;

-- Usar función
SELECT 
    rut,
    nombre,
    salario_uf,
    id_tipo_prev,
    obtener_nombre_tipo_prevision(id_tipo_prev) AS "Tipo",
    calcular_descuento_salario(salario_uf, id_tipo_prev) AS "Descuento (UF)",
    salario_uf - calcular_descuento_salario(salario_uf, id_tipo_prev) AS "Salario Neto (UF)"
FROM cliente
ORDER BY salario_uf DESC
LIMIT 20;

SELECT '✅ Función de cálculo de descuento creada' AS mensaje;

-- ============================================
-- 10. FUNCIÓN QUE CUENTA AFILIACIONES
-- ============================================

DELIMITER $$

CREATE FUNCTION contar_afiliaciones_cliente(id_cliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_afiliaciones INT;
    
    SELECT COUNT(*) INTO total_afiliaciones
    FROM afiliacion_historica
    WHERE id_cliente = id_cliente;
    
    RETURN total_afiliaciones;
END$$

DELIMITER ;

-- Usar función
SELECT 
    c.rut,
    c.nombre,
    c.apellido_paterno,
    contar_afiliaciones_cliente(c.id_cliente) AS "Nº Afiliaciones"
FROM cliente c
ORDER BY contar_afiliaciones_cliente(c.id_cliente) DESC
LIMIT 20;

SELECT '✅ Función que cuenta afiliaciones creada' AS mensaje;

-- ============================================
-- 11. FUNCIÓN QUE OBTENE REGIÓN POR CLIENTE
-- ============================================

DELIMITER $$

CREATE FUNCTION obtener_region_cliente(id_cliente INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE nombre_region VARCHAR(100);
    
    SELECT r.nombre INTO nombre_region
    FROM cliente c
    INNER JOIN comuna cm ON c.id_comuna = cm.id_comuna
    INNER JOIN region r ON cm.id_region = r.id_region
    WHERE c.id_cliente = id_cliente;
    
    RETURN IFNULL(nombre_region, 'No asignado');
END$$

DELIMITER ;

-- Usar función
SELECT 
    rut,
    nombre,
    apellido_paterno,
    obtener_region_cliente(id_cliente) AS "Región"
FROM cliente
LIMIT 20;

SELECT '✅ Función que obtiene región creada' AS mensaje;

-- ============================================
-- 12. FUNCIÓN COMPUESTA (varias operaciones)
-- ============================================

DELIMITER $$

CREATE FUNCTION generar_reporte_cliente(id_cliente INT)
RETURNS VARCHAR(500)
DETERMINISTIC
BEGIN
    DECLARE reporte VARCHAR(500);
    DECLARE nombre_completo VARCHAR(250);
    DECLARE edad INT;
    DECLARE tipo_prevision VARCHAR(50);
    DECLARE region VARCHAR(100);
    DECLARE afiliaciones INT;
    DECLARE nivel VARCHAR(30);
    DECLARE salario_uf DECIMAL(10,2);
    DECLARE descuento DECIMAL(10,2);
    
    -- Obtener todos los datos
    SELECT 
        CONCAT(nombre, ' ', apellido_paterno, ' ', IF(apellido_materno IS NOT NULL, apellido_materno, ''))
    INTO nombre_completo
    FROM cliente WHERE id_cliente = id_cliente;
    
    SELECT TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) INTO edad
    FROM cliente WHERE id_cliente = id_cliente;
    
    SELECT salario_uf INTO salario_uf
    FROM cliente WHERE id_cliente = id_cliente;
    
    SELECT nombre INTO tipo_prevision
    FROM cliente c
    INNER JOIN tipo_prevision tp ON c.id_tipo_prev = tp.id_tipo
    WHERE c.id_cliente = id_cliente;
    
    SELECT r.nombre INTO region
    FROM cliente c
    INNER JOIN comuna cm ON c.id_comuna = cm.id_comuna
    INNER JOIN region r ON cm.id_region = r.id_region
    WHERE c.id_cliente = id_cliente;
    
    SELECT COUNT(*) INTO afiliaciones
    FROM afiliacion_historica WHERE id_cliente = id_cliente;
    
    -- Calcular nivel
    SET nivel = obtener_nivel_cliente(salario_uf, afiliaciones);
    
    -- Calcular descuento
    SET descuento = calcular_descuento_salario(salario_uf, 
        (SELECT id_tipo_prev FROM cliente WHERE id_cliente = id_cliente)
    );
    
    -- Generar reporte
    SET reporte = CONCAT(
        'CLIENTE: ', nombre_completo, ' | ',
        'EDAD: ', edad, ' años | ',
        'TIPO: ', tipo_prevision, ' | ',
        'REGIÓN: ', region, ' | ',
        'AFILIACIONES: ', afiliaciones, ' | ',
        'SALARIO: ', salario_uf, ' UF | ',
        'DESCUENTO: ', descuento, ' UF | ',
        'NIVEL: ', nivel
    );
    
    RETURN reporte;
END$$

DELIMITER ;

-- Usar función compuesta
SELECT 
    id_cliente,
    rut,
    generar_reporte_cliente(id_cliente) AS "Reporte Completo"
FROM cliente
LIMIT 10;

SELECT '✅ Función compuesta creada (generar reporte)' AS mensaje;

-- ============================================
-- 13. LISTAR Y BORRAR FUNCIONES
-- ============================================

-- Ver todas las funciones
SHOW FUNCTION STATUS WHERE Db = 'clientes_previsional';

-- Ver el código de una función
SHOW CREATE FUNCTION calcular_edad;

-- Borrar una función
DROP FUNCTION IF EXISTS validar_rut;

SELECT '✅ Listado y borrado de funciones completado' AS mensaje;

-- ============================================
-- 14. USO DE FUNCIONES EN CONSULTAS COMPLEJAS
-- ============================================

-- Función en WHERE
SELECT 
    rut,
    nombre,
    salario_uf
FROM cliente
WHERE clasificar_salario(salario_uf) = 'Alto'
ORDER BY salario_uf DESC;

-- Función en GROUP BY
SELECT 
    clasificar_salario(salario_uf) AS nivel,
    COUNT(*) AS total_clientes,
    AVG(salario_uf) AS promedio_salario
FROM cliente
GROUP BY clasificar_salario(salario_uf)
ORDER BY total_clientes DESC;

-- Función en ORDER BY
SELECT 
    rut,
    nombre,
    salario_uf,
    clasificar_salario(salario_uf) AS nivel
FROM cliente
ORDER BY clasificar_salario(salario_uf), salario_uf DESC;

-- Función JOIN con otra tabla (usando función)
SELECT 
    c.rut,
    c.nombre,
    tp.nombre AS tipo,
    calcular_descuento_salario(c.salario_uf, c.id_tipo_prev) AS descuento
FROM cliente c
INNER JOIN tipo_prevision tp ON c.id_tipo_prev = tp.id_tipo
WHERE calcular_descuento_salario(c.salario_uf, c.id_tipo_prev) > 2.5
ORDER BY descuento DESC;

SELECT '✅ Uso de funciones en consultas complejas completado' AS mensaje;

-- ============================================
-- 15. RESUMEN DE LO QUE APRENDISTE
-- ============================================

SELECT '=== RESUMEN APRENDIZAJE PARTE 7 ===' AS categoria;
SELECT 'CREATE FUNCTION (crear función)' AS tema;
SELECT 'RETURNS tipo (valor que devuelve)' AS tema;
SELECT 'DETERMINISTIC (modificador de función)' AS tema;
SELECT 'Parámetros de entrada' AS tema;
SELECT 'Crear función sin parámetros' AS tema;
SELECT 'Crear función con 1 parámetro' AS tema;
SELECT 'Crear función con múltiples parámetros' AS tema;
SELECT 'IF/ELSE en función' AS tema;
SELECT 'CASE en función' AS tema;
SELECT 'DECLARE variables locales' AS tema;
SELECT 'SET asignar valores' AS tema;
SELECT 'RETURN devolver valor' AS tema;
SELECT 'Usar función en SELECT' AS tema;
SELECT 'Usar función en WHERE' AS tema;
SELECT 'Usar función en GROUP BY' AS tema;
SELECT 'Usar función en ORDER BY' AS tema;
SELECT 'Funciones compuestas (varias operaciones)' AS tema;
SELECT 'SHOW FUNCTION STATUS (listar)' AS tema;
SELECT 'DROP FUNCTION (borrar)' AS tema;
SELECT 'DIFERENCIA FUNCIÓN vs PROCEDIMIENTO' AS tema;
SELECT '=== FIN PARTE 7 ===' AS categoria;

-- Ejemplo práctico final: Reporte completo usando funciones
SELECT 
    rut,
    formatear_nombre_completo(nombre, apellido_paterno, apellido_materno) AS "Nombre Completo",
    calcular_edad(fecha_nacimiento) AS "Edad",
    obtener_nombre_tipo_prevision(id_tipo_prev) AS "Tipo Previsión",
    obtener_region_cliente(id_cliente) AS "Región",
    contar_afiliaciones_cliente(id_cliente) AS "Afiliaciones",
    salario_uf AS "Salario (UF)",
    calcular_descuento_salario(salario_uf, id_tipo_prev) AS "Descuento (UF)",
    salario_uf - calcular_descuento_salario(salario_uf, id_tipo_prev) AS "Salario Neto (UF)",
    obtener_nivel_cliente(salario_uf, contar_afiliaciones_cliente(id_cliente)) AS "Nivel Cliente",
    generar_reporte_cliente(id_cliente) AS "Reporte Completo"
FROM cliente
WHERE clasificar_salario(salario_uf) IN ('Alto', 'Medio')
ORDER BY salario_uf DESC
LIMIT 15;
