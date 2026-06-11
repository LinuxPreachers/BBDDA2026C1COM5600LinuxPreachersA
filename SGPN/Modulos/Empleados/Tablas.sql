-- Schema
IF NOT EXISTS ( SELECT 1 FROM sys.schemas WHERE name = 'sgpn' )
BEGIN EXEC('CREATE SCHEMA sgpn'); END; GO

-- Este SP asume que no existe ninguna tabla
CREATE OR ALTER PROCEDURE sgpn.crear_tablas_modulo_empleados
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE sgpn.TipoDocumento (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,

        CONSTRAINT PK_TipoDocumento PRIMARY KEY (id)
    );

    CREATE TABLE sgpn.Empleado (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        apellido VARCHAR(100) NOT NULL,
        nro_doc INT NOT NULL,
        id_tipo_documento INT NOT NULL,

        CONSTRAINT PK_Empleado PRIMARY KEY (id),

        CONSTRAINT FK_Empleado_TipoDocumento
            FOREIGN KEY (id_tipo_documento)
            REFERENCES sgpn.TipoDocumento(id),

        CONSTRAINT UQ_Empleado_Documento
            UNIQUE (id_tipo_documento, nro_doc)
    );

    CREATE TABLE sgpn.Especialidad (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(255) NULL,

        CONSTRAINT PK_Especialidad PRIMARY KEY (id)
    );

    CREATE TABLE sgpn.Titulo (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        institucion VARCHAR(100) NOT NULL,

        CONSTRAINT PK_Titulo PRIMARY KEY (id)
    );

    -- Sacar
    CREATE TABLE sgpn.Habilitacion (
        id INT IDENTITY(1,1) NOT NULL,
        CONSTRAINT PK_Habilitacion PRIMARY KEY (id)
    );

    CREATE TABLE sgpn.Guia (
        nro_registro INT NOT NULL,
        id_empleado INT NOT NULL,
        id_especialidad INT NOT NULL,
        id_titulo INT,

        CONSTRAINT PK_Guia PRIMARY KEY (id_empleado),

        CONSTRAINT FK_Guia_Empleado
            FOREIGN KEY (id_empleado)
            REFERENCES sgpn.Empleado(id),

        CONSTRAINT FK_Guia_Especialidad
            FOREIGN KEY (id_especialidad)
            REFERENCES sgpn.Especialidad(id),

        CONSTRAINT FK_Guia_Titulo
            FOREIGN KEY (id_titulo)
            REFERENCES sgpn.Titulo(id)
    );

    CREATE TABLE sgpn.Guardaparque (
        nro_matricula INT NOT NULL,
        id_empleado INT NOT NULL,

        CONSTRAINT PK_Guardaparque PRIMARY KEY (id_empleado),

        CONSTRAINT FK_Guardaparque_Empleado
            FOREIGN KEY (id_empleado)
            REFERENCES sgpn.Empleado(id)
    );

    CREATE TABLE sgpn.GuardaparqueAsignado (
        id_empleado INT NOT NULL,
        id_parque INT NOT NULL,
        fecha_ingreso DATE NOT NULL,
        fecha_egreso DATE NULL,
        motivo_egreso VARCHAR(255) NULL,

        CONSTRAINT PK_GuardaparqueAsignado
            PRIMARY KEY (id_empleado, id_parque, fecha_ingreso),

        CONSTRAINT FK_GuardaparqueAsignado_Guardaparque
            FOREIGN KEY (id_empleado)
            REFERENCES sgpn.Guardaparque(id_empleado),

        CONSTRAINT FK_GuardaparqueAsignado_Parque
            FOREIGN KEY (id_parque)
            REFERENCES sgpn.Parque(id),

        CONSTRAINT CK_GuardaparqueParqueAsignado_Fechas
            CHECK (fecha_egreso IS NULL OR fecha_egreso >= fecha_ingreso)
    );

    CREATE TABLE sgpn.GuiaEstaEnActividad (
        id_empleado INT NOT NULL,
        id_actividad INT NOT NULL,
        fecha_inicio DATE NOT NULL,
        fecha_fin DATE NULL,

        CONSTRAINT PK_GuiaActividad
            PRIMARY KEY (id_empleado, id_actividad, fecha_inicio),

        CONSTRAINT FK_GuiaActividad_Guia
            FOREIGN KEY (id_empleado)
            REFERENCES sgpn.Guia(id_empleado),

        CONSTRAINT FK_GuiaActividad_Actividad
            FOREIGN KEY (id_actividad)
            REFERENCES sgpn.Actividad(id),

        CONSTRAINT CK_GuiaActividad_Fechas
            CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
    );

    CREATE TABLE sgpn.GuiaPoseeHabilitacion (
        id_empleado INT NOT NULL,
        id_habilitacion INT NOT NULL,
        fecha_inicio DATE NOT NULL,

        CONSTRAINT PK_GuiaHabilitacion
            PRIMARY KEY (id_empleado, id_habilitacion, fecha_inicio),

        CONSTRAINT FK_GuiaHabilitacion_Guia
            FOREIGN KEY (id_empleado)
            REFERENCES sgpn.Guia(id_empleado),

        CONSTRAINT FK_GuiaHabilitacion_Habilitacion
            FOREIGN KEY (id_habilitacion)
            REFERENCES sgpn.Habilitacion(id)
    );

END;
GO

-- SP Wrapper con verificaciones
CREATE OR ALTER PROCEDURE sgpn.sp_crear_modulo_empleados
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
    WHERE s.name = 'sgpn'
      AND t.name IN (
            'TipoDocumento',
            'Empleado',
            'Especialidad',
            'Titulo',
            --'Habilitacion',
            'Guia',
            'Guardaparque',
            'GuardaparqueAsignado',
            'GuiaEstaEnActividad',
            'GuiaPoseeHabilitacion'
      );

    IF EXISTS (SELECT 1 FROM @tablas_existentes)
    BEGIN
        RAISERROR('No se puede crear el modulo: ya existe al menos una tabla del modulo empleados en el esquema sgpn.', 16, 1);
        RETURN;
    END;


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
        WHERE s.name = 'sgpn'
          AND t.name = d.nombre
    );

    IF EXISTS (SELECT 1 FROM @dependencias_faltantes)
    BEGIN
        RAISERROR('No se puede crear el modulo empleados: faltan tablas necesarias por relaciones.', 16, 1);
        RETURN;
    END;

    EXEC sgpn.crear_tablas_modulo_empleados;
END;
GO

CREATE OR ALTER PROCEDURE sgpn.sp_eliminar_modulo_empleados
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

            DROP TABLE IF EXISTS sgpn.GuiaPoseeHabilitacion;
            DROP TABLE IF EXISTS sgpn.GuiaActividad;
            DROP TABLE IF EXISTS sgpn.GuardaparqueAsignado;

            DROP TABLE IF EXISTS sgpn.Guia;
            DROP TABLE IF EXISTS sgpn.Guardaparque;

            --DROP TABLE IF EXISTS sgpn.Habilitacion;
            DROP TABLE IF EXISTS sgpn.Titulo;
            DROP TABLE IF EXISTS sgpn.Especialidad;

            DROP TABLE IF EXISTS sgpn.Empleado;
            DROP TABLE IF EXISTS sgpn.TipoDocumento;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @mensaje_error VARCHAR(4000);

        SET @mensaje_error = ERROR_MESSAGE();

        RAISERROR(@mensaje_error, 16, 1);
        RETURN;
    END CATCH;
END;
GO

-- Ejecucion
EXEC sgpn.sp_crear_modulo_empleados;
SELECT * FROM sys.tables;
GO

-- Autodestruccion
EXEC sgpn.sp_eliminar_modulo_empleados;
SELECT * FROM sys.tables;
GO