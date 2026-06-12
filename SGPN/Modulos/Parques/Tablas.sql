/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Creación de tablas módulo parques
*/

USE LinuxPreachers;
GO

-- Schema
IF NOT EXISTS ( SELECT 1 FROM sys.schemas WHERE name = 'parques' )
BEGIN 
    EXEC('CREATE SCHEMA parques'); 
END;
GO

-- Este SP Asume que no existe ninguna tabla
CREATE OR ALTER PROCEDURE parques.crear_tablas_modulo_parques
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE parques.Region (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,

        CONSTRAINT PK_Region PRIMARY KEY (id)
    );

    CREATE TABLE parques.Provincia (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        id_region INT NOT NULL,

        CONSTRAINT PK_Provincia PRIMARY KEY (id),

        CONSTRAINT FK_Provincia_Region
            FOREIGN KEY (id_region)
            REFERENCES parques.Region(id)
    );

    CREATE TABLE parques.TipoVisitante (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(255) NULL,

        CONSTRAINT PK_TipoVisitante PRIMARY KEY (id)
    );

    CREATE TABLE parques.TipoParque (
        id INT IDENTITY(1,1) NOT NULL,
        descripcion VARCHAR(255) NOT NULL,

        CONSTRAINT PK_TipoParque PRIMARY KEY (id)
    );

    CREATE TABLE parques.Parque (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        superficie_km2 DECIMAL(10,2) NULL,
        latitud DECIMAL(9,6) NULL,
        longitud DECIMAL(9,6) NULL,
        id_tipo_parque INT NOT NULL,

        CONSTRAINT PK_Parque PRIMARY KEY (id),

        CONSTRAINT FK_Parque_TipoParque
            FOREIGN KEY (id_tipo_parque)
            REFERENCES parques.TipoParque(id),

        CONSTRAINT CK_Parque_Superficie
            CHECK (superficie_km2 IS NULL OR superficie_km2 >= 0),

        CONSTRAINT CK_Parque_Latitud
            CHECK (latitud IS NULL OR latitud BETWEEN -90 AND 90),

        CONSTRAINT CK_Parque_Longitud
            CHECK (longitud IS NULL OR longitud BETWEEN -180 AND 180)
    );

    CREATE TABLE parques.EstadisticaVisitantes (
        id INT IDENTITY(1,1) NOT NULL,
        periodo VARCHAR(50) NOT NULL,
        periodo_inicio DATETIME NOT NULL,
        periodo_fin DATETIME NOT NULL,
        cantidad INT NOT NULL,
        id_region INT NOT NULL,

        CONSTRAINT PK_EstadisticaVisitantes PRIMARY KEY (id),

        CONSTRAINT FK_EstadisticaVisitantes_Region
            FOREIGN KEY (id_region)
            REFERENCES parques.Region(id),

        CONSTRAINT CK_EstadisticaVisitantes_Cantidad
            CHECK (cantidad >= 0)
    );

    CREATE TABLE parques.ProvinciaParque (
        id_provincia INT NOT NULL,
        id_parque INT NOT NULL,
        direccion VARCHAR(255) NULL,

        CONSTRAINT PK_ProvinciaParque
            PRIMARY KEY (id_provincia, id_parque),

        CONSTRAINT FK_ProvinciaParque_Provincia
            FOREIGN KEY (id_provincia)
            REFERENCES parques.Provincia(id),

        CONSTRAINT FK_ProvinciaParque_Parque
            FOREIGN KEY (id_parque)
            REFERENCES parques.Parque(id)
    );

    CREATE TABLE parques.ParqueTipoVisitante (
        id_parque INT NOT NULL,
        id_tipo_visitante INT NOT NULL,
        precio DECIMAL(10,2) NOT NULL,

        CONSTRAINT PK_ParqueTipoVisitante
            PRIMARY KEY (id_parque, id_tipo_visitante),

        CONSTRAINT FK_ParqueTipoVisitante_Parque
            FOREIGN KEY (id_parque)
            REFERENCES parques.Parque(id),

        CONSTRAINT FK_ParqueTipoVisitante_TipoVisitante
            FOREIGN KEY (id_tipo_visitante)
            REFERENCES parques.TipoVisitante(id),

        CONSTRAINT CK_ParqueTipoVisitante_Precio
            CHECK (precio >= 0)
    );

END;
GO

-- SP Wrapper con verificaciones
CREATE OR ALTER PROCEDURE parques.sp_crear_modulo_parques
AS
BEGIN

    DECLARE @tablas_existentes TABLE (
        nombre VARCHAR(128)
    );

    INSERT INTO @tablas_existentes (nombre)
    SELECT t.name
    FROM sys.tables t
    INNER JOIN sys.schemas s
        ON s.schema_id = t.schema_id
    WHERE s.name = 'parques'
        AND t.name IN (
            'Region',
            'Provincia',
            'TipoVisitante',
            'TipoParque',
            'Parque',
            'EstadisticaVisitantes',
            'ProvinciaParque',
            'ParqueTipoVisitante',
            'Actividad',
            'Concesion'
    );

    IF EXISTS (SELECT 1 FROM @tablas_existentes)
    BEGIN
        --THROW 50001, 'No se puede crear el modulo: ya existe al menos una tabla del modulo en el esquema parques.', 1;
        RAISERROR('No se puede crear el modulo: ya existe al menos una tabla del modulo en el esquema parques.',16,1);
    END;

    EXEC parques.crear_tablas_modulo_parques;

END;
GO

CREATE OR ALTER PROCEDURE parques.sp_eliminar_modulo_parques
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            DROP TABLE IF EXISTS parques.ParqueTipoVisitante;
            DROP TABLE IF EXISTS parques.ProvinciaParque;
            DROP TABLE IF EXISTS parques.Actividad;
            DROP TABLE IF EXISTS parques.Concesion;
            DROP TABLE IF EXISTS parques.EstadisticaVisitantes;

            DROP TABLE IF EXISTS parques.Parque;
            DROP TABLE IF EXISTS parques.Provincia;

            DROP TABLE IF EXISTS parques.TipoVisitante;
            DROP TABLE IF EXISTS parques.TipoParque;
            DROP TABLE IF EXISTS parques.Region;
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

/*
-- Ejecucion
EXEC parques.sp_crear_modulo_parques;
select * from sys.tables
GO

-- Autodestruccion
EXEC parques.sp_eliminar_modulo_parques;
select * from sys.tables
GO

-- Otra Verif
SELECT * 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'parques';
*/