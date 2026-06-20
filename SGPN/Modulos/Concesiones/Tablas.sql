/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Creación de tablas módulo concesiones
*/

USE LinuxPreachers;
GO
-- Schema
IF NOT EXISTS ( SELECT 1 FROM sys.schemas WHERE name = 'concesiones' )
BEGIN 
    EXEC('CREATE SCHEMA concesiones'); 
END;
GO

-- Este SP asume que no existe ninguna tabla para el módulo 
CREATE OR ALTER PROCEDURE concesiones.sp_crear_tablas_modulo_concesiones
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE concesiones.ActividadEmpresarial(
        id SMALLINT IDENTITY (1,1),
        nombre VARCHAR (100) NOT NULL,
        descripcion VARCHAR(255) NULL,

        CONSTRAINT PK_ActividadEmpresarial PRIMARY KEY (id)
    );

    CREATE TABLE concesiones.EmpresaConcesionaria(
        id INT IDENTITY (1,1),
        nombre VARCHAR (100) NOT NULL,
        descripcion VARCHAR(255) NULL,
        cuit BIGINT NOT NULL UNIQUE,
        razon_social VARCHAR(100) NOT NULL,
        id_actividad_empresarial SMALLINT NOT NULL,

        CONSTRAINT PK_EmpresaConcesionaria PRIMARY KEY (id),

        CONSTRAINT FK_Empresa_Actividad
            FOREIGN KEY (id_actividad_empresarial)
            REFERENCES concesiones.ActividadEmpresarial(id),

        CONSTRAINT CK_Cuit_Longitud
            CHECK (cuit < 99999999999 AND cuit >10000000000) 

    );

    CREATE TABLE concesiones.Concesion(
        id INT IDENTITY (1,1),
        fecha_inicio DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
        fecha_fin DATE NOT NULL,
        id_empresa_concesionaria INT NOT NULL,
        id_parque INT NOT NULL,
        descripcion VARCHAR(255) NULL,

        CONSTRAINT PK_Concesion PRIMARY KEY (id),

        CONSTRAINT FK_Empresa_Concesion
            FOREIGN KEY (id_empresa_concesionaria)
            REFERENCES concesiones.EmpresaConcesionaria(id),

        CONSTRAINT FK_Empresa_Parque
            FOREIGN KEY (id_parque)
            REFERENCES parques.Parque(id)

    );

    CREATE TABLE concesiones.Canon(
        id INT IDENTITY (1,1),
        periodo DATE NOT NULL, --Se guarda como date, luego se puede llevar a otro formato en vista o consulta
        monto DECIMAL(15,2) NOT NULL,
        fecha_pago DATE NULL,
        fecha_lim_pago DATE NOT NULL,
        id_concesion INT NOT NULL,
        id_forma_pago TINYINT NULL,

        CONSTRAINT PK_Canon PRIMARY KEY (id),

        CONSTRAINT FK_Canon_Concesion
            FOREIGN KEY (id_concesion)
            REFERENCES concesiones.Concesion(id),

       CONSTRAINT FK_Canon_forma_pago
           FOREIGN KEY (id_forma_pago)
           REFERENCES pagos.FormaPago(id)

    );

END;
GO


CREATE OR ALTER PROCEDURE concesiones.sp_crear_modulo_concesiones
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
    WHERE s.name = 'concesiones'
      AND t.name IN (
            'ActividadEmpresarial',
            'EmpresaConcesionaria',
            'Concesion',
            'Canon'
            );

    IF EXISTS (SELECT 1 FROM @tablas_existentes)
    BEGIN
        RAISERROR('No se puede crear el modulo: ya existe al menos una tabla del modulo actividades en el esquema concesiones.', 16, 1);
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
        WHERE s.name = 'pagos'
          AND t.name = d.nombre
    );

    IF EXISTS (SELECT 1 FROM @dependencias_faltantes)
    BEGIN
        RAISERROR('No se puede crear el modulo actividades: faltan tablas necesarias por relaciones (ej. FormaPago).', 16, 1);
        RETURN;
    END;

    -- Si pasamos los controles, ejecutamos la creación
    EXEC concesiones.sp_crear_tablas_modulo_concesiones;
END;
GO

-- SP para destruir el módulo (respetando orden de integridad referencial)
CREATE OR ALTER PROCEDURE concesiones.sp_eliminar_modulo_concesiones
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

            DROP TABLE IF EXISTS concesiones.Canon;
            DROP TABLE IF EXISTS concesiones.Concesion;
            DROP TABLE IF EXISTS concesiones.EmpresaConcesionaria;
            DROP TABLE IF EXISTS concesiones.ActividadEmpresarial;


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
EXEC concesiones.sp_crear_modulo_concesiones;
SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('concesiones') ORDER BY create_date DESC;
GO
*/

-- Autodestruccion (Comentado para evitar ejecución accidental)
/*
EXEC concesiones.sp_eliminar_modulo_concesiones;
SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('concesiones');
GO
*/