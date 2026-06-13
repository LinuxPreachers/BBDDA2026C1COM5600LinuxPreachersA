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


-- 1.1 ALTA EXITOSA 
DECLARE @nombre_tipo VARCHAR(40) = 'Testing de Tipo de Actividad';

BEGIN TRY

    PRINT 'NOMBRE VALIDO, SE ESPERA QUE EL ALTA SEA EXITOSO'

    EXEC actividades.sp_crear_tipo_actividad @nombre = @nombre_tipo;
    
    SELECT 'RESULTADO ALTA EXITOSA' AS Res_Esperado, id 
    FROM actividades.TipoActividad 
    WHERE nombre = @nombre_tipo;

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


-- 1.4 MODIFICACION FALLIDA

DECLARE @id_tipo_actividad INT = (SELECT MAX(id) FROM actividades.TipoActividad) +1; -- PONEMOS UN ID INVALIDO

BEGIN TRY

    PRINT 'ID NO EXISTENTE, DEBERIA FALLAR'

    EXEC actividades.sp_modificar_tipo_actividad @id= @id_tipo_actividad,@nombre = 'Modificacion fallida'

    PRINT 'SI EJECUTÓ ESTO SIGNIFICA QUE PERMITIO MODIFICAR UN ID NO EXISTENTE'

    SELECT 'RESULTADO MODIFICACION FALLIDA' AS Res_Esperado, id FROM actividades.TipoActividad WHERE id = @id_tipo_actividad;

END TRY

BEGIN CATCH

    PRINT ' ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO


-- 1.5 BAJA EXITOSA

--Tomamos el id insertado en el testing 1.1 
--(se intuye que no tiene actividades asociadas)

DECLARE @id_tipo_actividad_baja INT = (SELECT MAX(id) FROM actividades.TipoActividad );

BEGIN TRY

    PRINT ' ID EXISTENTE SIN ACTIVIDAD VINCULADA, DEBERIA PERMITIR LA BAJA'

    EXEC actividades.sp_eliminar_tipo_actividad @id = @id_tipo_actividad_baja

    SELECT 'RESULTADO BAJA EXITOSA' AS Res_Esperado, id FROM actividades.TipoActividad WHERE id = @id_tipo_actividad_baja;

END TRY

BEGIN CATCH

    PRINT ' ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO


-- 1.6 BAJA FALLIDA (ID INVALIDO)

DECLARE @id_tipo_actividad_baja_fallida INT = (SELECT MAX(id) FROM actividades.TipoActividad) + 1;

BEGIN TRY

    PRINT ' ID INEXISTENTE, DEBERIA FALLAR'

    EXEC actividades.sp_eliminar_tipo_actividad @id = @id_tipo_actividad_baja_fallida

    PRINT 'SI MOSTRÓ ESTO, EL SP PERMITIÓ LA BAJA DE UN ID INEXISTENTE'

END TRY

BEGIN CATCH

    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH


--1.7 BAJA FALLIDA (TIPO ACTIVIDAD CON ACTIVIDAD ASOCIADA)

-- Tomamos el primer id porque se intuye que tiene una actividad asociada
DECLARE @id_tipo_actividad_baja_ INT = (SELECT MIN(id) FROM actividades.TipoActividad);

BEGIN TRY

    PRINT ' ID EXISTENTE PERO CON ACTIVIDADES ASOCIADAS, DEBERIA FALLAR'

    EXEC actividades.sp_eliminar_tipo_actividad @id = @id_tipo_actividad_baja_

    PRINT ' SI MOSTRÓ ESTO, EL SP PERMITIÓ LA BAJA DE UN TIPO DE ACTIVIDAD CON ACTIVIDADES ASOCIADAS'

END TRY

BEGIN CATCH

    PRINT ' ERROR ESPERADO: ' + ERROR_MESSAGE();

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
    
    PRINT 'SI EJECUTó ESTO SE DIO DE ALTA CORRECTAMENTE';

    SELECT 'RESULTADO ALTA HABILITACION' AS Res_Esperado, id FROM actividades.Habilitacion WHERE nombre = @nombre_hab;

END TRY

BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

-- 2.2 ALTA FALLIDA 

DECLARE @nombre_hab_fallida VARCHAR(100) = ''

BEGIN TRY

    PRINT 'NOMBRE VACIO, DEBERIA FALLAR'
    
    EXEC actividades.sp_crear_habilitacion @nombre = @nombre_hab_fallida;

    PRINT ' SI EJECUTÓ ESTO PERMITIO LA ALTA DE UN NOMBRE VACIO'

     SELECT 'RESULTADO ALTA HABILITACION' AS Res_Esperado, id FROM actividades.Habilitacion WHERE nombre = @nombre_hab_fallida;

END TRY

BEGIN CATCH 

    PRINT ' ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH
GO

-- 2.3 MODIFICACIÓN EXITOSA

DECLARE @id_hab_modificar INT = (SELECT MAX(id) FROM actividades.Habilitacion);

BEGIN TRY

    PRINT 'SE ELIJE EL ULTIMO ID A MODIFICAR POR PURA ELECCIÓN. SI NO EXISTE ID, ENTRA AL CATCH';

    EXEC actividades.sp_modificar_habilitacion @id = @id_hab_modificar, @nombre = 'Tipo Modificado Test', @descripcion = 'Modif exitosa';
    
    PRINT 'SI EJECUTO ESTO SIGNIFICA QUE SE MODIFICÓ CORRECTAMENTE ';

    SELECT 'RESULTADO MODIFICACION EXITOSA' AS Res_Esperado, id FROM actividades.TipoActividad WHERE id = @id_hab_modificar;

END TRY

BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

-- 2.4 MODIFICACIÓN FALLIDA (ID INVALIDO)

DECLARE @id_hab_modificar_fallida INT = (SELECT MAX(id) FROM actividades.Habilitacion) + 1 ;

BEGIN TRY

    PRINT 'ID INVALIDO, NO DEBERIA MODIFICAR';

    EXEC actividades.sp_modificar_habilitacion @id = @id_hab_modificar_fallida, @nombre = 'Tipo Modificado Test', @descripcion = 'Modif fallida';
    
    PRINT 'SI EJECUTO ESTO SIGNIFICA QUE PERMITIÓ UNA MODIFICACION ERRONEA ';

END TRY

BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

-- 2.5 MODIFICACIÓN FALLIDA (NOMBRE VACIO)

DECLARE @id_hab_modificar_fallida INT = (SELECT MAX(id) FROM actividades.Habilitacion) ;

BEGIN TRY

    PRINT 'NOMBRE VACIO, NO DEBERIA MODIFICAR';

    EXEC actividades.sp_modificar_habilitacion @id = @id_hab_modificar_fallida, @nombre = '', @descripcion = 'Modif fallida';
    
    PRINT 'SI EJECUTO ESTO SIGNIFICA QUE PERMITIÓ UNA MODIFICACION ERRONEA ';

END TRY

BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO

-- 2.6 BAJA EXITOSA (Limpiamos la habilitación recién creada para probar)
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

--2.7 BAJA FALLIDA (ID INVALIDO)

DECLARE @id_hab_baja_fallida_1 INT =(SELECT MAX(id) FROM actividades.Habilitacion) + 1;

BEGIN TRY

    PRINT 'ID INVALIDO, DEBERIA FALLAR';

    EXEC actividades.sp_eliminar_habilitacion @id = @id_hab_baja_fallida_1;
    
    PRINT 'SI EJECUTÓ ESTO, PERMITIO ELIMINAR UN ID INEXISTENTE';

END TRY

BEGIN CATCH 
    
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH


--2.8 BAJA FALLIDA (DEPENDENCIAS EXISTENTE)

-- Se asume que el primer id insertado tiene dependencias existentes 
DECLARE @id_hab_baja_fallida_2 INT =(SELECT MIN(id) FROM actividades.Habilitacion);

BEGIN TRY

    PRINT 'DEPENDENCIAS EXISTENTES, DEBERIA FALLAR';

    EXEC actividades.sp_eliminar_habilitacion @id = @id_hab_baja_fallida_2;
    
    PRINT 'SI EJECUTÓ ESTO, PERMITIO ELIMINAR UN ID CON DEPENDENCIAS EXISTENTES';

END TRY

BEGIN CATCH 
    
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();

END CATCH


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

--3.3 MODIFICACION EXITOSA 

DECLARE @id_mod_act_exit INT =(SELECT MAX(id) FROM actividades.Actividad);

BEGIN TRY

    PRINT 'ID VALIDO, DEBERIA SER EXITOSO'
    -- Se asume que existen al menos un parque y un tipo de actividad
    EXEC actividades.sp_modificar_actividad @id = @id_mod_act_exit, 
                                            @nombre = 'Modificacion actividad exitosa',
                                            @cupo_maximo=1,
                                            @duracion_minutos=1,
                                            @precio=123.21,
                                            @id_parque=1,
                                            @id_tipo_actividad=1;
   SELECT 'MODIFICACION EXITOSA',id,nombre,cupo_maximo,duracion_minutos,precio 
   FROM actividades.Actividad 
   WHERE id=@id_mod_act_exit;

END TRY

BEGIN CATCH 
    
    PRINT 'ERROR INESPERADO:' + ERROR_MESSAGE();

END CATCH


-- 3.4 MODIFICACION FALLIDA (ID INVALIDO)

DECLARE @id_mod_act_fall INT =(SELECT MAX(id) FROM actividades.Actividad) +1 ;

BEGIN TRY 

    PRINT 'ID INVALIDO, DEBERIA FALLAR'

    EXEC actividades.sp_modificar_actividad @id = @id_mod_act_fall, 
                                            @nombre = 'Modificacion actividad exitosa',
                                            @cupo_maximo=1,
                                            @duracion_minutos=1,
                                            @precio=123.21,
                                            @id_parque=1,
                                            @id_tipo_actividad=1;
    SELECT 'MODIFICACION EXITOSA',id,nombre,cupo_maximo,duracion_minutos,precio 
    FROM actividades.Actividad 
    WHERE id=@id_mod_act_fall;

END TRY

BEGIN CATCH 
    
    PRINT 'ERROR INESPERADO:' + ERROR_MESSAGE();

END CATCH


--3.5 BAJA EXITOSA 

BEGIN TRY 

    -- Se inserta una actividad sabiendo que no tiene dependencias enlazadas
    EXEC actividades.sp_crear_actividad     @nombre = 'Act Test',
                                            @cupo_maximo=1,
                                            @duracion_minutos=1,
                                            @precio=123.21,
                                            @id_parque=1,
                                            @id_tipo_actividad=1;
    
    DECLARE @id_act_baja_exit INT =(SELECT MAX(id) FROM actividades.Actividad);

    EXEC actividades.sp_eliminar_actividad @id=@id_act_baja_exit;

    PRINT ' SI EJECUTÓ ESTO, HIZO LA BAJA CORRECTAMENTE';

END TRY

BEGIN CATCH

    PRINT 'ERROR INESPERADO' + ERROR_MESSAGE();

END CATCH


-- 3.6 BAJA FALLIDA (Actividad con Horario asignado)

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

    PRINT 'SI EJECUTÓ ESTO, HIZO UNA BAJA CON DEPENDENCIAS (GRAVE)';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE();
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
    PRINT 'ERROR ESPERADO:' + ERROR_MESSAGE();
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


-- 4.4 MODIFICACIÓN FALLIDA (IDs inexistentes - Error acumulado)
BEGIN TRY
    PRINT 'ID INEXISTENTE, DEBERIA FALLAR';
    
    
    EXEC actividades.sp_modificar_horario 
        @id = -1,               
        @hora_inicio = '14:00', 
        @hora_fin = '18:00',    
        @dia_semana = 3,       
        @fecha_vigencia_ini = '2026-06-01', 
        @fecha_vigencia_fin = '2026-12-31', 
        @visible = 1, 
        @id_actividad =-1;     
        
    PRINT 'SI EJECUTÓ ESTO, EL SP FALLÓ EN VALIDAR IDS';
END TRY
BEGIN CATCH
    PRINT 'ERROR ESPERADO:' +  ERROR_MESSAGE();
END CATCH;
GO


-- 4.5 MODIFICACIÓN FALLIDA (Parámetros obligatorios en NULL)

DECLARE @id_horario_modificar_null INT = (SELECT MAX(id) FROM actividades.Horario);
DECLARE @id_actividad_horario_null INT = (SELECT TOP 1 id FROM actividades.Actividad);

BEGIN TRY

    PRINT 'PARAMETROS EN NULL, DEBERIA FALLAR';
    
    EXEC actividades.sp_modificar_horario 
        @id = @id_horario_modificar_null,
        @hora_inicio = NULL,        
        @hora_fin = '18:00',    
        @dia_semana = 3,       
        @fecha_vigencia_ini = NULL, 
        @fecha_vigencia_fin = '2026-12-31', 
        @visible = 1, 
        @id_actividad = @id_actividad_horario_null;
        
    PRINT 'SI EJECUTÓ ESTO, EL SP FALLÓ EN VALIDAR PARAMETROS EN NULL';

END TRY

BEGIN CATCH

    PRINT 'ERROR ESPERADO:' +  ERROR_MESSAGE();

END CATCH;
GO

-- 4.4 BAJA LÓGICA EXITOSA
DECLARE @id_horario_eliminar INT = (SELECT MAX(id) FROM actividades.Horario);

BEGIN TRY
    PRINT 'UPDATE DE HORARIO A NO VISIBLE';
    
        EXEC actividades.sp_eliminar_horario @id = @id_horario_eliminar;
        
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
    
    
    SELECT 'RELACION ESPERADA' AS Res_Esperado, * FROM actividades.HabilitacionRegulaActividad 
    WHERE id_habilitacion = @id_hab_rel AND id_actividad = @id_act_rel;

END TRY

BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO



-- 5.2 ALTA FALLIDA (Relación duplicada)
-- Nota al pie: Es requisito ejecutar este bloque después del 5.1 para forzar el conflicto de PK compuesta.

DECLARE @id_act_rel_dup INT = (SELECT MAX(id) FROM actividades.Actividad);
DECLARE @id_hab_rel_dup INT = (SELECT MAX(id) FROM actividades.Habilitacion);

BEGIN TRY
    PRINT 'TEST ALTA FALLIDA (RELACION DUPLICADA)';
    
    -- Intentamos insertar la misma combinación que ya se generó en la prueba anterior
    EXEC actividades.sp_crear_habilitacion_regula_actividad 
        @id_habilitacion = @id_hab_rel_dup, 
        @id_actividad = @id_act_rel_dup;
    
    PRINT 'SI EJECUTÓ ESTO EL SP NO VALIDO CORRECTAMENTE LA UNICIDAD DE LA RELACION';

END TRY

BEGIN CATCH

    PRINT 'ERROR ESPERADO:' + ERROR_MESSAGE();

END CATCH;
GO


-- 5.3 BAJA EXITOSA DE RELACIÓN

DECLARE @id_act_rel_baja INT = (SELECT MAX(id) FROM actividades.Actividad);
DECLARE @id_hab_rel_baja INT = (SELECT MAX(id) FROM actividades.Habilitacion);

BEGIN TRY
    PRINT 'BAJA EXITOSA DE RELACION';
    
    EXEC actividades.sp_eliminar_habilitacion_regula_actividad 
        @id_habilitacion = @id_hab_rel_baja, 
        @id_actividad = @id_act_rel_baja;
    PRINT 'RESULTADO: OK - Relacion eliminada';
    -- Evidencia:
    SELECT 'EVIDENCIA BAJA RELACION (Debe estar vacio)' AS Res_Esperado, * FROM actividades.HabilitacionRegulaActividad 
    WHERE id_habilitacion = @id_hab_rel_baja AND id_actividad = @id_act_rel_baja;

END TRY

BEGIN CATCH

    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE();

END CATCH;
GO


-- 5.4 BAJA FALLIDA (Relación inexistente)

BEGIN TRY

    PRINT 'BAJA FALLIDA (Relacion inexistente)';
    
    -- Pasamos IDs que no existen
    EXEC actividades.sp_eliminar_habilitacion_regula_actividad 
        @id_habilitacion = -1, 
        @id_actividad = -1;

    print 'si ejecuto esto el sp fallo'

END TRY

BEGIN CATCH

    PRINT 'ERROR ESPERADO:' + ERROR_MESSAGE();

END CATCH;
GO