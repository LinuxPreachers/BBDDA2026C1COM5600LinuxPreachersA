/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Creación de SP ABM módulo actividades
*/

USE LinuxPreachers;
GO

-- ---------------------------------------------
-- 1. ABM: TipoActividad
-- ---------------------------------------------

-- Alta
CREATE OR ALTER PROCEDURE actividades.sp_crear_tipo_actividad
    @nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF(@nombre IS NULL)
            THROW 50000, 'El nombre ingresado para la actividad no es valido para ser insertado',1;
        INSERT INTO LinuxPreachers.actividades.TipoActividad (nombre)
        VALUES (@nombre);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE actividades.sp_modificar_tipo_actividad
    @id INT,
    @nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM actividades.TipoActividad WHERE id = @id)
            THROW 50001, 'El Tipo de Actividad con el ID provisto no existe.', 1;

        UPDATE actividades.TipoActividad
        SET nombre = @nombre
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja
CREATE OR ALTER PROCEDURE actividades.sp_eliminar_tipo_actividad
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM actividades.TipoActividad WHERE id = @id)
            THROW 50002, 'El Tipo de Actividad con el ID provisto no existe.', 1;

        DELETE FROM actividades.TipoActividad WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- ---------------------------------------------
-- 2. ABM: Habilitacion
-- ---------------------------------------------

-- Alta
CREATE OR ALTER PROCEDURE actividades.sp_crear_habilitacion
    @nombre VARCHAR(100),
    @descripcion VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
    IF @nombre IS NULL
        THROW 50003,'El nombre ingresado para la habilitacion no es valido para ser insertado',1;
        INSERT INTO actividades.Habilitacion (nombre, descripcion)
        VALUES (@nombre, @descripcion);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE actividades.sp_modificar_habilitacion
    @id INT,
    @nombre VARCHAR(100),
    @descripcion VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM actividades.Habilitacion WHERE id = @id)
            THROW 50004, 'La Habilitación con el ID provisto no existe.', 1;

        UPDATE actividades.Habilitacion
        SET nombre = @nombre,
            descripcion = @descripcion
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja
CREATE OR ALTER PROCEDURE actividades.sp_eliminar_habilitacion
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM actividades.Habilitacion WHERE id = @id)
            THROW 50005, 'La Habilitación con el ID provisto no existe.', 1;

        DELETE FROM actividades.Habilitacion WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO
-- ---------------------------------------------
-- 3. ABM: Actividad
-- ---------------------------------------------

-- Alta

CREATE OR ALTER PROCEDURE actividades.sp_crear_actividad
    @nombre VARCHAR(100),
    @descripcion VARCHAR(255) = NULL,
    @cupo_maximo INT,
    @duracion_minutos INT,
    @precio DECIMAL(18,2),
    @id_parque INT,
    @id_tipo_actividad INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(4000) = '';

        -- Validaciones de formato y lógica de negocio
        IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            SET @msj_errores += '- El nombre de la actividad no puede estar vacío. ';

        IF (@cupo_maximo <= 0)
            SET @msj_errores += '- El cupo máximo debe ser mayor a 0. ';

        IF (@duracion_minutos <= 0)
            SET @msj_errores += '- La duración debe ser estrictamente mayor a 0 minutos. ';

        IF (@precio < 0)
            SET @msj_errores += '- El precio no puede ser un valor negativo. ';

        -- Validaciones de integridad referencial
        IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id = @id_parque)
            SET @msj_errores += '- El ID del Parque especificado no existe. ';

        IF NOT EXISTS (SELECT 1 FROM actividades.TipoActividad WHERE id = @id_tipo_actividad)
            SET @msj_errores += '- El ID del Tipo de Actividad especificado no existe. ';

        -- Lanza el error unificado si se incumplió alguna condición
        IF (LEN(@msj_errores) > 0)
            THROW 50006, @msj_errores, 1;

        -- Inserción
        INSERT INTO actividades.Actividad (nombre, descripcion, cupo_maximo, duracion_minutos, precio, id_parque, id_tipo_actividad)
        VALUES (@nombre, @descripcion, @cupo_maximo, @duracion_minutos, @precio, @id_parque, @id_tipo_actividad);
        

    END TRY
    BEGIN CATCH
        ;THROW;
    END CATCH;
END;
GO


-- Modificacion
CREATE OR ALTER PROCEDURE actividades.sp_modificar_actividad
    @id INT,
    @nombre VARCHAR(100),
    @descripcion VARCHAR(255) = NULL,
    @cupo_maximo INT,
    @duracion_minutos INT,
    @precio DECIMAL(18,2),
    @id_parque INT,
    @id_tipo_actividad INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(1000) = '';

        -- Validación de existencia
        IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE id = @id) 
            SET @msj_errores += '- La Actividad con el ID provisto no existe. ';

        -- Validaciones de formato y lógica de negocio
        IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            SET @msj_errores += '- El nombre de la actividad no puede estar vacío. ';

        IF (@cupo_maximo <= 0)
            SET @msj_errores += '- El cupo máximo debe ser mayor a 0. ';

        IF (@duracion_minutos <= 0)
            SET @msj_errores += '- La duración debe ser estrictamente mayor a 0 minutos. ';

        IF (@precio < 0)
            SET @msj_errores += '- El precio no puede ser un valor negativo. ';

        -- Validaciones de integridad referencial
        IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id = @id_parque)
            SET @msj_errores += '- El ID del Parque especificado no existe. ';

        IF NOT EXISTS (SELECT 1 FROM actividades.TipoActividad WHERE id = @id_tipo_actividad)
            SET @msj_errores += '- El ID del Tipo de Actividad especificado no existe. ';

        -- Lanza el error unificado si se incumplió alguna condición
        IF (LEN(@msj_errores) > 0)
            THROW 50007, @msj_errores, 1;

        -- Actualización
        UPDATE actividades.Actividad
        SET nombre = @nombre,
            descripcion = @descripcion,
            cupo_maximo = @cupo_maximo,
            duracion_minutos = @duracion_minutos,
            precio = @precio,
            id_parque = @id_parque,
            id_tipo_actividad = @id_tipo_actividad
        WHERE id = @id;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja

CREATE OR ALTER PROCEDURE actividades.sp_eliminar_actividad
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validación de existencia directa
        IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE id = @id)
            THROW 50000, 'No se pudo eliminar: La Actividad con el ID provisto no existe.', 1;


        -- Validación preventiva (Opcional, pero buena práctica): 
        -- Verificar si hay registros que dependen de esta actividad (ej. horarios) antes de borrar.
        IF EXISTS (SELECT 1 FROM actividades.Horario WHERE id_actividad = @id)
            THROW 50008, 'No se puede eliminar la actividad porque tiene horarios asignados.', 1;

        DELETE FROM actividades.Actividad WHERE id = @id;

    END TRY
    BEGIN CATCH
        ;THROW;
    END CATCH;
END;
GO


-- ---------------------------------------------
-- 4. ABM: Horario
-- ---------------------------------------------

-- Alta
CREATE OR ALTER PROCEDURE actividades.sp_crear_horario
    @hora_inicio TIME,
    @hora_fin TIME,
    @dia_semana TINYINT,
    @fecha_vigencia_ini DATE,
    @fecha_vigencia_fin DATE = NULL,
    @visible BIT = 1,
    @id_actividad INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO actividades.Horario (hora_inicio, hora_fin, dia_semana, fecha_vigencia_ini, fecha_vigencia_fin, visible, id_actividad)
        VALUES (@hora_inicio, @hora_fin, @dia_semana, @fecha_vigencia_ini, @fecha_vigencia_fin, @visible, @id_actividad);
       
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE actividades.sp_modificar_horario
    @id INT,
    @hora_inicio TIME,
    @hora_fin TIME,
    @dia_semana TINYINT,
    @fecha_vigencia_ini DATE,
    @fecha_vigencia_fin DATE = NULL,
    @visible BIT,
    @id_actividad INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM actividades.Horario WHERE id = @id)
            THROW 50009, 'El Horario con el ID provisto no existe.', 1;

        IF NOT EXISTS(SELECT 1 FROM actividades.Actividad WHERE id=@id_actividad)
            THROW 50009, 'El ID para la Actividad especifica no existe',2;
        UPDATE actividades.Horario
        SET hora_inicio = @hora_inicio,
            hora_fin = @hora_fin,
            dia_semana = @dia_semana,
            fecha_vigencia_ini = @fecha_vigencia_ini,
            fecha_vigencia_fin = @fecha_vigencia_fin,
            visible = @visible,
            id_actividad = @id_actividad
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja (Física)
CREATE OR ALTER PROCEDURE actividades.sp_eliminar_horario
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM actividades.Horario WHERE id = @id)
            THROW 50010, 'El Horario con el ID provisto no existe.', 1;

        DELETE FROM actividades.Horario WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- ---------------------------------------------
-- 5.ABM: HabilitacionRegulaActividad
-- ---------------------------------------------

-- Alta de Relación
CREATE OR ALTER PROCEDURE actividades.sp_crear_habilitacion_regula_actividad
    @id_habilitacion INT,
    @id_actividad INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM actividades.HabilitacionRegulaActividad WHERE id_habilitacion = @id_habilitacion AND id_actividad = @id_actividad)
            THROW 50000, 'La relación entre la habilitación y la actividad ya se encuentra registrada.', 1;

        INSERT INTO actividades.HabilitacionRegulaActividad (id_habilitacion, id_actividad)
        VALUES (@id_habilitacion, @id_actividad);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja de Relación
CREATE OR ALTER PROCEDURE actividades.sp_eliminar_habilitacion_regula_actividad
    @id_habilitacion INT,
    @id_actividad INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM actividades.HabilitacionRegulaActividad WHERE id_habilitacion = @id_habilitacion AND id_actividad = @id_actividad)
            THROW 50000, 'No existe la relación especificada para eliminar.', 1;

        DELETE FROM actividades.HabilitacionRegulaActividad 
        WHERE id_habilitacion = @id_habilitacion AND id_actividad = @id_actividad;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO
