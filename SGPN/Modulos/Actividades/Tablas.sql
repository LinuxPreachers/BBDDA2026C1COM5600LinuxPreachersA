/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Creación de tablas módulo actividades
*/

USE LinuxPreachers;
GO

-- Schema
IF NOT EXISTS ( SELECT 1 FROM sys.schemas WHERE name = 'actividades' )
BEGIN 
    EXEC('CREATE SCHEMA actividades'); 
END;
GO

-- Este SP asume que no existe ninguna tabla para el módulo actividades
CREATE OR ALTER PROCEDURE actividades.sp_crear_tablas_modulo_actividades
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE actividades.TipoActividad (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,

        CONSTRAINT PK_TipoActividad PRIMARY KEY (id)
    );

    CREATE TABLE actividades.Habilitacion (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(255) NULL,

        CONSTRAINT PK_Habilitacion PRIMARY KEY (id)
    );

    CREATE TABLE actividades.Actividad (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(255) NULL,
        cupo_maximo INT NOT NULL,
        duracion_minutos INT NOT NULL,
        precio DECIMAL(20,4) NOT NULL,
        id_parque INT NOT NULL,
        id_tipo_actividad INT NOT NULL,

        CONSTRAINT PK_Actividad PRIMARY KEY (id),

        CONSTRAINT FK_Actividad_Parque
            FOREIGN KEY (id_parque)
            REFERENCES parques.Parque(id),

        CONSTRAINT FK_Actividad_TipoActividad
            FOREIGN KEY (id_tipo_actividad)
            REFERENCES actividades.TipoActividad(id),
            
        CONSTRAINT CK_Actividad_ValoresPositivos
            CHECK (cupo_maximo > 0 AND duracion_minutos > 0 AND precio >= 0)
    );

    CREATE TABLE actividades.Horario (
        id INT IDENTITY(1,1) NOT NULL,
        hora_inicio TIME NOT NULL,
        hora_fin TIME NOT NULL,
        dia_semana TINYINT NOT NULL, -- Se asume un valor numérico (1=Lunes, 7=Domingo)
        fecha_vigencia_ini DATE NOT NULL,
        fecha_vigencia_fin DATE NULL,
        visible BIT NOT NULL DEFAULT 1,
        id_actividad INT NOT NULL,

        CONSTRAINT PK_Horario PRIMARY KEY (id),

        CONSTRAINT FK_Horario_Actividad
            FOREIGN KEY (id_actividad)
            REFERENCES actividades.Actividad(id),

        CONSTRAINT CK_Horario_RangoFechas
            CHECK (fecha_vigencia_fin IS NULL OR fecha_vigencia_fin >= fecha_vigencia_ini),
            
        CONSTRAINT CK_Horario_RangoHoras
            CHECK (hora_fin > hora_inicio),
            
        CONSTRAINT CK_Horario_DiaSemana
            CHECK (dia_semana BETWEEN 1 AND 7)
    );

    CREATE TABLE actividades.HabilitacionRegulaActividad (
        id_habilitacion INT NOT NULL,
        id_actividad INT NOT NULL,

        CONSTRAINT PK_HabilitacionRegulaActividad 
            PRIMARY KEY (id_habilitacion, id_actividad),

        CONSTRAINT FK_HabilitacionRegulaActividad_Habilitacion
            FOREIGN KEY (id_habilitacion)
            REFERENCES actividades.Habilitacion(id),

        CONSTRAINT FK_HabilitacionRegulaActividad_Actividad
            FOREIGN KEY (id_actividad)
            REFERENCES actividades.Actividad(id)
    );

END;
GO

-- SP Wrapper con verificaciones
CREATE OR ALTER PROCEDURE actividades.sp_crear_modulo_actividades
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @tablas_existentes TABLE (
        nombre VARCHAR(128)
    );

    -- 1. Verificamos que ninguna de las tablas a crear exista previamente
    INSERT INTO @tablas_existentes (nombre)
    SELECT t.name
    FROM sys.tables t
    INNER JOIN sys.schemas s
        ON s.schema_id = t.schema_id
    WHERE s.name = 'actividades'
      AND t.name IN (
            'TipoActividad',
            'Habilitacion',
            'Actividad',
            'Horario',
            'HabilitacionRegulaActividad'
      );

    IF EXISTS (SELECT 1 FROM @tablas_existentes)
    BEGIN
        ;THROW 50000,'No se puede crear el modulo: ya existe al menos una tabla del modulo actividades en el esquema actividades.',1;
    END 
    DECLARE @dependencias_faltantes TABLE (
        nombre VARCHAR(128)
    );

    -- 2. Verificamos que las tablas externas necesarias ya estén creadas (en este caso: Parque)
    INSERT INTO @dependencias_faltantes (nombre)
    SELECT d.nombre
    FROM (
        VALUES
            ('Parque')
    ) AS d(nombre)
    WHERE NOT EXISTS (
        SELECT 1
        FROM sys.tables t
        INNER JOIN sys.schemas s
            ON s.schema_id = t.schema_id
        WHERE s.name = 'parques'
          AND t.name = d.nombre
    );

    IF EXISTS (SELECT 1 FROM @dependencias_faltantes)
    BEGIN
        ;THROW 50001,'No se puede crear el modulo actividades: faltan tablas necesarias por relaciones (ej. Parque).', 1;
    END

    -- Si pasamos los controles, ejecutamos la creación
    EXEC actividades.sp_crear_tablas_modulo_actividades;
END;
GO

-- SP para destruir el módulo (respetando orden de integridad referencial)
CREATE OR ALTER PROCEDURE actividades.sp_eliminar_modulo_actividades
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

            -- 1. Eliminar relaciones dependientes
            DROP TABLE IF EXISTS actividades.HabilitacionRegulaActividad;
            DROP TABLE IF EXISTS actividades.Horario;
            
            -- 2. Eliminar entidades dependientes de tipos
            DROP TABLE IF EXISTS actividades.Actividad;
            
            -- 3. Eliminar entidades maestras o catálogos
            DROP TABLE IF EXISTS actividades.TipoActividad;
            DROP TABLE IF EXISTS actividades.Habilitacion;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @mensaje_error VARCHAR(400);

        SET @mensaje_error = ERROR_MESSAGE();

        THROW 50002,@mensaje_error, 1;
        RETURN;
    END CATCH;
END;
GO



-- Ejecucion (Comentado para evitar ejecución accidental si copiás el script de corrido)
/*
EXEC actividades.sp_crear_modulo_actividades;
SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('actividades');
GO
*/

-- Autodestruccion (Comentado para evitar ejecución accidental)
/*
EXEC actividades.sp_eliminar_modulo_actividades;
SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('actividades');
GO
*/