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
CREATE OR ALTER PROCEDURE sgpn.sp_crear_tablas_modulo_pagos
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE sgpn.FormaPago(
        id INT IDENTITY (1,1),
        nombre VARCHAR(100) NOT NULL,
        estado BIT DEFAULT 1 NOT NULL,

        CONSTRAINT PK_FormaPago PRIMARY KEY (id)
    );

    CREATE TABLE sgpn.Pago(
        id INT IDENTITY (1,1),
        fecha_y_hora DATETIME NOT NULL DEFAULT GETDATE(),
        id_reserva INT NOT NULL, -- REVISAR CON DER OPCIONALIDAD ( si es un pago de canon, id_reserva sera NULL)
        id_forma_pago INT NOT NULL,
        importe DECIMAL(15,2) NOT NULL,

        CONSTRAINT PK_Pago PRIMARY KEY (id),

        CONSTRAINT FK_Pago_Reserva
            FOREIGN KEY (id_reserva)
            REFERENCES sgpn.Reserva(id),

        CONSTRAINT FK_Pago_FormaPago
            FOREIGN KEY (id_forma_pago)
            REFERENCES sgpn.FormaPago(id),

        CONSTRAINT CK_importe
        CHECK (importe > 0) 

       );

    CREATE TABLE sgpn.PuntoVenta(
        id INT IDENTITY (1,1),
        nombre VARCHAR(100) NULL,
        estado BIT DEFAULT 1 NOT NULL,

        CONSTRAINT PK_PuntoVenta PRIMARY KEY (id)
    );

    CREATE TABLE sgpn.TicketFactura(
        id INT IDENTITY (1,1),
        fecha_y_hora DATETIME NOT NULL DEFAULT GETDATE(),
        id_punto_venta INT NOT NULL,
        id_pago INT NOT NULL,

        CONSTRAINT PK_TicketFactura PRIMARY KEY (id),

        CONSTRAINT FK_TicketFactura_PuntoVenta
            FOREIGN KEY (id_punto_venta)
            REFERENCES sgpn.Reserva(id),

        CONSTRAINT FK_TicketFactura_Pago
            FOREIGN KEY (id_pago)
            REFERENCES sgpn.Pago(id)

       );

END;
GO

-- SP Wrapper con verificaciones
CREATE OR ALTER PROCEDURE sgpn.sp_crear_modulo_pagos
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
            'FormaPago',
            'Pago',
            'PuntoVenta',
            'TicketFactura'
            );

    IF EXISTS (SELECT 1 FROM @tablas_existentes)
    BEGIN
        RAISERROR('No se puede crear el modulo: ya existe al menos una tabla del modulo actividades en el esquema sgpn.', 16, 1);
        RETURN;
    END;

    DECLARE @dependencias_faltantes TABLE (
        nombre VARCHAR(128)
    );

    -- 2. Verificamos que las tablas externas necesarias ya estén creadas (en este caso: Reserva)
    INSERT INTO @dependencias_faltantes (nombre)
    SELECT d.nombre
    FROM (
        VALUES
            ('Reserva')
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
        RAISERROR('No se puede crear el modulo actividades: faltan tablas necesarias por relaciones (ej. Reserva).', 16, 1);
        RETURN;
    END;

    -- Si pasamos los controles, ejecutamos la creación
    EXEC sgpn.sp_crear_tablas_modulo_pagos;
END;
GO

-- SP para destruir el módulo (respetando orden de integridad referencial)
CREATE OR ALTER PROCEDURE sgpn.sp_eliminar_modulo_pagos
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

            DROP TABLE IF EXISTS sgpn.TicketFactura;
            DROP TABLE IF EXISTS sgpn.PuntoVenta;
            DROP TABLE IF EXISTS sgpn.Pago;
            DROP TABLE IF EXISTS sgpn.FormaPago;


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
EXEC sgpn.sp_crear_modulo_pagos;
SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('sgpn') ORDER BY create_date DESC;
GO
*/

-- Autodestruccion (Comentado para evitar ejecución accidental)
/*
EXEC sgpn.sp_eliminar_modulo_pagos;
SELECT * FROM sys.tables WHERE schema_id = SCHEMA_ID('sgpn');
GO
*/
