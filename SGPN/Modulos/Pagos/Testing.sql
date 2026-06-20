/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Testing ABM módulo pagos
*/



/* OPCIONAL: BORRAR DATOS ANTERIORES

DELETE FROM pagos.TicketFactura;
DELETE FROM pagos.Pago;
DELETE FROM pagos.PuntoVenta;
DELETE FROM pagos.FormaPago;
*/

-- Aseguramos que la reserva de prueba con ID 1 exista
IF NOT EXISTS (SELECT 1 FROM reservas.Reserva WHERE id = 1)
BEGIN
    SET IDENTITY_INSERT reservas.Reserva ON;
    INSERT INTO reservas.Reserva (id, fecha_y_hora) VALUES (1, GETDATE());
    SET IDENTITY_INSERT reservas.Reserva OFF;
END
GO


-- =============================================================================
-- SECCIÓN 1: PRUEBAS DE ÉXITO PARA TODOS LOS SP
-- =============================================================================

--------------------------------------------------------------------------------
-- 1.1 sp_crear_forma_pago
--------------------------------------------------------------------------------
PRINT '>>> 1.1: Alta Exitosa de FormaPago';
BEGIN TRY
    EXEC pagos.sp_crear_forma_pago @nombre = 'Efectivo';
    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA ALTA FORMA PAGO' AS Operacion, * FROM pagos.FormaPago WHERE id = (SELECT TOP 1 id FROM pagos.FormaPago ORDER BY id DESC);
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.2 sp_modificar_forma_pago
--------------------------------------------------------------------------------
PRINT '>>> 1.2: Modificación Exitosa de FormaPago';
BEGIN TRY
    DECLARE @id_fp TINYINT;
    SELECT TOP 1 @id_fp = id FROM pagos.FormaPago ORDER BY id DESC;

    EXEC pagos.sp_modificar_forma_pago @id = @id_fp, @nombre = 'Efectivo Modificado';
    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA MODIFICACION FORMA PAGO' AS Operacion, * FROM pagos.FormaPago WHERE id = @id_fp;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.3 sp_crear_punto_venta
--------------------------------------------------------------------------------
PRINT '>>> 1.3: Alta Exitosa de PuntoVenta';
BEGIN TRY
    EXEC pagos.sp_crear_punto_venta @nombre = 'Mostrador Principal';
    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA ALTA PUNTO VENTA' AS Operacion, * FROM pagos.PuntoVenta WHERE id = (SELECT TOP 1 id FROM pagos.PuntoVenta ORDER BY id DESC);
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.4 sp_modificar_punto_venta
--------------------------------------------------------------------------------
PRINT '>>> 1.4: Modificación Exitosa de PuntoVenta';
BEGIN TRY
    DECLARE @id_pv SMALLINT;
    SELECT TOP 1 @id_pv = id FROM pagos.PuntoVenta ORDER BY id DESC;

    EXEC pagos.sp_modificar_punto_venta @id = @id_pv, @nombre = 'Mostrador Modificado';
    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA MODIFICACION PUNTO VENTA' AS Operacion, * FROM pagos.PuntoVenta WHERE id = @id_pv;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.5 sp_crear_pago
--------------------------------------------------------------------------------
PRINT '>>> 1.5: Alta Exitosa de Pago';
BEGIN TRY
    DECLARE @id_fp TINYINT;
    DECLARE @id_re INT;

    SELECT TOP 1 @id_fp = id FROM pagos.FormaPago WHERE estado = 1;

    SELECT TOP 1 @id_re = id FROM reservas.Reserva;

    EXEC pagos.sp_crear_pago    
        @fecha_y_hora = '2026-06-12 17:59:30', 
        @id_reserva = @id_re, 
        @id_forma_pago = @id_fp,
        @importe = 250.75;

    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA ALTA PAGO' AS Operacion, * FROM pagos.Pago WHERE id = (SELECT TOP 1 id FROM pagos.Pago ORDER BY id DESC);
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.6 sp_crear_ticket_factura
--------------------------------------------------------------------------------
PRINT '>>> 1.6: Alta Exitosa de TicketFactura';
BEGIN TRY
    DECLARE @id_pv SMALLINT, @id_pago INT;
    SELECT TOP 1 @id_pv = id FROM pagos.PuntoVenta WHERE estado = 1 ORDER BY id DESC;
    SELECT TOP 1 @id_pago = id FROM pagos.Pago ORDER BY id DESC;

    EXEC pagos.sp_crear_ticket_factura
        @fecha_y_hora = '2026-06-12 18:05:00', 
        @id_punto_venta = @id_pv, 
        @id_pago = @id_pago;

    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA ALTA TICKET FACTURA' AS Operacion, * FROM pagos.TicketFactura WHERE id = (SELECT TOP 1 id FROM pagos.TicketFactura ORDER BY id DESC);
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.7 sp_eliminar_forma_pago
--------------------------------------------------------------------------------
PRINT '>>> 1.7: Baja Exitosa de FormaPago (Borrado Lógico)';
BEGIN TRY
    EXEC pagos.sp_crear_forma_pago @nombre = 'Temporal Baja';
    
    DECLARE @id_fp TINYINT;
    SELECT TOP 1 @id_fp = id FROM pagos.FormaPago ORDER BY id DESC;

    EXEC pagos.sp_eliminar_forma_pago @id = @id_fp;
    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA BAJA FORMA PAGO' AS Operacion, * FROM pagos.FormaPago WHERE id = @id_fp;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.8 sp_eliminar_punto_venta
--------------------------------------------------------------------------------
PRINT '>>> 1.8: Baja Exitosa de PuntoVenta (Borrado Lógico)';
BEGIN TRY
    EXEC pagos.sp_crear_punto_venta @nombre = 'Temporal PV Baja';
    
    DECLARE @id_pv SMALLINT;
    SELECT TOP 1 @id_pv = id FROM pagos.PuntoVenta ORDER BY id DESC;

    EXEC pagos.sp_eliminar_punto_venta @id = @id_pv;
    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA BAJA PUNTO VENTA' AS Operacion, * FROM pagos.PuntoVenta WHERE id = @id_pv;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO


-- =============================================================================
-- SECCIÓN 2: PRUEBAS DE VALIDACIÓN Y CONTROL DE ERRORES (PAGOS)
-- =============================================================================

--------------------------------------------------------------------------------
-- 2.1 FormaPago: Error en Alta (Nombre vacío)
--------------------------------------------------------------------------------
PRINT '>>> 2.1: Error de Validación en Alta de FormaPago (Nombre vacío)';
BEGIN TRY
    EXEC pagos.sp_crear_forma_pago @nombre = '   ';
    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.2 FormaPago: Errores Combinados en Modificación
--------------------------------------------------------------------------------
PRINT '>>> 2.2: Error de Validación Combinada en Modificación de FormaPago (ID Inexistente y Nombre Inválido)';
BEGIN TRY
    EXEC pagos.sp_modificar_forma_pago @id = -1, @nombre = '';
    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO (MENSAJE COMBINADO):';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.3 FormaPago: Error en Baja (ID Inexistente)
--------------------------------------------------------------------------------
PRINT '>>> 2.3: Error de Validación en Baja de FormaPago (ID Inexistente)';
BEGIN TRY
    EXEC pagos.sp_eliminar_forma_pago @id = -1;
    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.4 PuntoVenta: Error en Alta (Nombre vacío)
--------------------------------------------------------------------------------
PRINT '>>> 2.4: Error de Validación en Alta de PuntoVenta (Nombre vacío)';
BEGIN TRY
    EXEC pagos.sp_crear_punto_venta @nombre = '';
    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.5 PuntoVenta: Errores Combinados en Modificación
--------------------------------------------------------------------------------
PRINT '>>> 2.5: Error de Validación Combinada en Modificación de PuntoVenta (ID Inexistente y Nombre Inválido)';
BEGIN TRY
    EXEC pagos.sp_modificar_punto_venta @id = -1, @nombre = '  ';
    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO (MENSAJE COMBINADO):';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.6 PuntoVenta: Error en Baja (ID Inexistente)
--------------------------------------------------------------------------------
PRINT '>>> 2.6: Error de Validación en Baja de PuntoVenta (ID Inexistente)';
BEGIN TRY
    EXEC pagos.sp_eliminar_punto_venta @id = -1;
    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.7 Pago: Errores Combinados en Alta
--------------------------------------------------------------------------------
PRINT '>>> 2.7: Error de Validación Combinada en Alta de Pago (Fecha Futura, Reserva Inexistente, Forma Pago Inválida e Importe Negativo)';
BEGIN TRY
    EXEC pagos.sp_crear_pago    
        @fecha_y_hora = '2038-01-01 12:00:00', 
        @id_reserva = -1,                     
        @id_forma_pago = -1,                   
        @importe = -500.00;                   

    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO (MENSAJE COMBINADO):';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.8 TicketFactura: Errores Combinados en Alta
--------------------------------------------------------------------------------
PRINT '>>> 2.8: Error de Validación Combinada en Alta de TicketFactura (Fecha Futura, Punto Venta Inexistente y Pago Inexistente)';
BEGIN TRY
    EXEC pagos.sp_crear_ticket_factura
        @fecha_y_hora = '2038-01-01 12:00:00', 
        @id_punto_venta = -1,                  
        @id_pago = -1;                         

    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO (MENSAJE COMBINADO):';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH;
GO
