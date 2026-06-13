/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: TEST de SP módulo concesiones
*/

/* OPCIONAL, BORRAR DATOS

DELETE FROM concesiones.Canon;
DELETE FROM concesiones.Concesion;
DELETE FROM concesiones.EmpresaConcesionaria;
DELETE FROM concesiones.ActividadEmpresarial;
*/


-- Generar FormaPago de prueba dinámicamente si no existe ninguna activa
IF NOT EXISTS (SELECT 1 FROM pagos.FormaPago WHERE estado = 1)
BEGIN
    INSERT INTO pagos.FormaPago (nombre, estado) VALUES ('Forma Pago Alternativa', 1);
END

-- Generar Parque de prueba dinámicamente
ALTER TABLE parques.Parque NOCHECK CONSTRAINT FK_Parque_TipoParque;
IF NOT EXISTS (SELECT 1 FROM parques.Parque)
BEGIN
    INSERT INTO parques.Parque (nombre, id_tipo_parque) VALUES ('Parque Nacional Alternativo', 1);
END
ALTER TABLE parques.Parque CHECK CONSTRAINT FK_Parque_TipoParque;
GO


-- =============================================================================
-- SECCIÓN 1: PRUEBAS DE ÉXITO PARA TODOS LOS SP (CONCESIONES)
-- =============================================================================

--------------------------------------------------------------------------------
-- 1.1 ActividadEmpresarial: Alta Exitosa (sp_crear_actividad_empresarial)
--------------------------------------------------------------------------------
PRINT '>>> 1.1: Alta Exitosa de ActividadEmpresarial';
BEGIN TRY
    EXEC concesiones.sp_crear_actividad_empresarial @nombre = 'Fast Food', @descripcion = 'Fast food services';
    
    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA ALTA ACTIVIDAD EMPRESARIAL' AS Operacion, * FROM concesiones.ActividadEmpresarial WHERE id = (SELECT TOP 1 id FROM concesiones.ActividadEmpresarial ORDER BY id DESC);
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.2 ActividadEmpresarial: Modificación Exitosa (sp_modificar_actividad_empresarial)
--------------------------------------------------------------------------------
PRINT '>>> 1.2: Modificación Exitosa de ActividadEmpresarial';
BEGIN TRY
    DECLARE @id_act INT;
    SELECT TOP 1 @id_act = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;

    EXEC concesiones.sp_modificar_actividad_empresarial @id = @id_act, @nombre = 'Fast Food Modificado', @descripcion = 'Updated description';
    
    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA MODIFICACION ACTIVIDAD EMPRESARIAL' AS Operacion, * FROM concesiones.ActividadEmpresarial WHERE id = @id_act;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.3 EmpresaConcesionaria: Alta Exitosa (sp_crear_empresa_concesionaria)
--------------------------------------------------------------------------------
PRINT '>>> 1.3: Alta Exitosa de EmpresaConcesionaria';
BEGIN TRY
    DECLARE @id_act INT;
    SELECT TOP 1 @id_act = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;

    EXEC concesiones.sp_crear_empresa_concesionaria
        @nombre = 'Pepitos SRL',
        @descripcion = 'Venta de galletas',
        @cuit = 20300000002,
        @razon_social = 'Pepitos SRL Razon Social',
        @id_actividad_empresarial = @id_act;
    
    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA ALTA EMPRESA CONCESIONARIA' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = (SELECT TOP 1 id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC);
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.4 EmpresaConcesionaria: Modificación Exitosa (sp_modificar_empresa_concesionaria)
--------------------------------------------------------------------------------
PRINT '>>> 1.4: Modificación Exitosa de EmpresaConcesionaria';
BEGIN TRY
    DECLARE @id_emp INT, @id_act INT, @cuit_random BIGINT;

    SELECT TOP 1 @id_emp = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    SELECT TOP 1 @id_act = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;
    SET @cuit_random = 20300000020 + @id_emp;

    EXEC concesiones.sp_modificar_empresa_concesionaria
        @id = @id_emp,
        @nombre = 'Pepitos SRL Modificada',
        @descripcion = 'Nueva descripcion de galletas',
        @cuit = @cuit_random,
        @razon_social = 'Pepitos SRL Razon Social Modificada',
        @id_actividad_empresarial = @id_act;
    
    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA MODIFICACION EMPRESA' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_emp;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.5 Concesion: Alta Exitosa (sp_crear_concesion)
--------------------------------------------------------------------------------
PRINT '>>> 1.5: Alta Exitosa de Concesion';
BEGIN TRY
    DECLARE @id_emp INT, @id_parque INT;
    SELECT TOP 1 @id_emp = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    SELECT TOP 1 @id_parque = id FROM parques.Parque ORDER BY id DESC;

    EXEC concesiones.sp_crear_concesion
        @descripcion = 'Concesion de Galletitas en el Parque Principal',
        @fecha_inicio = '2026-01-01',
        @fecha_fin = '2026-12-31',
        @id_empresa_concesionaria = @id_emp,
        @id_parque = @id_parque;

    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA ALTA CONCESION' AS Operacion, * FROM concesiones.Concesion WHERE id = (SELECT TOP 1 id FROM concesiones.Concesion ORDER BY id DESC);
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.6 Concesion: Modificación Exitosa (sp_modificar_concesion)
--------------------------------------------------------------------------------
PRINT '>>> 1.6: Modificación Exitosa de Concesion';
BEGIN TRY
    DECLARE @id_concesion INT, @id_emp INT, @id_parque INT;
    
    -- Obtenemos los IDs reales mediante búsqueda dinámica
    SELECT TOP 1 @id_concesion = id FROM concesiones.Concesion ORDER BY id DESC;
    SELECT TOP 1 @id_emp = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    SELECT TOP 1 @id_parque = id FROM parques.Parque ORDER BY id DESC;

    -- Llamada correcta usando el ID de la concesión
    EXEC concesiones.sp_modificar_concesion
        @id = @id_concesion, -- ID real de la concesión recién creada
        @descripcion = 'Concesion Modificada Correctamente',
        @fecha_inicio = '2026-02-01',
        @fecha_fin = '2026-11-30',
        @id_empresa_concesionaria = @id_emp,
        @id_parque = @id_parque;

    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA MODIFICACION CONCESION' AS Operacion, * FROM concesiones.Concesion WHERE id = @id_concesion;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO
--------------------------------------------------------------------------------
-- 1.7 Canon: Alta Exitosa (sp_crear_canon)
--------------------------------------------------------------------------------
PRINT '>>> 1.7: Alta Exitosa de Canon';
BEGIN TRY
    DECLARE @id_conc INT, @id_fp INT;
    SELECT TOP 1 @id_conc = id FROM concesiones.Concesion ORDER BY id DESC;
    SELECT TOP 1 @id_fp = id FROM pagos.FormaPago WHERE estado = 1 ORDER BY id DESC;

    EXEC concesiones.sp_crear_canon
        @periodo = '2026-01-01',
        @monto = 1500.50,
        @fecha_pago = '2026-01-10',
        @id_concesion = @id_conc,
        @id_forma_pago = @id_fp;

    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA ALTA CANON' AS Operacion, * FROM concesiones.Canon WHERE id = (SELECT TOP 1 id FROM concesiones.Canon ORDER BY id DESC);
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.8 Canon: Modificación Exitosa (sp_modificar_canon)
--------------------------------------------------------------------------------
PRINT '>>> 1.8: Modificación Exitosa de Canon';
BEGIN TRY
    DECLARE @id_can INT, @id_conc INT, @id_fp INT;
    SELECT TOP 1 @id_can = id FROM concesiones.Canon ORDER BY id DESC;
    SELECT TOP 1 @id_conc = id FROM concesiones.Concesion ORDER BY id DESC;
    SELECT TOP 1 @id_fp = id FROM pagos.FormaPago WHERE estado = 1 ORDER BY id DESC;

    EXEC concesiones.sp_modificar_canon
        @id = @id_can,
        @periodo = '2026-02-01',
        @monto = 2000.00,
        @fecha_pago = '2026-02-12',
        @id_concesion = @id_conc,
        @id_forma_pago = @id_fp;

    PRINT 'RESULTADO: OK';
    SELECT 'EVIDENCIA MODIFICACION CANON' AS Operacion, * FROM concesiones.Canon WHERE id = @id_can;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.9 EmpresaConcesionaria: Baja Exitosa (sp_eliminar_empresa_concesionaria)
--------------------------------------------------------------------------------
PRINT '>>> 1.9: Baja Exitosa de EmpresaConcesionaria';
BEGIN TRY
    DECLARE @id_act INT;
    SELECT TOP 1 @id_act = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;

    -- Creamos una temporal para dar de baja, de modo de no romper dependencias del happy path anterior
    EXEC concesiones.sp_crear_empresa_concesionaria
        @nombre = 'Empresa Temporal Baja',
        @descripcion = 'Venta de galletas',
        @cuit = 30500000004,
        @razon_social = 'Empresa Temporal Razon Social',
        @id_actividad_empresarial = @id_act;

    DECLARE @id_empresa_baja INT;
    SELECT TOP 1 @id_empresa_baja = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;

    EXEC concesiones.sp_eliminar_empresa_concesionaria @id = @id_empresa_baja;
    
    PRINT 'RESULTADO: OK';
    IF NOT EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_baja)
        PRINT '  Confirmado: Registro de empresa temporal eliminado.';
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 1.10 ActividadEmpresarial: Baja Exitosa (sp_eliminar_actividad_empresarial)
--------------------------------------------------------------------------------
PRINT '>>> 1.10: Baja Exitosa de ActividadEmpresarial';
BEGIN TRY
    -- Creamos una actividad temporal para dar de baja sin romper dependencias
    EXEC concesiones.sp_crear_actividad_empresarial @nombre = 'Actividad Temporal Baja', @descripcion = 'Baja';
    
    DECLARE @id_actividad_baja INT;
    SELECT TOP 1 @id_actividad_baja = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;

    EXEC concesiones.sp_eliminar_actividad_empresarial @id = @id_actividad_baja;
    
    PRINT 'RESULTADO: OK';
    IF NOT EXISTS (SELECT 1 FROM concesiones.ActividadEmpresarial WHERE id = @id_actividad_baja)
        PRINT '  Confirmado: Registro de actividad temporal eliminado.';
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO


-- =============================================================================
-- SECCIÓN 2: PRUEBAS DE VALIDACIÓN Y CONTROL DE ERRORES (CONCESIONES)
-- =============================================================================

--------------------------------------------------------------------------------
-- 2.1 ActividadEmpresarial: Error en Alta (sp_crear_actividad_empresarial)
--------------------------------------------------------------------------------
PRINT '>>> 2.1: Error de Validación en Alta de ActividadEmpresarial (Nombre vacío)';
BEGIN TRY
    EXEC concesiones.sp_crear_actividad_empresarial @nombre = '  ', @descripcion = 'Fast Food';
    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.2 ActividadEmpresarial: Errores Combinados en Modificación
--------------------------------------------------------------------------------
PRINT '>>> 2.2: Error de Validación Combinada en Modificación de ActividadEmpresarial (ID Inexistente y Nombre Inválido)';
BEGIN TRY
    EXEC concesiones.sp_modificar_actividad_empresarial @id = -1, @nombre = '', @descripcion = 'Fast Food'; -- FIXED: Added @descripcion
    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO (MENSAJE COMBINADO):';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.3 ActividadEmpresarial: Errores Combinados en Baja
--------------------------------------------------------------------------------
PRINT '>>> 2.3: Error de Validación en Baja de ActividadEmpresarial (ID Inexistente y Actividad con Empresas Asociadas)';
BEGIN TRY
    PRINT '  -- Probando ID Inexistente:';
    EXEC concesiones.sp_eliminar_actividad_empresarial @id = -1;
END TRY
BEGIN CATCH
    PRINT '  ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    DECLARE @id_act INT;
    SELECT TOP 1 @id_act = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;

    PRINT '  -- Probando ID con Empresas Asociadas:';
    EXEC concesiones.sp_eliminar_actividad_empresarial @id = @id_act;
END TRY
BEGIN CATCH
    PRINT '  ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.4 EmpresaConcesionaria: Errores Combinados en Alta
--------------------------------------------------------------------------------
PRINT '>>> 2.4: Error de Validación Combinada en Alta de EmpresaConcesionaria (Nombre vacío, Razón Social vacía, CUIT inválido y Actividad inexistente)';
BEGIN TRY
    EXEC concesiones.sp_crear_empresa_concesionaria
        @nombre = '  ',
        @descripcion = 'Prueba combinada',
        @cuit = 9999, -- CUIT inválido
        @razon_social = '',
        @id_actividad_empresarial = -1; -- Actividad inexistente

    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO (MENSAJE COMBINADO):';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.5 EmpresaConcesionaria: Errores Combinados en Modificación
--------------------------------------------------------------------------------
PRINT '>>> 2.5: Error de Validación Combinada en Modificación de EmpresaConcesionaria (ID Inexistente, Nombre vacío, Razón Social vacía, CUIT inválido y Actividad inexistente)';
BEGIN TRY
    EXEC concesiones.sp_modificar_empresa_concesionaria
        @id = -1, -- ID inexistente
        @nombre = '',
        @descripcion = 'Prueba combinada',
        @cuit = 9999, -- CUIT inválido
        @razon_social = '  ',
        @id_actividad_empresarial = -1; -- Actividad inexistente

    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO (MENSAJE COMBINADO):';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.6 EmpresaConcesionaria: Errores Combinados en Baja
--------------------------------------------------------------------------------
PRINT '>>> 2.6: Error de Validación en Baja de EmpresaConcesionaria';
BEGIN TRY
    PRINT '  -- Probando ID Inexistente:';
    EXEC concesiones.sp_eliminar_empresa_concesionaria @id = -1;
END TRY
BEGIN CATCH
    PRINT '  ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    DECLARE @id_emp INT;
    SELECT TOP 1 @id_emp = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;

    PRINT '  -- Probando ID con Concesiones Activas:';
    EXEC concesiones.sp_eliminar_empresa_concesionaria @id = @id_emp;
END TRY
BEGIN CATCH
    PRINT '  ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.7 Concesion: Errores Combinados en Alta
--------------------------------------------------------------------------------
PRINT '>>> 2.7: Error de Validación Combinada en Alta de Concesion (Fecha Inicio > Fecha Fin, Empresa inexistente y Parque inexistente)';
BEGIN TRY
    EXEC concesiones.sp_crear_concesion
        @descripcion = 'Prueba combinada',
        @fecha_inicio = '2026-12-31',
        @fecha_fin = '2026-01-01', -- Inicio mayor que fin
        @id_empresa_concesionaria = -1, 
        @id_parque = -1; 

    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO (MENSAJE COMBINADO):';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.8 Concesion: Errores Combinados en Modificación
--------------------------------------------------------------------------------
PRINT '>>> 2.8: Error de Validación Combinada en Modificación de Concesion (ID Inexistente, Fecha Inicio > Fecha Fin, Empresa inexistente y Parque inexistente)';
BEGIN TRY
    EXEC concesiones.sp_modificar_concesion
        @id = -1, -- ActividadEmpresarial inexistente
        @descripcion = 'Prueba combinada',
        @fecha_inicio = '2026-12-31',
        @fecha_fin = '2026-01-01', -- Inicio mayor que fin
        @id_empresa_concesionaria = -1, 
        @id_parque = -1; 

    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO (MENSAJE COMBINADO):';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.9 Canon: Errores Combinados en Alta
--------------------------------------------------------------------------------
PRINT '>>> 2.9: Error de Validación Combinada en Alta de Canon (Concesión inexistente, Forma Pago inexistente y Monto <= 0)';
BEGIN TRY
    EXEC concesiones.sp_crear_canon
        @periodo = '2026-01-01',
        @monto = -500.00,       -- Monto negativo
        @fecha_pago = '2026-01-10',
        @id_concesion = -1,     
        @id_forma_pago = -1;    

    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO (MENSAJE COMBINADO):';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH;
GO

--------------------------------------------------------------------------------
-- 2.10 Canon: Errores Combinados en Modificación
--------------------------------------------------------------------------------
PRINT '>>> 2.10: Error de Validación Combinada en Modificación de Canon (Concesión inexistente, Forma Pago inexistente y Monto <= 0)';
BEGIN TRY
    EXEC concesiones.sp_modificar_canon
        @id = 1,
        @periodo = '2026-01-01',
        @monto = -100.00,       -- Monto negativo
        @fecha_pago = '2026-01-10',
        @id_concesion = -1,     
        @id_forma_pago = -1;    

    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO (MENSAJE COMBINADO):';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH;
GO



-- =============================================================================
-- SECCIÓN 3: PRUEBAS PARA OTROS SP (CONCESIONES)
-- =============================================================================

SET NOCOUNT ON
-- ActividadEmpresarial
EXEC concesiones.sp_crear_actividad_empresarial
    @nombre = 'Gastronomia',
    @descripcion = 'Servicios gastronomicos';

-- EmpresaConcesionaria
DECLARE @id_act INT, @cuit_rand BIGINT
SELECT TOP 1 @id_act = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;

SET @cuit_rand = 20100000000 + @id_act;

EXEC concesiones.sp_crear_empresa_concesionaria
    @nombre = 'Parrillas ',
    @descripcion = 'Servicio de parrilla',
    @cuit = @cuit_rand,
    @razon_social = 'Parrillas SA',
    @id_actividad_empresarial = @id_act;

-- FormaPago
IF NOT EXISTS (SELECT 1 FROM pagos.FormaPago WHERE estado = 1)
BEGIN
    INSERT INTO pagos.FormaPago (nombre, estado) VALUES ('Efectivo', 1);
END

-- Parque
ALTER TABLE parques.Parque NOCHECK CONSTRAINT FK_Parque_TipoParque;
IF NOT EXISTS (SELECT 1 FROM parques.Parque)
BEGIN
    INSERT INTO parques.Parque (nombre, id_tipo_parque) VALUES ('Parque Nacional Test', 1);
END
ALTER TABLE parques.Parque CHECK CONSTRAINT FK_Parque_TipoParque;

PRINT 'SETUP COMPLETO';
GO

------------------------------------------------------------------------------------
PRINT '';
PRINT '>>> TEST 1:  sp_generar_concesion_y_canon exitoso';

BEGIN TRY
    DECLARE @id_emp INT, @id_parque INT, @id_fp INT;
    DECLARE @desc VARCHAR(255) = 'Concesion de prueba';
    DECLARE @fecha_ini DATE = '2026-01-01';
    DECLARE @fecha_fin DATE = '2026-12-31';
    DECLARE @monto DECIMAL(15,2) = 5000.00;

    SELECT TOP 1 @id_emp = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    SELECT TOP 1 @id_parque = id FROM parques.Parque ORDER BY id DESC;
    SELECT TOP 1 @id_fp = id FROM pagos.FormaPago WHERE estado = 1 ORDER BY id DESC;

    EXEC concesiones.sp_generar_concesion_y_canon
        @descripcion = @desc,
        @fecha_inicio = @fecha_ini,
        @fecha_fin = @fecha_fin,
        @id_empresa_concesionaria = @id_emp,
        @id_parque = @id_parque,
        @monto_canon = @monto,
        @id_forma_pago = @id_fp,
        @cantidad_dias_vencimiento = 15;

    -- Verificar concesión creada
    DECLARE @id_conc INT, @cant_canons INT;
    SELECT TOP 1 @id_conc = id FROM concesiones.Concesion ORDER BY id DESC;
    SELECT @cant_canons = COUNT(*) FROM concesiones.Canon WHERE id_concesion = @id_conc;

    PRINT 'RESULTADO: OK';
    PRINT '  Concesion ID: ' + CAST(@id_conc AS VARCHAR);
    PRINT '  Canons generados: ' + CAST(@cant_canons AS VARCHAR) + ' (esperado: 12)';

    SELECT 'TEST 1 - CONCESION' AS Operacion, * FROM concesiones.Concesion WHERE id = @id_conc;
    SELECT 'TEST 1 - CANONS' AS Operacion, id, periodo, monto, fecha_pago, id_concesion, id_forma_pago
    FROM concesiones.Canon WHERE id_concesion = @id_conc ORDER BY periodo;
END TRY
BEGIN CATCH
    PRINT 'RESULTADO: ERROR INESPERADO';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH;
GO

------------------------------------------------------------------------------------
PRINT '';
PRINT '>>> TEST 2: @cantidad_dias_vencimiento = 0 (rollback esperado)';

BEGIN TRY
    DECLARE @id_emp2 INT, @id_parque2 INT, @id_fp2 INT;

    SELECT TOP 1 @id_emp2 = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    SELECT TOP 1 @id_parque2 = id FROM parques.Parque ORDER BY id DESC;
    SELECT TOP 1 @id_fp2 = id FROM pagos.FormaPago WHERE estado = 1 ORDER BY id DESC;

    -- Contar concesiones antes
    DECLARE @antes_conc INT, @antes_canon INT;
    SELECT @antes_conc = COUNT(*) FROM concesiones.Concesion;
    SELECT @antes_canon = COUNT(*) FROM concesiones.Canon;

    -- Llamada con @cantidad_dias_vencimiento inválido
    EXEC concesiones.sp_generar_concesion_y_canon
        @descripcion = 'No deberia crearse',
        @fecha_inicio = '2026-01-01',
        @fecha_fin = '2026-03-01',
        @id_empresa_concesionaria = @id_emp2,
        @id_parque = @id_parque2,
        @monto_canon = 1000.00,
        @id_forma_pago = @id_fp2,
        @cantidad_dias_vencimiento = 0;

    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH
    DECLARE @despues_conc INT, @despues_canon INT;
    SELECT @despues_conc = COUNT(*) FROM concesiones.Concesion;
    SELECT @despues_canon = COUNT(*) FROM concesiones.Canon;

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

    IF @antes_conc = @despues_conc AND @antes_canon = @despues_canon
        PRINT 'ROLLBACK VERIFICADO: No se insertaron registros (Concesiones: ' + CAST(@despues_conc AS VARCHAR) + ', Canons: ' + CAST(@despues_canon AS VARCHAR) + ')';
    ELSE
        PRINT 'ROLLBACK FALLIDO: Se insertaron registros a pesar del error';
END CATCH;
GO

------------------------------------------------------------------------------------
PRINT '';
PRINT '>>> TEST 3:  @fecha_inicio > @fecha_fin (rollback total)';

BEGIN TRY
    DECLARE @id_emp3 INT, @id_parque3 INT, @id_fp3 INT,@antes_conc INT,@antes_canon INT;

    SELECT TOP 1 @id_emp3 = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    SELECT TOP 1 @id_parque3 = id FROM parques.Parque ORDER BY id DESC;
    SELECT TOP 1 @id_fp3 = id FROM pagos.FormaPago WHERE estado = 1 ORDER BY id DESC;

    SELECT @antes_conc = COUNT(*) FROM concesiones.Concesion;
    SELECT @antes_canon = COUNT(*) FROM concesiones.Canon;

    EXEC concesiones.sp_generar_concesion_y_canon
        @descripcion = 'Concesion con fechas invalidas',
        @fecha_inicio = '2026-12-31',
        @fecha_fin = '2026-01-01',
        @id_empresa_concesionaria = @id_emp3,
        @id_parque = @id_parque3,
        @monto_canon = 1000.00,
        @id_forma_pago = @id_fp3,
        @cantidad_dias_vencimiento = 15;

    PRINT 'RESULTADO: ERROR (Debió lanzar excepción)';
END TRY
BEGIN CATCH

    DECLARE @despues_conc INT,@despues_canon INT;
    SELECT @despues_conc = COUNT(*) FROM concesiones.Concesion;
    SELECT @despues_canon = COUNT(*) FROM concesiones.Canon;

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

    IF @antes_conc = @despues_conc AND @antes_canon = @despues_canon
        PRINT 'ROLLBACK VERIFICADO: No se insertaron registros';
    ELSE
        PRINT 'ROLLBACK FALLIDO: Se insertaron registros a pesar del error';
END CATCH;
GO

------------------------------------------------------------------------------------
