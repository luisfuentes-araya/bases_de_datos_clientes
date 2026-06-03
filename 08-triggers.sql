--| #   | Concepto                  | Qué hace                                     | Ejemplo                                                          | Para qué sirve                             |
--| --- | ------------------------- | -------------------------------------------- | ---------------------------------------------------------------- | ------------------------------------------ |
--| 109 | TRIGGER                   | Procedimiento que se ejecuta AUTOMÁTICAMENTE | CREATE TRIGGER validar_email BEFORE INSERT                       | Automatizar validaciones/auditoría         |
--| 110 | BEFORE INSERT             | Se ejecuta ANTES de insertar                 | BEFORE INSERT ON cliente                                         | Validar/modificar datos antes de guardar   |
--| 111 | AFTER INSERT              | Se ejecuta DESPUÉS de insertar               | AFTER INSERT ON cliente                                          | Auditoría después de crear registro        |
--| 112 | BEFORE UPDATE             | Se ejecuta ANTES de actualizar               | BEFORE UPDATE ON cliente                                         | Validar cambios antes de aplicar           |
--| 113 | AFTER UPDATE              | Se ejecuta DESPUÉS de actualizar             | AFTER UPDATE ON cliente                                          | Auditoría después de modificar             |
--| 114 | BEFORE DELETE             | Se ejecuta ANTES de eliminar                 | BEFORE DELETE ON cliente                                         | Prevenir eliminación o validar             |
--| 115 | AFTER DELETE              | Se ejecuta DESPUÉS de eliminar               | AFTER DELETE ON cliente                                          | Auditoría después de borrar                |
--| 116 | FOR EACH ROW              | Se ejecuta por cada fila afectada            | FOR EACH ROW BEGIN ... END                                       | Trigger fila por fila (no por tabla)       |
--| 117 | OLD.columna               | Valor ANTES del cambio                       | OLD.salario_uf                                                   | Ver valor anterior en UPDATE/DELETE        |
--| 118 | NEW.columna               | Valor DESPUÉS del cambio                     | NEW.salario_uf                                                   | Ver/modificar valor nuevo en INSERT/UPDATE |
--| 119 | SIGNAL SQLSTATE           | Lanzar error personalizado                   | SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR'               | Validar y detener operación inválida       |
--| 120 | SET NEW.columna           | Modificar valor antes de guardar             | SET NEW.email = LOWER(NEW.email)                                 | Auto-convertir a minúsculas, etc.          |
--| 121 | IF/THEN/END IF            | Condicional en trigger                       | IF edad < 18 THEN SIGNAL ... END IF                              | Validar condiciones antes de guardar       |
--| 122 | Validación de email       | Verificar formato email                      | IF NEW.email NOT LIKE '%@%.%'                                    | Prevenir emails inválidos                  |
--| 123 | Validación de RUT         | Verificar RUT no vacío                       | IF NEW.rut IS NULL                                               | Campos obligatorios                        |
--| 124 | Validación de edad        | Calcular y validar edad                      | TIMESTAMPDIFF(YEAR, fecha, CURDATE()) < 18                       | Mayor de edad (18+)                        |
--| 125 | Auto-convertir minúsculas | Convertir texto automáticamente              | SET NEW.email = LOWER(NEW.email)                                 | Normalizar datos                           |
--| 126 | Auto-convertir mayúscula  | Primer letra mayúscula                       | SET NEW.nombre = CONCAT(UPPER(LEFT(...)), LCASE(SUBSTRING(...))) | Formatear nombres                          |
--| 127 | Auditoría INSERT          | Registrar creación                           | INSERT INTO historial_cambios ... VALUES ('INSERT')              | Saber cuándo se creó registro              |
--| 128 | Auditoría UPDATE          | Registrar cambios                            | INSERT INTO historial_cambios ... VALUES ('UPDATE')              | Saber qué cambió y cuándo                  |
--| 129 | Prevención eliminación    | Bloquear DELETE físico                       | SIGNAL SQLSTATE ... 'No se puede eliminar'                       | Forzar soft delete en su lugar             |
--| 130 | Soft delete automático    | Desactivar en vez de borrar                  | UPDATE cliente SET activo = FALSE                                | Mantener datos pero marcar inactivo        |
--| 131 | SHOW TRIGGERS             | Listar todos los triggers                    | SHOW TRIGGERS                                                    | Ver triggers existentes                    |
--| 132 | SHOW CREATE TRIGGER       | Ver código trigger                           | SHOW CREATE TRIGGER nombre                                       | Revisar trigger creado                     |
--| 133 | DROP TRIGGER              | Borrar trigger                               | DROP TRIGGER IF EXISTS nombre                                    | Eliminar trigger obsoleto                  |
-- ============================================
-- PARTE 8: TRIGGERS (Disparadores Automáticos)
-- ============================================

USE clientes_previsional;

-- ============================================
-- 1. QUÉ ES UN TRIGGER
-- ============================================

-- TRIGGER = Procedimiento que se ejecuta AUTOMÁTICAMENTE
-- Cuando ocurre un evento (INSERT, UPDATE, DELETE)
--
-- Tipos de triggers:
-- - BEFORE INSERT: Antes de insertar (validar, modificar datos)
-- - AFTER INSERT: Después de insertar (auditoría, cálculos)
-- - BEFORE UPDATE: Antes de actualizar (validar cambios)
-- - AFTER UPDATE: Después de actualizar (auditoría)
-- - BEFORE DELETE: Antes de eliminar (validar, prevenir)
-- - AFTER DELETE: Después de eliminar (auditoría, cascada)
--
-- OLD.columna = Valor ANTES del cambio (UPDATE/DELETE)
-- NEW.columna = Valor DESPUÉS del cambio (INSERT/UPDATE)

SELECT '=== QUÉ ES UN TRIGGER ===' AS informacion;

-- ============================================
-- 2. TRIGGER BEFORE INSERT (validar y modificar antes de insertar)
-- ============================================

-- Trigger que valida email antes de insertar
DELIMITER $$

CREATE TRIGGER validar_email_before_insert
BEFORE INSERT ON cliente
FOR EACH ROW
BEGIN
    -- Validar que email tenga formato correcto
    IF NEW.email NOT LIKE '%@%.%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '❌ ERROR: El email debe tener formato válido (ej: usuario@email.com)';
    END IF;
    
    -- Validar que RUT no esté vacío
    IF NEW.rut IS NULL OR NEW.rut = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '❌ ERROR: El RUT es obligatorio';
    END IF;
    
    -- Auto-convertir email a minúsculas
    SET NEW.email = LOWER(NEW.email);
    
    -- Auto-convertir nombres a mayúscula inicial
    SET NEW.nombre = CONCAT(UPPER(LEFT(NEW.nombre, 1)), LCASE(SUBSTRING(NEW.nombre, 2)));
END$$

DELIMITER ;

-- Intentar insertar con email inválido (debería fallar)
INSERT INTO cliente (
    rut, nombre, apellido_paterno, apellido_materno,
    fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
) VALUES (
    '88.888.888-8',
    'Test Invalido',
    'Prueba',
    'Test',
    '1990-01-01',
    '+56988887777',
    'email_invalido',  -- ❌ Email sin @
    1,
    2,
    30.0
);

-- Intentar insertar con email válido (debería funcionar)
INSERT INTO cliente (
    rut, nombre, apellido_paterno, apellido_materno,
    fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
) VALUES (
    '87.777.777-7',
    'test valido',
    'Prueba',
    'Test',
    '1990-01-01',
    '+56977776666',
    'test.valido@email.com',  -- ✅ Email válido
    1,
    2,
    30.0
);

-- Verificar que email fue convertido a minúsculas y nombre a mayúscula inicial
SELECT rut, nombre, email FROM cliente WHERE rut = '87.777.777-7';

SELECT '✅ Trigger BEFORE INSERT creado (validar email)' AS mensaje;

-- ============================================
-- 3. TRIGGER AFTER INSERT (auditoría después de insertar)
-- ============================================

-- Trigger que registra en historial_cambios cuando se inserta un cliente
DELIMITER $$

CREATE TRIGGER after_insert_cliente_auditoria
AFTER INSERT ON cliente
FOR EACH ROW
BEGIN
    INSERT INTO historial_cambios (
        id_cliente,
        campo_cambiado,
        valor_anterior,
        valor_nuevo,
        operacion
    ) VALUES (
        NEW.id_cliente,
        'INSERT_CLIENTE',
        NULL,
        CONCAT('Cliente creado: ', NEW.nombre, ' ', NEW.apellido_paterno),
        'INSERT'
    );
END$$

DELIMITER ;

-- Insertar un cliente (el trigger se ejecuta automáticamente)
INSERT INTO cliente (
    rut, nombre, apellido_paterno, apellido_materno,
    fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
) VALUES (
    '86.666.666-6',
    'Auditoria',
    'Trigger',
    'Test',
    '1990-01-01',
    '+56966665555',
    'auditoria@trigger.com',
    1,
    2,
    30.0
);

-- Verificar que se registró en historial_cambios
SELECT * FROM historial_cambios WHERE id_cliente = (SELECT id_cliente FROM cliente WHERE rut = '86.666.666-6');

SELECT '✅ Trigger AFTER INSERT creado (auditoría)' AS mensaje;

-- ============================================
-- 4. TRIGGER BEFORE UPDATE (validar antes de actualizar)
-- ============================================

-- Trigger que impide cambiar RUT de un cliente
DELIMITER $$

CREATE TRIGGER before_update_cliente_no_rut
BEFORE UPDATE ON cliente
FOR EACH ROW
BEGIN
    -- Impedir cambio de RUT
    IF OLD.rut != NEW.rut THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '❌ ERROR: No se puede modificar el RUT de un cliente';
    END IF;
    
    -- Validar que salario no sea negativo
    IF NEW.salario_uf < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '❌ ERROR: El salario no puede ser negativo';
    END IF;
END$$

DELIMITER ;

-- Intentar cambiar RUT (debería fallar)
UPDATE cliente SET rut = '99.999.999-9' WHERE rut = '87.777.777-7';

-- Actualizar salario válido (debería funcionar)
UPDATE cliente SET salario_uf = 35.5 WHERE rut = '87.777.777-7';

-- Intentar poner salario negativo (debería fallar)
UPDATE cliente SET salario_uf = -10 WHERE rut = '87.777.777-7';

SELECT '✅ Trigger BEFORE UPDATE creado (validar RUT y salario)' AS mensaje;

-- ============================================
-- 5. TRIGGER AFTER UPDATE (auditoría después de actualizar)
-- ============================================

-- Trigger que registra TODOS los cambios en historial_cambios
DELIMITER $$

CREATE TRIGGER after_update_cliente_auditoria
AFTER UPDATE ON cliente
FOR EACH ROW
BEGIN
    -- Registrar cambio de salario
    IF OLD.salario_uf != NEW.salario_uf THEN
        INSERT INTO historial_cambios (
            id_cliente,
            campo_cambiado,
            valor_anterior,
            valor_nuevo,
            operacion
        ) VALUES (
            NEW.id_cliente,
            'salario_uf',
            CONCAT(OLD.salario_uf, ' UF'),
            CONCAT(NEW.salario_uf, ' UF'),
            'UPDATE'
        );
    END IF;
    
    -- Registrar cambio de email
    IF OLD.email != NEW.email THEN
        INSERT INTO historial_cambios (
            id_cliente,
            campo_cambiado,
            valor_anterior,
            valor_nuevo,
            operacion
        ) VALUES (
            NEW.id_cliente,
            'email',
            OLD.email,
            NEW.email,
            'UPDATE'
        );
    END IF;
    
    -- Registrar cambio de activo
    IF OLD.activo != NEW.activo THEN
        INSERT INTO historial_cambios (
            id_cliente,
            campo_cambiado,
            valor_anterior,
            valor_nuevo,
            operacion
        ) VALUES (
            NEW.id_cliente,
            'activo',
            IF(OLD.activo = TRUE, 'Activo', 'Inactivo'),
            IF(NEW.activo = TRUE, 'Activo', 'Inactivo'),
            'UPDATE'
        );
    END IF;
END$$

DELIMITER ;

-- Actualizar cliente (el trigger registra cambios)
UPDATE cliente SET salario_uf = 40.0, email = 'nuevo.email@email.com' WHERE rut = '87.777.777-7';

-- Verificar historial de cambios
SELECT * FROM historial_cambios WHERE id_cliente = (SELECT id_cliente FROM cliente WHERE rut = '87.777.777-7')
ORDER BY id_historial DESC;

SELECT '✅ Trigger AFTER UPDATE creado (auditoría detallada)' AS mensaje;

-- ============================================
-- 6. TRIGGER BEFORE DELETE (validar antes de eliminar)
-- ============================================

-- Trigger que previene eliminación física (soft delete en su lugar)
DELIMITER $$

CREATE TRIGGER before_delete_cliente_soft_delete
BEFORE DELETE ON cliente
FOR EACH ROW
BEGIN
    -- Impedir eliminación física, hacer soft delete en su lugar
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '❌ ERROR: No se puede eliminar un cliente. Usa desactivar_cliente() procedimiento.';
END$$

DELIMITER ;

-- Intentar eliminar cliente (debería fallar)
DELETE FROM cliente WHERE rut = '87.777.777-7';

-- Usar procedimiento de soft delete en su lugar
CALL desactivar_cliente((SELECT id_cliente FROM cliente WHERE rut = '87.777.777-7'));

-- Verificar que está inactivo (no eliminado)
SELECT id_cliente, rut, nombre, activo FROM cliente WHERE rut = '87.777.777-7';

SELECT '✅ Trigger BEFORE DELETE creado (previene eliminación física)' AS mensaje;

-- ============================================
-- 7. TRIGGER PARA AUTOMATIZAR (calcular automático)
-- ============================================

-- Trigger que actualiza fecha_modificacion automáticamente
DELIMITER $$

CREATE TRIGGER before_update_cliente_autofecha
BEFORE UPDATE ON cliente
FOR EACH ROW
BEGIN
    -- Auto-actualizar timestamp (si no se proporciona)
    SET NEW.fecha_registro = NOW();
END$$

DELIMITER ;

-- Actualizar cliente (fecha se actualiza automáticamente)
UPDATE cliente SET telefono = '+56911119999' WHERE rut = '12.345.678-9';

-- Verificar fecha de registro
SELECT rut, nombre, fecha_registro FROM cliente WHERE rut = '12.345.678-9';

SELECT '✅ Trigger BEFORE UPDATE autofecha creado' AS mensaje;

-- ============================================
-- 8. TRIGGER COMPLEJO (múltiples validaciones)
-- ============================================

-- Trigger que valida edad mínima (18 años) antes de insertar
DELIMITER $$

CREATE TRIGGER validar_edad_before_insert_cliente
BEFORE INSERT ON cliente
FOR EACH ROW
BEGIN
    DECLARE edad INT;
    
    -- Calcular edad
    SET edad = TIMESTAMPDIFF(YEAR, NEW.fecha_nacimiento, CURDATE());
    
    -- Validar edad mínima
    IF edad < 18 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = CONCAT('❌ ERROR: El cliente debe tener al menos 18 años. Edad actual: ', edad);
    END IF;
    
    -- Validar edad máxima (100 años)
    IF edad > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = CONCAT('❌ ERROR: La edad parece incorrecta. Edad: ', edad);
    END IF;
    
    -- Validar teléfono (debe comenzar con +569)
    IF NEW.telefono NOT LIKE '+569%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '❌ ERROR: El teléfono debe comenzar con +569 (ej: +56912345678)';
    END IF;
END$$

DELIMITER ;

-- Intentar insertar menor de edad (debería fallar)
INSERT INTO cliente (
    rut, nombre, apellido_paterno, apellido_materno,
    fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
) VALUES (
    '85.555.555-5',
    'Menor',
    'Edad',
    'Test',
    '2010-01-01',  -- ❌ 16 años
    '+56955554444',
    'menor@test.com',
    1,
    2,
    30.0
);

-- Intentar insertar teléfono inválido (debería fallar)
INSERT INTO cliente (
    rut, nombre, apellido_paterno, apellido_materno,
    fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
) VALUES (
    '84.444.444-4',
    'Telefono',
    'Invalido',
    'Test',
    '1990-01-01',
    '912345678',  -- ❌ Sin +569
    'telefono@test.com',
    1,
    2,
    30.0
);

-- Insertar válido (debería funcionar)
INSERT INTO cliente (
    rut, nombre, apellido_paterno, apellido_materno,
    fecha_nacimiento, telefono, email, id_comuna, id_tipo_prev, salario_uf
) VALUES (
    '83.333.333-3',
    'Valido',
    'Completo',
    'Test',
    '1990-01-01',  -- ✅ 36 años
    '+56944443333',  -- ✅ Formato correcto
    'valido@test.com',
    1,
    2,
    30.0
);

SELECT '✅ Trigger complejo de validación creado' AS mensaje;

-- ============================================
-- 9. LISTAR Y BORRAR TRIGGERS
-- ============================================

-- Ver todos los triggers
SHOW TRIGGERS;

-- Ver triggers de una tabla específica
SHOW TRIGGERS FROM clientes_previsional WHERE Table = 'cliente';

-- Ver código de un trigger
SHOW CREATE TRIGGER validar_email_before_insert;

-- Borrar un trigger
DROP TRIGGER IF EXISTS validar_email_before_insert;
DROP TRIGGER IF EXISTS after_insert_cliente_auditoria;
DROP TRIGGER IF EXISTS before_update_cliente_no_rut;
DROP TRIGGER IF EXISTS after_update_cliente_auditoria;
DROP TRIGGER IF EXISTS before_delete_cliente_soft_delete;
DROP TRIGGER IF EXISTS before_update_cliente_autofecha;
DROP TRIGGER IF EXISTS validar_edad_before_insert_cliente;

SELECT '✅ Listado y borrado de triggers completado' AS mensaje;

-- ============================================
-- 10. RESUMEN DE LO QUE APRENDISTE
-- ============================================

SELECT '=== RESUMEN APRENDIZAJE PARTE 8 ===' AS categoria;
SELECT 'QUÉ ES UN TRIGGER (disparador automático)' AS tema;
SELECT 'BEFORE INSERT (antes de insertar)' AS tema;
SELECT 'AFTER INSERT (después de insertar)' AS tema;
SELECT 'BEFORE UPDATE (antes de actualizar)' AS tema;
SELECT 'AFTER UPDATE (después de actualizar)' AS tema;
SELECT 'BEFORE DELETE (antes de eliminar)' AS tema;
SELECT 'AFTER DELETE (después de eliminar)' AS tema;
SELECT 'OLD.columna (valor antes del cambio)' AS tema;
SELECT 'NEW.columna (valor después del cambio)' AS tema;
SELECT 'VALIDACIÓN con SIGNAL SQLSTATE (lanzar error)' AS tema;
SELECT 'AUTO-MODIFICAR datos (SET NEW.columna = ...)' AS tema;
SELECT 'AUDITORÍA (registrar cambios en historial)' AS tema;
SELECT 'PREVENCIÓN de eliminación física' AS tema;
SELECT 'SHOW TRIGGERS / SHOW CREATE TRIGGER' AS tema;
SELECT 'DROP TRIGGER IF EXISTS (eliminar trigger)' AS tema;

-- ============================================
-- 11. RESUMEN TIPO TABLA
-- ============================================

-- | Uso                  | Qué hace                                 | Trigger recomendado           |
-- | -------------------- | ---------------------------------------- | ----------------------------- |
-- | Validación           | Verificar datos antes de guardar         | BEFORE INSERT o BEFORE UPDATE |
-- | Auditoría            | Registrar cambios en historial           | AFTER INSERT o AFTER UPDATE   |
-- | Auto-formateo        | Convertir texto (minúsculas, mayúsculas) | BEFORE INSERT y BEFORE UPDATE |
-- | Prevención           | Bloquear operaciones inválidas           | BEFORE DELETE o BEFORE UPDATE |
-- | Soft delete          | Desactivar en vez de borrar              | BEFORE DELETE (SIGNAL error)  |
-- | Cálculo automático   | Calcular valores derivados               | BEFORE INSERT o BEFORE UPDATE |
-- | Timestamp automático | Actualizar fecha/hora                    | BEFORE UPDATE                 |

SELECT '=== FIN PARTE 8: TRIGGERS ===' AS mensaje;







| Uso                  | Qué hace                                 | Trigger recomendado           |
| -------------------- | ---------------------------------------- | ----------------------------- |
| Validación           | Verificar datos antes de guardar         | BEFORE INSERT o BEFORE UPDATE |
| Auditoría            | Registrar cambios en historial           | AFTER INSERT o AFTER UPDATE   |
| Auto-formateo        | Convertir texto (minúsculas, mayúsculas) | BEFORE INSERT y BEFORE UPDATE |
| Prevención           | Bloquear operaciones inválidas           | BEFORE DELETE o BEFORE UPDATE |
| Soft delete          | Desactivar en vez de borrar              | BEFORE DELETE (SIGNAL error)  |
| Cálculo automático   | Calcular valores derivados               | BEFORE INSERT o BEFORE UPDATE |
| Timestamp automático | Actualizar fecha/hora                    | BEFORE UPDATE                 |
