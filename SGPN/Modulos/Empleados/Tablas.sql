/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Creación de tablas módulo empleados
*/

USE LinuxPreachers;
GO

-- Schema
IF NOT EXISTS ( SELECT 1 FROM sys.schemas WHERE name = 'empleados' )
BEGIN 
    EXEC('CREATE SCHEMA empleados'); 
END; 
GO

-- Este SP asume que no existe ninguna tabla
CREATE OR ALTER PROCEDURE empleados.crear_tablas_modulo_empleados
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE empleados.TipoDocumento (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,

        CONSTRAINT PK_TipoDocumento PRIMARY KEY (id)
    );

    CREATE TABLE empleados.Empleado (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        apellido VARCHAR(100) NOT NULL,
        nro_doc INT NOT NULL,
        id_tipo_documento INT NOT NULL,
        activo BIT NOT NULL DEFAULT 1,

        CONSTRAINT PK_Empleado PRIMARY KEY (id),

        CONSTRAINT FK_Empleado_TipoDocumento
            FOREIGN KEY (id_tipo_documento)
            REFERENCES empleados.TipoDocumento(id),

        CONSTRAINT UQ_Empleado_Documento
            UNIQUE (id_tipo_documento, nro_doc)
    );

    CREATE TABLE empleados.Especialidad (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(255) NULL,

        CONSTRAINT PK_Especialidad PRIMARY KEY (id)
    );

    CREATE TABLE empleados.Titulo (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        institucion VARCHAR(100) NOT NULL,

        CONSTRAINT PK_Titulo PRIMARY KEY (id)
    );

    CREATE TABLE empleados.Guia (
        nro_registro INT NOT NULL,
        id_empleado INT NOT NULL,
        id_especialidad INT NOT NULL,
        id_titulo INT,

        CONSTRAINT PK_Guia PRIMARY KEY (id_empleado),

        CONSTRAINT FK_Guia_Empleado
            FOREIGN KEY (id_empleado)
            REFERENCES empleados.Empleado(id),

        CONSTRAINT FK_Guia_Especialidad
            FOREIGN KEY (id_especialidad)
            REFERENCES empleados.Especialidad(id),

        CONSTRAINT FK_Guia_Titulo
            FOREIGN KEY (id_titulo)
            REFERENCES empleados.Titulo(id)
    );

    CREATE TABLE empleados.Guardaparque (
        nro_matricula INT NOT NULL,
        id_empleado INT NOT NULL,

        CONSTRAINT PK_Guardaparque PRIMARY KEY (id_empleado),

        CONSTRAINT FK_Guardaparque_Empleado
            FOREIGN KEY (id_empleado)
            REFERENCES empleados.Empleado(id)
    );

    CREATE TABLE empleados.GuardaparqueAsignado (
        id INT NOT NULL,
        id_empleado INT NOT NULL,
        id_parque INT NOT NULL,
        fecha_ingreso DATE NOT NULL,
        fecha_egreso DATE NULL,
        motivo_egreso VARCHAR(255) NULL,

        CONSTRAINT PK_GuardaparqueAsignado
            PRIMARY KEY (id),

        CONSTRAINT FK_GuardaparqueAsignado_Guardaparque
            FOREIGN KEY (id_empleado)
            REFERENCES empleados.Guardaparque(id_empleado),

        CONSTRAINT FK_GuardaparqueAsignado_Parque
            FOREIGN KEY (id_parque)
            REFERENCES parques.Parque(id),

        CONSTRAINT CK_GuardaparqueParqueAsignado_Fechas
            CHECK (fecha_egreso IS NULL OR fecha_egreso >= fecha_ingreso)
    );

    CREATE TABLE empleados.GuiaEstaEnActividad (
        id INT NOT NULL,
        id_empleado INT NOT NULL,
        id_actividad INT NOT NULL,
        fecha_inicio DATE NOT NULL,
        fecha_fin DATE NULL,

        CONSTRAINT PK_GuiaActividad
            PRIMARY KEY (id),

        CONSTRAINT FK_GuiaActividad_Guia
            FOREIGN KEY (id_empleado)
            REFERENCES empleados.Guia(id_empleado),

        CONSTRAINT FK_GuiaActividad_Actividad
            FOREIGN KEY (id_actividad)
            REFERENCES actividades.Actividad(id),

        CONSTRAINT CK_GuiaActividad_Fechas
            CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
    );

    CREATE TABLE empleados.GuiaPoseeHabilitacion (
        id INT NOT NULL,
        id_empleado INT NOT NULL,
        id_habilitacion INT NOT NULL,
        fecha_inicio DATE NOT NULL,
        fecha_fin DATE NOT NULL,

        CONSTRAINT PK_GuiaHabilitacion
            PRIMARY KEY (id),

        CONSTRAINT FK_GuiaHabilitacion_Guia
            FOREIGN KEY (id_empleado)
            REFERENCES empleados.Guia(id_empleado),

        CONSTRAINT FK_GuiaHabilitacion_Habilitacion
            FOREIGN KEY (id_habilitacion)
            REFERENCES actividades.Habilitacion(id)
    );

END;
GO

-- SP Wrapper con verificaciones
CREATE OR ALTER PROCEDURE empleados.sp_crear_modulo_empleados
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tablas_existentes TABLE (
        nombre VARCHAR(128)
    );

    INSERT INTO @tablas_existentes (nombre)
    SELECT t.name
    FROM sys.tables t
    INNER JOIN sys.schemas s
        ON s.schema_id = t.schema_id
    WHERE s.name = 'empleados'
      AND t.name IN (
            'TipoDocumento',
            'Empleado',
            'Especialidad',
            'Titulo',
            'Guia',
            'Guardaparque',
            'GuardaparqueAsignado',
            'GuiaEstaEnActividad',
            'GuiaPoseeHabilitacion'
      );

    IF EXISTS (SELECT 1 FROM @tablas_existentes)
    BEGIN
        ;THROW 50100,'No se puede crear el modulo: ya existe al menos una tabla del modulo empleados en el esquema empleados.',1;
    END

    DECLARE @dependencias_faltantes TABLE (
        nombre VARCHAR(128)
    );

    INSERT INTO @dependencias_faltantes (nombre)
    SELECT d.nombre
    FROM (
        VALUES
            ('Parque'),
            ('Actividad'),
            ('Habilitacion')
    ) AS d(nombre)
    WHERE NOT EXISTS (
        SELECT 1
        FROM sys.tables t
        INNER JOIN sys.schemas s
            ON s.schema_id = t.schema_id
        WHERE s.name = 'parques' OR s.name = 'actividades'
          AND t.name = d.nombre
    );

    IF EXISTS (SELECT 1 FROM @dependencias_faltantes)
    BEGIN
        ;THROW 50101,'No se puede crear el modulo empleados: faltan tablas necesarias por relaciones.', 1;
    END 

    EXEC empleados.crear_tablas_modulo_empleados;
END;
GO

CREATE OR ALTER PROCEDURE empleados.sp_eliminar_modulo_empleados
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

            DROP TABLE IF EXISTS empleados.GuiaPoseeHabilitacion;
            DROP TABLE IF EXISTS empleados.GuiaEstaEnActividad;
            DROP TABLE IF EXISTS empleados.GuardaparqueAsignado;

            
            DROP TABLE IF EXISTS empleados.Guia;
            DROP TABLE IF EXISTS empleados.Guardaparque;

            DROP TABLE IF EXISTS empleados.Titulo;
            DROP TABLE IF EXISTS empleados.Especialidad;

            DROP TABLE IF EXISTS empleados.Empleado;
            DROP TABLE IF EXISTS empleados.TipoDocumento;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @mensaje_error VARCHAR(4000);

        SET @mensaje_error = ERROR_MESSAGE();

        THROW 50102,@mensaje_error,1;
        RETURN;
    END CATCH;
END;
GO

/*
-- Ejecucion
EXEC empleados.sp_crear_modulo_empleados;
SELECT * FROM sys.tables;
GO

-- Autodestruccion
EXEC empleados.sp_eliminar_modulo_empleados;
SELECT * FROM sys.tables;
GO
*/