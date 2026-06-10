USE LinuxPreachers;
GO

SET NOCOUNT ON;

-- ------------------------------------------------------------------------------
-- PREPARACIÓN DE ENTORNO (MOCK DATA)
-- Se generan datos temporales necesarios para satisfacer las claves foráneas.
-- ------------------------------------------------------------------------------
DECLARE @id_parque_test INT;
DECLARE @id_tipo_actividad_test INT;
DECLARE @id_actividad_insertada INT;

/**
    FALTA LA CREACION DEL SP PARA PODER REALIZAR EL TESTING
*/
-- EXEC sgpn.sp_crear_parque @nombre=,@ubicacion=,@superficie=, @tipo= ) 


EXEC sgpn.sp_crear_tipo_actividad @nombre = 'Excursión de Prueba';

PRINT '==================================================';
PRINT 'INICIO DE TESTING: ABM ACTIVIDADES';
PRINT '==================================================';

-- ------------------------------------------------------------------------------
-- PRUEBA 1: ALTA EXITOSA
-- ------------------------------------------------------------------------------
PRINT  '>>> PRUEBA 1: Alta Exitosa de Actividad';
BEGIN TRY
    EXEC sgpn.sp_crear_actividad 
        @nombre = 'Caminata Nocturna',
        @descripcion = 'Recorrido guiado bajo las estrellas',
        @cupo_maximo = 20,
        @duracion_minutos = 120,
        @precio = 1500.50,
        @id_parque = @id_parque_test,
        @id_tipo_actividad = @id_tipo_actividad_test;

    -- Recuperar el ID generado para la evidencia
    SELECT TOP 1 @id_actividad_insertada = id FROM sgpn.Actividad ORDER BY id DESC;
    
    PRINT 'RESULTADO: OK - Actividad creada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA DE ALTA EJECUTADA CORRECTAMENTE' AS Operacion, * FROM sgpn.Actividad WHERE id = @id_actividad_insertada;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;

-- ------------------------------------------------------------------------------
-- PRUEBA 2: ALTA CON FALLA (Validaciones de negocio acumuladas)
-- ------------------------------------------------------------------------------
PRINT '>>> PRUEBA 2: Alta Fallida (Nombre nulo, precio negativo, cupo 0)';
BEGIN TRY
    EXEC sgpn.sp_crear_actividad 
        @nombre = '',                 -- Error: Vacío
        @descripcion = 'Invalido',
        @cupo_maximo = 0,             -- Error: Cupo 0
        @duracion_minutos = 60,
        @precio = -500.00,            -- Error: Precio negativo
        @id_parque = @id_parque_test,
        @id_tipo_actividad = @id_tipo_actividad_test;
    
    PRINT 'RESULTADO: FALLO - El SP permitió insertar datos inválidos.';
END TRY
BEGIN CATCH
    PRINT 'RESULTADO: OK - El SP bloqueó la inserción. Mensaje recibido:';
    PRINT ERROR_MESSAGE();
END CATCH;

-- ------------------------------------------------------------------------------
-- PRUEBA 3: MODIFICACIÓN EXITOSA
-- ------------------------------------------------------------------------------
PRINT CHAR(13) + '>>> PRUEBA 3: Modificación Exitosa de Actividad';
BEGIN TRY
    EXEC sgpn.sp_modificar_actividad 
        @id = @id_actividad_insertada,
        @nombre = 'Caminata Nocturna Extendida',
        @descripcion = 'Recorrido de 3 horas modificado',
        @cupo_maximo = 25,
        @duracion_minutos = 180,
        @precio = 2000.00,
        @id_parque = @id_parque_test,
        @id_tipo_actividad = @id_tipo_actividad_test;

    PRINT 'RESULTADO: OK - Actividad modificada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA MODIFICACION' AS Operacion, * FROM sgpn.Actividad WHERE id = @id_actividad_insertada;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;

-- ------------------------------------------------------------------------------
-- PRUEBA 4: MODIFICACIÓN CON FALLA (Integridad referencial)
-- ------------------------------------------------------------------------------
PRINT CHAR(13) + '>>> PRUEBA 4: Modificación Fallida (Parque Inexistente)';
BEGIN TRY
    EXEC sgpn.sp_modificar_actividad 
        @id = @id_actividad_insertada,
        @nombre = 'Caminata Nocturna',
        @descripcion = 'Intento de asginar a parque falso',
        @cupo_maximo = 20,
        @duracion_minutos = 120,
        @precio = 1500.00,
        @id_parque = 999999, -- Error: ID no existe
        @id_tipo_actividad = @id_tipo_actividad_test;
    
    PRINT 'RESULTADO: FALLO - El SP permitió asignar un parque inexistente.';
END TRY
BEGIN CATCH
    PRINT 'RESULTADO: OK - El SP bloqueó la modificación. Mensaje recibido:';
    PRINT ERROR_MESSAGE();
END CATCH;

-- ------------------------------------------------------------------------------
-- PRUEBA 5: BAJA CON FALLA (Dependencias existentes)
-- ------------------------------------------------------------------------------
PRINT CHAR(13) + '>>> PRUEBA 5: Baja Fallida (Actividad con Horario asignado)';
BEGIN TRY
    -- Insertamos un horario dependiente para forzar la falla
    EXEC sgpn.sp_crear_horario 
        @hora_inicio = '10:00', @hora_fin = '12:00', @dia_semana = 1, 
        @fecha_vigencia_ini = '2026-01-01', @fecha_vigencia_fin = NULL, 
        @visible = 1, @id_actividad = @id_actividad_insertada;

    -- Intentamos eliminar
    EXEC sgpn.sp_eliminar_actividad @id = @id_actividad_insertada;

    PRINT 'RESULTADO: FALLO - El SP permitió eliminar una actividad con dependencias.';
END TRY
BEGIN CATCH
    PRINT 'RESULTADO: OK - El SP bloqueó la eliminación preventiva. Mensaje recibido:';
    PRINT ERROR_MESSAGE();
END CATCH;

-- ------------------------------------------------------------------------------
-- PRUEBA 6: BAJA EXITOSA
-- ------------------------------------------------------------------------------
PRINT CHAR(13) + '>>> PRUEBA 6: Baja Exitosa de Actividad';
BEGIN TRY
    -- Limpiamos la dependencia primero
    DELETE FROM sgpn.Horario WHERE id_actividad = @id_actividad_insertada;

    -- Ejecutamos el SP de baja
    EXEC sgpn.sp_eliminar_actividad @id = @id_actividad_insertada;

    PRINT 'RESULTADO: OK - Actividad eliminada correctamente.';
    
    -- Evidencia:
    SELECT 'EVIDENCIA BAJA (Debe estar vacio)' AS Operacion, * FROM sgpn.Actividad WHERE id = @id_actividad_insertada;
END TRY
BEGIN CATCH
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();
END CATCH;

-- ------------------------------------------------------------------------------
-- LIMPIEZA DE ENTORNO (Rollback manual del Mock Data)
-- ------------------------------------------------------------------------------
DELETE FROM sgpn.TipoActividad WHERE id = @id_tipo_actividad_test;
DELETE FROM sgpn.Parque WHERE id = @id_parque_test;

PRINT CHAR(13) + '==================================================';
PRINT 'FIN DE TESTING';
PRINT '==================================================';
GO