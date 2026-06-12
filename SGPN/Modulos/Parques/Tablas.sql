USE LinuxPreachers

-- Schema
IF NOT EXISTS ( SELECT 1 FROM sys.schemas WHERE name = 'sgpn' )
BEGIN 
    EXEC('CREATE SCHEMA sgpn'); 
END
GO

-- Este SP Asume que no existe ninguna tabla
CREATE OR ALTER PROCEDURE sgpn.crear_tablas_modulo_parques
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE sgpn.Region (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,

        CONSTRAINT PK_Region PRIMARY KEY (id)
    );

    CREATE TABLE sgpn.Provincia (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        id_region INT NOT NULL,

        CONSTRAINT PK_Provincia PRIMARY KEY (id),

        CONSTRAINT FK_Provincia_Region
            FOREIGN KEY (id_region)
            REFERENCES sgpn.Region(id)
    );

    CREATE TABLE sgpn.TipoVisitante (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(255) NULL,

        CONSTRAINT PK_TipoVisitante PRIMARY KEY (id)
    );

    CREATE TABLE sgpn.TipoParque (
        id INT IDENTITY(1,1) NOT NULL,
        descripcion VARCHAR(255) NOT NULL,

        CONSTRAINT PK_TipoParque PRIMARY KEY (id)
    );

    CREATE TABLE sgpn.Parque (
        id INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        superficie_km2 DECIMAL(10,2) NULL,
        latitud DECIMAL(9,6) NULL,
        longitud DECIMAL(9,6) NULL,
        id_tipo_parque INT NOT NULL,

        CONSTRAINT PK_Parque PRIMARY KEY (id),

        CONSTRAINT FK_Parque_TipoParque
            FOREIGN KEY (id_tipo_parque)
            REFERENCES sgpn.TipoParque(id),

        CONSTRAINT CK_Parque_Superficie
            CHECK (superficie_km2 IS NULL OR superficie_km2 >= 0),

        CONSTRAINT CK_Parque_Latitud
            CHECK (latitud IS NULL OR latitud BETWEEN -90 AND 90),

        CONSTRAINT CK_Parque_Longitud
            CHECK (longitud IS NULL OR longitud BETWEEN -180 AND 180)
    );

    CREATE TABLE sgpn.EstadisticaVisitantes (
        id INT IDENTITY(1,1) NOT NULL,
        periodo VARCHAR(50) NOT NULL,
        periodo_inicio DATETIME NOT NULL,
        periodo_fin DATETIME NOT NULL,
        cantidad INT NOT NULL,
        id_region INT NOT NULL,

        CONSTRAINT PK_EstadisticaVisitantes PRIMARY KEY (id),

        CONSTRAINT FK_EstadisticaVisitantes_Region
            FOREIGN KEY (id_region)
            REFERENCES sgpn.Region(id),

        CONSTRAINT CK_EstadisticaVisitantes_Cantidad
            CHECK (cantidad >= 0)
    );

    CREATE TABLE sgpn.ProvinciaParque (
        id_provincia INT NOT NULL,
        id_parque INT NOT NULL,
        direccion VARCHAR(255) NULL,

        CONSTRAINT PK_ProvinciaParque
            PRIMARY KEY (id_provincia, id_parque),

        CONSTRAINT FK_ProvinciaParque_Provincia
            FOREIGN KEY (id_provincia)
            REFERENCES sgpn.Provincia(id),

        CONSTRAINT FK_ProvinciaParque_Parque
            FOREIGN KEY (id_parque)
            REFERENCES sgpn.Parque(id)
    );

    CREATE TABLE sgpn.ParqueTipoVisitante (
        id_parque INT NOT NULL,
        id_tipo_visitante INT NOT NULL,
        precio DECIMAL(10,2) NOT NULL,

        CONSTRAINT PK_ParqueTipoVisitante
            PRIMARY KEY (id_parque, id_tipo_visitante),

        CONSTRAINT FK_ParqueTipoVisitante_Parque
            FOREIGN KEY (id_parque)
            REFERENCES sgpn.Parque(id),

        CONSTRAINT FK_ParqueTipoVisitante_TipoVisitante
            FOREIGN KEY (id_tipo_visitante)
            REFERENCES sgpn.TipoVisitante(id),

        CONSTRAINT CK_ParqueTipoVisitante_Precio
            CHECK (precio >= 0)
    );

END;
GO

-- SP Wrapper con verificaciones
CREATE OR ALTER PROCEDURE sgpn.sp_crear_modulo_parques
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
    WHERE s.name = 'sgpn'
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
        --THROW 50001, 'No se puede crear el modulo: ya existe al menos una tabla del modulo en el esquema sgpn.', 1;
        RAISERROR('No se puede crear el modulo: ya existe al menos una tabla del modulo en el esquema sgpn.',16,1);
    END;

    EXEC sgpn.crear_tablas_modulo_parques;

END;
GO

CREATE OR ALTER PROCEDURE sgpn.sp_eliminar_modulo_parques
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            DROP TABLE IF EXISTS sgpn.ParqueTipoVisitante;
            DROP TABLE IF EXISTS sgpn.ProvinciaParque;
            DROP TABLE IF EXISTS sgpn.Actividad;
            DROP TABLE IF EXISTS sgpn.Concesion;
            DROP TABLE IF EXISTS sgpn.EstadisticaVisitantes;

            DROP TABLE IF EXISTS sgpn.Parque;
            DROP TABLE IF EXISTS sgpn.Provincia;

            DROP TABLE IF EXISTS sgpn.TipoVisitante;
            DROP TABLE IF EXISTS sgpn.TipoParque;
            DROP TABLE IF EXISTS sgpn.Region;
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
EXEC sgpn.sp_crear_modulo_parques;
select * from sys.tables
GO

-- Autodestruccion
EXEC sgpn.sp_eliminar_modulo_parques;
select * from sys.tables
GO

-- Otra Verif
SELECT * 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'sgpn';
*/