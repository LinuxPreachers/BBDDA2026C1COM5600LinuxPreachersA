/*a
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
            THROW 60001, 'El nombre ingresado para la Forma de Pago no es válido.', 1;
            
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
        IF NOT EXISTS (SELECT 1 FROM pagos.FormaPago WHERE id = @id)
            THROW 60002, 'La Forma de Pago con el ID provisto no existe.', 1;

        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            THROW 60003, 'El nombre ingresado para la Forma de Pago no es válido.', 2;

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
            THROW 60004, 'La forma de Pago con el ID provisto no existe.', 1;

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
            THROW 60011, 'El nombre ingresado para el Punto de Venta no es válido.', 1;
            
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
        IF NOT EXISTS (SELECT 1 FROM pagos.PuntoVenta WHERE id = @id)
            THROW 60012, 'El Punto de Venta con el ID provisto no existe.', 1;

        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            THROW 60013, 'El nombre ingresado para el Punto de Venta no es válido.', 2;

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
CREATE OR ALTER PROCEDURE pagos.sp_eliminar_forma_pago
    @id SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM pagos.FormaPago WHERE id = @id)
            THROW 60014, 'La forma de Pago con el ID provisto no existe.', 1;

        UPDATE pagos.FormaPago
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
        IF( @fecha_y_hora > GETDATE())
            THROW 60020, 'La fecha hora de pago es mayor a la actual', 1;

        IF( @id_reserva NOT IN(SELECT id FROM reserva.Reserva) )
            THROW 60021, 'No existe la reserva', 1;

        IF( @id_forma_pago NOT IN(SELECT id FROM pagos.FormaPago WHERE estado = 1) )
            THROW 60022, 'Forma de pago no válida', 1;

        IF( @importe < 0 )
            THROW 60023, 'Importe de Pago negativo', 1;

        IF( @importe <> (SELECT SUM(precio) FROM reserva.ItemReserva WHERE id_reserva = @id_reserva) )
            THROW 60024, 'Importe incorrecto', 1;
            
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
        IF( @fecha_y_hora > GETDATE())
            THROW 60030, 'La fecha hora de ticket es mayor a la actual', 1;

        IF( @id_punto_venta NOT IN(SELECT id FROM pagos.PuntoVenta WHERE estado = 1) )
            THROW 60031, 'No existe el punto de venta', 1;

        IF( @id_pago NOT IN(SELECT id FROM pagos.Pago) )
            THROW 60032, 'No existe el pago', 1;
            
        INSERT INTO pagos.TicketFactura(fecha_y_hora,id_punto_venta,id_pago)
        VALUES (@fecha_y_hora,@id_punto_venta,@id_pago);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Por logica de negocio no se permiten modificar ni eliminar Tickets Factura.