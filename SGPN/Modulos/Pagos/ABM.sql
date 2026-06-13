/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Creación de SP ABM módulo pagos
*/

USE LinuxPreachers;
GO

-- ---------------------------------------------
-- 1. ABM: FormaPago
-- ---------------------------------------------

-- Alta
CREATE OR ALTER PROCEDURE pagos.sp_crear_forma_pago
    @nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            THROW 50500, 'El nombre ingresado para la Forma de Pago no es válido.', 1;
            
        INSERT INTO pagos.FormaPago(nombre)
        VALUES (@nombre);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE pagos.sp_modificar_forma_pago
    @id SMALLINT,
    @nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @errores VARCHAR(4000) = '';

        IF NOT EXISTS (SELECT 1 FROM pagos.FormaPago WHERE id = @id)
            SET @errores = @errores + 'La Forma de Pago con el ID provisto no existe. ';

        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            SET @errores = @errores + 'El nombre ingresado para la Forma de Pago no es válido. ';

        IF LEN(@errores) > 0
            THROW 50501, @errores, 1;

        UPDATE pagos.FormaPago
        SET nombre = @nombre
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja
CREATE OR ALTER PROCEDURE pagos.sp_eliminar_forma_pago
    @id SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM pagos.FormaPago WHERE id = @id)
            THROW 50503, 'La forma de Pago con el ID provisto no existe.', 1;

        UPDATE pagos.FormaPago SET estado = 0  WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- ---------------------------------------------
-- 2. ABM: PuntoVenta
-- ---------------------------------------------

-- Alta
CREATE OR ALTER PROCEDURE pagos.sp_crear_punto_venta
    @nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            THROW 50504, 'El nombre ingresado para el Punto de Venta no es válido.', 1;
            
        INSERT INTO pagos.PuntoVenta (nombre)
        VALUES (@nombre);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE pagos.sp_modificar_punto_venta
    @id SMALLINT,
    @nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @errores VARCHAR(4000) = '';

        IF NOT EXISTS (SELECT 1 FROM pagos.PuntoVenta WHERE id = @id)
            SET @errores = @errores + 'El Punto de Venta con el ID provisto no existe. ';

        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            SET @errores = @errores + 'El nombre ingresado para el Punto de Venta no es válido. ';

        IF LEN(@errores) > 0
            THROW 50505, @errores, 1;

        UPDATE pagos.PuntoVenta
        SET nombre = @nombre
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja
CREATE OR ALTER PROCEDURE pagos.sp_eliminar_punto_venta
    @id SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM pagos.PuntoVenta WHERE id = @id)
            THROW 50507, 'La forma de Pago con el ID provisto no existe.', 1;

        UPDATE pagos.PuntoVenta
        SET estado = 0  
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO
-- ---------------------------------------------
-- 3.  Pago
-- ---------------------------------------------

-- Alta

CREATE OR ALTER PROCEDURE pagos.sp_crear_pago
    @fecha_y_hora DATETIME,
    @id_reserva INT,
    @id_forma_pago SMALLINT,
    @importe DECIMAL(15,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @errores VARCHAR(4000) = '';

        IF( @fecha_y_hora > GETDATE())
            SET @errores = @errores + 'La fecha hora de pago es mayor a la actual. ';

        IF( @id_reserva NOT IN(SELECT id FROM reservas.Reserva) )
            SET @errores = @errores + 'No existe la reserva. ';

        IF( @id_forma_pago NOT IN(SELECT id FROM pagos.FormaPago WHERE estado = 1) )
            SET @errores = @errores + 'Forma de pago no válida. ';

        IF( @importe < 0 )
            SET @errores = @errores + 'Importe de Pago negativo. ';

        IF LEN(@errores) > 0
            THROW 50508, @errores, 1;

        INSERT INTO pagos.Pago(fecha_y_hora,id_reserva,id_forma_pago,importe)
        VALUES (@fecha_y_hora,@id_reserva,@id_forma_pago,@importe);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Por logica de negocio no se permiten modificar ni eliminar pagos.

-- ---------------------------------------------
-- 4.  TicketFactura
-- ---------------------------------------------

-- Alta

CREATE OR ALTER PROCEDURE pagos.sp_crear_ticket_factura
    @fecha_y_hora DATETIME,
    @id_punto_venta SMALLINT,
    @id_pago INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @errores VARCHAR(4000) = '';

        IF( @fecha_y_hora > GETDATE())
            SET @errores = @errores + 'La fecha hora de ticket es mayor a la actual. ';

        IF( @id_punto_venta NOT IN(SELECT id FROM pagos.PuntoVenta WHERE estado = 1) )
            SET @errores = @errores + 'No existe el punto de venta. ';

        IF( @id_pago NOT IN(SELECT id FROM pagos.Pago) )
            SET @errores = @errores + 'No existe el pago. ';
            
        IF LEN(@errores) > 0
            THROW 50513, @errores, 1;

        INSERT INTO pagos.TicketFactura(fecha_y_hora,id_punto_venta,id_pago)
        VALUES (@fecha_y_hora,@id_punto_venta,@id_pago);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Por logica de negocio no se permiten modificar ni eliminar Tickets Factura.