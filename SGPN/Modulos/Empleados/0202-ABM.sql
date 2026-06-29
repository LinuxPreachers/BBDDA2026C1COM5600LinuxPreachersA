/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Creación de tablas módulo empleados
*/

USE LinuxPreachers;
GO

-- ---------------------------------------------
-- 1. ABM: TipoDocumento
-- ---------------------------------------------

-- Alta
CREATE OR ALTER PROCEDURE empleados.sp_crear_tipo_documento
    @nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            THROW 50103, '- El nombre ingresado para el Tipo de Documento no es válido.', 1;
            
        INSERT INTO empleados.TipoDocumento (nombre)
        VALUES (@nombre);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE empleados.sp_modificar_tipo_documento
    @id TINYINT,
    @nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.TipoDocumento WHERE id = @id)
            THROW 50104, '- El Tipo de Documento con el ID provisto no existe.', 1;

        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            THROW 50104, '- El nombre ingresado para el Tipo de Documento no es válido.', 2;

        UPDATE empleados.TipoDocumento
        SET nombre = @nombre
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja
CREATE OR ALTER PROCEDURE empleados.sp_eliminar_tipo_documento
    @id TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.TipoDocumento WHERE id = @id)
            THROW 50105, '- El Tipo de Documento con el ID provisto no existe.', 1;

        IF EXISTS (SELECT 1 FROM empleados.Empleado WHERE id_tipo_documento = @id)
            THROW 50105, '- El tipo de Documento a eliminar tiene empleados asociados, no se puede eliminar.',2;

        DELETE FROM empleados.TipoDocumento WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- ---------------------------------------------
-- 2. ABM: Empleado
-- ---------------------------------------------

-- Alta
CREATE OR ALTER PROCEDURE empleados.sp_crear_empleado
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @nro_doc INT,
    @id_tipo_documento TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(400) = '';

        IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            SET @msj_errores += '- El nombre no puede estar vacío. ';

        IF (@apellido IS NULL OR LTRIM(RTRIM(@apellido)) = '')
            SET @msj_errores += '- El apellido no puede estar vacío. ';

        IF NOT EXISTS (SELECT 1 FROM empleados.TipoDocumento WHERE id = @id_tipo_documento)
            SET @msj_errores += '- El ID del Tipo de Documento especificado no existe. ';

        IF EXISTS (SELECT 1 FROM empleados.Empleado WHERE id_tipo_documento = @id_tipo_documento AND nro_doc = @nro_doc)
            SET @msj_errores += '- Ya existe un Empleado con ese Tipo y Número de Documento. ';

        IF (LEN(@msj_errores) > 0)
            THROW 50106, @msj_errores, 1;

        INSERT INTO empleados.Empleado (nombre, apellido, nro_doc, id_tipo_documento)
        VALUES (@nombre, @apellido, @nro_doc, @id_tipo_documento);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE empleados.sp_modificar_empleado
    @id INT,
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @nro_doc INT,
    @id_tipo_documento TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(400) = '';

        IF NOT EXISTS (SELECT 1 FROM empleados.Empleado WHERE id = @id)
            SET @msj_errores += '- El Empleado con el ID provisto no existe. ';

        IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            SET @msj_errores += '- El nombre no puede estar vacío. ';

        IF (@apellido IS NULL OR LTRIM(RTRIM(@apellido)) = '')
            SET @msj_errores += '- El apellido no puede estar vacío. ';

        IF NOT EXISTS (SELECT 1 FROM empleados.TipoDocumento WHERE id = @id_tipo_documento)
            SET @msj_errores += '- El ID del Tipo de Documento especificado no existe. ';

        -- Verifica que no haya otro empleado con los mismos datos primarios
        IF EXISTS (SELECT 1 FROM empleados.Empleado WHERE id_tipo_documento = @id_tipo_documento AND nro_doc = @nro_doc AND id != @id)
            SET @msj_errores += '- Ya existe otro Empleado con ese Tipo y Número de Documento. ';

        IF (LEN(@msj_errores) > 0)
            THROW 50107, @msj_errores, 1;

        UPDATE empleados.Empleado
        SET nombre = @nombre,
            apellido = @apellido,
            nro_doc = @nro_doc,
            id_tipo_documento = @id_tipo_documento
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja Logica
CREATE OR ALTER PROCEDURE empleados.sp_eliminar_empleado
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.Empleado WHERE id = @id)
            THROW 50108, 'El Empleado con el ID provisto no existe.', 1;

        UPDATE empleados.Empleado SET activo=0 WHERE id=@id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- ---------------------------------------------
-- 3. ABM: Especialidad
-- ---------------------------------------------

-- Alta
CREATE OR ALTER PROCEDURE empleados.sp_crear_especialidad
    @nombre VARCHAR(100),
    @descripcion VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            THROW 50109, 'El nombre ingresado para la Especialidad no es válido.', 1;

        INSERT INTO empleados.Especialidad (nombre, descripcion)
        VALUES (@nombre, @descripcion);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE empleados.sp_modificar_especialidad
    @id SMALLINT,
    @nombre VARCHAR(100),
    @descripcion VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.Especialidad WHERE id = @id)
            THROW 50110, 'La Especialidad con el ID provisto no existe.', 1;

        IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            THROW 50107, 'El nombre ingresado para la Especialidad no es válido.', 2;

        UPDATE empleados.Especialidad
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
CREATE OR ALTER PROCEDURE empleados.sp_eliminar_especialidad
    @id SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.Especialidad WHERE id = @id)
            THROW 50111, 'La Especialidad con el ID provisto no existe.', 1;

        IF EXISTS(SELECT 1 FROM empleados.Guia WHERE id_especialidad= @id) -- especialidad no puede ser null
            THROW 50111, 'La Especialidad especificada esta siendo ocupada por Guías, no es posible eliminar la especialidad hasta que modifique los guías',2;

        DELETE FROM empleados.Especialidad WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- ---------------------------------------------
-- 4. ABM: Titulo
-- ---------------------------------------------

-- Alta
CREATE OR ALTER PROCEDURE empleados.sp_crear_titulo
    @nombre VARCHAR(100),
    @institucion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            THROW 50112, 'El nombre ingresado no es válido.', 1;

        IF (@institucion IS NULL OR LTRIM(RTRIM(@institucion)) = '')
            THROW 50112, ' La institución ingresada no es válida',2;

        INSERT INTO empleados.Titulo (nombre, institucion)
        VALUES (@nombre, @institucion);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE empleados.sp_modificar_titulo
    @id SMALLINT,
    @nombre VARCHAR(100),
    @institucion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.Titulo WHERE id = @id)
            THROW 50113, 'El Titulo con el ID provisto no existe.', 1;

        IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = ''  )
            THROW 50113, 'El nombre ingresado no es válido.', 2;

        IF( @institucion IS NULL OR LTRIM(RTRIM(@institucion)) = '')
            THROW 50113, 'La institución ingresada no es válida.',3;

        UPDATE empleados.Titulo
        SET nombre = @nombre,
            institucion = @institucion
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja
CREATE OR ALTER PROCEDURE empleados.sp_eliminar_titulo
    @id SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.Titulo WHERE id = @id)
            THROW 50114, 'El Titulo con el ID provisto no existe.', 1;
        
        -- Titulo puede ser NULL, no hay conflicto con Guia
        DELETE FROM empleados.Titulo WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- ---------------------------------------------
-- 5. ABM: Guia
-- ---------------------------------------------

-- Lectura Guia
CREATE OR ALTER VIEW empleados.vw_leer_guia AS
SELECT 
    e.id AS id_empleado,
    e.nombre,
    e.apellido,
    td.nombre AS tipo_documento,
    e.nro_doc,
    g.nro_registro,
    esp.nombre AS especialidad,
    t.nombre AS titulo,
    t.institucion,
    e.activo
FROM empleados.Guia g
INNER JOIN empleados.Empleado e ON g.id_empleado = e.id
INNER JOIN empleados.TipoDocumento td ON e.id_tipo_documento = td.id
INNER JOIN empleados.Especialidad esp ON g.id_especialidad = esp.id
LEFT JOIN empleados.Titulo t ON g.id_titulo = t.id; -- LEFT JOIN porque el título acepta NULL
GO


-- Alta
CREATE OR ALTER PROCEDURE empleados.sp_crear_guia
    @nro_registro VARCHAR(30),
    @id_empleado INT,
    @id_especialidad SMALLINT,
    @id_titulo SMALLINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(400) = '';

        IF NOT EXISTS (SELECT 1 FROM empleados.Empleado WHERE id = @id_empleado)
            SET @msj_errores += '- El Empleado especificado no existe. ';

        IF NOT EXISTS (SELECT 1 FROM empleados.Especialidad WHERE id = @id_especialidad)
            SET @msj_errores += '- La Especialidad especificada no existe. ';

        IF (@id_titulo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM empleados.Titulo WHERE id = @id_titulo))
            SET @msj_errores += '- El Titulo especificado no existe. ';

        IF EXISTS (SELECT 1 FROM empleados.Guia WHERE id_empleado = @id_empleado)
            SET @msj_errores += '- El Empleado ya se encuentra registrado como Guía. ';

        IF (LEN(@msj_errores) > 0)
            THROW 50115, @msj_errores, 1;

        INSERT INTO empleados.Guia (nro_registro, id_empleado, id_especialidad, id_titulo)
        VALUES (@nro_registro, @id_empleado, @id_especialidad, @id_titulo);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE empleados.sp_modificar_guia
    @id_empleado INT,
    @nro_registro VARCHAR(30),
    @id_especialidad SMALLINT,
    @id_titulo SMALLINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(400) = '';

        IF NOT EXISTS (SELECT 1 FROM empleados.Guia WHERE id_empleado = @id_empleado)
            SET @msj_errores += '- El Guía con el ID provisto no existe. ';

        IF NOT EXISTS (SELECT 1 FROM empleados.Especialidad WHERE id = @id_especialidad)
            SET @msj_errores += '- La Especialidad especificada no existe. ';

        IF (@id_titulo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM empleados.Titulo WHERE id = @id_titulo))
            SET @msj_errores += '- El Titulo especificado no existe. ';

        IF (LEN(@msj_errores) > 0)
            THROW 50116, @msj_errores, 1;

        UPDATE empleados.Guia
        SET nro_registro = @nro_registro,
            id_especialidad = @id_especialidad,
            id_titulo = @id_titulo
        WHERE id_empleado = @id_empleado;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja
CREATE OR ALTER PROCEDURE empleados.sp_eliminar_guia
    @id_empleado INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.Guia WHERE id_empleado = @id_empleado)
            THROW 50117, 'El Guía con el ID provisto no existe o ya está inactivo.', 1;

        BEGIN TRANSACTION;

        -- 1. Como es un guia de baja debemos establecer la fecha de fin de sus habilitaciones 
        UPDATE empleados.GuiaPoseeHabilitacion
        SET fecha_fin = CAST(GETDATE() AS DATE)
        WHERE id_empleado = @id_empleado 
          AND fecha_fin IS NULL;

        -- 2. Damos de baja al guía lógicamente
        UPDATE empleados.Empleado
        SET activo = 0 
        WHERE id=@id_empleado

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
-- ---------------------------------------------
-- 6. ABM: Guardaparque
-- ---------------------------------------------

-- Lectura Guardaparque

CREATE OR ALTER VIEW empleados.vw_leer_guardaparque AS
SELECT 
    e.id AS id_empleado,
    e.nombre,
    e.apellido,
    td.nombre AS tipo_documento,
    e.nro_doc,
    gp.nro_matricula,
    e.activo
FROM empleados.Guardaparque gp
INNER JOIN empleados.Empleado e ON gp.id_empleado = e.id
INNER JOIN empleados.TipoDocumento td ON e.id_tipo_documento = td.id;
GO

-- Alta
CREATE OR ALTER PROCEDURE empleados.sp_crear_guardaparque
    @nro_matricula INT,
    @id_empleado INT 
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(400) = '';

        IF NOT EXISTS (SELECT 1 FROM empleados.Empleado WHERE id = @id_empleado)
            SET @msj_errores += '- El Empleado especificado no existe. ';

        IF EXISTS (SELECT 1 FROM empleados.Guardaparque WHERE id_empleado = @id_empleado)
            SET @msj_errores += '- El Empleado ya se encuentra registrado como Guardaparque. ';

        IF (LEN(@msj_errores) > 0)
            THROW 50118, @msj_errores, 1;

        INSERT INTO empleados.Guardaparque (nro_matricula, id_empleado)
        VALUES (@nro_matricula, @id_empleado);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE empleados.sp_modificar_guardaparque
    @id_empleado INT,
    @nro_matricula INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.Guardaparque WHERE id_empleado = @id_empleado)
            THROW 50119, 'El Guardaparque con el ID provisto no existe.', 1;

        UPDATE empleados.Guardaparque
        SET nro_matricula = @nro_matricula
        WHERE id_empleado = @id_empleado;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja
CREATE OR ALTER PROCEDURE empleados.sp_eliminar_guardaparque
    @id_empleado INT 
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.Guardaparque WHERE id_empleado = @id_empleado)
            THROW 50120, 'El Guardaparque con el ID provisto no existe.', 1;

        BEGIN TRANSACTION;

        -- 1. Debemos dar de baja al guardarque del parque asignado, eso lo hacemos asignando una fecha de egreso
        UPDATE empleados.GuardaparqueAsignado
        SET fecha_egreso = CAST(GETDATE() AS DATE)
        WHERE id_empleado = @id_empleado 
          AND fecha_egreso IS NULL;

        -- 2. Damos de baja al guía lógicamente
        UPDATE empleados.Empleado
        SET activo = 0 
        WHERE id = @id_empleado

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ---------------------------------------------
-- 6. ABM: GuardaparqueAsignado
-- ---------------------------------------------

--Lectura Guardaparque asignado

CREATE OR ALTER VIEW empleados.vw_leer_guardaparque_asignado_parque AS
SELECT 
    gpa.id,
    gpa.id_empleado,
    e.nombre,
    e.apellido,
    gp.nro_matricula,
    gpa.id_parque, -- Queda el ID hasta tener el módulo Parques
    gpa.fecha_ingreso,
    gpa.fecha_egreso,
    gpa.motivo_egreso
FROM empleados.GuardaparqueAsignado gpa
INNER JOIN empleados.Guardaparque gp ON gpa.id_empleado = gp.id_empleado
INNER JOIN empleados.Empleado e ON gp.id_empleado = e.id;
GO

CREATE OR ALTER PROCEDURE empleados.sp_asignar_guardaparque
    @id_empleado INT,
    @id_parque INT,
    @fecha_ingreso DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(400) = '';

        IF NOT EXISTS (SELECT 1 FROM empleados.Guardaparque WHERE id_empleado = @id_empleado)
            SET @msj_errores += '- El Guardaparque no existe. ';

        IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id = @id_parque)
            SET @msj_errores += '- El Parque especificado no existe. ';

         -- Se verifica que ese guardaparque en ese parque este activo, si esta activo se notifica y no se completa el alta
        IF EXISTS (SELECT 1 FROM empleados.GuardaparqueAsignado 
                   WHERE id_empleado = @id_empleado AND id_parque = @id_parque AND fecha_egreso IS NULL)
            SET @msj_errores += '- El Guardaparque ya se encuentra asignado y activo en este parque. ';

        IF (LEN(@msj_errores) > 0)
            THROW 50121, @msj_errores, 1;

        INSERT INTO empleados.GuardaparqueAsignado (id_empleado, id_parque, fecha_ingreso)
        VALUES (@id_empleado, @id_parque, @fecha_ingreso);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja Lógica (Registrar Egreso del Parque)
CREATE OR ALTER PROCEDURE empleados.sp_registrar_egreso_guardaparque
    @id_empleado INT,
    @id_parque INT,
    @fecha_ingreso DATE, 
    @fecha_egreso DATE,
    @motivo_egreso VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que el registro exacto exista
        IF NOT EXISTS (SELECT 1 FROM empleados.GuardaparqueAsignado 
                       WHERE id_empleado = @id_empleado AND id_parque = @id_parque AND fecha_ingreso = @fecha_ingreso)
            THROW 50122, 'El registro de asignación especificado no existe.', 1;

        -- Validar lógica de fechas
        IF (@fecha_egreso < @fecha_ingreso)
            THROW 50122, 'La fecha de egreso no puede ser anterior a la fecha de ingreso.', 2;

        UPDATE empleados.GuardaparqueAsignado
        SET fecha_egreso = @fecha_egreso,
            motivo_egreso = @motivo_egreso
        WHERE id_empleado = @id_empleado 
          AND id_parque = @id_parque 
          AND fecha_ingreso = @fecha_ingreso;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja Física (Eliminación por error de carga)
CREATE OR ALTER PROCEDURE empleados.sp_eliminar_asignacion_guardaparque
    @id_empleado INT,
    @id_parque INT,
    @fecha_ingreso DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.GuardaparqueAsignado 
                       WHERE id_empleado = @id_empleado AND id_parque = @id_parque AND fecha_ingreso = @fecha_ingreso)
            THROW 50123, 'El registro de asignación especificado no existe para ser eliminado.', 1;

        DELETE FROM empleados.GuardaparqueAsignado 
        WHERE id_empleado = @id_empleado 
          AND id_parque = @id_parque 
          AND fecha_ingreso = @fecha_ingreso;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO


-- -----------------------------------------------------------
-- 8. GuiaPoseeHabilitacion
-- -----------------------------------------------------------

-- Lectura Guia posee Habilitacion
CREATE OR ALTER VIEW empleados.vw_leer_guia_posee_habilitacion AS
SELECT 
    gph.id,
    gph.id_empleado,
    e.nombre,
    e.apellido,
    g.nro_registro,
    gph.id_habilitacion, -- Queda el ID hasta tener el módulo Actividades
    gph.fecha_inicio,
    gph.fecha_fin
FROM empleados.GuiaPoseeHabilitacion gph
INNER JOIN empleados.Guia g ON gph.id_empleado = g.id_empleado
INNER JOIN empleados.Empleado e ON g.id_empleado = e.id;
GO

-- Alta 
CREATE OR ALTER PROCEDURE empleados.sp_asignar_habilitacion_guia
    @id_empleado INT,
    @id_habilitacion INT,
    @fecha_inicio DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(400) = '';

        IF NOT EXISTS (SELECT 1 FROM empleados.Guia WHERE id_empleado = @id_empleado)
            SET @msj_errores += '- El Guía no existe. ';

        IF NOT EXISTS (SELECT 1 FROM empleados.Habilitacion WHERE id = @id_habilitacion)
            SET @msj_errores += '- La Habilitación especificada no existe. ';

        IF EXISTS (SELECT 1 FROM empleados.GuiaPoseeHabilitacion 
                   WHERE id_empleado = @id_empleado AND id_habilitacion = @id_habilitacion AND fecha_fin IS NULL)
            SET @msj_errores += '- El Guía ya posee esta habilitación vigente. ';

        IF (LEN(@msj_errores) > 0)
            THROW 50124, @msj_errores, 1;

        INSERT INTO empleados.GuiaPoseeHabilitacion (id_empleado, id_habilitacion, fecha_inicio)
        VALUES (@id_empleado, @id_habilitacion, @fecha_inicio);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja Lógica (Revocar / Vencer Habilitación)
CREATE OR ALTER PROCEDURE empleados.sp_revocar_habilitacion_guia
    @id_empleado INT,
    @id_habilitacion INT,
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.GuiaPoseeHabilitacion 
                       WHERE id_empleado = @id_empleado AND id_habilitacion = @id_habilitacion AND fecha_inicio = @fecha_inicio)
            THROW 50125, 'El registro de habilitación especificado no existe.', 1;

        IF (@fecha_fin < @fecha_inicio)
            THROW 50125, 'La fecha de fin/revocación no puede ser anterior a la fecha de inicio.', 2;

        UPDATE empleados.GuiaPoseeHabilitacion
        SET fecha_fin = @fecha_fin
        WHERE id_empleado = @id_empleado 
          AND id_habilitacion = @id_habilitacion 
          AND fecha_inicio = @fecha_inicio;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja Física (Eliminación por error de carga)
CREATE OR ALTER PROCEDURE empleados.sp_eliminar_asignacion_habilitacion
    @id_empleado INT,
    @id_habilitacion INT,
    @fecha_inicio DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.GuiaPoseeHabilitacion 
                       WHERE id_empleado = @id_empleado AND id_habilitacion = @id_habilitacion AND fecha_inicio = @fecha_inicio)
            THROW 50126, 'El registro de habilitación no existe para ser eliminado.', 1;

        DELETE FROM empleados.GuiaPoseeHabilitacion 
        WHERE id_empleado = @id_empleado 
          AND id_habilitacion = @id_habilitacion 
          AND fecha_inicio = @fecha_inicio;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO


-- -----------------------------------------------------------
-- 3.  GuiaEstaEnActividad 
-- -----------------------------------------------------------

-- Lectura Guia esta en actividad
CREATE OR ALTER VIEW empleados.vw_leer_guia_en_actividad AS
SELECT 
    gea.id,
    gea.id_empleado,
    e.nombre,
    e.apellido,
    g.nro_registro,
    gea.id_actividad, -- Queda el ID hasta tener el módulo Actividades
    gea.fecha_inicio,
    gea.fecha_fin
FROM empleados.GuiaEstaEnActividad gea
INNER JOIN empleados.Guia g ON gea.id_empleado = g.id_empleado
INNER JOIN empleados.Empleado e ON g.id_empleado = e.id;
GO

-- Alta (Asignar Guía a Actividad)
CREATE OR ALTER PROCEDURE empleados.sp_asignar_actividad_guia
    @id_empleado INT,
    @id_actividad INT,
    @fecha_inicio DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(400) = '';

        IF NOT EXISTS (SELECT 1 FROM empleados.Guia WHERE id_empleado = @id_empleado)
            SET @msj_errores += '- El Guía no existe. ';

        IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE id = @id_actividad)
            SET @msj_errores += '- La Actividad especificada no existe. ';

        IF EXISTS (SELECT 1 FROM empleados.GuiaEstaEnActividad 
                   WHERE id_empleado = @id_empleado AND id_actividad = @id_actividad AND fecha_fin IS NULL)
            SET @msj_errores += '- El Guía ya se encuentra asignado de forma activa a esta actividad. ';

        IF (LEN(@msj_errores) > 0)
            THROW 50127, @msj_errores, 1;

        INSERT INTO empleados.GuiaEstaEnActividad (id_empleado, id_actividad, fecha_inicio)
        VALUES (@id_empleado, @id_actividad, @fecha_inicio);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja Lógica (Registrar fin de participación en Actividad)
CREATE OR ALTER PROCEDURE empleados.sp_registrar_fin_actividad_guia
    @id_empleado INT,
    @id_actividad INT,
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.GuiaEstaEnActividad 
                       WHERE id_empleado = @id_empleado AND id_actividad = @id_actividad AND fecha_inicio = @fecha_inicio)
            THROW 50128, 'El registro de asignación a la actividad especificada no existe.', 1;

        IF (@fecha_fin < @fecha_inicio)
            THROW 50128, 'La fecha de fin no puede ser anterior a la fecha de inicio.', 2;

        UPDATE empleados.GuiaEstaEnActividad
        SET fecha_fin = @fecha_fin
        WHERE id_empleado = @id_empleado 
          AND id_actividad = @id_actividad 
          AND fecha_inicio = @fecha_inicio;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja Física (Eliminación por error de carga)
CREATE OR ALTER PROCEDURE empleados.sp_eliminar_asignacion_actividad
    @id_empleado INT,
    @id_actividad INT,
    @fecha_inicio DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM empleados.GuiaEstaEnActividad 
                       WHERE id_empleado = @id_empleado
                       AND id_actividad = @id_actividad 
                       AND fecha_inicio = @fecha_inicio)
            THROW 50129, 'El registro de asignación a actividad no existe para ser eliminado.', 1;

        DELETE FROM empleados.GuiaEstaEnActividad 
        WHERE id_empleado = @id_empleado 
          AND id_actividad = @id_actividad 
          AND fecha_inicio = @fecha_inicio;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO