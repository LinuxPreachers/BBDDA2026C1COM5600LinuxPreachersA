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
            THROW 50003, 'El nombre ingresado para la actividad no es valido para ser insertado',1;

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
    @id SMALLINT,
    @nombre VARCHAR(100)
AS
BEGIN
    DECLARE @msj_error varchar(100) = ' ';
    SET NOCOUNT ON;
    BEGIN TRY
        IF @nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''
            SET @msj_error += '- Nombre del tipo de actividad invalido';
            
        IF NOT EXISTS (SELECT 1 FROM actividades.TipoActividad WHERE id = @id)
            SET @msj_error += '- El Tipo de Actividad con el ID provisto no existe.';

        IF(LEN(@msj_error)>0)
            THROW 50004, @msj_error,1;
        
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
    @id SMALLINT
AS
BEGIN
    DECLARE @msj_error VARCHAR (200) = ' ';
    SET NOCOUNT ON;
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM actividades.TipoActividad WHERE id = @id)
            SET @msj_error += '- El Tipo de Actividad con el ID provisto no existe.';

        IF EXISTS (SELECT 1 FROM actividades.Actividad WHERE id_tipo_actividad=@id)
            SET @msj_error += '- El Tipo de Actividad no es posible eliminar debido a que tiene Actividades asociadas.';

        IF(LEN(@msj_error)>0)
            THROW 50005, @msj_error,1;

        DELETE FROM actividades.TipoActividad WHERE id = 1;

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
        THROW 50006,'- El nombre ingresado para la habilitacion no es valido para ser insertado',1;

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
    DECLARE @msj_error VARCHAR(200) = ' ';
    SET NOCOUNT ON;
    BEGIN TRY
        IF @nombre IS NULL OR LTRIM(RTRIM(@nombre))='' 
           SET @msj_error += '- El nombre a modificar de la habilitacion es invalido';
        IF NOT EXISTS (SELECT 1 FROM actividades.Habilitacion WHERE id = @id)
           SET @msj_error += '- La Habilitación con el ID provisto no existe.';


        IF( LEN(@msj_error)>0)
            THROW 50007, @msj_error,1;

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
    DECLARE @msj_errores VARCHAR(400) = '';
    SET NOCOUNT ON;
    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM actividades.Habilitacion WHERE id = @id)
            SET @msj_errores = @msj_errores + '- La Habilitación con el ID provisto no existe.';

        IF EXISTS (SELECT 1 FROM actividades.HabilitacionRegulaActividad WHERE id_habilitacion=@id)
            SET @msj_errores = @msj_errores + '- La Habilitación no es posible eliminar debido a que tiene Actividades asociadas.';

        IF EXISTS (SELECT 1 FROM empleados.GuiaPoseeHabilitacion WHERE id_habilitacion = @id)
            SET @msj_errores = @msj_errores + '- La Habilitación no es posible eliminar debido a que tiene Guías asociados';

        IF (LEN(@msj_errores) > 0)
            THROW 50008, @msj_errores, 1;

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
    @id_tipo_actividad SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(400) = '';

        
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

     
        IF (LEN(@msj_errores) > 0)
            THROW 50009, @msj_errores, 1;

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
    @id_tipo_actividad SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(1000) = '';

        -- Validación de existencia
        IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE id = @id) 
            SET @msj_errores += '- La Actividad con el ID provisto no existe. ';

        IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            SET @msj_errores += '- El nombre de la actividad no puede estar vacío. ';

        -- Validaciones de lógica de negocio
        IF (@cupo_maximo <= 0)
            SET @msj_errores += '- El cupo máximo debe ser mayor a 0. ';

        IF (@duracion_minutos <= 0)
            SET @msj_errores += '- La duración debe ser estrictamente mayor a 0 minutos. ';

        IF (@precio < 0)
            SET @msj_errores += '- El precio no puede ser un valor negativo. ';

        
        IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id = @id_parque)
            SET @msj_errores += '- El ID del Parque especificado no existe. ';

        IF NOT EXISTS (SELECT 1 FROM actividades.TipoActividad WHERE id = @id_tipo_actividad)
            SET @msj_errores += '- El ID del Tipo de Actividad especificado no existe. ';

        
        IF (LEN(@msj_errores) > 0)
            THROW 50010, @msj_errores, 1;

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
    DECLARE @msj_error VARCHAR(300) ='';
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validación de existencia directa
        IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE id = @id)
            SET @msj_error+= '- No se pudo eliminar: La Actividad con el ID provisto no existe.';


        -- Validación preventiva (Opcional, pero buena práctica): 
        -- Verificar si hay registros que dependen de esta actividad (ej. horarios) antes de borrar.
        IF EXISTS (SELECT 1 FROM actividades.Horario WHERE id_actividad = @id)
            SET @msj_error += '- No se puede eliminar la actividad porque tiene horarios asignados.';

        IF EXISTS(SELECT 1 FROM actividades.HabilitacionRegulaActividad WHERE id_actividad=@id)
            SET @msj_error+= '- No se puede eliminar la actividad porque tiene habilitaciones que la regulan asignadas ';
        
        IF EXISTS(SELECT 1 FROM empleados.GuiaEstaEnActividad WHERE id_actividad=@id)
            SET @msj_error+= '- No se puede eliminar la actividad porque tiene asociado guías. ';

        IF LEN(@msj_error)>0
            THROW 50011, @msj_error,1;


        DELETE FROM actividades.Actividad WHERE id = @id;

    END TRY
    BEGIN CATCH
        THROW;
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
    DECLARE @msj_error VARCHAR (200) ='';
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS(SELECT 1 FROM actividades.Actividad WHERE id=@id_actividad)
            SET @msj_error += ' - La actividad asociada al horario no existe';

        IF @hora_inicio IS NULL OR @hora_fin IS NULL OR @dia_semana IS NULL OR @fecha_vigencia_ini IS NULL 
            SET @msj_error += ' - Los datos NO pueden ser NULL.';

        IF(LEN(@msj_error)>0)
            THROW 50012,@msj_error,1;

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
    DECLARE @msj_error VARCHAR(200) = '';
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM actividades.Horario WHERE id = @id)
            SET @msj_error += 'El Horario con el ID provisto no existe.';

        IF NOT EXISTS(SELECT 1 FROM actividades.Actividad WHERE id=@id_actividad)
            SET @msj_error += 'El ID para la Actividad especifica no existe';

        IF @hora_inicio IS NULL OR @hora_fin IS NULL OR @dia_semana IS NULL OR @fecha_vigencia_ini IS NULL 
            SET @msj_error += ' - Los datos NO pueden ser NULL.';

        IF(LEN(@msj_error)>0)
            THROW 50013, @msj_error,1;

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



-- Baja (Lógica)
CREATE OR ALTER PROCEDURE actividades.sp_eliminar_horario
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM actividades.Horario WHERE id = @id)
            THROW 50014, 'El Horario con el ID provisto no existe.', 1;

       UPDATE actividades.Horario SET visible=0 WHERE id=@id;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- ---------------------------------------------
-- 5.ABM: HabilitacionRegulaActividad
-- ---------------------------------------------

-- Alta
CREATE OR ALTER PROCEDURE actividades.sp_crear_habilitacion_regula_actividad
    @id_habilitacion INT,
    @id_actividad INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM actividades.HabilitacionRegulaActividad WHERE id_habilitacion = @id_habilitacion AND id_actividad = @id_actividad)
            THROW 50015, 'La relación entre la habilitación y la actividad ya se encuentra registrada.', 1;

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
            THROW 50016, 'No existe la relación especificada para eliminar.', 1;

        DELETE FROM actividades.HabilitacionRegulaActividad 
        WHERE id_habilitacion = @id_habilitacion AND id_actividad = @id_actividad;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO


