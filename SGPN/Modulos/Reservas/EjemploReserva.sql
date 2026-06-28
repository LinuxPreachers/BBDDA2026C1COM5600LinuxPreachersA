USE LinuxPreachers;
GO

---------------------------------------
-- SPS A EJECUTAR ANTES DE LA PRUEBA
---------------------------------------
--EXEC pagos.sp_crear_forma_pago @nombre = 'Tarjeta de Credito';
--EXEC pagos.sp_crear_punto_venta @nombre = 'Boletería Zona Norte';
--EXEC reservas.sp_crear_estado_item @nombre = 'Reservada', @descripcion = 'Ítem comprado y pendiente de uso.';
--EXEC reservas.sp_crear_estado_item @nombre = 'Cancelada', @descripcion = 'Ítem comprado cancelada.';
--EXEC reservas.sp_crear_motivo_cancelacion @nombre = 'Cliente', @descripcion = 'Cancelado por cliente';

--- Ante la duda: DBCC CHECKIDENT ('pagos.FormaPago', RESEED, 0); Reiniciar los identitys

SELECT * FROM actividades.Actividad
SELECT * FROM actividades.Horario
SELECT * FROM reservas.Reserva
GO

-------------------------------------------------------- 
-- Creación de reserva con pago y ticket factura
--------------------------------------------------------
DECLARE @id_reserva INT;

BEGIN TRY

    SET NOCOUNT ON;

    DECLARE @id_forma_pago TINYINT;
    DECLARE @id_punto_venta SMALLINT;
    DECLARE @entradas reservas.TVP_Entradas;
    DECLARE @participaciones reservas.TVP_Participaciones;

    SELECT @id_forma_pago = id FROM pagos.FormaPago 
    WHERE nombre = 'Tarjeta de credito'

    SELECT @id_punto_venta = id FROM pagos.PuntoVenta 
    WHERE nombre = 'Boleterias del parque'
    
    -- Llenamos el TVP con 3 entradas de ejemplo 
    INSERT INTO @entradas (id_parque, id_tipo_visitante, fecha_acceso, cantidad)
    VALUES 
        (2, 4, CAST(GETDATE() AS DATE), 1),    
        (1, 2, CAST(GETDATE() AS DATE), 1),    
        (1, 2, CAST(GETDATE() AS DATE), 1); 

    INSERT INTO @participaciones(id_horario, fecha_realizacion, cantidad)
    VALUES 
        (1, CAST(GETDATE() AS DATE), 5),    
        (2, CAST(GETDATE() AS DATE), 2);

    EXEC reservas.sp_registrar_reserva_con_pago   
        @entradas = @entradas,
        @participaciones = @participaciones,
        @id_forma_pago = @id_forma_pago,
        @id_punto_venta = @id_punto_venta,
        @id_reserva = @id_reserva OUTPUT;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
        
    PRINT 'ERROR EN EL FLUJO: ' + ERROR_MESSAGE();
END CATCH;

PRINT 'SE GENERÓ LA RESERVA #' + CAST(@id_reserva AS VARCHAR);

-------------------------------------------------------- 
-- Comprobación Visual
--------------------------------------------------------

-- Reserva
SELECT * FROM reservas.Reserva WHERE id = @id_reserva;

-- Entradas
SELECT 
    e.id_item_reserva, 
    e.id_parque,
    e.id_tipo_visitante,
    e.fecha_acceso,
    i.precio, 
    i.id_reserva, 
    ei.nombre AS estado 
FROM reservas.Entrada e
INNER JOIN reservas.ItemReserva i ON i.id = e.id_item_reserva
INNER JOIN reservas.EstadoItem ei ON i.id_estado = ei.id
WHERE i.id_reserva = @id_reserva;

-- Participaciones
SELECT 
    p.id_item_reserva, 
    p.id_horario,
    p.fecha_realizacion,
    i.precio, 
    i.id_reserva, 
    ei.nombre AS estado 
FROM reservas.Participacion p
INNER JOIN reservas.ItemReserva i ON i.id = p.id_item_reserva
INNER JOIN reservas.EstadoItem ei ON i.id_estado = ei.id
WHERE i.id_reserva = @id_reserva;

-- Pago con ticket factura, forma de pago y punto de venta
SELECT 
    p.id AS id_pago, 
    p.fecha_y_hora,
    p.importe,
    fp.nombre AS forma_pago,   
    pv.nombre AS punto_venta
FROM pagos.Pago p
INNER JOIN pagos.FormaPago fp ON p.id_forma_pago = fp.id
INNER JOIN pagos.TicketFactura t ON p.id = t.id_pago
INNER JOIN pagos.PuntoVenta pv ON pv.id = t.id_punto_venta
WHERE id_reserva = @id_reserva;


-------------------------------------------------------- 
-- Ver reservas activas (no canceladas)
--------------------------------------------------------
/*
SELECT * FROM 
reservas.ItemReserva i 
JOIN reservas.Participacion p 
ON i.id = p.id_item_reserva
WHERE i.id_cancelacion IS NULL
AND id_horario = 1

SELECT * FROM actividades.Actividad
SELECT * FROM actividades.Horario
*/

-------------------------------------------------------- 
-- Cancelar reservas (libera cupos)
--------------------------------------------------------
/*
DECLARE @items reservas.TVP_ItemsReserva;

INSERT INTO @items
SELECT id
FROM reservas.ItemReserva
WHERE id_reserva = 1;

EXEC reservas.sp_cancelar_items_reserva
    @items = @items,
    @id_motivo = 1;

SELECT c.id, c.fecha_y_hora, m.descripcion AS motivo 
FROM reservas.Cancelacion c
JOIN reservas.MotivoCancelacion m ON c.id_motivo = m.id;
*/

-------------------------------------------------------- 
-- Registrar reembolso
--------------------------------------------------------
/*
EXEC reservas.sp_registrar_reembolso
    @id_cancelacion = 1,
    @cvu_cuenta_destino = 1234567890123456789012;

SELECT * FROM reservas.Reembolso
*/