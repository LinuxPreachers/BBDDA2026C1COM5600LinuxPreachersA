/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Script: SP de negocio + Testing
 */

USE LinuxPreachers;
GO



-- =============================================================================
-- TESTS
-- =============================================================================


-- -----------------------------------------------------------------------
-- SETUP: Limpiar datos de pruebas anteriores y generar dependencias
-- -----------------------------------------------------------------------


-- ActividadEmpresarial
EXEC concesiones.sp_crear_actividad_empresarial
    @nombre = 'Gastronomia',
    @descripcion = 'Servicios gastronomicos';

-- EmpresaConcesionaria
DECLARE @id_act SMALLINT;
SELECT TOP 1 @id_act = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;

EXEC concesiones.sp_crear_empresa_concesionaria
    @nombre = 'Parrillas ',
    @descripcion = 'Servicio de parrilla',
    @cuit = 20300000099,
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

-- =============================================================================
-- TEST 1: Creación de concesión + canons exitosa
-- =============================================================================
PRINT '';
PRINT '>>> TEST 1:  sp_generar_concesion_y_canon exitoso';

BEGIN TRY
    DECLARE @id_emp INT, @id_parque INT, @id_fp TINYINT;
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

-- =============================================================================
-- TEST 2: ERROR  cantidad_dias_vencimiento inválido
-- =============================================================================
PRINT '';
PRINT '>>> TEST 2: @cantidad_dias_vencimiento = 0 (rollback esperado)';

BEGIN TRY
    DECLARE @id_emp2 INT, @id_parque2 INT, @id_fp2 TINYINT;

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

-- =============================================================================
-- TEST 3: ERROR Fecha inicio > fecha fin
-- =============================================================================
PRINT '';
PRINT '>>> TEST 3:  @fecha_inicio > @fecha_fin (rollback total)';

BEGIN TRY
    DECLARE @id_emp3 INT, @id_parque3 INT, @id_fp3 TINYINT,@antes_conc INT,@antes_canon INT;

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
