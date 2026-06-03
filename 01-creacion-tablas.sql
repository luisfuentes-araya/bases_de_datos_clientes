--| #  | Concepto           | Qué hace                     | Ejemplo                                              | Para qué sirve                                 |
--| -- | ------------------ | ---------------------------- | ---------------------------------------------------- | ---------------------------------------------- |
--| 1  | CREATE DATABASE    | Crea la base de datos        | CREATE DATABASE clientes_previsional;                | Punto de partida del proyecto                  |
--| 2  | USE                | Selecciona la base de datos  | USE clientes_previsional;                            | Trabajar en la BD correcta                     |
--| 3  | CREATE TABLE       | Crea una tabla nueva         | CREATE TABLE cliente (...);                          | Definir estructura de datos                    |
--| 4  | PRIMARY KEY        | Clave única por registro     | id_cliente INT PRIMARY KEY                           | Identifica cada fila única                     |
--| 5  | AUTO_INCREMENT     | Genera IDs automáticos       | INT PRIMARY KEY AUTO_INCREMENT                       | No escribir IDs manualmente                    |
--| 6  | FOREIGN KEY        | Relaciona 2 tablas           | FOREIGN KEY (id_comuna) REFERENCES comuna(id_comuna) | Integridad referencial entre tablas            |
--| 7  | NOT NULL           | Campo obligatorio            | nombre VARCHAR(100) NOT NULL                         | Evita datos vacíos                             |
--| 8  | UNIQUE             | Valor único en columna       | rut VARCHAR(12) UNIQUE                               | Evita duplicados (RUT, email)                  |
--| 9  | DEFAULT            | Valor por defecto            | activo BOOLEAN DEFAULT TRUE                          | Auto-asignar valor si no se especifica         |
--| 10 | CHECK              | Validación personalizada     | CHECK(edad >= 18)                                    | Reglas de negocio (ej: mayoría de edad)        |
--| 11 | TIMESTAMP          | Fecha/hora automática        | created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP       | Registro de cuándo se creó/actualizó           |
--| 12 | ON UPDATE CASCADE  | Actualiza FK automáticamente | ON UPDATE CASCADE                                    | Si cambia el ID padre, se actualizan los hijos |
--| 13 | ON DELETE RESTRICT | Evita borrar si hay hijos    | ON DELETE RESTRICT                                   | Protege integridad de datos                    |
--| 14 | CREATE INDEX       | Acelera consultas            | CREATE INDEX idx_cliente_rut ON cliente(rut);        | Optimizar búsquedas por columna                |-- ============================================
-- PROYECTO: Base de Datos de Clientes AFP/Fonasa/Isapre
-- OBJETIVO: Aprender SQL desde Junior hasta avanzado
-- ============================================

-- 1. CREAR LA BASE DE DATOS
CREATE DATABASE IF NOT EXISTS clientes_previsional;
USE clientes_previsional;

-- ============================================
-- 2. CREAR TABLAS (DDL)
-- ============================================

-- TABLA 1: REGIONES
CREATE TABLE region (
    id_region INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    capital VARCHAR(100),
    poblacion BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABLA 2: COMUNAS
CREATE TABLE comuna (
    id_comuna INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    id_region INT NOT NULL,
    poblacion INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_region) REFERENCES region(id_region)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- TABLA 3: TIPOS DE PREVISIÓN (AFP/Fonasa/Isapre)
CREATE TABLE tipo_prevision (
    id_tipo INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    tasa_contribucion DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABLA 4: CLIENTES (tabla principal)
CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    rut VARCHAR(12) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(100) NOT NULL,
    apellido_materno VARCHAR(100),
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    id_comuna INT NOT NULL,
    id_tipo_prev INT NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    salario_uf DECIMAL(10,2),
    
    -- Constraint
    CONSTRAINT chk_edad CHECK (TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) >= 18),
    CONSTRAINT chk_email CHECK (email LIKE '%@%.%'),
    
    -- Foreign Keys
    FOREIGN KEY (id_comuna) REFERENCES comuna(id_comuna)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (id_tipo_prev) REFERENCES tipo_prevision(id_tipo)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- TABLA 5: HISTORIAL_CAMBIOS (para auditoría - triggers)
CREATE TABLE historial_cambios (
    id_historial INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    campo_cambiado VARCHAR(50),
    valor_anterior VARCHAR(255),
    valor_nuevo VARCHAR(255),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operacion ENUM('INSERT', 'UPDATE', 'DELETE'),
    
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- TABLA 6: AFILIACIONES_HISTORICAS (relación N:N con fechas)
CREATE TABLE afiliacion_historica (
    id_afiliacion INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    nombre_afiliadora VARCHAR(100) NOT NULL,
    fecha_afiliacion DATE NOT NULL,
    fecha_desafiliacion DATE,
    tipo_afiliacion ENUM('AFP', 'FONASA', 'ISAPRE') NOT NULL,
    folio_contrato VARCHAR(50),
    
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ============================================
-- 3. CREAR ÍNDICES (para optimizar consultas)
-- ============================================
CREATE INDEX idx_cliente_rut ON cliente(rut);
CREATE INDEX idx_cliente_email ON cliente(email);
CREATE INDEX idx_cliente_nombre ON cliente(nombre, apellido_paterno);
CREATE INDEX idx_cliente_fecha_nac ON cliente(fecha_nacimiento);
CREATE INDEX idx_cliente_tipo ON cliente(id_tipo_prev);
CREATE INDEX idx_cliente_comuna ON cliente(id_comuna);
CREATE INDEX idx_cliente_activo ON cliente(activo);
CREATE INDEX idx_comuna_region ON comuna(id_region);
