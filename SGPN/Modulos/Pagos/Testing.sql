--------------------------------------------------------------------------------
-- PRUEBA 1: ALTA EXITOSA PARA LAS 4 TABLAS
--------------------------------------------------------------------------------

DECLARE @id_forma_pago_test INT;

PRINT  '>>> PRUEBA 1: Alta Exitosa de FormaPago';
BEGIN TRY
    EXEC pagos.sp_crear_forma_pago
        @nombre = 'Efectivo' 

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_forma_pago_test = id FROM pagos.FormaPago ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.FormaPago WHERE id = @id_forma_pago_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
-----------------------------------------------------------

DECLARE @id_pago_test INT;
PRINT  '>>> PRUEBA 2: Alta Exitosa de Pago';
BEGIN TRY
    --Se necesita una reserva
   --Todavia no implementado EXEC reservas.sp_crear_reserva
   INSERT INTO reservas.Reserva (fecha_y_hora) VALUES (GETDATE()); --Borrar despues

    EXEC pagos.sp_crear_pago    
    @fecha_y_hora = '2026-06-12 17:59:30', 
    @id_reserva = 1, 
    @id_forma_pago = 1,
    @importe = 100.10;

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_pago_test = id FROM pagos.Pago ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Pago creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.Pago WHERE id = @id_pago_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------
DECLARE @id_punto_venta_test INT;

PRINT  '>>> PRUEBA 3: Alta Exitosa de PuntoVenta';
BEGIN TRY
    EXEC pagos.sp_crear_punto_venta
        @nombre = 'Mostrador' 

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_punto_venta_test = id FROM pagos.PuntoVenta ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - PuntoVenta creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.PuntoVenta WHERE id = @id_punto_venta_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
------------------------------------------------------------

DECLARE @id_ticket_factura_test INT;

PRINT  '>>> PRUEBA 4: Alta Exitosa de TicketFactura';
BEGIN TRY

    EXEC pagos.sp_crear_ticket_factura
    @fecha_y_hora = '2026-06-12 17:59:30', 
    @id_punto_venta = 1, 
    @id_pago = 1;

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_ticket_factura_test = id FROM pagos.TicketFactura  ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - TicketFactura creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.TicketFactura WHERE id = @id_ticket_factura_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
--------------------------------------------------------

--------------------------------------------------------------------------------
-- PRUEBA 2: ERRORES FORMA PAGO
--------------------------------------------------------------------------------

DECLARE @id_forma_pago_test INT;

PRINT  '>>> Alta con nombre nulo de FormaPago';
BEGIN TRY
    EXEC pagos.sp_crear_forma_pago
        @nombre = ''  --ERROR NOMBRE NULL

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_forma_pago_test = id FROM pagos.FormaPago ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.FormaPago WHERE id = @id_forma_pago_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
--------------------------------------------------------------------------------

DECLARE @id_forma_pago_test INT;

PRINT  '>>> Modificacion con id inexistente de FormaPago';
BEGIN TRY
    EXEC pagos.sp_modificar_forma_pago
        @nombre = 'nombre',
        @id = 0 --ERROR ID NO EXISTE

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_forma_pago_test = id FROM pagos.FormaPago ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.FormaPago WHERE id = @id_forma_pago_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
--------------------------------------------------------------------------------

DECLARE @id_forma_pago_test INT;

PRINT  '>>> Modificacion con id inexistente de FormaPago';
BEGIN TRY
    EXEC pagos.sp_modificar_forma_pago
        @nombre = 'nombre',
        @id = 0 --ERROR ID NO EXISTE

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_forma_pago_test = id FROM pagos.FormaPago ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.FormaPago WHERE id = @id_forma_pago_test;

END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
--------------------------------------------------------------------------------

DECLARE @id_forma_pago_test INT;

PRINT  '>>> Modificacion con nombre nulo de FormaPago';
BEGIN TRY
    EXEC pagos.sp_modificar_forma_pago
        @nombre = '' , --ERROR NOMBRE NULL
        @id = 1

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_forma_pago_test = id FROM pagos.FormaPago ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.FormaPago WHERE id = @id_forma_pago_test;
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------

DECLARE @id_forma_pago_test INT;

PRINT  '>>> BAja con id no existente de FormaPago';
BEGIN TRY
    EXEC pagos.sp_eliminar_forma_pago
        @id = 0 --ERROR ID NO ENCONTRADO

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_forma_pago_test = id FROM pagos.FormaPago ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.FormaPago WHERE id = @id_forma_pago_test;
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO


--------------------------------------------------------------------------------
-- PRUEBA 3: ERRORES PAGO
--------------------------------------------------------------------------------

DECLARE @id_pago_test INT;
PRINT  '>>> Error fecha de Pago';
BEGIN TRY

    EXEC pagos.sp_crear_pago    
    @fecha_y_hora = '2038-06-12 18:59:30', --mayor a actual
    @id_reserva = 1, 
    @id_forma_pago = 1,
    @importe = 100.10;

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_pago_test = id FROM pagos.Pago ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Pago creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.Pago WHERE id = @id_pago_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
--------------------------------------------------------------------------------

DECLARE @id_pago_test INT;
PRINT  '>>> Error reserva en Pago';
BEGIN TRY

    EXEC pagos.sp_crear_pago    
    @fecha_y_hora = '2026-06-12 17:59:30', 
    @id_reserva = 0, -- no existe reserva
    @id_forma_pago = 1,
    @importe = 100.10;

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_pago_test = id FROM pagos.Pago ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Pago creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.Pago WHERE id = @id_pago_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------

DECLARE @id_pago_test INT;
PRINT  '>>> Error forma pago en Pago';
BEGIN TRY

    EXEC pagos.sp_crear_pago    
    @fecha_y_hora = '2026-06-12 17:59:30', 
    @id_reserva = 1,
    @id_forma_pago = 0,  -- no existe forma pago
    @importe = 100.10;

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_pago_test = id FROM pagos.Pago ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Pago creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.Pago WHERE id = @id_pago_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------

DECLARE @id_pago_test INT;
PRINT  '>>> Error importe en Pago';
BEGIN TRY

    EXEC pagos.sp_crear_pago    
    @fecha_y_hora = '2026-06-12 17:59:30', 
    @id_reserva = 1,
    @id_forma_pago = 1,  
    @importe = -100.10; --IMPORTE NEGATIVO

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_pago_test = id FROM pagos.Pago ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Pago creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.Pago WHERE id = @id_pago_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO


--------------------------------------------------------------------------------
-- PRUEBA 4: ERRORES PUNTO VENTA
--------------------------------------------------------------------------------

DECLARE @id_punto_venta_test INT;

PRINT  '>>>Error Alta sin nombre de PuntoVenta';
BEGIN TRY
    EXEC pagos.sp_crear_punto_venta
        @nombre = '' -- NOMBRE VACIO

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_punto_venta_test = id FROM pagos.PuntoVenta ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - PuntoVenta creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.PuntoVenta WHERE id = @id_punto_venta_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------

DECLARE @id_punto_venta_test INT;

PRINT  '>>>Error Modificacion sin nombre de PuntoVenta';
BEGIN TRY
    EXEC pagos.sp_modificar_punto_venta
        @id = 1 ,
        @nombre = '' -- NOMBRE VACIO

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_punto_venta_test = id FROM pagos.PuntoVenta ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - PuntoVenta creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.PuntoVenta WHERE id = @id_punto_venta_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------

DECLARE @id_punto_venta_test INT;

PRINT  '>>>Error Modificacion id de PuntoVenta';
BEGIN TRY
    EXEC pagos.sp_modificar_punto_venta
        @id = 0 , --id no existe
        @nombre = 'nombre' 

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_punto_venta_test = id FROM pagos.PuntoVenta ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - PuntoVenta creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.PuntoVenta WHERE id = @id_punto_venta_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO


--------------------------------------------------------------------------------

DECLARE @id_punto_venta_test INT;

PRINT  '>>>Error Baja id de PuntoVenta';
BEGIN TRY
    EXEC pagos.sp_eliminar_punto_venta
        @id = 0  --id no existe 

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_punto_venta_test = id FROM pagos.PuntoVenta ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - PuntoVenta creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.PuntoVenta WHERE id = @id_punto_venta_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

-- ------------------------------------------------------------------------------
-- PRUEBA 5: ERRORES TICKET FACTURA
-- ------------------------------------------------------------------------------

DECLARE @id_ticket_factura_test INT;

PRINT  '>>>ERROR Alta fecha de TicketFactura';
BEGIN TRY

    EXEC pagos.sp_crear_ticket_factura
    @fecha_y_hora = '2036-06-12 17:59:30',  -- FECHA mayor a actual
    @id_punto_venta = 1, 
    @id_pago = 1;

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_ticket_factura_test = id FROM pagos.TicketFactura  ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - TicketFactura creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.TicketFactura WHERE id = @id_ticket_factura_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------

DECLARE @id_ticket_factura_test INT;

PRINT  '>>>ERROR Alta punto de venta TicketFactura';
BEGIN TRY

    EXEC pagos.sp_crear_ticket_factura
    @fecha_y_hora = '2026-06-12 17:59:30',
    @id_punto_venta = 0,  -- No existe
    @id_pago = 1;

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_ticket_factura_test = id FROM pagos.TicketFactura  ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - TicketFactura creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.TicketFactura WHERE id = @id_ticket_factura_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------

DECLARE @id_ticket_factura_test INT;

PRINT  '>>>ERROR Alta punto de pago TicketFactura';
BEGIN TRY

    EXEC pagos.sp_crear_ticket_factura
    @fecha_y_hora = '2026-06-12 17:59:30',
    @id_punto_venta = 1,  
    @id_pago = 0; -- No existe

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_ticket_factura_test = id FROM pagos.TicketFactura  ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - TicketFactura creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM pagos.TicketFactura WHERE id = @id_ticket_factura_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO