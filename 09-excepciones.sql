--| #  | Concepto                  | Qué hace                                   | Ejemplo                                                      | Para qué sirve                                      |
--| -- | ------------------------- | ------------------------------------------ | ------------------------------------------------------------ | --------------------------------------------------- |
--| 1  | DECLARE HANDLER           | Define cómo reaccionar ante un error       | DECLARE CONTINUE HANDLER FOR SQLEXCEPTION ...               | Manejar errores dentro de procedimientos            |
--| 2  | SQLEXCEPTION              | Captura cualquier error SQL                | DECLARE EXIT HANDLER FOR SQLEXCEPTION                       | Detener ejecución ante error                        |
--| 3  | SQLWARNING                | Captura advertencias                       | DECLARE CONTINUE HANDLER FOR SQLWARNING                     | Manejar warnings sin detener todo                   |
--| 4  | NOT FOUND                 | Captura cuando no hay filas                | DECLARE CONTINUE HANDLER FOR NOT FOUND                      | Evitar errores en cursores o consultas vacías       |
--| 5  | SIGNAL SQLSTATE           | Lanza un error personalizado               | SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error'          | Crear mensajes propios de validación                |
--| 6  | SQLSTATE '45000'          | Código genérico de error personalizado     | SIGNAL SQLSTATE '45000'                                   | Indicar error definido por el usuario               |
--| 7  | RESIGNAL                  | Re-lanza el error original                 | RESIGNAL;                                                    | Propagar un error capturado                         |
--| 8  | EXIT HANDLER              | Sale del bloque al ocurrir error           | DECLARE EXIT HANDLER FOR SQLEXCEPTION                       | Cortar ejecución si algo falla                      |
--| 9  | CONTINUE HANDLER          | Continúa después del error                 | DECLARE CONTINUE HANDLER FOR NOT FOUND                      | Seguir ejecutando tras error menor                  |
--| 10 | START TRANSACTION         | Inicia transacción                          | START TRANSACTION;                                           | Agrupar operaciones como una sola unidad            |
--| 11 | COMMIT                   | Confirma cambios                            | COMMIT;                                                      | Guardar todo si salió bien                          |
--| 12 | ROLLBACK                 | Deshace cambios                             | ROLLBACK;                                                    | Volver atrás si algo falla                          |
--| 13 | SAVEPOINT                | Punto intermedio dentro de transacción      | SAVEPOINT sp1;                                               | Volver solo hasta cierto punto                      |
--| 14 | ROLLBACK TO SAVEPOINT    | Revierte hasta un punto específico          | ROLLBACK TO SAVEPOINT sp1;                                  | Deshacer parte de la transacción                    |
--| 15 | RELEASE SAVEPOINT        | Elimina un savepoint                        | RELEASE SAVEPOINT sp1;                                       | Limpiar puntos de control                           |
--| 16 | DUPLICATE KEY             | Error por clave repetida                    | INSERT ... UNIQUE = valor repetido                            | Evitar duplicados en RUT o email                    |
--| 17 | FOREIGN KEY ERROR         | Error por relación inválida                | FK a comuna inexistente                                      | Mantener integridad referencial                     |
--| 18 | NOT NULL ERROR            | Error por campo obligatorio vacío          | Insertar nombre = NULL                                        | Evitar datos incompletos                             |
--| 19 | CHECK ERROR               | Error por regla de negocio                 | edad < 18                                                    | Validar condiciones del negocio                     |
--| 20 | PERSONALIZADA: RUT DUPLICADO | Mensaje propio para RUT repetido         | SIGNAL ... 'El RUT ya existe'                                | Validación más clara para el usuario                |
--| 21 | PERSONALIZADA: EMAIL INVÁLIDO | Mensaje propio para email mal escrito   | SIGNAL ... 'Formato de email incorrecto'                     | Evitar datos mal ingresados                          |
--| 22 | PERSONALIZADA: SALARIO NEGATIVO | Mensaje propio para salario inválido | SIGNAL ... 'El salario no puede ser negativo'               | Controlar reglas del sistema                        |
--| 23 | PERSONALIZADA: MENOR DE EDAD | Mensaje propio para edad mínima         | SIGNAL ... 'Debe ser mayor de 18 años'                      | Cumplir reglas de negocio                           |
--| 24 | PERSONALIZADA: COMUNA NO EXISTE | Mensaje propio para FK inválida     | SIGNAL ... 'La comuna no existe'                             | Mejorar experiencia de error                         |



-- ============================================
-- PARTE 9: EXCEPCIONES + TRANSACCIONES
-- ============================================

USE clientes_previsional;

-- ============================================
-- QUÉ ES UNA EXCEPCIÓN
-- ============================================

SELECT '=== PARTE 9: EXCEPCIONES + TRANSACCIONES ===' AS categoria;
SELECT 'Una excepción es un error controlado que interrumpe o modifica el flujo normal de ejecución.' AS descripcion;

-- ============================================
-- CONCEPTOS MÁS COMUNES
-- ============================================

SELECT 'DECLARE HANDLER' AS concepto, 'Define cómo reaccionar ante un error' AS que_hace, 'Manejar errores en procedimientos' AS para_que_sirve;
SELECT 'SQLEXCEPTION' AS concepto, 'Captura cualquier error SQL' AS que_hace, 'Detener ejecución ante error' AS para_que_sirve;
SELECT 'SQLWARNING' AS concepto, 'Captura advertencias' AS que_hace, 'Manejar warnings' AS para_que_sirve;
SELECT 'NOT FOUND' AS concepto, 'Captura cuando no hay filas' AS que_hace, 'Evitar fallos en SELECT INTO y cursores' AS para_que_sirve;
SELECT 'SIGNAL SQLSTATE' AS concepto, 'Lanza un error personalizado' AS que_hace, 'Mostrar mensajes propios' AS para_que_sirve;
SELECT 'SQLSTATE 45000' AS concepto, 'Código de error personalizado' AS que_hace, 'Indicar error definido por el usuario' AS para_que_sirve;
SELECT 'RESIGNAL' AS concepto, 'Re-lanza el error original' AS que_hace, 'Propagar el error' AS para_que_sirve;
SELECT 'START TRANSACTION' AS concepto, 'Inicia una transacción' AS que_hace, 'Agrupar operaciones' AS para_que_sirve;
SELECT 'COMMIT' AS concepto, 'Confirma cambios' AS que_hace, 'Guardar todo si salió bien' AS para_que_sirve;
SELECT 'ROLLBACK' AS concepto, 'Deshace cambios' AS que_hace, 'Volver atrás si algo falla' AS para_que_sirve;
SELECT 'SAVEPOINT' AS concepto, 'Marca un punto intermedio' AS que_hace, 'Deshacer solo una parte' AS para_que_sirve;

-- ============================================
-- ERROR PERSONALIZADO: RUT DUPLICADO
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_insertar_cliente_seguro(
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
    DECLARE v_rut_existe INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_rut_existe
    FROM cliente
    WHERE rut = p_rut;

    IF v_rut_existe > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '❌ ERROR: El RUT ya existe en la base de datos';
    END IF;

    INSERT INTO cliente (
        rut, nombre, apellido_paterno, apellido_materno,
        fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
    ) VALUES (
        p_rut, p_nombre, p_apellido_paterno, p_apellido_materno,
        p_fecha_nacimiento, p_telefono, p_email, p_id_comuna, p_id_tipo_prev, p_salario_uf
    );
END$$

DELIMITER ;

-- ============================================
-- ERROR PERSONALIZADO: EMAIL INVÁLIDO
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_validar_email(
    IN p_email VARCHAR(100)
)
BEGIN
    IF p_email IS NULL OR p_email NOT LIKE '%@%.%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '❌ ERROR: El email no tiene un formato válido';
    END IF;
END$$

DELIMITER ;

-- ============================================
-- ERROR PERSONALIZADO: SALARIO NEGATIVO
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_validar_salario(
    IN p_salario_uf DECIMAL(10,2)
)
BEGIN
    IF p_salario_uf < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '❌ ERROR: El salario no puede ser negativo';
    END IF;
END$$

DELIMITER ;

-- ============================================
-- ERROR PERSONALIZADO: MENOR DE EDAD
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_validar_edad(
    IN p_fecha_nacimiento DATE
)
BEGIN
    DECLARE v_edad INT;

    SET v_edad = TIMESTAMPDIFF(YEAR, p_fecha_nacimiento, CURDATE());

    IF v_edad < 18 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '❌ ERROR: El cliente debe ser mayor de 18 años';
    END IF;
END$$

DELIMITER ;

-- ============================================
-- ERROR PERSONALIZADO: COMUNA NO EXISTE
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_validar_comuna(
    IN p_id_comuna INT
)
BEGIN
    DECLARE v_comuna_existe INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_comuna_existe
    FROM comuna
    WHERE id_comuna = p_id_comuna;

    IF v_comuna_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '❌ ERROR: La comuna no existe';
    END IF;
END$$

DELIMITER ;

-- ============================================
-- HANDLER PARA SQLEXCEPTION
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_insertar_cliente_con_handler(
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
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT '❌ ERROR: Se produjo un error y la transacción fue revertida' AS mensaje;
    END;

    START TRANSACTION;

    INSERT INTO cliente (
        rut, nombre, apellido_paterno, apellido_materno,
        fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
    ) VALUES (
        p_rut, p_nombre, p_apellido_paterno, p_apellido_materno,
        p_fecha_nacimiento, p_telefono, p_email, p_id_comuna, p_id_tipo_prev, p_salario_uf
    );

    COMMIT;
    SELECT '✅ Cliente insertado correctamente' AS mensaje;
END$$

DELIMITER ;

-- ============================================
-- HANDLER PARA NOT FOUND
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_buscar_cliente_por_rut(
    IN p_rut VARCHAR(12)
)
BEGIN
    DECLARE v_id_cliente INT;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_apellido VARCHAR(100);
    DECLARE v_email VARCHAR(100);
    DECLARE v_no_encontrado INT DEFAULT 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
    BEGIN
        SET v_no_encontrado = 1;
    END;

    SELECT id_cliente, nombre, apellido_paterno, email
    INTO v_id_cliente, v_nombre, v_apellido, v_email
    FROM cliente
    WHERE rut = p_rut
    LIMIT 1;

    IF v_no_encontrado = 1 THEN
        SELECT '⚠️ No se encontró un cliente con ese RUT' AS mensaje;
    ELSE
        SELECT v_id_cliente AS id_cliente, v_nombre AS nombre, v_apellido AS apellido_paterno, v_email AS email;
    END IF;
END$$

DELIMITER ;

-- ============================================
-- EJEMPLO CON RESIGNAL
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_resignal_ejemplo()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Se capturó un error y se volverá a lanzar' AS mensaje;
        RESIGNAL;
    END;

    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '❌ ERROR de prueba para RESIGNAL';
END$$

DELIMITER ;

-- ============================================
-- TRANSACCIÓN: INSERTAR CLIENTE Y AFILIACIÓN
-- ============================================

START TRANSACTION;

INSERT INTO cliente (
    rut, nombre, apellido_paterno, apellido_materno,
    fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
) VALUES (
    '77.777.777-7', 'Pedro', 'Transaccion', 'Test',
    '1990-01-01', '+56977777777', 'pedro.transaccion@email.com',
    1, 1, 40.0
);

INSERT INTO afiliacion_historica (
    id_cliente, nombre_afiliadora, fecha_afiliacion, tipo_afiliacion, folio_contrato
) VALUES (
    LAST_INSERT_ID(), 'AFP Modelo', '2026-06-03', 'AFP', 'AFP-999-2026'
);

COMMIT;

-- ============================================
-- TRANSACCIÓN CON ROLLBACK
-- ============================================

START TRANSACTION;

INSERT INTO cliente (
    rut, nombre, apellido_paterno, apellido_materno,
    fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
) VALUES (
    '66.666.666-6', 'Error', 'Prueba', 'Sistema',
    '2010-01-01', '+56966666666', 'error.email@email.com',
    1, 1, 20.0
);

ROLLBACK;

-- ============================================
-- SAVEPOINT
-- ============================================

START TRANSACTION;

INSERT INTO cliente (
    rut, nombre, apellido_paterno, apellido_materno,
    fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
) VALUES (
    '55.555.555-5', 'Laura', 'Punto', 'Control',
    '1988-05-10', '+56955555555', 'laura.punto@email.com',
    2, 2, 33.0
);

SAVEPOINT sp_cliente;

INSERT INTO afiliacion_historica (
    id_cliente, nombre_afiliadora, fecha_afiliacion, tipo_afiliacion, folio_contrato
) VALUES (
    LAST_INSERT_ID(), 'FONASA', '2026-06-03', 'FONASA', 'FON-555-2026'
);

ROLLBACK TO SAVEPOINT sp_cliente;

COMMIT;

-- ============================================
-- DUPLICATE KEY ERROR
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_insertar_cliente_duplicado()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT '❌ ERROR: Clave duplicada o error en la inserción' AS mensaje;
    END;

    START TRANSACTION;

    INSERT INTO cliente (
        rut, nombre, apellido_paterno, apellido_materno,
        fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
    ) VALUES (
        '12.345.678-9', 'Duplicado', 'Prueba', 'Test',
        '1991-01-01', '+56912340000', 'duplicado@email.com',
        1, 1, 25.0
    );

    COMMIT;
END$$

DELIMITER ;

-- ============================================
-- FOREIGN KEY ERROR
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_insertar_con_fk_invalida()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT '❌ ERROR: Clave foránea inválida o error relacionado' AS mensaje;
    END;

    START TRANSACTION;

    INSERT INTO cliente (
        rut, nombre, apellido_paterno, apellido_materno,
        fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
    ) VALUES (
        '88.888.888-8', 'FK', 'Invalida', 'Test',
        '1992-01-01', '+56988888888', 'fk.invalida@email.com',
        999, 1, 30.0
    );

    COMMIT;
END$$

DELIMITER ;

-- ============================================
-- NOT NULL ERROR
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_insertar_nombre_nulo()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT '❌ ERROR: Campo obligatorio vacío o nulo' AS mensaje;
    END;

    START TRANSACTION;

    INSERT INTO cliente (
        rut, nombre, apellido_paterno, apellido_materno,
        fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
    ) VALUES (
        '99.999.999-9', NULL, 'Nulo', 'Test',
        '1993-01-01', '+56999999999', 'nulo@email.com',
        1, 1, 15.0
    );

    COMMIT;
END$$

DELIMITER ;

-- ============================================
-- CHECK ERROR
-- ============================================

DELIMITER $$

CREATE PROCEDURE sp_insertar_menor_edad()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT '❌ ERROR: Regla de negocio inválida (CHECK o validación)' AS mensaje;
    END;

    START TRANSACTION;

    INSERT INTO cliente (
        rut, nombre, apellido_paterno, apellido_materno,
        fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
    ) VALUES (
        '11.111.111-1', 'Menor', 'Edad', 'Test',
        '2010-01-01', '+56911111111', 'menor.edad@email.com',
        1, 1, 10.0
    );

    COMMIT;
END$$

DELIMITER ;

-- ============================================
-- EJEMPLOS DE LLAMADA
-- ============================================

CALL sp_validar_email('correo@valido.com');
CALL sp_validar_salario(25.5);
CALL sp_validar_edad('1990-01-01');
CALL sp_validar_comuna(1);
CALL sp_buscar_cliente_por_rut('12.345.678-9');
CALL sp_buscar_cliente_por_rut('00.000.000-0');

-- ============================================
-- RESUMEN FINAL
-- ============================================

SELECT '=== FIN PARTE 9 ===' AS categoria;
SELECT 'Excepciones: SQLEXCEPTION, SQLWARNING, NOT FOUND' AS tema;
SELECT 'Errores personalizados: SIGNAL SQLSTATE 45000' AS tema;
SELECT 'Transacciones: START TRANSACTION, COMMIT, ROLLBACK' AS tema;
SELECT 'Puntos intermedios: SAVEPOINT, ROLLBACK TO SAVEPOINT' AS tema;
SELECT 'Manejo de errores: DECLARE HANDLER, EXIT HANDLER, CONTINUE HANDLER' AS tema;

