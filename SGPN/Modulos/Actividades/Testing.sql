/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha: 2026-06-12
 * Script: Testing ABM módulo actividades (Ejecución por bloques independientes)
*/

USE LinuxPreachers;
GO

-- ==============================================================================
-- 1. TESTING: TipoActividad
-- ==============================================================================
DBCC CHECKIDENT ('actividades.TipoActividad', RESEED, 0);
GO
-- 1.1 ALTA EXITOSA 
DECLARE @nombre_tipo VARCHAR(40) = 'Testing de Tipo de Actividad';
BEGIN TRY
    PRINT 'NOMBRE VALIDO, SE ESPERA QUE EL ALTA SEA EXITOSO'
    EXEC actividades.sp_crear_tipo_actividad @nombre = @nombre_tipo;
    
    SELECT 'RESULTADO ALTA EXITOSA' AS Res_Esperado, id FROM actividades.TipoActividad WHERE nombre = @nombre_tipo;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 1.2 ALTA FALLIDA - Parámetro NULL
BEGIN TRY
    PRINT 'Nombre en null, DEBE FALLAR'
    EXEC actividades.sp_crear_tipo_actividad @nombre = NULL;
    
END TRY
BEGIN CATCH
    PRINT 'RESULTADO:El SP bloqueó la inserción. Mensaje: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 1.3 MODIFICACIÓN EXITOSA
DECLARE @id_tipo_modificar INT = (SELECT MAX(id) FROM actividades.TipoActividad);
SELECT @id_tipo_modificar
BEGIN TRY
    PRINT 'SE ELIJE EL ULTIMO ID A MODIFICAR POR PURA ELECCIÓN. SI NO EXISTE ID, ENTRA AL CATCH';
    EXEC actividades.sp_modificar_tipo_actividad @id = @id_tipo_modificar, @nombre = 'Tipo Modificado Test';
    
    PRINT 'SI EJECUTO ESTO SIGNIFICA QUE SE MODIFICÓ CORRECTAMENTE ';

    SELECT 'RESULTADO MODIFICACION EXITOSA' AS Res_Esperado, id FROM actividades.TipoActividad WHERE id = @id_tipo_modificar;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ==============================================================================
-- 2. TESTING: Habilitacion
-- ==============================================================================

-- 2.1 ALTA EXITOSA
DECLARE @nombre_hab VARCHAR(100) = 'Testing de Habilitacion';
BEGIN TRY
    PRINT 'NOMBRE VALIDO, SE ESPERA QUE EL ALTA SEA EXITOSO';
    EXEC actividades.sp_crear_habilitacion @nombre = @nombre_hab, @descripcion = 'Desc Test';
    
    PRINT 'SI EJECUTO ESTO SE DIO DE ALTA CORRECTAMENTE';

    SELECT 'RESULTADO ALTA HABILITACION' AS Res_Esperado, id FROM actividades.Habilitacion WHERE nombre = @nombre_hab;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 2.2 BAJA EXITOSA (Limpiamos la habilitación recién creada para probar)
DECLARE @id_hab_eliminar INT = (SELECT MAX(id) FROM actividades.Habilitacion);
BEGIN TRY
    PRINT 'BAJA DE HABILITACION';
    EXEC actividades.sp_eliminar_habilitacion @id = @id_hab_eliminar;
    
    PRINT 'RESULTADO: OK - Habilitación eliminada.';
    SELECT 'EVIDENCIA BAJA HAB (Debe estar vacio)' AS Operacion, id FROM actividades.Habilitacion WHERE id = @id_hab_eliminar;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ==============================================================================
-- 3. TESTING: Actividad
-- ==============================================================================
    
-- 3.1 ALTA EXITOSA
-- Nota: Requiere que exista al menos un Parque y un TipoActividad en la BD.
DECLARE @id_parque_test INT = (SELECT TOP 1 id FROM parques.Parque);
DECLARE @id_tipo_test INT = (SELECT TOP 1 id FROM actividades.TipoActividad);
DECLARE @nombre_actividad VARCHAR(30) = 'Actividad Test ';

BEGIN TRY
    PRINT 'ALTA EXITOSA DE ACTIVIDAD';
    
   
        EXEC actividades.sp_crear_actividad 
            @nombre = @nombre_actividad, @descripcion = 'Desc', 
            @cupo_maximo = 10, @duracion_minutos = 60, @precio = 1500.00, 
            @id_parque = @id_parque_test, @id_tipo_actividad = @id_tipo_test;
        
        PRINT 'RESULTADO: OK - Actividad insertada.';
        SELECT 'EVIDENCIA ALTA ACT' AS Res_Esperado, * FROM actividades.Actividad WHERE nombre = @nombre_actividad;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 3.2 ALTA FALLIDA (Validaciones acumuladas: Precio negativo, Cupo 0, Duracion 0)
DECLARE @id_parque_test INT = (SELECT TOP 1 id FROM parques.Parque);
DECLARE @id_tipo_test INT = (SELECT TOP 1 id FROM actividades.TipoActividad);
DECLARE @nombre_test VARCHAR(30) = 'FALLA TEST';
BEGIN TRY
    PRINT 'ALTA FALLIDA : ATRIBUTOS INVALIDOS';
    EXEC actividades.sp_crear_actividad 
        @nombre = @nombre_test, @descripcion = 'Desc', 
        @cupo_maximo = 0, @duracion_minutos = -10, @precio = -500.00, 
        @id_parque = @id_parque_test, @id_tipo_actividad = @id_tipo_test;
    
    PRINT 'RESULTADO: FALLO - Se insertaron datos inválidos.';
END TRY
BEGIN CATCH
    PRINT 'RESULTADO: OK - El SP bloqueó la inserción. Errores detectados:';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

-- 3.3 BAJA FALLIDA (Actividad con Horario asignado)
DECLARE @id_act_test INT = (SELECT MAX(id) FROM actividades.Actividad);
BEGIN TRY
    PRINT 'BAJA FALLIDA: DEPENDENCIAS ENLAZADAS';
    
    -- Insertamos dependencia forzada
    EXEC actividades.sp_crear_horario 
        @hora_inicio = '10:00', @hora_fin = '12:00', @dia_semana = 1, 
        @fecha_vigencia_ini = '2026-01-01', @fecha_vigencia_fin = NULL, 
        @visible = 1, @id_actividad = @id_act_test;

    -- Intentamos borrar la actividad
    EXEC actividades.sp_eliminar_actividad @id = @id_act_test;

    PRINT 'RESULTADO: FALLO - Se eliminó a pesar de tener dependencias.';
END TRY
BEGIN CATCH
    PRINT 'RESULTADO: OK - El SP bloqueó la baja preventiva. Mensaje: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ==============================================================================
-- 4. TESTING: Horario
-- ==============================================================================

-- 4.1 ALTA EXITOSA
-- Nota: Requiere que exista al menos una Actividad en la BD.
DECLARE @id_actividad_horario INT = (SELECT TOP 1 id FROM actividades.Actividad);

BEGIN TRY
    PRINT 'ALTA EXITOSA DE HORARIO';
    
    
       EXEC actividades.sp_crear_horario 
            @hora_inicio = '08:00', 
            @hora_fin = '12:00', 
            @dia_semana = 1, -- 1 = Lunes
            @fecha_vigencia_ini = '2026-01-01', 
            @fecha_vigencia_fin = NULL, 
            @visible = 1, 
            @id_actividad = @id_actividad_horario;
        
        PRINT 'RESULTADO: OK - Horario insertado.';
        
       
        
        SELECT 'ALTA HORARIO' AS Res_Esperado, * FROM actividades.Horario WHERE id = (SELECT MAX(id) FROM actividades.Horario);

END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 4.2 ALTA FALLIDA (Validación de negocio: Actividad inexistente)
BEGIN TRY
    PRINT 'ALTA FALLIDA: DEPENDENCIA CON ACTIVIDAD';
    
    EXEC actividades.sp_crear_horario 
        @hora_inicio = '08:00', 
        @hora_fin = '12:00', 
        @dia_semana = 1, 
        @fecha_vigencia_ini = '2026-01-01', 
        @fecha_vigencia_fin = NULL, 
        @visible = 1, 
        @id_actividad = 999999; -- ID que no existe
    
    PRINT 'RESULTADO: FALLO - El SP permitió asignar una actividad inexistente.';
END TRY
BEGIN CATCH
    PRINT 'RESULTADO: OK - El SP bloqueó la inserción. Mensaje recibido:';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

-- 4.3 MODIFICACIÓN EXITOSA
DECLARE @id_horario_modificar INT = (SELECT MAX(id) FROM actividades.Horario);
DECLARE @id_actividad_horario INT = (SELECT TOP 1 id FROM actividades.Actividad);

BEGIN TRY
    PRINT 'MODIFICACIÓN EXITOSA: MODIFICACION DE PARAMETROS';
    
   
        EXEC actividades.sp_modificar_horario 
            @id = @id_horario_modificar,
            @hora_inicio = '14:00', 
            @hora_fin = '18:00',    
            @dia_semana = 3,       
            @fecha_vigencia_ini = '2026-06-01', 
            @fecha_vigencia_fin = '2026-12-31', 
            @visible = 1, 
            @id_actividad = @id_actividad_horario;
        
        PRINT 'RESULTADO: OK - Horario modificado.';
        SELECT 'MODIFICACION HORARIO' AS Res_Esperado, * FROM actividades.Horario WHERE id = @id_horario_modificar;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 4.4 BAJA LÓGICA EXITOSA
DECLARE @id_horario_eliminar INT = (SELECT MAX(id) FROM actividades.Horario);

BEGIN TRY
    PRINT 'UPDATE DE HORARIO A NO VISIBLE';
    
        EXEC actividades.sp_eliminar_horario @id = @id_horario_eliminar;
        
        PRINT 'RESULTADO: OK - Horario dado de baja lógicamente.';
        SELECT 'BAJA LOGICA HORARIO' AS Res_Test,id, visible FROM actividades.Horario WHERE id = @id_horario_eliminar;

END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO


-- ==============================================================================
-- 5. TESTING: HabilitacionRegulaActividad
-- ==============================================================================

-- 5.1 ALTA EXITOSA DE RELACIÓN
DECLARE @id_act_rel INT = (SELECT MAX(id) FROM actividades.Actividad);
DECLARE @id_hab_rel INT;
BEGIN TRY
    PRINT ' ALTA EXITOSA DE RELACION ENTRE HABILITACION Y ACTIVIDAD';
    
    -- Creamos una habilitación rápida para la relación
    EXEC actividades.sp_crear_habilitacion @nombre = 'HabRegAct', @descripcion = '';
    SET @id_hab_rel = (SELECT MAX(id) FROM actividades.Habilitacion);

    EXEC actividades.sp_crear_habilitacion_regula_actividad @id_habilitacion = @id_hab_rel, @id_actividad = @id_act_rel;
    
    PRINT 'RESULTADO: OK - Relación creada.';
    SELECT 'EVIDENCIA RELACION' AS Operacion, * FROM actividades.HabilitacionRegulaActividad 
    WHERE id_habilitacion = @id_hab_rel AND id_actividad = @id_act_rel;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;
GO