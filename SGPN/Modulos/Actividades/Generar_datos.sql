/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Script: Generación e inserción de datos masivos para el módulo de actividades.
*/

USE LinuxPreachers;
GO

-----------------------------------
-- 1. TipoActividad
-----------------------------------
BEGIN TRANSACTION;
BEGIN TRY
    EXEC actividades.sp_crear_tipo_actividad @nombre = 'Trekking y Senderismo';
    EXEC actividades.sp_crear_tipo_actividad @nombre = 'Ascenso y Alta Montaña';
    EXEC actividades.sp_crear_tipo_actividad @nombre = 'Navegación Lacustre';
    EXEC actividades.sp_crear_tipo_actividad @nombre = 'Avistaje de Flora y Fauna';
    EXEC actividades.sp_crear_tipo_actividad @nombre = 'Cicloturismo de Montaña';
    EXEC actividades.sp_crear_tipo_actividad @nombre = 'Rafting en Aguas Blancas';
    EXEC actividades.sp_crear_tipo_actividad @nombre = 'Kayak de Travesía';
    EXEC actividades.sp_crear_tipo_actividad @nombre = 'Cabalgata Guiada';
    EXEC actividades.sp_crear_tipo_actividad @nombre = 'Pesca Deportiva y Fly Fishing';
    EXEC actividades.sp_crear_tipo_actividad @nombre = 'Recorrido Histórico';

    COMMIT TRANSACTION;
    PRINT 'OK - TipoActividad (10 registros insertados).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Error en TipoActividad: ' + ERROR_MESSAGE();
END CATCH;
GO

-----------------------------------
-- 2. Habilitacion
-----------------------------------
BEGIN TRANSACTION;
BEGIN TRY
    -- Estas habilitaciones se pensaron para complementar las especialidades de los empleados
    EXEC actividades.sp_crear_habilitacion @nombre = 'Primeros Auxilios en Terreno Agreste', @descripcion = 'Certificación obligatoria en socorrismo para zonas remotas y de difícil acceso.';
    EXEC actividades.sp_crear_habilitacion @nombre = 'Certificación AAGM (Alta Montaña)', @descripcion = 'Acreditación técnica indispensable para liderar expediciones en glaciares y cumbres.';
    EXEC actividades.sp_crear_habilitacion @nombre = 'Licencia de Timonel / Patrón de Yate', @descripcion = 'Habilitación oficial otorgada por Prefectura para la conducción de embarcaciones a motor.';
    EXEC actividades.sp_crear_habilitacion @nombre = 'Certificación en Rescate en Aguas Blancas', @descripcion = 'Requisito excluyente para guías a cargo de actividades de Rafting y Kayak en ríos rápidos.';
    EXEC actividades.sp_crear_habilitacion @nombre = 'Carnet Habilitante de Pesca Deportiva', @descripcion = 'Licencia provincial para guiar contingentes de pesca con mosca (Catch & Release).';
    EXEC actividades.sp_crear_habilitacion @nombre = 'Especialización en Ornitología', @descripcion = 'Acreditación científica para guías enfocados en el avistaje e identificación de aves endémicas.';
    EXEC actividades.sp_crear_habilitacion @nombre = 'Certificación ACA Kayak Nivel 3', @descripcion = 'Acreditación internacional de habilidades avanzadas de remo y rescate en aguas abiertas.';
    EXEC actividades.sp_crear_habilitacion @nombre = 'Manejo de Animales de Silla y Carga', @descripcion = 'Acreditación técnica y de bienestar animal para liderar excursiones ecuestres.';
    EXEC actividades.sp_crear_habilitacion @nombre = 'Guía Intérprete Bilingüe (Nivel C1+)', @descripcion = 'Certificación de fluidez en idiomas extranjeros para atención de contingentes internacionales.';
    EXEC actividades.sp_crear_habilitacion @nombre = 'Orientación y Supervivencia Avanzada', @descripcion = 'Capacitación en uso de cartografía, GPS y armado de vivac para travesías de varios días.';

    COMMIT TRANSACTION;
    PRINT 'Habilitaciones Ingresadas';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 
        ROLLBACK TRANSACTION;
    PRINT 'Error en Habilitacion: ' + ERROR_MESSAGE();
END CATCH;
GO

-----------------------------------
-- 3. Actividad
-----------------------------------
BEGIN TRANSACTION;
BEGIN TRY
    -- Capturamos dos parques existentes (NOTA: Deben existir dos parques para que esto funcione)
    DECLARE @id_p1 INT = (SELECT MIN(id) FROM parques.Parque);
    DECLARE @id_p2 INT = (SELECT MAX(id) FROM parques.Parque);

    DECLARE @id_trekking SMALLINT; 
    DECLARE @id_montana SMALLINT;
    DECLARE @id_navegacion SMALLINT; 
    DECLARE @id_fauna SMALLINT;
    DECLARE @id_bici SMALLINT;
    DECLARE @id_rafting SMALLINT; 
    DECLARE @id_kayak SMALLINT;
    DECLARE @id_cabalgata SMALLINT; 
    DECLARE @id_pesca SMALLINT;
    DECLARE @id_historia SMALLINT;



    -- Capturamos los Tipos de Actividad
    SET @id_trekking= (SELECT TOP 1 id FROM actividades.TipoActividad WHERE nombre = 'Trekking y Senderismo');
    SET @id_montana= (SELECT TOP 1 id FROM actividades.TipoActividad WHERE nombre = 'Ascenso y Alta Montaña');
    SET @id_navegacion=(SELECT TOP 1 id FROM actividades.TipoActividad WHERE nombre = 'Navegación Lacustre');
    SET @id_fauna= (SELECT TOP 1 id FROM actividades.TipoActividad WHERE nombre = 'Avistaje de Flora y Fauna');
    SET @id_bici= (SELECT TOP 1 id FROM actividades.TipoActividad WHERE nombre = 'Cicloturismo de Montaña');
    SET @id_rafting = (SELECT TOP 1 id FROM actividades.TipoActividad WHERE nombre = 'Rafting en Aguas Blancas');
    SET @id_kayak = (SELECT TOP 1 id FROM actividades.TipoActividad WHERE nombre = 'Kayak de Travesía');
    SET @id_cabalgata=( SELECT TOP 1 id FROM actividades.TipoActividad WHERE nombre = 'Cabalgata Guiada');
    SET @id_pesca = (SELECT TOP 1 id FROM actividades.TipoActividad WHERE nombre = 'Pesca Deportiva y Fly Fishing');
    SET @id_historia = (SELECT TOP 1 id FROM actividades.TipoActividad WHERE nombre = 'Recorrido Histórico');

    -- Inserciones
    EXEC actividades.sp_crear_actividad @nombre = 'Sendero al Mirador Principal', @descripcion = 'Caminata familiar de baja dificultad por bosque nativo.', @cupo_maximo = 20, @duracion_minutos = 120, @precio = 8500.00, @id_parque = @id_p1, @id_tipo_actividad = @id_trekking;
    EXEC actividades.sp_crear_actividad @nombre = 'Ascenso a la Cumbre Norte', @descripcion = 'Expedición exigente con tramos de acarreo y cruce de neblina.', @cupo_maximo = 8, @duracion_minutos = 480, @precio = 45000.00, @id_parque = @id_p1, @id_tipo_actividad = @id_montana;
    EXEC actividades.sp_crear_actividad @nombre = 'Navegación por el Lago Escondido', @descripcion = 'Paseo en catamarán moderno con vistas a glaciares colgantes.', @cupo_maximo = 45, @duracion_minutos = 180, @precio = 35000.00, @id_parque = @id_p2, @id_tipo_actividad = @id_navegacion;
    EXEC actividades.sp_crear_actividad @nombre = 'Ruta de los Huemules', @descripcion = 'Avistaje silencioso en zonas de reserva estricta.', @cupo_maximo = 10, @duracion_minutos = 240, @precio = 18000.00, @id_parque = @id_p1, @id_tipo_actividad = @id_fauna;
    EXEC actividades.sp_crear_actividad @nombre = 'Descenso en Rafting Nivel III', @descripcion = 'Aventura en los rápidos del río principal del parque.', @cupo_maximo = 16, @duracion_minutos = 200, @precio = 28000.00, @id_parque = @id_p2, @id_tipo_actividad = @id_rafting;
    EXEC actividades.sp_crear_actividad @nombre = 'Travesía Kayak 7 Lagos', @descripcion = 'Remada tranquila bordeando bahías protegidas del viento.', @cupo_maximo = 12, @duracion_minutos = 150, @precio = 22000.00, @id_parque = @id_p2, @id_tipo_actividad = @id_kayak;
    EXEC actividades.sp_crear_actividad @nombre = 'Cabalgata a la Laguna Azul', @descripcion = 'Paseo ecuestre cruzando valles y arroyos cordilleranos.', @cupo_maximo = 15, @duracion_minutos = 240, @precio = 32000.00, @id_parque = @id_p1, @id_tipo_actividad = @id_cabalgata;
    EXEC actividades.sp_crear_actividad @nombre = 'Clínica de Pesca con Mosca', @descripcion = 'Jornada completa de pesca deportiva con instructor exclusivo.', @cupo_maximo = 4, @duracion_minutos = 480, @precio = 65000.00, @id_parque = @id_p2, @id_tipo_actividad = @id_pesca;
    EXEC actividades.sp_crear_actividad @nombre = 'Circuito Histórico Ruinas', @descripcion = 'Recorrido guiado por los asentamientos originales de la zona.', @cupo_maximo = 25, @duracion_minutos = 90, @precio = 5000.00, @id_parque = @id_p1, @id_tipo_actividad = @id_historia;
    EXEC actividades.sp_crear_actividad @nombre = 'Mountain Bike Sendero Sur', @descripcion = 'Recorrido técnico en bicicleta pasando por miradores panorámicos.', @cupo_maximo = 15, @duracion_minutos = 180, @precio = 15000.00, @id_parque = @id_p1, @id_tipo_actividad = @id_bici;

    COMMIT TRANSACTION;
    PRINT 'Actividades insertadas correctamente';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 
        ROLLBACK TRANSACTION;
    PRINT 'Error en Actividad: ' + ERROR_MESSAGE();
END CATCH;
GO

-----------------------------------
-- 4. Horario 
-----------------------------------
BEGIN TRANSACTION;
BEGIN TRY
    -- Capturamos dinámicamente IDs de Actividades creadas arriba
    DECLARE @id_sendero INT ;
    DECLARE @id_ascenso INT; 
    DECLARE @id_navegacion INT ; 
    DECLARE @id_rafting INT ; 
    DECLARE @id_cabalgata INT ;
    DECLARE @id_pesca INT ;
    DECLARE @id_historia INT ; 

    SET @id_sendero    = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Sendero al Mirador Principal');
    SET @id_ascenso    = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Ascenso a la Cumbre Norte');
    SET @id_navegacion = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Navegación por el Lago Escondido');
    SET @id_rafting    = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Descenso en Rafting Nivel III');
    SET @id_cabalgata  = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Cabalgata a la Laguna Azul');
    SET @id_pesca      = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Clínica de Pesca con Mosca');
    SET @id_historia   = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Circuito Histórico Ruinas');
    -- Sendero al Mirador (Sábados y Domingos a la mañana y tarde)
    EXEC actividades.sp_crear_horario @hora_inicio = '09:00', @hora_fin = '11:00', @dia_semana = 6, @fecha_vigencia_ini = '2026-01-01', @fecha_vigencia_fin = NULL, @visible = 1, @id_actividad = @id_sendero;
    EXEC actividades.sp_crear_horario @hora_inicio = '15:00', @hora_fin = '17:00', @dia_semana = 6, @fecha_vigencia_ini = '2026-01-01', @fecha_vigencia_fin = NULL, @visible = 1, @id_actividad = @id_sendero;
    EXEC actividades.sp_crear_horario @hora_inicio = '10:00', @hora_fin = '12:00', @dia_semana = 7, @fecha_vigencia_ini = '2026-01-01', @fecha_vigencia_fin = NULL, @visible = 1, @id_actividad = @id_sendero;

    -- Ascenso (Solo Jueves y Viernes temprano, por complejidad operativa)
    EXEC actividades.sp_crear_horario @hora_inicio = '05:00', @hora_fin = '13:00', @dia_semana = 4, @fecha_vigencia_ini = '2026-09-01', @fecha_vigencia_fin = NULL, @visible = 1, @id_actividad = @id_ascenso;
    EXEC actividades.sp_crear_horario @hora_inicio = '05:00', @hora_fin = '13:00', @dia_semana = 5, @fecha_vigencia_ini = '2026-09-01', @fecha_vigencia_fin = NULL, @visible = 1, @id_actividad = @id_ascenso;

    -- Navegación (Lunes, Miércoles, Viernes en dos turnos)
    EXEC actividades.sp_crear_horario @hora_inicio = '10:00', @hora_fin = '13:00', @dia_semana = 1, @fecha_vigencia_ini = '2026-01-01', @fecha_vigencia_fin = NULL, @visible = 1, @id_actividad = @id_navegacion;
    EXEC actividades.sp_crear_horario @hora_inicio = '14:00', @hora_fin = '17:00', @dia_semana = 1, @fecha_vigencia_ini = '2026-01-01', @fecha_vigencia_fin = NULL, @visible = 1, @id_actividad = @id_navegacion;
    EXEC actividades.sp_crear_horario @hora_inicio = '10:00', @hora_fin = '13:00', @dia_semana = 3, @fecha_vigencia_ini = '2026-01-01', @fecha_vigencia_fin = NULL, @visible = 1, @id_actividad = @id_navegacion;
    EXEC actividades.sp_crear_horario @hora_inicio = '14:00', @hora_fin = '17:00', @dia_semana = 3, @fecha_vigencia_ini = '2026-01-01', @fecha_vigencia_fin = NULL, @visible = 1, @id_actividad = @id_navegacion;

    -- Rafting (Martes y Jueves al mediodía)
    EXEC actividades.sp_crear_horario @hora_inicio = '12:00', @hora_fin = '15:20', @dia_semana = 2, @fecha_vigencia_ini = '2026-11-01', @fecha_vigencia_fin = NULL, @visible = 1, @id_actividad = @id_rafting;
    EXEC actividades.sp_crear_horario @hora_inicio = '12:00', @hora_fin = '15:20', @dia_semana = 4, @fecha_vigencia_ini = '2026-11-01', @fecha_vigencia_fin = NULL, @visible = 1, @id_actividad = @id_rafting;

    -- Cabalgata (Fines de semana)
    EXEC actividades.sp_crear_horario @hora_inicio = '09:00', @hora_fin = '13:00', @dia_semana = 6, @fecha_vigencia_ini = '2026-01-01', @fecha_vigencia_fin = NULL, @visible = 1, @id_actividad = @id_cabalgata;
    EXEC actividades.sp_crear_horario @hora_inicio = '09:00', @hora_fin = '13:00', @dia_semana = 7, @fecha_vigencia_ini = '2026-01-01', @fecha_vigencia_fin = NULL, @visible = 1, @id_actividad = @id_cabalgata;

    -- Pesca (Sábados turno completo)
    EXEC actividades.sp_crear_horario @hora_inicio = '07:00', @hora_fin = '15:00', @dia_semana = 6, @fecha_vigencia_ini = '2026-11-01', @fecha_vigencia_fin = '2027-05-01', @visible = 1, @id_actividad = @id_pesca;

    -- Historia (Lunes)
    EXEC actividades.sp_crear_horario @hora_inicio = '11:00', @hora_fin = '12:30', @dia_semana = 1, @fecha_vigencia_ini = '2026-01-01', @fecha_vigencia_fin = NULL, @visible = 1, @id_actividad = @id_historia;

    COMMIT TRANSACTION;
    PRINT 'Horarios insertados';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 
        ROLLBACK TRANSACTION;
    PRINT 'Error en Horario: ' + ERROR_MESSAGE();
END CATCH;
GO

-----------------------------------
-- 5. HabilitacionRegulaActividad (Mínimo 10)
-----------------------------------
BEGIN TRANSACTION;
BEGIN TRY
    -- Capturamos IDs de las habilitaciones
    DECLARE @id_wfr INT;
    DECLARE @id_aagm INT;
    DECLARE @id_timonel INT ;
    DECLARE @id_aguas_blancas INT ;
    DECLARE @id_pesca INT ;
    DECLARE @id_aves INT;
    DECLARE @id_kayak INT;
    DECLARE @id_caballos INT ;
    DECLARE @id_idioma INT;

    SET @id_wfr =(SELECT  TOP 1 id FROM actividades.Habilitacion WHERE nombre = 'Primeros Auxilios en Terreno Agreste');
    SET @id_aagm =( SELECT  TOP 1 id FROM actividades.Habilitacion WHERE nombre = 'Certificación AAGM (Alta Montaña)');
    SET @id_timonel= (SELECT TOP 1 id FROM actividades.Habilitacion WHERE nombre = 'Licencia de Timonel / Patrón de Yate');
    SET @id_aguas_blancas =( SELECT TOP 1 id FROM actividades.Habilitacion WHERE nombre = 'Certificación en Rescate en Aguas Blancas');
    SET @id_pesca= (SELECT TOP 1 id FROM actividades.Habilitacion WHERE nombre = 'Carnet Habilitante de Pesca Deportiva');
    SET @id_aves = (SELECT TOP 1 id FROM actividades.Habilitacion WHERE nombre = 'Especialización en Ornitología');
    SET @id_kayak= (SELECT  TOP 1 id FROM actividades.Habilitacion WHERE nombre = 'Certificación ACA Kayak Nivel 3');
    SET @id_caballos =( SELECT  TOP 1 id FROM actividades.Habilitacion WHERE nombre = 'Manejo de Animales de Silla y Carga');
    SET @id_idioma = (SELECT TOP 1 id FROM actividades.Habilitacion WHERE nombre = 'Guía Intérprete Bilingüe (Nivel C1+)');

    -- Capturamos IDs de las actividades
    DECLARE @id_sendero INT = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Sendero al Mirador Principal');
    DECLARE @id_ascenso INT = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Ascenso a la Cumbre Norte');
    DECLARE @id_navegacion INT = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Navegación por el Lago Escondido');
    DECLARE @id_fauna INT = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Ruta de los Huemules');
    DECLARE @id_rafting INT = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Descenso en Rafting Nivel III');
    DECLARE @act_kayak INT = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Travesía Kayak 7 Lagos');
    DECLARE @id_cabalgata INT = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Cabalgata a la Laguna Azul');
    DECLARE @act_pesca INT = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Clínica de Pesca con Mosca');
    DECLARE @id_historia INT = (SELECT TOP 1 id FROM actividades.Actividad WHERE nombre = 'Circuito Histórico Ruinas');

    -- Asignaciones de habilitaciones a actividades
    -- Ascenso --> Alta montaña, primeros auxilios
    EXEC actividades.sp_crear_habilitacion_regula_actividad @id_habilitacion = @id_aagm, @id_actividad = @id_ascenso;
    EXEC actividades.sp_crear_habilitacion_regula_actividad @id_habilitacion = @id_wfr, @id_actividad = @id_ascenso;

    -- Navegación --> timonel,bilingüe
    EXEC actividades.sp_crear_habilitacion_regula_actividad @id_habilitacion = @id_timonel, @id_actividad = @id_navegacion;
    EXEC actividades.sp_crear_habilitacion_regula_actividad @id_habilitacion = @id_idioma, @id_actividad = @id_navegacion;

    -- Rafting --> Rescate en aguas blancas, socorrismo
    EXEC actividades.sp_crear_habilitacion_regula_actividad @id_habilitacion = @id_aguas_blancas, @id_actividad = @id_rafting;
    EXEC actividades.sp_crear_habilitacion_regula_actividad @id_habilitacion = @id_wfr, @id_actividad = @id_rafting;

    -- Kayak de Travesía --> certificación ACA
    EXEC actividades.sp_crear_habilitacion_regula_actividad @id_habilitacion = @id_kayak, @id_actividad = @act_kayak;

    -- Avistaje --> especialización en ornitología/fauna
    EXEC actividades.sp_crear_habilitacion_regula_actividad @id_habilitacion = @id_aves, @id_actividad = @id_fauna;
                                                                                
    -- Cabalgata necesita manejo de animales y socorrismo preventivo            
    EXEC actividades.sp_crear_habilitacion_regula_actividad @id_habilitacion = @id_caballos, @id_actividad = @id_cabalgata;
    EXEC actividades.sp_crear_habilitacion_regula_actividad @id_habilitacion = @id_wfr, @id_actividad = @id_cabalgata;
                                                                                
    -- Clínica de pesca necesita licencia                                       
    EXEC actividades.sp_crear_habilitacion_regula_actividad @id_habilitacion = @id_pesca, @id_actividad = @act_pesca;
                                                                                
    -- Recorrido histórico en inglés                                            
    EXEC actividades.sp_crear_habilitacion_regula_actividad @id_habilitacion = @id_idioma, @id_actividad = @id_historia;

    COMMIT TRANSACTION;
    PRINT 'HabilitacionRegulaActividad insertados con exito';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Error en HabilitacionRegulaActividad: ' + ERROR_MESSAGE();
END CATCH;
GO

-----------------------------------
-- Verificación final
-----------------------------------
SELECT 'TipoActividad' AS Tabla, COUNT(*) AS Cantidad FROM actividades.TipoActividad;
SELECT 'Habilitacion' AS Tabla, COUNT(*) AS Cantidad FROM actividades.Habilitacion;
SELECT 'Actividad' AS Tabla, COUNT(*) AS Cantidad FROM actividades.Actividad;
SELECT 'Horario' AS Tabla, COUNT(*) AS Cantidad FROM actividades.Horario;
SELECT 'HabilitacionRegulaActividad' AS Tabla, COUNT(*) AS Cantidad FROM actividades.HabilitacionRegulaActividad;
GO