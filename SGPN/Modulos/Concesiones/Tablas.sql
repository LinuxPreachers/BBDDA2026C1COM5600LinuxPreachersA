/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Creación de tablas módulo reservas
*/

USE LinuxPreachers
-- Schema
IF NOT EXISTS ( SELECT 1 FROM sys.schemas WHERE name = 'sgpn' )
BEGIN 
EXEC('CREATE SCHEMA sgpn'); 
END;
GO

-- Este SP asume que no existe ninguna tabla para el módulo 
CREATE OR ALTER PROCEDURE sgpn.sp_crear_tablas_modulo_concesiones
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE sgpn.ActividadEmpresarial(
        id INT IDENTITY (1,1),
        nombre VARCHAR (100) NOT NULL,
        descripcion VARCHAR(255) NULL,

        CONSTRAINT PK_ActividadEmpresarial PRIMARY KEY (id)
    );

    CREATE TABLE sgpn.EmpresaConcesionaria(
        id INT IDENTITY (1,1),
        nombre VARCHAR (100) NOT NULL,
        descripcion VARCHAR(255) NULL,
        cuit BIGINT NOT NULL UNIQUE,
        razon_social VARCHAR(100) NOT NULL UNIQUE,
        id_actividad_empresarial INT NOT NULL,

        CONSTRAINT PK_EmpresaConcesionaria PRIMARY KEY (id),

        CONSTRAINT FK_Empresa_Actividad
            FOREIGN KEY (id_actividad_empresarial)
            REFERENCES sgpn.ActividadEmpresarial(id),

        CONSTRAINT CK_Cuit_Longitud
            CHECK (cuit < 99999999999 AND cuit >10000000000) -- Investigar digito verificador

    );

    CREATE TABLE sgpn.Concesion(
        id INT IDENTITY (1,1),
        fecha_inicio DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
        fecha_fin DATE NOT NULL,
        id_empresa_concesionaria INT NOT NULL,
        id_parque INT NOT NULL,
        descripcion VARCHAR(255) NULL,

        CONSTRAINT PK_Concesion PRIMARY KEY (id),

        CONSTRAINT FK_Empresa_Concesion
            FOREIGN KEY (id_empresa_concesionaria)
            REFERENCES sgpn.EmpresaConcesionaria(id),

        CONSTRAINT FK_Empresa_Parque
            FOREIGN KEY (id_parque)
            REFERENCES sgpn.Parque(id)

    );

    CREATE TABLE sgpn.Canon(
        id INT IDENTITY (1,1),
        periodo DATE NOT NULL, --Se guarda como date, luego se puede llevar a otro formato en vista o consulta
        monto DECIMAL(15,2) NOT NULL,
        fecha_pago DATE NULL,
        id_concesion INT NOT NULL,
        id_forma_pago INT NULL,

        CONSTRAINT PK_Canon PRIMARY KEY (id),

        CONSTRAINT FK_Canon_Concesion
            FOREIGN KEY (id_concesion)
            REFERENCES sgpn.Concesion(id),

       CONSTRAINT FK_Canon_forma_pago
           FOREIGN KEY (id_concesion)
           REFERENCES sgpn.Concesion(id)

    );

END;
GO

-- SP Wrapper con verificaciones
CREATE OR ALTER PROCEDURE sgpn.sp_crear_modulo_concesiones
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
    WHERE s.name = 'sgpn'
      AND t.name IN (
            'ActividadEmpresarial',
            'EmpresaConcesionaria',
            'Concesion',
            'Canon'
            );

    IF EXISTS (SELECT 1 FROM @tablas_existentes)
    BEGIN
        RAISERROR('No se puede crear el modulo: ya existe al menos una tabla del modulo actividades en el esquema sgpn.', 16, 1);
        RETURN;
    END;

    DECLARE @dependencias_faltantes TABLE (
        nombre VARCHAR(128)
    );

    -- 2. Verificamos que las tablas externas necesarias ya estén creadas (en este caso: FormaPago)
    INSERT INTO @dependencias_faltantes (nombre)
    SELECT d.nombre
    FROM (
        VALUES
            ('FormaPago')
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
        RAISERROR('No se puede crear el modulo actividades: faltan tablas necesarias por relaciones (ej. FormaPago).', 16, 1);
        RETURN;
    END;

    -- Si pasamos los controles, ejecutamos la creación
    EXEC sgpn.sp_crear_tablas_modulo_concesiones;
END;
GO

-- SP para destruir el módulo (respetando orden de integridad referencial)
CREATE OR ALTER PROCEDURE sgpn.sp_eliminar_modulo_concesiones
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

            DROP TABLE IF EXISTS sgpn.Canon;
            DROP TABLE IF EXISTS sgpn.Concesion;
            DROP TABLE IF EXISTS sgpn.EmpresaConcesionaria;
            DROP TABLE IF EXISTS sgpn.ActividadEmpresarial;


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

-- Ejecucion (Comentado para evitar ejecución accidental si copiás el script de corrido)
/*
EXEC sgpn.sp_crear_modulo_concesiones;
SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('sgpn') ORDER BY create_date DESC;
GO
*/

-- Autodestruccion (Comentado para evitar ejecución accidental)
/*
EXEC sgpn.sp_eliminar_modulo_concesiones;
SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('sgpn');
GO
*/