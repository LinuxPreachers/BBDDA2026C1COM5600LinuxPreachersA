--------------------------------------------------------------------------------
-- PRUEBA 1: ALTA EXITOSA PARA LAS 4 TABLAS
--------------------------------------------------------------------------------
    --Se necesita un parque, esto esta mal, pero solo lo hago para probar
    ALTER TABLE parques.parque NOCHECK CONSTRAINT FK_Parque_TipoParque ;
    GO
        INSERT INTO parques.Parque (nombre,id_tipo_parque)
       VALUES( 'ejemplo',1);

    ALTER TABLE parques.parque CHECK CONSTRAINT FK_Parque_TipoParque;
    GO
    ------


DECLARE @id_actividad_emrpresarial_test INT;

PRINT  '>>> PRUEBA 1: Alta Exitosa de Actividad Empresarial';
BEGIN TRY


    EXEC concesiones.sp_crear_actividad_empresarial
        @nombre = 'Fast Food', 
        @descripcion = 'Loren impsum'

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_actividad_emrpresarial_test = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.ActividadEmpresarial WHERE id = @id_actividad_emrpresarial_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

-----------------------------------------------------------
DECLARE @id_empresa_concesionaria_test INT;

PRINT  '>>> PRUEBA 2: Alta Exitosa de EMPRESA CONCESIONARIA';
BEGIN TRY


    EXEC concesiones.sp_crear_empresa_concesionaria
        @nombre = 'Empresa distribuidora de galletitas', 
        @descripcion = 'Loren impsum',
        @cuit = 20300000002,
        @razon_social = 'Pepitos SRL',
        @id_actividad_empresarial = 1

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_empresa_concesionaria_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
-----------------------------------------------------------
DECLARE @id_concesion_test INT;

PRINT  '>>> PRUEBA 3: Alta Exitosa de Concesion';
BEGIN TRY

    EXEC concesiones.sp_crear_concesion
        @descripcion = 'Empresa de galletitas',
        @fecha_inicio = '01-01-26',
        @fecha_fin = '01-12-26',
        @id_empresa_concesionaria = 1,
        @id_parque = 2

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_concesion_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_concesion_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
-----------------------------------------------------------
DECLARE @id_canon_test INT;

PRINT  '>>> PRUEBA 3: Alta Exitosa de Canon';
BEGIN TRY


    EXEC concesiones.sp_crear_canon
        @fecha_pago = '01-01-26',
        @periodo = '1-12-25',
        @id_concesion = 1,
        @id_forma_pago = 1,
        @monto =100.10

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_canon_test = id FROM concesiones.Canon ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.Canon WHERE id = @id_canon_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
-----------------------------------------------------------

--------------------------------------------------------------------------------
-- PRUEBA 2: ERRORES ACTIVIDAD EMPRESARIAL
--------------------------------------------------------------------------------
DECLARE @id_actividad_emrpresarial_test INT;

PRINT  '>>>ERROR nombre de Alta de Actividad Empresarial';
BEGIN TRY


    EXEC concesiones.sp_crear_actividad_empresarial
        @nombre = '',  --Nombre vacio
        @descripcion = 'Loren impsum'

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_actividad_emrpresarial_test = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.ActividadEmpresarial WHERE id = @id_actividad_emrpresarial_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

-----------------------------------------------------------
DECLARE @id_actividad_emrpresarial_test INT;

PRINT  '>>>ERROR modificacion, id inexistente de Actividad Empresarial';
BEGIN TRY


    EXEC concesiones.sp_modificar_actividad_empresarial
        @id = 0, -- id no existe
        @nombre = 'Empresa grande',  
        @descripcion = 'Loren impsum'

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_actividad_emrpresarial_test = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.ActividadEmpresarial WHERE id = @id_actividad_emrpresarial_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

-----------------------------------------------------------

DECLARE @id_actividad_emrpresarial_test INT;

PRINT  '>>>ERROR modificacion, nombre vacio de de Actividad Empresarial';
BEGIN TRY


    EXEC concesiones.sp_modificar_actividad_empresarial
        @id = 1, 
        @nombre = '',  --Nombre vacio
        @descripcion = 'Loren impsum'

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_actividad_emrpresarial_test = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.ActividadEmpresarial WHERE id = @id_actividad_emrpresarial_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

-----------------------------------------------------------

DECLARE @id_actividad_emrpresarial_test INT;

PRINT  '>>>Exito modificacion Actividad Empresarial';
BEGIN TRY


    EXEC concesiones.sp_modificar_actividad_empresarial
        @id = 1, 
        @nombre = 'nombre',  
        @descripcion = 'Loren impsum'

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_actividad_emrpresarial_test = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.ActividadEmpresarial WHERE id = @id_actividad_emrpresarial_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO


-----------------------------------------------------------
DECLARE @id_actividad_emrpresarial_test INT;

PRINT  '>>>ERROR baja, id inexistente de Actividad Empresarial';
BEGIN TRY


    EXEC concesiones.sp_eliminar_actividad_empresarial
        @id = 0-- id no existe


    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_actividad_emrpresarial_test = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.ActividadEmpresarial WHERE id = @id_actividad_emrpresarial_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

-----------------------------------------------------------
DECLARE @id_actividad_emrpresarial_test INT;

PRINT  '>>> ERROR baja, id  de Actividad Empresarial tiene empresas asociadas';
BEGIN TRY


    EXEC concesiones.sp_eliminar_actividad_empresarial
        @id = 1


    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_actividad_emrpresarial_test = id FROM concesiones.ActividadEmpresarial ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.ActividadEmpresarial WHERE id = @id_actividad_emrpresarial_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------
-- PRUEBA 3: ERRORES EMPRESA CONCESIONARIA
--------------------------------------------------------------------------------
DECLARE @id_empresa_concesionaria_test INT;

PRINT  '>>>ERROR Alta de EMPRESA CONCESIONARIA por nombre';
BEGIN TRY


    EXEC concesiones.sp_crear_empresa_concesionaria
        @nombre = '', --nombre vacio
        @descripcion = 'Loren impsum',
        @cuit = 20300000015,
        @razon_social = 'Pepitos SRL',
        @id_actividad_empresarial = 1

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_empresa_concesionaria_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
--------------------------------------------------------------------------------
DECLARE @id_empresa_concesionaria_test INT;

PRINT  '>>>ERROR Alta de EMPRESA CONCESIONARIA por razon social';
BEGIN TRY


    EXEC concesiones.sp_crear_empresa_concesionaria
        @nombre = 'pepitos', 
        @descripcion = 'Loren impsum',
        @cuit = 20300000015,
        @razon_social = '',-- vacio
        @id_actividad_empresarial = 1

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_empresa_concesionaria_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------
DECLARE @id_empresa_concesionaria_test INT;

PRINT  '>>>ERROR Alta de EMPRESA CONCESIONARIA por cuit';
BEGIN TRY


    EXEC concesiones.sp_crear_empresa_concesionaria
        @nombre = 'pepitos', 
        @descripcion = 'Loren impsum',
        @cuit = 120300000015,
        @razon_social = 'razon',-- vacio
        @id_actividad_empresarial = 1

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_empresa_concesionaria_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------

DECLARE @id_empresa_concesionaria_test INT;

PRINT  '>>>ERROR Alta de EMPRESA CONCESIONARIA por actividad inexistente';
BEGIN TRY


    EXEC concesiones.sp_crear_empresa_concesionaria
        @nombre = 'pepitos', 
        @descripcion = 'Loren impsum',
        @cuit = 20300000020,
        @razon_social = 'razon',-- vacio
        @id_actividad_empresarial = 0

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_empresa_concesionaria_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------

DECLARE @id_empresa_concesionaria_test INT;

PRINT  '>>>ERROR Modificacion de EMPRESA CONCESIONARIA por id inexistente';
BEGIN TRY


    EXEC concesiones.sp_modificar_empresa_concesionaria
        @id = 0,
        @nombre = 'nombre', --nombre vacio
        @descripcion = 'Loren impsum',
        @cuit = 20300000015,
        @razon_social = 'Pepitos SRL',
        @id_actividad_empresarial = 1

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_empresa_concesionaria_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
--------------------------------------------------------------------------------

DECLARE @id_empresa_concesionaria_test INT;

PRINT  '>>>ERROR Modificacion de EMPRESA CONCESIONARIA por nombre';
BEGIN TRY


    EXEC concesiones.sp_modificar_empresa_concesionaria
        @id = 1,
        @nombre = '', --nombre vacio
        @descripcion = 'Loren impsum',
        @cuit = 20300000015,
        @razon_social = 'Pepitos SRL',
        @id_actividad_empresarial = 1

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_empresa_concesionaria_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
--------------------------------------------------------------------------------
DECLARE @id_empresa_concesionaria_test INT;

PRINT  '>>>ERROR Modificacion de EMPRESA CONCESIONARIA por razon social';
BEGIN TRY


    EXEC concesiones.sp_modificar_empresa_concesionaria
         @id = 1,
        @nombre = 'pepitos', 
        @descripcion = 'Loren impsum',
        @cuit = 20300000015,
        @razon_social = '',-- vacio
        @id_actividad_empresarial = 1

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_empresa_concesionaria_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------
DECLARE @id_empresa_concesionaria_test INT;

PRINT  '>>>ERROR Modificacion de EMPRESA CONCESIONARIA por cuit';
BEGIN TRY


    EXEC concesiones.sp_modificar_empresa_concesionaria
        @id = 1,
        @nombre = 'pepitos', 
        @descripcion = 'Loren impsum',
        @cuit = 120300000015,
        @razon_social = 'razon',-- vacio
        @id_actividad_empresarial = 1

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_empresa_concesionaria_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------
DECLARE @id_empresa_concesionaria_test INT;

PRINT  '>>>ERROR Modificacion de EMPRESA CONCESIONARIA por actividad inexistente';
BEGIN TRY


    EXEC concesiones.sp_modificar_empresa_concesionaria
        @id = 1,
        @nombre = 'pepitos', 
        @descripcion = 'Loren impsum',
        @cuit = 20300000020,
        @razon_social = 'razon',
        @id_actividad_empresarial = 0 --error

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_empresa_concesionaria_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------
DECLARE @id_empresa_concesionaria_test INT;

PRINT  '>>>Exito Modificacion de EMPRESA CONCESIONARIA';
BEGIN TRY


    EXEC concesiones.sp_modificar_empresa_concesionaria
        @id = 1,
        @nombre = 'pepitos', 
        @descripcion = 'Loren impsum',
        @cuit = 20300000020,
        @razon_social = 'razon',
        @id_actividad_empresarial = 1

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_empresa_concesionaria_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO



--------------------------------------------------------------------------------
-- PRUEBA 4: ERRORES CONCESION
--------------------------------------------------------------------------------

DECLARE @id_concesion_test INT;

PRINT  '>>>ERROR Alta de Concesion por fecha';
BEGIN TRY

    EXEC concesiones.sp_crear_concesion
        @descripcion = 'Empresa de galletitas',
        @fecha_fin = '01-01-26', --error
        @fecha_inicio = '01-12-26',
        @id_empresa_concesionaria = 1,
        @id_parque = 2

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_concesion_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_concesion_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------

DECLARE @id_concesion_test INT;

PRINT  '>>>ERROR Alta de Concesion por empresa';
BEGIN TRY

    EXEC concesiones.sp_crear_concesion
        @descripcion = 'Empresa de galletitas',
        @fecha_inicio = '01-01-26',
        @fecha_fin = '01-12-26',
        @id_empresa_concesionaria = 0, --error
        @id_parque = 2

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_concesion_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_concesion_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------

DECLARE @id_concesion_test INT;

PRINT  '>>>ERROR Alta de Concesion por parque';
BEGIN TRY

    EXEC concesiones.sp_crear_concesion
        @descripcion = 'Empresa de galletitas',
        @fecha_inicio = '01-01-26',
        @fecha_fin = '01-12-26',
        @id_empresa_concesionaria = 1, 
        @id_parque = 0 --error

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_concesion_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_concesion_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO


--------------------------------------------------------------------------------

DECLARE @id_concesion_test INT;

PRINT  '>>>ERROR Modificacion de Concesion por id';
BEGIN TRY

    EXEC concesiones.sp_modificar_concesion
        @id = 0,
        @descripcion = 'Empresa de galletitas',
        @fecha_inicio = '01-01-26',
        @fecha_fin = '01-12-26',
        @id_empresa_concesionaria = 1, 
        @id_parque = 2

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_concesion_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_concesion_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------

DECLARE @id_concesion_test INT;

PRINT  '>>>ERROR Modificacion de Concesion por fecha';
BEGIN TRY

    EXEC concesiones.sp_modificar_concesion
        @id = 1,
        @descripcion = 'Empresa de galletitas',
        @fecha_fin = '01-01-26', --error
        @fecha_inicio = '01-12-26',
        @id_empresa_concesionaria = 1,
        @id_parque = 2

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_concesion_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_concesion_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------

DECLARE @id_concesion_test INT;

PRINT  '>>>ERROR Modificacion de Concesion por empresa';
BEGIN TRY

    EXEC concesiones.sp_modificar_concesion
        @id = 1,
        @descripcion = 'Empresa de galletitas',
        @fecha_inicio = '01-01-26',
        @fecha_fin = '01-12-26',
        @id_empresa_concesionaria = 0, --error
        @id_parque = 2

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_concesion_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_concesion_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------

DECLARE @id_concesion_test INT;

PRINT  '>>>ERROR Modificacion de Concesion por parque';
BEGIN TRY

    EXEC concesiones.sp_modificar_concesion
        @id = 1,
        @descripcion = 'Empresa de galletitas',
        @fecha_inicio = '01-01-26',
        @fecha_fin = '01-12-26',
        @id_empresa_concesionaria = 1, 
        @id_parque = 0 --error

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_concesion_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_concesion_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
---------------------------------------------------

DECLARE @id_concesion_test INT;

PRINT  '>>>Caso exitoso Modificacion de Concesion';
BEGIN TRY

    EXEC concesiones.sp_modificar_concesion
        @id = 1,
        @descripcion = 'Empresa de galletitas',
        @fecha_inicio = '01-01-26',
        @fecha_fin = '01-12-26',
        @id_empresa_concesionaria = 1, 
        @id_parque = 2

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_concesion_test = id FROM concesiones.EmpresaConcesionaria ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.EmpresaConcesionaria WHERE id = @id_concesion_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO


--------------------------------------------------------------------------------
-- PRUEBA 5: ERRORES CANON
--------------------------------------------------------------------------------


DECLARE @id_canon_test INT;

PRINT  '>>> ERROR Alta  de Canon por concesion';
BEGIN TRY


    EXEC concesiones.sp_crear_canon
        @fecha_pago = '01-01-26',
        @periodo = '1-12-25',
        @id_concesion = 0, --error
        @id_forma_pago = 1,
        @monto =100.10

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_canon_test = id FROM concesiones.Canon ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.Canon WHERE id = @id_canon_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------


DECLARE @id_canon_test INT;

PRINT  '>>> ERROR Alta  de Canon por forma de pago';
BEGIN TRY


    EXEC concesiones.sp_crear_canon
        @fecha_pago = '01-01-26',
        @periodo = '1-12-25',
        @id_concesion = 2,
        @id_forma_pago = 0, --error
        @monto =100.10

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_canon_test = id FROM concesiones.Canon ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.Canon WHERE id = @id_canon_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
--------------------------------------------------------------------------------


DECLARE @id_canon_test INT;

PRINT  '>>> ERROR Alta  de Canon por monto';
BEGIN TRY


    EXEC concesiones.sp_crear_canon
        @fecha_pago = '01-01-26',
        @periodo = '1-12-25',
        @id_concesion = 2,
        @id_forma_pago = 1, 
        @monto = -100.10 --error

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_canon_test = id FROM concesiones.Canon ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.Canon WHERE id = @id_canon_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
------------------------------------------------------------
DECLARE @id_canon_test INT;

PRINT  '>>> ERROR Modificacion  de Canon por concesion';
BEGIN TRY


    EXEC concesiones.sp_modificar_canon
        @id = 1,
        @fecha_pago = '01-01-26',
        @periodo = '1-12-25',
        @id_concesion = 0, --error
        @id_forma_pago = 1,
        @monto =100.10

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_canon_test = id FROM concesiones.Canon ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.Canon WHERE id = @id_canon_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------


DECLARE @id_canon_test INT;

PRINT  '>>> ERROR Modificacion  de Canon por forma de pago';
BEGIN TRY

    EXEC concesiones.sp_modificar_canon
        @id = 1,
        @fecha_pago = '01-01-26',
        @periodo = '1-12-25',
        @id_concesion = 2,
        @id_forma_pago = 0, --error
        @monto =100.10

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_canon_test = id FROM concesiones.Canon ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.Canon WHERE id = @id_canon_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
--------------------------------------------------------------------------------


DECLARE @id_canon_test INT;

PRINT  '>>> ERROR Modificacion  de Canon por monto';
BEGIN TRY


    EXEC concesiones.sp_modificar_canon
        @id = 1,
        @fecha_pago = '01-01-26',
        @periodo = '1-12-25',
        @id_concesion = 2,
        @id_forma_pago = 1, 
        @monto = -100.10 --error

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_canon_test = id FROM concesiones.Canon ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.Canon WHERE id = @id_canon_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

--------------------------------------------------------------------------------


DECLARE @id_canon_test INT;

PRINT  '>>> Caso existoso modificar canon';
BEGIN TRY


    EXEC concesiones.sp_modificar_canon
        @id = 1,
        @fecha_pago = '01-01-26',
        @periodo = '1-12-25',
        @id_concesion = 2,
        @id_forma_pago = 1, 
        @monto = 100.10

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_canon_test = id FROM concesiones.Canon ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM concesiones.Canon WHERE id = @id_canon_test;
END TRY
BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO
