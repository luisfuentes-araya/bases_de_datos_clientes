--| #  | Concepto                | Qué hace                 | Ejemplo                                     | Para qué sirve                      |
--| -- | ----------------------- | ------------------------ | ------------------------------------------- | ----------------------------------- |
--| 71 | CREATE PROCEDURE        | Crea procedimiento       | CREATE PROCEDURE mostrar_clientes()         | Guardar queries reutilizables       |
--| 72 | DELIMITER $$            | Cambia delimitador       | DELIMITER $$ ... $$ DELIMITER ;             | Evitar conflictos con ; interno     |
--| 73 | BEGIN ... END           | Bloque de código         | BEGIN ... consultas ... END                 | Agrupar múltiples comandos          |
--| 74 | Parámetro IN            | Entrada al procedimiento | CREATE PROCEDURE test(IN id INT)            | Recibir valor desde fuera           |
--| 75 | Parámetro OUT           | Salida del procedimiento | CREATE PROCEDURE test(OUT total INT)        | Devolver valor al caller            |
--| 76 | Parámetro INOUT         | Entrada y salida         | CREATE PROCEDURE test(INOUT num INT)        | Recibe y modifica valor             |
--| 77 | DECLARE                 | Variable local           | DECLARE total INT DEFAULT 0;                | Variables dentro del procedimiento  |
--| 78 | SET                     | Asignar valor            | SET numero = 100;                           | Modificar variables                 |
--| 79 | IF/ELSEIF/ELSE          | Condicional              | IF salario > 30 THEN ... ELSE ... END IF    | Lógica condicional                  |
--| 80 | CASE en procedimiento   | Condicional múltiple     | CASE id WHEN 1 THEN ... END CASE            | Múltiples opciones                  |
--| 81 | WHILE                   | Bucle con condición      | WHILE i <= 10 DO ... SET i = i+1; END WHILE | Iterar mientras se cumple condición |
--| 82 | LOOP                    | Bucle básico             | LOOP ... END LOOP                           | Iteración (con LEAVE para salir)    |
--| 83 | CALL                    | Ejecutar procedimiento   | CALL procedimiento(parametro)               | Usar el procedimiento creado        |
--| 84 | INSERT en procedimiento | Insertar datos           | INSERT INTO cliente VALUES (...)            | CRUD desde procedimiento            |
--| 85 | UPDATE en procedimiento | Actualizar datos         | UPDATE cliente SET nombre = ...             | Modificar registros                 |
--| 86 | DELETE en procedimiento | Eliminar datos           | UPDATE cliente SET activo = FALSE           | Soft delete (desactivar)            |
--| 87 | Validación con IF       | Verificar existencia     | IF EXISTS THEN ERROR ELSE INSERT END IF     | Evitar duplicados antes de insertar |
--| 88 | SHOW CREATE PROCEDURE   | Ver código               | SHOW CREATE PROCEDURE nombre                | Revisar procedimiento               |
--| 89 | SHOW PROCEDURE STATUS   | Listar procedimientos    | SHOW PROCEDURE STATUS WHERE Db = 'bd'       | Ver todos los procedimientos        |
--| 90 | DROP PROCEDURE          | Borrar procedimiento     | DROP PROCEDURE IF EXISTS nombre             | Eliminar procedimiento obsoleto     |
-- ============================================
-- PARTE 6: PROCEDIMIENTOS ALMACENADOS
-- ============================================

USE clientes_previsional;

-- ============================================
-- 1. PROCEDIMIENTO BÁSICO (sin parámetros)
-- ============================================

-- Crear procedimiento que muestra todos los clientes
DELIMITER $$

CREATE PROCEDURE mostrar_todos_clientes()
BEGIN
    SELECT 
        id_cliente,
        rut,
        nombre,
        apellido_paterno,
        apellido_materno,
        email,
        telefono,
        activo
    FROM cliente
    ORDER BY apellido_paterno, nombre;
END$$

DELIMITER ;

-- Ejecutar procedimiento
CALL mostrar_todos_clientes();

SELECT '✅ Procedimiento básico creado y ejecutado' AS mensaje;

-- ============================================
-- 2. PROCEDIMIENTO CON PARÁMETROS DE ENTRADA (IN)
-- ============================================

-- Procedimiento que filtra clientes por tipo de previsión
DELIMITER $$

CREATE PROCEDURE clientes_por_tipo(IN id_tipo INT)
BEGIN
    SELECT 
        c.rut,
        CONCAT(c.nombre, ' ', c.apellido_paterno) AS nombre_completo,
        c.email,
        c.telefono,
        c.salario_uf,
        tp.nombre AS tipo_prevision
    FROM cliente c
    INNER JOIN tipo_prevision tp ON c.id_tipo_prev = tp.id_tipo
    WHERE c.id_tipo_prev = id_tipo
    ORDER BY c.salario_uf DESC;
END$$

DELIMITER ;

-- Ejecutar con parámetro (AFP = 1)
CALL clientes_por_tipo(1);

-- Ejecutar con parámetro (FONASA = 2)
CALL clientes_por_tipo(2);

-- Ejecutar con parámetro (ISAPRE = 3)
CALL clientes_por_tipo(3);

SELECT '✅ Procedimiento con parámetro IN creado' AS mensaje;

-- ============================================
-- 3. PROCEDIMIENTO CON PARÁMETROS DE SALIDA (OUT)
-- ============================================

-- Procedimiento que cuenta clientes y devuelve el total
DELIMITER $$

CREATE PROCEDURE contar_clientes(OUT total INT)
BEGIN
    SELECT COUNT(*) INTO total FROM cliente;
END$$

DELIMITER ;

-- Ejecutar y obtener el resultado
CALL contar_clientes(@total_clientes);
SELECT @total_clientes AS "Total Clientes";

-- Contar activos
DELIMITER $$

CREATE PROCEDURE contar_clientes_activos(OUT activos INT)
BEGIN
    SELECT COUNT(*) INTO activos FROM cliente WHERE activo = TRUE;
END$$

DELIMITER ;

CALL contar_clientes_activos(@activos);
SELECT @activos AS "Clientes Activos";

SELECT '✅ Procedimientos con parámetro OUT creados' AS mensaje;

-- ============================================
-- 4. PROCEDIMIENTO CON PARÁMETROS INOUT
-- ============================================

-- Procedimiento que recibe un valor y lo modifica
DELIMITER $$

CREATE PROCEDURE sumar_valor(INOUT numero DECIMAL(10,2), IN cantidad DECIMAL(10,2))
BEGIN
    SET numero = numero + cantidad;
END$$

DELIMITER ;

-- Usar el procedimiento
SET @mi_numero = 100.50;
CALL sumar_valor(@mi_numero, 25.75);
SELECT @mi_numero AS "Resultado después de sumar";

SELECT '✅ Procedimiento INOUT creado' AS mensaje;

-- ============================================
-- 5. PROCEDIMIENTO CON VARIABLES LOCALES
-- ============================================

-- Procedimiento con DECLARE de variables
DELIMITER $$

CREATE PROCEDURE resumen_clientes()
BEGIN
    DECLARE total_clientes INT;
    DECLARE total_activos INT;
    DECLARE total_inactivos INT;
    DECLARE promedio_salario DECIMAL(10,2);
    
    -- Asignar valores a las variables
    SELECT COUNT(*) INTO total_clientes FROM cliente;
    SELECT COUNT(*) INTO total_activos FROM cliente WHERE activo = TRUE;
    SELECT COUNT(*) INTO total_inactivos FROM cliente WHERE activo = FALSE;
    SELECT AVG(salario_uf) INTO promedio_salario FROM cliente;
    
    -- Mostrar resultado
    SELECT 
        total_clientes AS "Total Clientes",
        total_activos AS "Activos",
        total_inactivos AS "Inactivos",
        total_activos - total_inactivos AS Diferencia,
        ROUND(promedio_salario, 2) AS "Promedio Salario (UF)"
    FROM dual;
END$$

DELIMITER ;

CALL resumen_clientes();

SELECT '✅ Procedimiento con variables locales creado' AS mensaje;

-- ============================================
-- 6. PROCEDIMIENTO CON IF/ELSE (condicionales)
-- ============================================

-- Procedimiento que clasifica salario
DELIMITER $$

CREATE PROCEDURE clasificar_salario(IN salario DECIMAL(10,2))
BEGIN
    DECLARE clasificacion VARCHAR(50);
    
    IF salario < 30 THEN
        SET clasificacion = 'Bajo';
    ELSEIF salario BETWEEN 30 AND 45 THEN
        SET clasificacion = 'Medio';
    ELSEIF salario > 45 THEN
        SET clasificacion = 'Alto';
    ELSE
        SET clasificacion = 'Desconocido';
    END IF;
    
    SELECT 
        salario AS "Salario (UF)",
        clasificacion AS "Clasificación";
END$$

DELIMITER ;

-- Ejecutar con diferentes valores
CALL clasificar_salario(25.5);
CALL clasificar_salario(38.0);
CALL clasificar_salario(52.0);

SELECT '✅ Procedimiento con IF/ELSE creado' AS mensaje;

-- ============================================
-- 7. PROCEDIMIENTO CON CASE
-- ============================================

-- Procedimiento que clasifica cliente por tipo de previsión
DELIMITER $$

CREATE PROCEDURE tipo_prevision_nombre(IN id_tipo INT)
BEGIN
    DECLARE nombre_tipo VARCHAR(50);
    
    CASE id_tipo
        WHEN 1 THEN SET nombre_tipo = 'AFP';
        WHEN 2 THEN SET nombre_tipo = 'FONASA';
        WHEN 3 THEN SET nombre_tipo = 'ISAPRE';
        ELSE SET nombre_tipo = 'No asignado';
    END CASE;
    
    SELECT 
        id_tipo AS "ID Tipo",
        nombre_tipo AS "Nombre Tipo";
END$$

DELIMITER ;

CALL tipo_prevision_nombre(1);
CALL tipo_prevision_nombre(2);
CALL tipo_prevision_nombre(3);
CALL tipo_prevision_nombre(5);

SELECT '✅ Procedimiento con CASE creado' AS mensaje;

-- ============================================
-- 8. PROCEDIMIENTO CON LOOP (iteración)
-- ============================================

-- Procedimiento que inserta múltiples clientes de prueba
DELIMITER $$

CREATE PROCEDURE insertar_clientes_prueba(IN cantidad INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE rut_temp VARCHAR(12);
    DECLARE nombre_temp VARCHAR(100);
    
    WHILE i <= cantidad DO
        SET rut_temp = CONCAT(90000000 + i, '-', IF(i % 2 = 0, 'K', '0'));
        SET nombre_temp = CONCAT('Cliente Prueba ', i);
        
        INSERT INTO cliente (
            rut, 
            nombre, 
            apellido_paterno, 
            apellido_materno,
            fecha_nacimiento, 
            telefono, 
            email, 
            id_comuna, 
            id_tipo_prev,
            salario_uf,
            activo
        ) VALUES (
            rut_temp,
            nombre_temp,
            'Prueba',
            'Test',
            DATE_SUB(CURDATE(), INTERVAL 30 YEAR),
            CONCAT('+5699999', LPAD(i, 4, '0')),
            CONCAT('prueba', i, '@test.com'),
            1,
            2,
            30.0 + i,
            TRUE
        );
        
        SET i = i + 1;
    END WHILE;
    
    SELECT CONCAT('✅ ', cantidad, ' clientes de prueba insertados') AS mensaje;
END$$

DELIMITER ;

-- Ejecutar (inserta 5 clientes de prueba)
CALL insertar_clientes_prueba(5);

-- Verificar
SELECT rut, nombre, email FROM cliente WHERE nombre LIKE 'Cliente Prueba%';

SELECT '✅ Procedimiento con LOOP creado' AS mensaje;

-- ============================================
-- 9. PROCEDIMIENTO CON SELECT + WHERE DINÁMICO
-- ============================================

-- Procedimiento que busca clientes por múltiples filtros
DELIMITER $$

CREATE PROCEDURE buscar_clientes_filtrados(
    IN tipo_prevision_id INT,
    IN comuna_id INT,
    IN salario_min DECIMAL(10,2),
    IN salario_max DECIMAL(10,2),
    IN solo_activos BOOLEAN
)
BEGIN
    SELECT 
        c.rut,
        CONCAT(c.nombre, ' ', c.apellido_paterno) AS nombre_completo,
        tp.nombre AS tipo_prevision,
        cm.nombre AS comuna,
        c.salario_uf,
        c.email,
        c.telefono
    FROM cliente c
    INNER JOIN tipo_prevision tp ON c.id_tipo_prev = tp.id_tipo
    INNER JOIN comuna cm ON c.id_comuna = cm.id_comuna
    WHERE (tipo_prevision_id = 0 OR c.id_tipo_prev = tipo_prevision_id)
      AND (comuna_id = 0 OR c.id_comuna = comuna_id)
      AND c.salario_uf >= salario_min
      AND c.salario_uf <= salario_max
      AND (solo_activos = FALSE OR c.activo = TRUE)
    ORDER BY c.salario_uf DESC;
END$$

DELIMITER ;

-- Ejecutar con diferentes filtros
-- Todos los clientes (parámetros 0 = sin filtro)
CALL buscar_clientes_filtrados(0, 0, 0, 999, FALSE);

-- Solo AFP con salario entre 30 y 50 UF
CALL buscar_clientes_filtrados(1, 0, 30, 50, TRUE);

-- Solo Fonasa de comuna 1 (Santiago) con salario > 25 UF
CALL buscar_clientes_filtrados(2, 1, 25, 999, TRUE);

SELECT '✅ Procedimiento de búsqueda filtrada creado' AS mensaje;

-- ============================================
-- 10. PROCEDIMIENTO CON JOIN + GROUP BY + HAVING
-- ============================================

-- Procedimiento que genera reporte por región
DELIMITER $$

CREATE PROCEDURE reporte_por_region()
BEGIN
    SELECT 
        r.nombre AS region,
        COUNT(DISTINCT c.id_cliente) AS total_clientes,
        COUNT(DISTINCT c.id_tipo_prev) AS tipos_distintos,
        AVG(c.salario_uf) AS promedio_salario_uf,
        MIN(c.salario_uf) AS minimo_salario,
        MAX(c.salario_uf) AS maximo_salario,
        SUM(c.salario_uf) AS total_salarios_uf
    FROM cliente c
    INNER JOIN comuna cm ON c.id_comuna = cm.id_comuna
    INNER JOIN region r ON cm.id_region = r.id_region
    GROUP BY r.id_region, r.nombre
    HAVING total_clientes >= 1
    ORDER BY total_clientes DESC, r.nombre;
END$$

DELIMITER ;

CALL reporte_por_region();

SELECT '✅ Procedimiento de reporte por región creado' AS mensaje;

-- ============================================
-- 11. PROCEDIMIENTO CON OPERACIONES CRUD (Insertar, Actualizar, Eliminar)
-- ============================================

-- Procedimiento para insertar un cliente completo
DELIMITER $$

CREATE PROCEDURE insertar_cliente_completo(
    IN p_rut VARCHAR(12),
    IN p_nombre VARCHAR(100),
    IN p_apellido_paterno VARCHAR(100),
    IN p_apellido_materno VARCHAR(100),
    IN p_fecha_nacimiento DATE,
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_id_comuna INT,
    IN p_id_tipo_prev INT,
    IN p_salario_uf DECIMAL(10,2)
)
BEGIN
    DECLARE cliente_existe INT DEFAULT 0;
    
    -- Verificar si el RUT ya existe
    SELECT COUNT(*) INTO cliente_existe FROM cliente WHERE rut = p_rut;
    
    IF cliente_existe > 0 THEN
        SELECT '❌ ERROR: El RUT ya existe en la base de datos' AS mensaje;
    ELSE
        INSERT INTO cliente (
            rut, nombre, apellido_paterno, apellido_materno,
            fecha_nacimiento, telefono, email, id_comuna, 
            id_tipo_prev, salario_uf, activo
        ) VALUES (
            p_rut, p_nombre, p_apellido_paterno, p_apellido_materno,
            p_fecha_nacimiento, p_telefono, p_email, p_id_comuna,
            p_id_tipo_prev, p_salario_uf, TRUE
        );
        SELECT '✅ Cliente insertado correctamente' AS mensaje;
    END IF;
END$$

DELIMITER ;

-- Ejecutar
CALL insertar_cliente_completo(
    '99.999.999-9',
    'Nuevo',
    'Cliente',
    'Ejemplo',
    '1990-01-01',
    '+56911112222',
    'nuevo.cliente@email.com',
    1,
    2,
    35.0
);

-- Verificar
SELECT rut, nombre, apellido_paterno, email FROM cliente WHERE rut = '99.999.999-9';

SELECT '✅ Procedimiento INSERT con validación creado' AS mensaje;

-- ============================================
-- 12. PROCEDIMIENTO PARA ACTUALIZAR CLIENTE
-- ============================================

DELIMITER $$

CREATE PROCEDURE actualizar_cliente(
    IN p_id_cliente INT,
    IN p_nombre VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_salario_uf DECIMAL(10,2)
)
BEGIN
    DECLARE cliente_existe INT DEFAULT 0;
    
    -- Verificar si el cliente existe
    SELECT COUNT(*) INTO cliente_existe FROM cliente WHERE id_cliente = p_id_cliente;
    
    IF cliente_existe = 0 THEN
        SELECT '❌ ERROR: El cliente no existe' AS mensaje;
    ELSE
        UPDATE cliente
        SET 
            nombre = IFNULL(p_nombre, nombre),
            email = IFNULL(p_email, email),
            telefono = IFNULL(p_telefono, telefono),
            salario_uf = IFNULL(p_salario_uf, salario_uf)
        WHERE id_cliente = p_id_cliente;
        
        SELECT '✅ Cliente actualizado correctamente' AS mensaje;
    END IF;
END$$

DELIMITER ;

-- Ejecutar
CALL actualizar_cliente(1, 'Juan Carlos', 'juan.nuevo@email.com', '+56999998888', 28.0);

-- Verificar
SELECT rut, nombre, email, telefono, salario_uf FROM cliente WHERE id_cliente = 1;

SELECT '✅ Procedimiento UPDATE creado' AS mensaje;

-- ============================================
-- 13. PROCEDIMIENTO PARA ELIMINAR (LOGICAL DELETE)
-- ============================================

DELIMITER $$

CREATE PROCEDURE desactivar_cliente(IN p_id_cliente INT)
BEGIN
    DECLARE cliente_existe INT DEFAULT 0;
    
    SELECT COUNT(*) INTO cliente_existe FROM cliente WHERE id_cliente = p_id_cliente;
    
    IF cliente_existe = 0 THEN
        SELECT '❌ ERROR: El cliente no existe' AS mensaje;
    ELSE
        UPDATE cliente
        SET activo = FALSE
        WHERE id_cliente = p_id_cliente;
        
        SELECT '✅ Cliente desactivado (soft delete)' AS mensaje;
    END IF;
END$$

DELIMITER ;

-- Ejecutar
CALL desactivar_cliente(31);

-- Verificar
SELECT id_cliente, rut, nombre, activo FROM cliente WHERE id_cliente = 31;

SELECT '✅ Procedimiento DELETE (soft delete) creado' AS mensaje;

-- ============================================
-- 14. LISTAR Y BORRAR PROCEDIMIENTOS
-- ============================================

-- Ver todos los procedimientos
SHOW PROCEDURE STATUS WHERE Db = 'clientes_previsional';

-- Ver el código de un procedimiento
SHOW CREATE PROCEDURE mostrar_todos_clientes;

-- Borrar un procedimiento
DROP PROCEDURE IF EXISTS insertar_clientes_prueba;

SELECT '✅ Listado y borrado de procedimientos completado' AS mensaje;

-- ============================================
-- 15. RESUMEN DE LO QUE APRENDISTE
-- ============================================

SELECT '=== RESUMEN APRENDIZAJE PARTE 6 ===' AS categoria;
SELECT 'CREATE PROCEDURE (crear procedimiento)' AS tema;
SELECT 'DELIMITER (cambiar delimitador)' AS tema;
SELECT 'Parámetros IN (entrada)' AS tema;
SELECT 'Parámetros OUT (salida)' AS tema;
SELECT 'Parámetros INOUT (entrada y salida)' AS tema;
SELECT 'DECLARE variables locales' AS tema;
SELECT 'IF/ELSEIF/ELSE/END IF' AS tema;
SELECT 'CASE WHEN/THEN/END CASE' AS tema;
SELECT 'WHILE/LOOP/END WHILE (iteración)' AS tema;
SELECT 'SET (asignar valores)' AS tema;
SELECT 'CALL (ejecutar procedimiento)' AS tema;
SELECT 'INSERT/UPDATE/DELETE dentro de procedimientos' AS tema;
SELECT 'SHOW PROCEDURE STATUS (listar)' AS tema;
SELECT 'DROP PROCEDURE (borrar)' AS tema;
SELECT '✅ VALIDACIÓN con IF (verificar existencia)' AS tema;
SELECT '=== FIN PARTE 6 ===' AS categoria;

-- Ejemplo práctico final: Reporte completo de clientes
CALL reporte_por_region();
