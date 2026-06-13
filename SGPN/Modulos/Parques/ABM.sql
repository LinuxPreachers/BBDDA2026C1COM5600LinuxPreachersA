/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Creación de SP ABM módulo parques
*/

USE LinuxPreachers;
GO

-----------------------------------------------
-- Region
-----------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_leer_region
    @id INT = NULL,
    @nombre VARCHAR(100) = NULL
AS
BEGIN
    IF (@id IS NULL AND @nombre IS NULL)
    BEGIN
        ;THROW 50000, 'Debe ingresar un id o un nombre.', 1;
    END;

    SELECT
        id,
        nombre
    FROM parques.Region
    WHERE (@id IS NULL OR id = @id)
      AND (@nombre IS NULL OR nombre = @nombre)
    ORDER BY id;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_crear_region
    @nombre VARCHAR(100)
AS
BEGIN

    DECLARE @msj_errores VARCHAR(4000) = '';

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @msj_errores += '- El nombre de la region no puede estar vacio. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.Region (nombre)
    VALUES (@nombre);
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_modificar_region
    @id INT,
    @nombreNuevo VARCHAR(100)
AS
BEGIN

    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.Region WHERE id = @id)
        SET @msj_errores += '- La Region con el ID provisto no existe. ';

    IF (@nombreNuevo IS NULL OR LTRIM(RTRIM(@nombreNuevo)) = '')
        SET @msj_errores += '- El nombre nuevo de la region no puede estar vacio. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.Region
    SET nombre = @nombreNuevo
    WHERE id = @id;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_eliminar_region
    @id INT
AS
BEGIN

    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.Region WHERE id = @id)
        SET @msj_errores += '- La Region con el ID provisto no existe. ';

    IF EXISTS (SELECT 1 FROM parques.Provincia WHERE id_region = @id)
        SET @msj_errores += '- No se puede eliminar la Region porque tiene provincias asociadas. ';

    IF EXISTS (SELECT 1 FROM parques.EstadisticaVisitantes WHERE id_region = @id)
        SET @msj_errores += '- No se puede eliminar la Region porque tiene estadisticas de visitantes asociadas. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    DELETE FROM parques.Region
    WHERE id = @id;
END;
GO

-----------------------------------------------
-- Provincia
-----------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_leer_provincia
    @id INT = NULL,
    @id_region INT = NULL
AS
BEGIN

    SELECT
        id,
        nombre,
        id_region
    FROM parques.Provincia
    WHERE (@id IS NULL OR id = @id) 
            AND (@id_region IS NULL OR id_region=@id_region)
    ORDER BY id;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_crear_provincia
    @nombre VARCHAR(100),
    @id_region INT
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @msj_errores += '- El nombre de la provincia no puede estar vacio. ';

    IF NOT EXISTS (SELECT 1 FROM parques.Region WHERE id = @id_region)
        SET @msj_errores += '- El ID de Region especificado no existe. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.Provincia (nombre, id_region)
    VALUES (@nombre, @id_region);
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_modificar_provincia
    @id INT,
    @nombre VARCHAR(100) = NULL,
    @id_region INT = NULL
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.Provincia WHERE id = @id)
        SET @msj_errores += '- La Provincia con el ID provisto no existe. ';

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @msj_errores += '- El nombre de la provincia no puede estar vacio. ';

    IF NOT EXISTS (SELECT 1 FROM parques.Region WHERE id = @id_region)
        SET @msj_errores += '- El ID de Region especificado no existe. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.Provincia
    SET nombre = COALESCE(@nombre, nombre),
        id_region = COALESCE(@id_region, id_region)
    WHERE id = @id;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_eliminar_provincia
    @id INT
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.Provincia WHERE id = @id)
        SET @msj_errores += '- La Provincia con el ID provisto no existe. ';

    IF EXISTS (SELECT 1 FROM parques.ProvinciaParque WHERE id_provincia = @id)
        SET @msj_errores += '- No se puede eliminar la Provincia porque tiene parques asociados. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    DELETE FROM parques.Provincia
    WHERE id = @id;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_eliminar_provincias_de_region
    @id_region INT
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.Region WHERE id = @id_region)
        SET @msj_errores += '- La Region con el ID provisto no existe. ';


    IF NOT EXISTS (SELECT 1 FROM parques.Provincia WHERE id_region = @id_region)
        SET @msj_errores += '- No hay ninguna provincia en la region. ';

    IF EXISTS (
        SELECT 1 
        FROM parques.ProvinciaParque PP join parques.Provincia P on PP.id_parque = P.id
        WHERE P.id_region = @id_region
    )
        SET @msj_errores += '- No se pueden eliminar las Provincias porque tienen Parques asociados. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    BEGIN TRANSACTION;
        DECLARE @ProvinciasAEliminar TABLE ( id INT );
        INSERT INTO @ProvinciasAEliminar (id) SELECT id FROM parques.Provincia WHERE id_region = @id_region;
        DECLARE @id_provincia INT;
        WHILE EXISTS (SELECT 1 FROM @ProvinciasAEliminar)
        BEGIN
            SELECT TOP 1 @id_provincia = id FROM @ProvinciasAEliminar;
            EXEC parques.sp_eliminar_provincia @id_provincia;
            DELETE FROM @ProvinciasAEliminar WHERE id = @id_provincia;
        END;
    COMMIT TRANSACTION;
END;
GO


-----------------------------------------------
-- TipoVisitante
-----------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_leer_tipo_visitante
    @id INT = NULL
AS
BEGIN
    
    SELECT
        id,
        nombre,
        descripcion
    FROM parques.TipoVisitante
    WHERE (@id IS NULL OR id = @id)
    ORDER BY id;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_crear_tipo_visitante
    @nombre VARCHAR(100),
    @descripcion VARCHAR(255) = NULL
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @msj_errores += '- El nombre del tipo de visitante no puede estar vacio. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.TipoVisitante (nombre, descripcion)
    VALUES (@nombre, @descripcion);
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_modificar_tipo_visitante
    @id INT,
    @nombre VARCHAR(100) = NULL,
    @descripcion VARCHAR(255) = NULL
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE id = @id)
        SET @msj_errores += '- El TipoVisitante con el ID provisto no existe. ';

    IF (@nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = '')
        SET @msj_errores += '- El nombre del tipo de visitante no puede estar vacio. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.TipoVisitante
    SET nombre = COALESCE(@nombre, nombre),
        descripcion = COALESCE(@descripcion, descripcion)
    WHERE id = @id;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_eliminar_tipo_visitante
    @id INT
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE id = @id)
        SET @msj_errores += '- El TipoVisitante con el ID provisto no existe. ';

    IF EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante WHERE id_tipo_visitante = @id)
        SET @msj_errores += '- No se puede eliminar el TipoVisitante porque esta asociado a al menos un parque. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    DELETE FROM parques.TipoVisitante
    WHERE id = @id;
END;
GO

-----------------------------------------------
-- TipoParque
-----------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_leer_tipo_parque
    @id INT = NULL
AS
BEGIN
    
    SELECT
        id,
        descripcion
    FROM parques.TipoParque
    WHERE (@id IS NULL OR id = @id)
    ORDER BY id;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_crear_tipo_parque
    @descripcion VARCHAR(255)
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF (@descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = '')
        SET @msj_errores += '- La descripcion del tipo de parque no puede estar vacia. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.TipoParque (descripcion)
    VALUES (@descripcion);
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_modificar_tipo_parque
    @id INT,
    @descripcion VARCHAR(255)
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.TipoParque WHERE id = @id)
        SET @msj_errores += '- El TipoParque con el ID provisto no existe. ';

    IF (@descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = '')
        SET @msj_errores += '- La descripcion del tipo de parque no puede estar vacia. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.TipoParque
    SET descripcion = @descripcion
    WHERE id = @id;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_eliminar_tipo_parque
    @id INT
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.TipoParque WHERE id = @id)
        SET @msj_errores += '- El TipoParque con el ID provisto no existe. ';

    IF EXISTS (SELECT 1 FROM parques.Parque WHERE id_tipo_parque = @id)
        SET @msj_errores += '- No se puede eliminar el TipoParque porque tiene parques asociados. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    DELETE FROM parques.TipoParque
    WHERE id = @id;
END;
GO

-----------------------------------------------
-- Parque
-----------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_leer_parque
    @id INT = NULL,
    @id_tipo_parque INT = NULL
AS
BEGIN
    
    SELECT
        id,
        nombre,
        superficie_km2,
        latitud,
        longitud,
        id_tipo_parque
    FROM parques.Parque
    WHERE (@id IS NULL OR id = @id)
        AND (@id_tipo_parque IS NULL OR id_tipo_parque = @id_tipo_parque)
    ORDER BY id;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_crear_parque
    @nombre VARCHAR(100),
    @superficie_km2 DECIMAL(10,2) = NULL,
    @latitud DECIMAL(9,6) = NULL,
    @longitud DECIMAL(9,6) = NULL,
    @id_tipo_parque INT
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @msj_errores += '- El nombre del parque no puede estar vacio. ';

    IF (@superficie_km2 IS NOT NULL AND @superficie_km2 <= 0)
        SET @msj_errores += '- La superficie del parque debe ser positiva. ';

    IF (@latitud IS NOT NULL AND (@latitud < -90 OR @latitud > 90))
        SET @msj_errores += '- La latitud debe estar entre -90 y 90. ';

    IF (@longitud IS NOT NULL AND (@longitud < -180 OR @longitud > 180))
        SET @msj_errores += '- La longitud debe estar entre -180 y 180. ';

    IF NOT EXISTS (SELECT 1 FROM parques.TipoParque WHERE id = @id_tipo_parque)
        SET @msj_errores += '- El ID de Tipo de Parque especificado no existe. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.Parque (nombre, superficie_km2, latitud, longitud, id_tipo_parque)
    VALUES (@nombre, @superficie_km2, @latitud, @longitud, @id_tipo_parque);
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_modificar_parque
    @id INT,
    @nombre VARCHAR(100) = NULL,
    @superficie_km2 DECIMAL(10,2) = NULL,
    @latitud DECIMAL(9,6) = NULL,
    @longitud DECIMAL(9,6) = NULL,
    @id_tipo_parque INT
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id = @id)
        SET @msj_errores += '- El Parque con el ID provisto no existe. ';

    IF (@nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = '')
        SET @msj_errores += '- El nombre del parque no puede estar vacio. ';

    IF (@superficie_km2 IS NOT NULL AND @superficie_km2 < 0)
        SET @msj_errores += '- La superficie del parque no puede ser negativa. ';

    IF (@latitud IS NOT NULL AND (@latitud < -90 OR @latitud > 90))
        SET @msj_errores += '- La latitud debe estar entre -90 y 90. ';

    IF (@longitud IS NOT NULL AND (@longitud < -180 OR @longitud > 180))
        SET @msj_errores += '- La longitud debe estar entre -180 y 180. ';

    IF NOT EXISTS (SELECT 1 FROM parques.TipoParque WHERE id = @id_tipo_parque)
        SET @msj_errores += '- El ID de TipoParque especificado no existe. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.Parque
    SET nombre = COALESCE(@nombre,nombre),
        superficie_km2 = COALESCE(@superficie_km2, superficie_km2),
        latitud = COALESCE(@latitud,latitud),
        longitud = COALESCE(@longitud,longitud),
        id_tipo_parque = COALESCE(@id_tipo_parque, id_tipo_parque)
    WHERE id = @id;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_eliminar_parque
    @id INT
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id = @id)
        SET @msj_errores += '- El Parque con el ID provisto no existe. ';

    --IF EXISTS (SELECT 1 FROM parques.ProvinciaParque WHERE id_parque = @id)
    --    SET @msj_errores += '- No se puede eliminar el Parque porque tiene provincias asociadas. ';

    --IF EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante WHERE id_parque = @id)
    --    SET @msj_errores += '- No se puede eliminar el Parque porque tiene tipos de visitante asociados. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    BEGIN TRANSACTION
        DELETE FROM parques.ProvinciaParque WHERE id_parque = @id
        DELETE FROM parques.ParqueTipoVisitante WHERE id_parque = @id
        DELETE FROM parques.Parque WHERE id = @id;
    COMMIT TRANSACTION
END;
GO

-----------------------------------------------
-- EstadisticaVisitantes
-----------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_leer_estadistica_visitantes
    @id INT = NULL
AS
BEGIN
    
    SELECT
        id,
        periodo,
        periodo_inicio,
        periodo_fin,
        cantidad,
        id_region
    FROM parques.EstadisticaVisitantes
    WHERE (@id IS NULL OR id = @id)
    ORDER BY id;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_crear_estadistica_visitantes
    @periodo VARCHAR(50),
    @periodo_inicio DATETIME,
    @periodo_fin DATETIME,
    @cantidad INT,
    @id_region INT
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF (@periodo IS NULL OR LTRIM(RTRIM(@periodo)) = '')
        SET @msj_errores += '- El periodo no puede estar vacio. ';

    IF (@periodo_inicio IS NULL)
        SET @msj_errores += '- La fecha de inicio del periodo no puede ser nula. ';

    IF (@periodo_fin IS NULL)
        SET @msj_errores += '- La fecha de fin del periodo no puede ser nula. ';

    IF (@periodo_inicio IS NOT NULL AND @periodo_fin IS NOT NULL AND @periodo_fin < @periodo_inicio)
        SET @msj_errores += '- La fecha de fin del periodo no puede ser anterior a la fecha de inicio. ';

    IF (@cantidad IS NULL OR @cantidad < 0)
        SET @msj_errores += '- La cantidad de visitantes no puede ser negativa. ';

    IF NOT EXISTS (SELECT 1 FROM parques.Region WHERE id = @id_region)
        SET @msj_errores += '- El ID de Region especificado no existe. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.EstadisticaVisitantes (periodo, periodo_inicio, periodo_fin, cantidad, id_region)
    VALUES (@periodo, @periodo_inicio, @periodo_fin, @cantidad, @id_region);
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_modificar_estadistica_visitantes
    @id INT,
    @periodo VARCHAR(50),
    @periodo_inicio DATETIME,
    @periodo_fin DATETIME,
    @cantidad INT,
    @id_region INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.EstadisticaVisitantes WHERE id = @id)
        SET @msj_errores += '- La EstadisticaVisitantes con el ID provisto no existe. ';

    IF (@periodo IS NULL OR LTRIM(RTRIM(@periodo)) = '')
        SET @msj_errores += '- El periodo no puede estar vacio. ';

    IF (@periodo_inicio IS NULL)
        SET @msj_errores += '- La fecha de inicio del periodo no puede ser nula. ';

    IF (@periodo_fin IS NULL)
        SET @msj_errores += '- La fecha de fin del periodo no puede ser nula. ';

    IF (@periodo_inicio IS NOT NULL AND @periodo_fin IS NOT NULL AND @periodo_fin < @periodo_inicio)
        SET @msj_errores += '- La fecha de fin del periodo no puede ser anterior a la fecha de inicio. ';

    IF (@cantidad IS NULL OR @cantidad < 0)
        SET @msj_errores += '- La cantidad de visitantes no puede ser nula ni negativa. ';

    IF NOT EXISTS (SELECT 1 FROM parques.Region WHERE id = @id_region)
        SET @msj_errores += '- El ID de Region especificado no existe. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.EstadisticaVisitantes
    SET periodo = @periodo,
        periodo_inicio = @periodo_inicio,
        periodo_fin = @periodo_fin,
        cantidad = @cantidad,
        id_region = @id_region
    WHERE id = @id;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_eliminar_estadistica_visitantes
    @id INT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM parques.EstadisticaVisitantes WHERE id = @id)
    BEGIN
        RAISERROR('La EstadisticaVisitantes con el ID provisto no existe.', 16, 1);
        RETURN;
    END;

    DELETE FROM parques.EstadisticaVisitantes
    WHERE id = @id;
END;
GO

-----------------------------------------------
-- ProvinciaParque
-----------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_leer_provincia_parque
    @id_provincia INT = NULL,
    @id_parque INT = NULL
AS
BEGIN
    
    SELECT
        id_provincia,
        id_parque,
        direccion
    FROM parques.ProvinciaParque
    WHERE (@id_provincia IS NULL OR id_provincia = @id_provincia)
      AND (@id_parque IS NULL OR id_parque = @id_parque)
    ORDER BY id_provincia, id_parque;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_crear_provincia_parque
    @id_provincia INT,
    @id_parque INT,
    @direccion VARCHAR(255) = NULL
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.Provincia WHERE id = @id_provincia)
        SET @msj_errores += '- El ID de Provincia especificado no existe. ';

    IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id = @id_parque)
        SET @msj_errores += '- El ID de Parque especificado no existe. ';

    IF EXISTS (SELECT 1 FROM parques.ProvinciaParque WHERE id_provincia = @id_provincia AND id_parque = @id_parque)
        SET @msj_errores += '- Ya existe una relacion entre esa Provincia y ese Parque. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.ProvinciaParque (id_provincia, id_parque, direccion)
    VALUES (@id_provincia, @id_parque, @direccion);
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_modificar_provincia_parque
    @id_provincia INT,
    @id_parque INT,
    @direccion VARCHAR(255) = NULL
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM parques.ProvinciaParque WHERE id_provincia = @id_provincia AND id_parque = @id_parque)
    BEGIN
        RAISERROR('La relacion ProvinciaParque con los IDs provistos no existe.', 16, 1);
        RETURN;
    END;

    UPDATE parques.ProvinciaParque
    SET direccion = @direccion
    WHERE id_provincia = @id_provincia
      AND id_parque = @id_parque;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_eliminar_provincia_parque
    @id_provincia INT,
    @id_parque INT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM parques.ProvinciaParque WHERE id_provincia = @id_provincia AND id_parque = @id_parque)
    BEGIN
        RAISERROR('La relacion ProvinciaParque con los IDs provistos no existe.', 16, 1);
        RETURN;
    END;

    DELETE FROM parques.ProvinciaParque
    WHERE id_provincia = @id_provincia
      AND id_parque = @id_parque;
END;
GO

-- ---------------------------------------------
-- ParqueTipoVisitante
-- ---------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_leer_parque_tipo_visitante
    @id_parque INT = NULL,
    @id_tipo_visitante INT = NULL
AS
BEGIN
    
    SELECT
        id_parque,
        id_tipo_visitante,
        precio
    FROM parques.ParqueTipoVisitante
    WHERE (@id_parque IS NULL OR id_parque = @id_parque)
      AND (@id_tipo_visitante IS NULL OR id_tipo_visitante = @id_tipo_visitante)
    ORDER BY id_parque, id_tipo_visitante;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_crear_parque_tipo_visitante
    @id_parque INT,
    @id_tipo_visitante INT,
    @precio DECIMAL(10,2)
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id = @id_parque)
        SET @msj_errores += '- El ID de Parque especificado no existe. ';

    IF NOT EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE id = @id_tipo_visitante)
        SET @msj_errores += '- El ID de TipoVisitante especificado no existe. ';

    IF (@precio IS NULL OR @precio < 0)
        SET @msj_errores += '- El precio no puede ser negativo. ';

    IF EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante WHERE id_parque = @id_parque AND id_tipo_visitante = @id_tipo_visitante)
        SET @msj_errores += '- Ya existe un precio para ese Parque y ese TipoVisitante. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.ParqueTipoVisitante (id_parque, id_tipo_visitante, precio)
    VALUES (@id_parque, @id_tipo_visitante, @precio);
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_modificar_parque_tipo_visitante
    @id_parque INT,
    @id_tipo_visitante INT,
    @precio DECIMAL(10,2)
AS
BEGIN
    
    DECLARE @msj_errores VARCHAR(4000) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante WHERE id_parque = @id_parque AND id_tipo_visitante = @id_tipo_visitante)
        SET @msj_errores += '- La relacion ParqueTipoVisitante con los IDs provistos no existe. ';

    IF (@precio IS NULL OR @precio < 0)
        SET @msj_errores += '- El precio no puede ser negativo. ';

    IF (LEN(@msj_errores) > 0)
    BEGIN
        RAISERROR(@msj_errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.ParqueTipoVisitante
    SET precio = @precio
    WHERE id_parque = @id_parque
      AND id_tipo_visitante = @id_tipo_visitante;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_eliminar_parque_tipo_visitante
    @id_parque INT,
    @id_tipo_visitante INT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM parques.ParqueTipoVisitante WHERE id_parque = @id_parque AND id_tipo_visitante = @id_tipo_visitante)
    BEGIN
        RAISERROR('La relacion ParqueTipoVisitante con los IDs provistos no existe.', 16, 1);
        RETURN;
    END;

    DELETE FROM parques.ParqueTipoVisitante
    WHERE id_parque = @id_parque
      AND id_tipo_visitante = @id_tipo_visitante;
END;
GO
