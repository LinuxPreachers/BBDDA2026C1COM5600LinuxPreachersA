/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Testing de sps ABM para tablas del módulo empleados
*/

USE LinuxPreachers;
GO


RAISERROR(N'Este script no esta pensado para que lo ejecutes "de una" con F5. Selecciona y ejecuta el Test 1 a 1', 16, 1) WITH LOG;
SET NOEXEC ON; -- Esto bloquea las ejecuciones para esta conexion en particular
GO



/* 
 * Si usted intentó ejecutrar este script de manera no secuencial, debera ejecutar el siguiente comando:
*/
--===============================================
SET NOEXEC OFF;
--===============================================



-- ==============================================================================
-- 1. TESTING: TipoDocumento
-- ==============================================================================

-- 1.1 ALTA EXITOSA
DECLARE @nombre_tipo_doc VARCHAR(20) = 'DNI Test '; 

BEGIN TRY

    PRINT '1.1 ALTA EXITOSA TIPO DOCUMENTO';

    EXEC empleados.sp_crear_tipo_documento @nombre = @nombre_tipo_doc;

    SELECT 'ALTA TIPO DOC EXITOSA' AS Res_Esperado, * FROM empleados.TipoDocumento WHERE id=IDENT_CURRENT('empleados.TipoDocumento');

END TRY
BEGIN CATCH 
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;

GO

-- 1.2 ALTA FALLIDA (Nombre NULL)
BEGIN TRY

    PRINT '1.2 ALTA FALLIDA TIPO DOCUMENTO (Nombre Vacio)';

    EXEC empleados.sp_crear_tipo_documento @nombre = '';
    
    PRINT 'SI IMPRIMIO ESTO FALLÓ EL TEST';
END TRY
BEGIN CATCH 
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO

-- 1.3 MODIFICACIÓN EXITOSA
DECLARE @id_tipo_doc_mod INT = (SELECT MAX(id) FROM empleados.TipoDocumento);

BEGIN TRY

    SELECT * FROM empleados.TipoDocumento WHERE id=@id_tipo_doc_mod;-- para ver que contenido tenia antes del cambio

    PRINT '1.3 MODIFICACION EXITOSA TIPO DOCUMENTO';

    EXEC empleados.sp_modificar_tipo_documento @id = @id_tipo_doc_mod, @nombre = 'Pasaporte Test';

    SELECT 'MODIFICACION TIPO DOC EXITOSA' AS Res_Esperado, * FROM empleados.TipoDocumento WHERE id = @id_tipo_doc_mod;

END TRY
BEGIN CATCH 
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO


-- 1.4 MODIFICACIÓN FALLIDA (ID Inexistente)
BEGIN TRY

    PRINT '1.4 MODIFICACION FALLIDA TIPO DOCUMENTO (ID Invalido)';

    EXEC empleados.sp_modificar_tipo_documento @id = -1, @nombre = 'Falla';

    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST: Permitió modificar ID inexistente';

END TRY
BEGIN CATCH 
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO

-- 1.5 BAJA EXITOSA 
BEGIN TRY

    PRINT '1.5 BAJA EXITOSA TIPO DOCUMENTO';

    EXEC empleados.sp_crear_tipo_documento @nombre = 'A Borrar'; -- creamos un tipo doc para eliminarlo

    DECLARE @id_borrar INT = (SELECT MAX(id) FROM empleados.TipoDocumento); 

    EXEC empleados.sp_eliminar_tipo_documento @id = @id_borrar;

    SELECT 'BAJA TIPO DOC EXITOSA (Debe estar vacio)' AS Res_Esperado, * FROM empleados.TipoDocumento WHERE id = @id_borrar;

END TRY
BEGIN CATCH 
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO

--1.6 BAJA FALLIDA

DECLARE @id_tipo_doc_baja INT = (SELECT MAX(id) FROM empleados.TipoDocumento) + 1;
BEGIN TRY

    PRINT '1.6 BAJA FALLIDA TIPO DOCUMENTO: id inexistente';

    EXEC empleados.sp_eliminar_tipo_documento @id=@id_tipo_doc_baja;

    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST: Permitió dar de baja un tipo de documento inexistente';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO' + ERROR_MESSAGE();
END CATCH;
GO

-- ==============================================================================
-- 2. TESTING: Empleado
-- ==============================================================================

-- 2.1 ALTA EXITOSA
DECLARE @id_tipo_doc_emp INT = (SELECT MAX(id) FROM empleados.TipoDocumento);
DECLARE @doc_random INT = CAST(RAND()*10000000 AS INT);

BEGIN TRY

    PRINT '2.1 ALTA EXITOSA EMPLEADO';

    EXEC empleados.sp_crear_empleado @nombre = 'Juan', @apellido = 'Perez', @nro_doc = @doc_random, @id_tipo_documento = @id_tipo_doc_emp;

    SELECT 'ALTA EMPLEADO EXITOSA' AS Res_Esperado, * FROM empleados.Empleado WHERE nro_doc = @doc_random;

END TRY
BEGIN CATCH 
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO

-- 2.2 ALTA FALLIDA (Documento Duplicado)
DECLARE @id_tipo_doc_emp INT = (SELECT MAX(id) FROM empleados.TipoDocumento);
DECLARE @doc_existente INT = (SELECT TOP 1 nro_doc FROM empleados.Empleado WHERE id_tipo_documento = @id_tipo_doc_emp);

BEGIN TRY

    PRINT '2.2 ALTA FALLIDA EMPLEADO (Doc Duplicado)';

    EXEC empleados.sp_crear_empleado @nombre = 'Clon', @apellido = 'Perez', @nro_doc = @doc_existente, @id_tipo_documento = @id_tipo_doc_emp;

    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST: Permitió clonar documento';

END TRY
BEGIN CATCH 
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO

-- 2.3 MODIFICACIÓN EXITOSA
DECLARE @id_emp_mod INT = (SELECT MAX(id) FROM empleados.Empleado);
DECLARE @doc_actual INT = (SELECT nro_doc FROM empleados.Empleado WHERE id = @id_emp_mod);
DECLARE @id_tipo_doc_emp INT = (SELECT id_tipo_documento FROM empleados.Empleado WHERE id = @id_emp_mod);

BEGIN TRY

    PRINT '2.3 MODIFICACION EXITOSA EMPLEADO';

    EXEC empleados.sp_modificar_empleado @id = @id_emp_mod, @nombre = 'Juan Modificado', @apellido = 'Perez', @nro_doc = @doc_actual, @id_tipo_documento = @id_tipo_doc_emp;

    SELECT 'MODIFICACION EMPLEADO EXITOSA' AS Res_Esperado, * FROM empleados.Empleado WHERE id = @id_emp_mod;

END TRY
BEGIN CATCH 
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO

-- 2.4 MODIFICACIÓN FALLIDA (Nombre Vacio)
DECLARE @id_emp_mod INT = (SELECT MAX(id) FROM empleados.Empleado);
DECLARE @id_tipo_doc_emp INT = (SELECT id_tipo_documento FROM empleados.Empleado WHERE id = @id_emp_mod);

BEGIN TRY

    PRINT '2.4 MODIFICACION FALLIDA EMPLEADO (Nombre Vacio)';

    EXEC empleados.sp_modificar_empleado @id = @id_emp_mod, @nombre = '', @apellido = 'Perez', @nro_doc = 12345, @id_tipo_documento = @id_tipo_doc_emp;

    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST: Permitió modificar con nombre vacio';

END TRY
BEGIN CATCH 
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO

-- 2.5 BAJA LÓGICA EXITOSA
DECLARE @id_emp_baja INT = (SELECT MAX(id) FROM empleados.Empleado);

BEGIN TRY

    PRINT '2.5 BAJA LOGICA EXITOSA EMPLEADO (activo = 0)';

    EXEC empleados.sp_eliminar_empleado @id = @id_emp_baja;

    SELECT 'BAJA EMPLEADO EXITOSA' AS Res_Esperado, id, activo FROM empleados.Empleado WHERE id = @id_emp_baja;

END TRY
BEGIN CATCH 
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO


-- ==============================================================================
-- 3. TESTING: Especialidad
-- ==============================================================================

--3.1 ALTA EXITOSA

BEGIN TRY

    PRINT '3.1 ALTA EXITOSA ESPECIALIDAD';

    EXEC empleados.sp_crear_especialidad @nombre = 'Alta Montaña', @descripcion = 'Test';

    SELECT 'ALTA ESPECIALIDAD EXITOSA' AS Res_Esperado, * FROM empleados.Especialidad WHERE id = IDENT_CURRENT('empleados.Especialidad');

END TRY
BEGIN CATCH 
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

--3.2 ALTA FALLIDA
BEGIN TRY

    PRINT  '3.2 ALTA FALLIDA ESPECIALIDAD (Nombre Vacio)';

    EXEC empleados.sp_crear_especialidad @nombre = '';

    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST';

END TRY
BEGIN CATCH 
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO


-- 3.3 MODIFICACIÓN EXITOSA


DECLARE @id_esp_mod_exitosa INT = (SELECT MAX(id) FROM empleados.Especialidad);

BEGIN TRY
    PRINT 'PRUEBA 3.3: Modificación Exitosa Especialidad';
    
    EXEC empleados.sp_modificar_especialidad 
        @id = @id_esp_mod_exitosa, 
        @nombre = 'Especialidad Modificada', 
        @descripcion = 'Descripción actualizada exitosamente';
        
    PRINT 'RESULTADO: OK - Especialidad modificada.';

    SELECT 'MODIFICACION EXITOSA' AS Res_Esperado, * FROM empleados.Especialidad WHERE id = @id_esp_mod_exitosa;

END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO


-- 3.4 MODIFICACIÓN FALLIDA (Nombre Inválido / Vacío)

DECLARE @id_esp_mod_fallida INT = (SELECT MAX(id) FROM empleados.Especialidad);

BEGIN TRY

    PRINT 'PRUEBA 3.4: Modificación Fallida Especialidad (Nombre Vacío)';
    
    EXEC empleados.sp_modificar_especialidad 
        @id = @id_esp_mod_fallida, 
        @nombre = '   ',  -- Enviamos un string vacío/solo espacios
        @descripcion = 'Intento de falla';
        
    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST: El SP permitió modificar con un nombre inválido.';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO:' + ERROR_MESSAGE();
END CATCH;
GO


-- 3.5 MODIFICACIÓN FALLIDA (ID Inexistente)

BEGIN TRY

    PRINT 'PRUEBA 3.5: Modificación Fallida Especialidad (ID Inexistente)';
    
    EXEC empleados.sp_modificar_especialidad 
        @id = -1, -- ID que sabemos que no existe
        @nombre = 'Nombre Valido', 
        @descripcion = 'Intento de falla';
        
    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST: El SP permitió modificar un ID que no existe.';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO:' + ERROR_MESSAGE();
END CATCH;
GO

-- 3.6 BAJA EXITOSA

BEGIN TRY
    PRINT 'PRUEBA 3.6: Baja Exitosa Especialidad';
    
    -- Para asegurarnos de que el testing de baja exitosa siempre funcione (incluso si 
    -- las otras especialidades están vinculadas a guías), insertamos una temporal y la borramos.
    EXEC empleados.sp_crear_especialidad @nombre = 'Especialidad A Borrar Temporal';

    DECLARE @id_esp_baja_exitosa INT = (SELECT MAX(id) FROM empleados.Especialidad);


    EXEC empleados.sp_eliminar_especialidad @id = @id_esp_baja_exitosa;
    
    PRINT 'RESULTADO: OK - Especialidad eliminada físicamente.';
    SELECT 'BAJA EXITOSA (Debe estar vacio)' AS Res_Esperado, * FROM empleados.Especialidad WHERE id = @id_esp_baja_exitosa;

END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO


-- 3.7 BAJA FALLIDA (ID Inexistente)

BEGIN TRY

    PRINT 'PRUEBA 3.7: Baja Fallida Especialidad (ID Inexistente)';
    
    EXEC empleados.sp_eliminar_especialidad @id = -1;
    
    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST: El SP intentó borrar un registro inexistente sin arrojar excepción de negocio.';

END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO


-- 3.8 BAJA FALLIDA (Dependencias Existentes con Guía)


-- Buscamos el ID de una especialidad que sabemos que está en uso por la tabla Guía
DECLARE @id_esp_ocupada INT = (SELECT TOP 1 id_especialidad FROM empleados.Guia);

BEGIN TRY

    PRINT 'PRUEBA 3.8: Baja Fallida Especialidad (Dependencia con Guía)';
    
    IF @id_esp_ocupada IS NOT NULL
    BEGIN
        EXEC empleados.sp_eliminar_especialidad @id = @id_esp_ocupada;
        PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST: El SP permitió borrar una Especialidad que está asignada a un Guía (GRAVE).';
    END

    ELSE
    BEGIN

        PRINT 'ADVERTENCIA: No hay guías registrados con especialidades para probar esta restricción.';

    END
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO


-- ==============================================================================
-- 4. TESTING: Titulo
-- ==============================================================================

BEGIN TRY

    PRINT '4.1 ALTA EXITOSA TITULO';

    EXEC empleados.sp_crear_titulo @nombre = 'Guia Turistico', @institucion = 'UNLaM';

    SELECT 'ALTA TITULO EXITOSA' AS Res_Esperado, * FROM empleados.Titulo WHERE id = IDENT_CURRENT('empleados.Titulo');

END TRY
BEGIN CATCH 
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY

    PRINT '4.2 MODIFICACION FALLIDA TITULO (ID Inexistente)';

    EXEC empleados.sp_modificar_titulo @id = -1, @nombre = 'Falla', @institucion = 'X';

    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST';

END TRY
BEGIN CATCH 
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO


-- ==============================================================================
-- 5. TESTING: Guia
-- ==============================================================================

-- Preparamos un empleado activo para ser Guía
DECLARE @id_tipo INT = (SELECT MAX(id) FROM empleados.TipoDocumento);
DECLARE @doc INT = CAST(RAND()*100000 AS INT);
EXEC empleados.sp_crear_empleado @nombre = 'Guia', @apellido = 'Test', @nro_doc = @doc, @id_tipo_documento = @id_tipo;
DECLARE @id_empleado_guia INT = (SELECT MAX(id) FROM empleados.Empleado);

-- 5.1 ALTA EXITOSA
DECLARE @id_esp INT = (SELECT MAX(id) FROM empleados.Especialidad);
DECLARE @id_tit INT = (SELECT MAX(id) FROM empleados.Titulo);

BEGIN TRY

    PRINT '5.1 ALTA EXITOSA GUIA';

    
    EXEC empleados.sp_crear_guia @nro_registro = 'RL-2026-123456-ENTUR', @id_empleado = @id_empleado_guia, @id_especialidad = @id_esp, @id_titulo = @id_tit;

    SELECT 'ALTA GUIA EXITOSA' AS Res_Esperado, * FROM empleados.Guia WHERE id_empleado = @id_empleado_guia;

END TRY
BEGIN CATCH 
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 5.2 ALTA FALLIDA (Ya es guía)
DECLARE @id_empleado_guia INT = (SELECT MAX(id_empleado) FROM empleados.Guia);
DECLARE @id_esp INT = (SELECT MAX(id) FROM empleados.Especialidad);
BEGIN TRY

    PRINT '5.2 ALTA FALLIDA GUIA (Empleado ya es guia)';

    EXEC empleados.sp_crear_guia @nro_registro = 'RL-2026-999999-ENTUR', @id_empleado = @id_empleado_guia, @id_especialidad = @id_esp;

    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST: Duplicó guia';

END TRY
BEGIN CATCH 
PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 5.3 MODIFICACION EXITOSA
DECLARE @id_empleado_guia INT = (SELECT MAX(id_empleado) FROM empleados.Guia);
DECLARE @id_esp INT = (SELECT MAX(id) FROM empleados.Especialidad);
BEGIN TRY

    PRINT '5.3 MODIFICACION EXITOSA GUIA';

    EXEC empleados.sp_modificar_guia @id_empleado = @id_empleado_guia, @nro_registro = 'RL-2026-111111-DGDTU', @id_especialidad = @id_esp, @id_titulo = NULL;

    SELECT 'MODIFICACION GUIA EXITOSA' AS Res_Esperado, * FROM empleados.Guia WHERE id_empleado = @id_empleado_guia;

END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ==============================================================================
-- 6. TESTING: Guardaparque
-- ==============================================================================

-- Preparamos un empleado activo
DECLARE @id_tipo INT = (SELECT MAX(id) FROM empleados.TipoDocumento);
DECLARE @doc INT = CAST(RAND()*100000 AS INT);
EXEC empleados.sp_crear_empleado @nombre = 'Guarda', @apellido = 'Parque', @nro_doc = @doc, @id_tipo_documento = @id_tipo;
DECLARE @id_emp_guarda INT = (SELECT MAX(id) FROM empleados.Empleado);

-- 6.1 ALTA EXITOSA
BEGIN TRY

    PRINT '6.1 ALTA EXITOSA GUARDAPARQUE';

    EXEC empleados.sp_crear_guardaparque @nro_matricula = 1001, @id_empleado = @id_emp_guarda;

    SELECT 'ALTA GUARDAPARQUE EXITOSA' AS Res_Esperado, * FROM empleados.Guardaparque WHERE id_empleado = @id_emp_guarda;

END TRY
BEGIN CATCH 
PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO

-- 6.2 MODIFICACION FALLIDA (ID Invalido)
BEGIN TRy
    
    PRINT '6.2 MODIFICACION FALLIDA GUARDAPARQUE (No existe)';
    
    EXEC empleados.sp_modificar_guardaparque @id_empleado = -1, @nro_matricula = 999;
    
    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST';

END TRY
BEGIN CATCH 
PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO

-- 6.3 BAJA LÓGICA EXITOSA
DECLARE @id_emp_guarda INT = (SELECT MAX(id_empleado) FROM empleados.Guardaparque);
BEGIN TRY
   
    PRINT '6.3 BAJA EXITOSA GUARDAPARQUE (Logica)';
    
    EXEC empleados.sp_eliminar_guardaparque @id_empleado = @id_emp_guarda;
    
    SELECT 'BAJA GUARDAPARQUE EXITOSA (Activo = 0)' AS Res_Esperado, id, activo FROM empleados.Empleado WHERE id = @id_emp_guarda;
END TRY
BEGIN CATCH 
PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO


-- ==============================================================================
-- 7. TESTING: GuardaparqueAsignado
-- ==============================================================================

-- ALTA EXITOSA GuardaparqueAsignado
DECLARE @id_guarda_asig_test INT = (SELECT MAX(id_empleado) FROM empleados.Guardaparque);
DECLARE @id_parque_asig_test INT = (SELECT MAX(id) FROM parques.Parque);
BEGIN TRY
    PRINT '7.1 ALTA EXITOSA ASIGNACION GUARDAPARQUE';
    
    IF @id_parque_asig_test IS NOT NULL
    BEGIN
        EXEC empleados.sp_asignar_guardaparque @id_empleado = @id_guarda_asig_test, @id_parque = @id_parque_asig_test, @fecha_ingreso = '2026-01-01';
        SELECT 'ALTA ASIGNACION EXITOSA' AS Res_Esperado, * FROM empleados.GuardaparqueAsignado WHERE id_empleado = @id_guarda_asig_test AND fecha_ingreso = '2026-01-01';
    END
END TRY
BEGIN CATCH PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- ALTA FALLIDA GuardaparqueAsignado (Guardaparque Inexistente)
DECLARE @id_parque_asig_test INT = (SELECT MAX(id) FROM parques.Parque);
BEGIN TRY
    PRINT '7.2 ALTA FALLIDA ASIGNACION GUARDAPARQUE (Guarda Inexistente)';
    
    EXEC empleados.sp_asignar_guardaparque @id_empleado = -1, @id_parque = @id_parque_asig_test, @fecha_ingreso = '2026-01-01';
    
    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST';
END TRY
BEGIN CATCH PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- BAJA LÓGICA EXITOSA GuardaparqueAsignado (Egreso)
DECLARE @id_guarda_egreso INT = (SELECT MAX(id_empleado) FROM empleados.GuardaparqueAsignado);
DECLARE @id_parque_egreso INT = (SELECT MAX(id_parque) FROM empleados.GuardaparqueAsignado WHERE id_empleado = @id_guarda_egreso);
DECLARE @fecha_ing_egreso DATE = (SELECT MAX(fecha_ingreso) FROM empleados.GuardaparqueAsignado WHERE id_empleado = @id_guarda_egreso AND id_parque = @id_parque_egreso);
BEGIN TRY
    PRINT '7.3 BAJA LOGICA EXITOSA ASIGNACION GUARDAPARQUE (Egreso)';
    
    EXEC empleados.sp_registrar_egreso_guardaparque @id_empleado = @id_guarda_egreso, @id_parque = @id_parque_egreso, @fecha_ingreso = @fecha_ing_egreso, @fecha_egreso = '2026-12-31', @motivo_egreso = 'Traslado';
    
    SELECT 'BAJA LOGICA ASIGNACION EXITOSA' AS Res_Esperado, * FROM empleados.GuardaparqueAsignado WHERE id_empleado = @id_guarda_egreso AND id_parque = @id_parque_egreso AND fecha_ingreso = @fecha_ing_egreso;
END TRY
BEGIN CATCH PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- BAJA LÓGICA FALLIDA GuardaparqueAsignado (Fechas Invertidas)
DECLARE @id_guarda_egreso INT = (SELECT MAX(id_empleado) FROM empleados.GuardaparqueAsignado);
DECLARE @id_parque_egreso INT = (SELECT MAX(id_parque) FROM empleados.GuardaparqueAsignado WHERE id_empleado = @id_guarda_egreso);
DECLARE @fecha_ing_egreso DATE = (SELECT MAX(fecha_ingreso) FROM empleados.GuardaparqueAsignado WHERE id_empleado = @id_guarda_egreso AND id_parque = @id_parque_egreso);
BEGIN TRY
    PRINT '7.4 BAJA LOGICA FALLIDA ASIGNACION GUARDAPARQUE (Fechas Invertidas)';
    
    EXEC empleados.sp_registrar_egreso_guardaparque @id_empleado = @id_guarda_egreso, @id_parque = @id_parque_egreso, @fecha_ingreso = @fecha_ing_egreso, @fecha_egreso = '2020-01-01';
    
    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST';
END TRY
BEGIN CATCH PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- BAJA FÍSICA EXITOSA GuardaparqueAsignado
DECLARE @id_guarda_fisica INT = (SELECT MAX(id_empleado) FROM empleados.GuardaparqueAsignado);
DECLARE @id_parque_fisica INT = (SELECT MAX(id_parque) FROM empleados.GuardaparqueAsignado WHERE id_empleado = @id_guarda_fisica);
DECLARE @fecha_ing_fisica DATE = (SELECT MAX(fecha_ingreso) FROM empleados.GuardaparqueAsignado WHERE id_empleado = @id_guarda_fisica AND id_parque = @id_parque_fisica);
BEGIN TRY
    PRINT '7.5 BAJA FISICA EXITOSA ASIGNACION GUARDAPARQUE';
    
    EXEC empleados.sp_eliminar_asignacion_guardaparque @id_empleado = @id_guarda_fisica, @id_parque = @id_parque_fisica, @fecha_ingreso = @fecha_ing_fisica;
    
    SELECT 'BAJA FISICA ASIGNACION EXITOSA (Vacio)' AS Res_Esperado, * FROM empleados.GuardaparqueAsignado WHERE id_empleado = @id_guarda_fisica AND id_parque = @id_parque_fisica AND fecha_ingreso = @fecha_ing_fisica;
END TRY
BEGIN CATCH PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- BAJA FÍSICA FALLIDA GuardaparqueAsignado (No existe)
BEGIN TRY
    PRINT '7.6 BAJA FISICA FALLIDA ASIGNACION GUARDAPARQUE (No existe)';
    
    EXEC empleados.sp_eliminar_asignacion_guardaparque @id_empleado = -1, @id_parque = -1, @fecha_ingreso = '2026-01-01';
    
    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST';
END TRY
BEGIN CATCH PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO


-- ==============================================================================
-- 8. TESTING: GuiaPoseeHabilitacion
-- ==============================================================================

-- ALTA EXITOSA GuiaPoseeHabilitacion
DECLARE @id_guia_hab_test INT = (SELECT MAX(id_empleado) FROM empleados.Guia);
DECLARE @id_hab_test INT = (SELECT MAX(id) FROM actividades.Habilitacion);
DECLARE @fecha_ini_hab DATE = '2026-01-01';
BEGIN TRY
    PRINT '8.1 ALTA EXITOSA ASIGNACION HABILITACION GUIA';
    
    EXEC empleados.sp_asignar_habilitacion_guia @id_empleado = @id_guia_hab_test, @id_habilitacion = @id_hab_test, @fecha_inicio = @fecha_ini_hab;
        
    SELECT 'ALTA HABILITACION GUIA EXITOSA' AS Res_Esperado, * FROM empleados.GuiaPoseeHabilitacion 
    WHERE id_empleado = @id_guia_hab_test AND id_habilitacion = @id_hab_test AND fecha_inicio = @fecha_ini_hab;
END TRY
BEGIN CATCH PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- ALTA FALLIDA GuiaPoseeHabilitacion (ID Inexistente)
BEGIN TRY
    PRINT '8.2 ALTA FALLIDA ASIGNACION HABILITACION GUIA (ID Inexistente)';
    
    EXEC empleados.sp_asignar_habilitacion_guia @id_empleado = -1, @id_habilitacion = -1, @fecha_inicio = '2026-01-01';
        
    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST';
END TRY
BEGIN CATCH PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- BAJA LÓGICA EXITOSA GuiaPoseeHabilitacion (Revocar)
DECLARE @id_guia_hab_test INT = (SELECT MAX(id_empleado) FROM empleados.GuiaPoseeHabilitacion);
DECLARE @id_hab_test INT = (SELECT MAX(id_habilitacion) FROM empleados.GuiaPoseeHabilitacion WHERE id_empleado = @id_guia_hab_test);
DECLARE @fecha_ini_hab DATE = (SELECT MAX(fecha_inicio) FROM empleados.GuiaPoseeHabilitacion WHERE id_empleado = @id_guia_hab_test AND id_habilitacion = @id_hab_test);
BEGIN TRY
    PRINT '8.3 BAJA LÓGICA EXITOSA HABILITACION GUIA (Revocar)';
    
    EXEC empleados.sp_revocar_habilitacion_guia @id_empleado = @id_guia_hab_test, @id_habilitacion = @id_hab_test, @fecha_inicio = @fecha_ini_hab, @fecha_fin = '2026-12-31';
        
    SELECT 'BAJA LOGICA HABILITACION GUIA EXITOSA' AS Res_Esperado, * FROM empleados.GuiaPoseeHabilitacion 
    WHERE id_empleado = @id_guia_hab_test AND id_habilitacion = @id_hab_test AND fecha_inicio = @fecha_ini_hab;
END TRY
BEGIN CATCH PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- BAJA LÓGICA FALLIDA GuiaPoseeHabilitacion (Fechas invertidas)
DECLARE @id_guia_hab_test INT = (SELECT MAX(id_empleado) FROM empleados.GuiaPoseeHabilitacion);
DECLARE @id_hab_test INT = (SELECT MAX(id_habilitacion) FROM empleados.GuiaPoseeHabilitacion WHERE id_empleado = @id_guia_hab_test);
DECLARE @fecha_ini_hab DATE = (SELECT MAX(fecha_inicio) FROM empleados.GuiaPoseeHabilitacion WHERE id_empleado = @id_guia_hab_test AND id_habilitacion = @id_hab_test);
BEGIN TRY
    PRINT '8.4 BAJA LÓGICA FALLIDA HABILITACION GUIA (Fechas invertidas)';
    
    EXEC empleados.sp_revocar_habilitacion_guia @id_empleado = @id_guia_hab_test, @id_habilitacion = @id_hab_test, @fecha_inicio = @fecha_ini_hab, @fecha_fin = '2025-01-01';
        
    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST';
END TRY
BEGIN CATCH PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- BAJA FÍSICA EXITOSA GuiaPoseeHabilitacion
DECLARE @id_guia_hab_test INT = (SELECT MAX(id_empleado) FROM empleados.GuiaPoseeHabilitacion);
DECLARE @id_hab_test INT = (SELECT MAX(id_habilitacion) FROM empleados.GuiaPoseeHabilitacion WHERE id_empleado = @id_guia_hab_test);
DECLARE @fecha_ini_hab DATE = (SELECT MAX(fecha_inicio) FROM empleados.GuiaPoseeHabilitacion WHERE id_empleado = @id_guia_hab_test AND id_habilitacion = @id_hab_test);
BEGIN TRY
    PRINT '8.5 BAJA FÍSICA EXITOSA HABILITACION GUIA';
    
    EXEC empleados.sp_eliminar_asignacion_habilitacion @id_empleado = @id_guia_hab_test, @id_habilitacion = @id_hab_test, @fecha_inicio = @fecha_ini_hab;
        
    SELECT 'BAJA FISICA EXITOSA (Vacio)' AS Res_Esperado, * FROM empleados.GuiaPoseeHabilitacion 
    WHERE id_empleado = @id_guia_hab_test AND id_habilitacion = @id_hab_test AND fecha_inicio = @fecha_ini_hab;
END TRY
BEGIN CATCH PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- BAJA FÍSICA FALLIDA GuiaPoseeHabilitacion (No existe)
BEGIN TRY
    PRINT '8.6 BAJA FÍSICA FALLIDA HABILITACION GUIA (No existe)';
    
    EXEC empleados.sp_eliminar_asignacion_habilitacion @id_empleado = -1, @id_habilitacion = -1, @fecha_inicio = '2026-01-01';
        
    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST';
END TRY
BEGIN CATCH PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO


-- ==============================================================================
-- 9. TESTING: GuiaEstaEnActividad
-- ==============================================================================

-- ALTA EXITOSA GuiaEstaEnActividad
DECLARE @id_guia_act_test INT = (SELECT MAX(id_empleado) FROM empleados.Guia);
DECLARE @id_act_test INT = (SELECT MAX(id) FROM actividades.Actividad);
DECLARE @fecha_ini_act DATE = '2026-02-01';
BEGIN TRY
    PRINT '9.1 ALTA EXITOSA ASIGNACION ACTIVIDAD GUIA';
    
    EXEC empleados.sp_asignar_actividad_guia @id_empleado = @id_guia_act_test, @id_actividad = @id_act_test, @fecha_inicio = @fecha_ini_act;
        
    SELECT 'ALTA ACTIVIDAD GUIA EXITOSA' AS Res_Esperado, * FROM empleados.GuiaEstaEnActividad 
    WHERE id_empleado = @id_guia_act_test AND id_actividad = @id_act_test AND fecha_inicio = @fecha_ini_act;
END TRY
BEGIN CATCH PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- ALTA FALLIDA GuiaEstaEnActividad (ID Inexistente)
BEGIN TRY
    PRINT '9.2 ALTA FALLIDA ASIGNACION ACTIVIDAD GUIA (ID Inexistente)';
    
    EXEC empleados.sp_asignar_actividad_guia @id_empleado = -1, @id_actividad = -1, @fecha_inicio = '2026-02-01';
        
    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST';
END TRY
BEGIN CATCH PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- BAJA LÓGICA EXITOSA GuiaEstaEnActividad (Registrar fin)
DECLARE @id_guia_act_test INT = (SELECT MAX(id_empleado) FROM empleados.GuiaEstaEnActividad);
DECLARE @id_act_test INT = (SELECT MAX(id_actividad) FROM empleados.GuiaEstaEnActividad WHERE id_empleado = @id_guia_act_test);
DECLARE @fecha_ini_act DATE = (SELECT MAX(fecha_inicio) FROM empleados.GuiaEstaEnActividad WHERE id_empleado = @id_guia_act_test AND id_actividad = @id_act_test);
BEGIN TRY
    PRINT '9.3 BAJA LÓGICA EXITOSA ACTIVIDAD GUIA (Registrar fin)';
    
    EXEC empleados.sp_registrar_fin_actividad_guia @id_empleado = @id_guia_act_test, @id_actividad = @id_act_test, @fecha_inicio = @fecha_ini_act, @fecha_fin = '2026-12-31';
        
    SELECT 'BAJA LOGICA ACTIVIDAD GUIA EXITOSA' AS Res_Esperado, * FROM empleados.GuiaEstaEnActividad 
    WHERE id_empleado = @id_guia_act_test AND id_actividad = @id_act_test AND fecha_inicio = @fecha_ini_act;
END TRY
BEGIN CATCH PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- BAJA LÓGICA FALLIDA GuiaEstaEnActividad (Fechas invertidas)
DECLARE @id_guia_act_test INT = (SELECT MAX(id_empleado) FROM empleados.GuiaEstaEnActividad);
DECLARE @id_act_test INT = (SELECT MAX(id_actividad) FROM empleados.GuiaEstaEnActividad WHERE id_empleado = @id_guia_act_test);
DECLARE @fecha_ini_act DATE = (SELECT MAX(fecha_inicio) FROM empleados.GuiaEstaEnActividad WHERE id_empleado = @id_guia_act_test AND id_actividad = @id_act_test);
BEGIN TRY
    PRINT '9.4 BAJA LÓGICA FALLIDA ACTIVIDAD GUIA (Fechas invertidas)';
    
    EXEC empleados.sp_registrar_fin_actividad_guia @id_empleado = @id_guia_act_test, @id_actividad = @id_act_test, @fecha_inicio = @fecha_ini_act, @fecha_fin = '2025-01-01';
        
    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST';
END TRY
BEGIN CATCH PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- BAJA FÍSICA EXITOSA GuiaEstaEnActividad
DECLARE @id_guia_act_test INT = (SELECT MAX(id_empleado) FROM empleados.GuiaEstaEnActividad);
DECLARE @id_act_test INT = (SELECT MAX(id_actividad) FROM empleados.GuiaEstaEnActividad WHERE id_empleado = @id_guia_act_test);
DECLARE @fecha_ini_act DATE = (SELECT MAX(fecha_inicio) FROM empleados.GuiaEstaEnActividad WHERE id_empleado = @id_guia_act_test AND id_actividad = @id_act_test);
BEGIN TRY
    PRINT '9.5 BAJA FÍSICA EXITOSA ACTIVIDAD GUIA';
    
    EXEC empleados.sp_eliminar_asignacion_actividad @id_empleado = @id_guia_act_test, @id_actividad = @id_act_test, @fecha_inicio = @fecha_ini_act;
        
    SELECT 'BAJA FISICA EXITOSA (Vacio)' AS Res_Esperado, * FROM empleados.GuiaEstaEnActividad 
    WHERE id_empleado = @id_guia_act_test AND id_actividad = @id_act_test AND fecha_inicio = @fecha_ini_act;
END TRY
BEGIN CATCH PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO

-- BAJA FÍSICA FALLIDA GuiaEstaEnActividad (No existe)
BEGIN TRY
    PRINT '9.6 BAJA FÍSICA FALLIDA ACTIVIDAD GUIA (No existe)';
    
    EXEC empleados.sp_eliminar_asignacion_actividad @id_empleado = -1, @id_actividad = -1, @fecha_inicio = '2026-02-01';
        
    PRINT 'SI IMPRIMIÓ ESTO FALLÓ EL TEST';
END TRY
BEGIN CATCH PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE(); END CATCH;
GO