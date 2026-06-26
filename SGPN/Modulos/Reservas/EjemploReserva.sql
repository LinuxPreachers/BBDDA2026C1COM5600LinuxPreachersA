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

BEGIN TRY
    BEGIN TRANSACTION;

    ------------------------------------------------------
    -- 1. Preparación de Datos Maestros (Módulo Pagos)
    -----------------------------------------------------
    
    -- Corrección: Declaramos primero y asignamos después con SET
    DECLARE @id_forma_pago TINYINT;
    DECLARE @id_punto_venta SMALLINT;

    SET @id_forma_pago = (SELECT TOP 1 id FROM pagos.FormaPago WHERE nombre = 'Tarjeta de Credito' ORDER BY id DESC);
    SET @id_punto_venta = (SELECT TOP 1 id FROM pagos.PuntoVenta WHERE nombre = 'Boleteria Zona Norte' ORDER BY id DESC);

    ------------------------------------------------------
    -- 2. Declaración de Tipos de Tabla (TVP) para la Reserva
    ------------------------------------------------------
    DECLARE @lista_entradas reservas.TVP_Entradas;
    DECLARE @lista_participaciones reservas.TVP_Participaciones;

    -- Llenamos el TVP con 3 entradas de ejemplo 
    INSERT INTO @lista_entradas (id_parque, id_tipo_visitante, fecha_acceso, cantidad)
    VALUES 
        (2, 4, CAST(GETDATE() AS DATE), 1),    
        (1, 2, CAST(GETDATE() AS DATE), 1),    
        (1, 2, CAST(GETDATE() AS DATE), 1); 

    INSERT INTO @lista_participaciones(id_horario, fecha_realizacion, cantidad)
    VALUES 
        (1, CAST(GETDATE() AS DATE), 5),    
        (2, CAST(GETDATE() AS DATE), 2);
    ------------------------------------------------------
    -- 3. Generación de la Reserva
    ------------------------------------------------------
    DECLARE @id_reserva_generada INT;

    EXEC reservas.sp_registrar_reserva        
        @entradas = @lista_entradas,
        @participaciones = @lista_participaciones,
        @id_reserva = @id_reserva_generada OUTPUT;

    ------------------------------------------------------
    -- 4. Registro del Pago
    ------------------------------------------------------
    DECLARE @fecha_operacion DATETIME = GETDATE();
    DECLARE @importe_total DECIMAL(15,2);
    
    -- Calculamos el monto total para el pago
    SELECT @importe_total = ISNULL(SUM(precio), 0)
    FROM reservas.ItemReserva
    WHERE id_reserva = @id_reserva_generada;

    EXEC pagos.sp_crear_pago        
        @fecha_y_hora = @fecha_operacion,
        @id_reserva = @id_reserva_generada,
        @id_forma_pago = @id_forma_pago,
        @importe = @importe_total;

    -- Corrección: Separación de DECLARE y SET para la subconsulta
    DECLARE @id_pago_generado INT;
    
    SET @id_pago_generado = (
        SELECT TOP 1 id 
        FROM pagos.Pago 
        WHERE id_reserva = @id_reserva_generada 
        ORDER BY id DESC
    );

    ------------------------------------------------------
    -- 5. Emisión del Ticket Factura
    ------------------------------------------------------
    EXEC pagos.sp_crear_ticket_factura        
        @fecha_y_hora = @fecha_operacion,
        @id_punto_venta = @id_punto_venta,
        @id_pago = @id_pago_generado;

    COMMIT TRANSACTION;
    PRINT 'Éxito: Se generó la Reserva #' + CAST(@id_reserva_generada AS VARCHAR) + ' y su Ticket Factura correspondiente.';

END TRY
BEGIN CATCH
    -- Corrección: Espaciado correcto del bloque CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
        
    PRINT 'Error en el flujo: ' + ERROR_MESSAGE();
END CATCH;
GO

-------------------------------------------------------- 
-- 6. Comprobación Visual
--------------------------------------------------------
-- Corrección: Separamos las declaraciones de las subconsultas de asignación
DECLARE @id_reserva_generada_res INT;
DECLARE @id_pago_generado_res INT;
DECLARE @id_ticket_generado_res INT;

SET @id_reserva_generada_res = (SELECT TOP 1 id FROM reservas.Reserva ORDER BY id DESC);
SET @id_pago_generado_res = (SELECT TOP 1 id FROM pagos.Pago ORDER BY id DESC);
SET @id_ticket_generado_res = (SELECT TOP 1 id FROM pagos.TicketFactura ORDER BY id DESC);

SELECT * FROM reservas.Reserva WHERE id = @id_reserva_generada_res;
SELECT * FROM pagos.Pago WHERE id = @id_pago_generado_res;
SELECT * FROM pagos.TicketFactura WHERE id_pago = @id_ticket_generado_res;
GO

SELECT * FROM reservas.Reserva;
SELECT * FROM pagos.Pago;
SELECT * FROM pagos.TicketFactura;
GO

-------------------------------------------------------- 
-- 7. Ver reservas activas (no canceladas)
--------------------------------------------------------
SELECT * FROM 
reservas.ItemReserva i 
JOIN reservas.Participacion p 
ON i.id = p.id_item_reserva
WHERE i.id_cancelacion IS NULL
-- AND id_horario = 1

SELECT * FROM actividades.Actividad
SELECT * FROM actividades.Horario

-------------------------------------------------------- 
-- 8. Cancelar reservas (libera cupos)
--------------------------------------------------------
DECLARE @items reservas.TVP_ItemsReserva;

INSERT INTO @items
SELECT id
FROM reservas.ItemReserva
WHERE id_reserva = 1;

EXEC reservas.sp_cancelar_items_reserva
    @items = @items,
    @id_motivo = 1,
    @id_cancelacion = NULL