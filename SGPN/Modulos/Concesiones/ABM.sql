/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Creación de SP ABM módulo concesiones
*/

USE LinuxPreachers;
GO

-- ---------------------------------------------
-- 1. ABM: EMPRESA CONCESIONARIA
-- ---------------------------------------------

-- Alta
CREATE OR ALTER PROCEDURE concesiones.sp_crear_empresa_concesionaria

    @nombre VARCHAR(100),
    @descripcion VARCHAR(255),
    @cuit BIGINT,
    @razon_social VARCHAR(100),
    @id_actividad_empresarial INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @errores VARCHAR(4000) = '';

        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            SET @errores = @errores + 'El nombre ingresado para la Empresa no es válido. ';

        IF(@razon_social IS NULL OR LTRIM(RTRIM(@razon_social)) = '')
            SET @errores = @errores + 'La razon social ingresada para la Empresa no es válida. ';

        IF(@cuit >= 99999999999 OR @cuit <= 10000000000)
            SET @errores = @errores + 'CUIT inválido. ';

        IF(EXISTS(SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE cuit = @cuit))
            SET @errores = @errores + 'CUIT ya cargado. ';

        IF(@id_actividad_empresarial NOT IN(SELECT id FROM concesiones.ActividadEmpresarial))
            SET @errores = @errores + 'No existe la Actividad. ';

        IF LEN(@errores) > 0
            THROW 50400, @errores, 1;

        INSERT INTO concesiones.EmpresaConcesionaria(nombre,descripcion,cuit,razon_social,id_actividad_empresarial)
        VALUES (@nombre,@descripcion,@cuit,@razon_social,@id_actividad_empresarial);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE concesiones.sp_modificar_empresa_concesionaria
    @id INT,
    @nombre VARCHAR(100),
    @descripcion VARCHAR(255),
    @cuit BIGINT,
    @razon_social VARCHAR(100),
    @id_actividad_empresarial INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @errores VARCHAR(4000) = '';

        IF NOT EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id = @id)
            SET @errores = @errores + 'La Empresa con el ID provisto no existe. ';

        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            SET @errores = @errores + 'El nombre ingresado para la Empresa no es válido. ';

        IF(@razon_social IS NULL OR LTRIM(RTRIM(@razon_social)) = '')
            SET @errores = @errores + 'La razon social ingresada para la Empresa no es válida. ';

        IF(@cuit >= 99999999999 OR @cuit <= 10000000000)
            SET @errores = @errores + 'CUIT inválido. ';

        IF(@id_actividad_empresarial NOT IN(SELECT id FROM concesiones.ActividadEmpresarial))
            SET @errores = @errores + 'No existe la Actividad. ';

        IF LEN(@errores) > 0
            THROW 50410, @errores, 1;

        UPDATE concesiones.EmpresaConcesionaria
        SET nombre = @nombre, descripcion = @descripcion, cuit = @cuit, razon_social = @razon_social, id_actividad_empresarial = @id_actividad_empresarial
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja
CREATE OR ALTER PROCEDURE concesiones.sp_eliminar_empresa_concesionaria
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @errores VARCHAR(4000) = '';

        IF NOT EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id = @id)
            SET @errores = @errores + 'La Empresa con el ID provisto no existe. ';

        IF EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id_empresa_concesionaria = @id)
            SET @errores = @errores + 'La Empresa con el ID provisto tiene concesiones. ';

        IF LEN(@errores) > 0
            THROW 50420, @errores, 1;

        DELETE FROM concesiones.EmpresaConcesionaria WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO
-- ---------------------------------------------
-- 2. ABM: ACTIVIDAD EMPRESARIAL
-- ---------------------------------------------

-- Alta
CREATE OR ALTER PROCEDURE concesiones.sp_crear_actividad_empresarial
    @nombre VARCHAR(100),
    @descripcion VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            THROW 50430, 'El nombre ingresado para la actividad empresarial no es válido.', 1;
            
        INSERT INTO concesiones.ActividadEmpresarial(nombre,descripcion)
        VALUES (@nombre,@descripcion);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE concesiones.sp_modificar_actividad_empresarial
    @id INT,
    @nombre VARCHAR(100),
    @descripcion VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @errores VARCHAR(4000) = '';

        IF NOT EXISTS (SELECT 1 FROM concesiones.ActividadEmpresarial WHERE id = @id)
            SET @errores = @errores + 'La actividad empresarial con el ID provisto no existe. ';

        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            SET @errores = @errores + 'El nombre ingresado para la actividad empresarial no es válido. ';

        IF LEN(@errores) > 0
            THROW 50431, @errores, 1;

        UPDATE concesiones.ActividadEmpresarial
        SET nombre = @nombre, descripcion = @descripcion
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Baja
CREATE OR ALTER PROCEDURE concesiones.sp_eliminar_actividad_empresarial
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @errores VARCHAR(4000) = '';

        IF NOT EXISTS (SELECT 1 FROM concesiones.ActividadEmpresarial WHERE id = @id)
            SET @errores = @errores + 'La actividad empresarial con el ID provisto no existe. ';

        IF EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id_actividad_empresarial = @id)
            SET @errores = @errores + 'La Actividad con el ID provisto tiene Empresas. ';

        IF LEN(@errores) > 0
            THROW 50433, @errores, 1;

        DELETE FROM concesiones.ActividadEmpresarial WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO
-- ---------------------------------------------
-- 3.  CONCESION
-- ---------------------------------------------

-- Alta

CREATE OR ALTER PROCEDURE concesiones.sp_crear_concesion
    @descripcion VARCHAR(255),
    @fecha_inicio DATE,
    @fecha_fin DATE,
    @id_empresa_concesionaria INT,
    @id_parque INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @errores VARCHAR(4000) = '';

        IF(@fecha_inicio > @fecha_fin)
            SET @errores = @errores + 'La fecha de inicio es mayor a la de fin. ';

        IF(NOT EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria))
            SET @errores = @errores + 'No existe la empresa. ';

        IF(NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id = @id_parque))
            SET @errores = @errores + 'No existe el parque. ';

        IF LEN(@errores) > 0
            THROW 50400, @errores, 1;

        INSERT INTO concesiones.Concesion(descripcion,fecha_inicio,fecha_fin,id_empresa_concesionaria,id_parque)
        VALUES (@descripcion,@fecha_inicio,@fecha_fin,@id_empresa_concesionaria,@id_parque);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificación
CREATE OR ALTER PROCEDURE concesiones.sp_modificar_concesion
    @id INT,
    @descripcion VARCHAR(255),
    @fecha_inicio DATETIME,
    @fecha_fin DATETIME,
    @id_empresa_concesionaria INT,
    @id_parque INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @errores VARCHAR(4000) = '';

         IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id = @id)
            SET @errores = @errores + 'La Concesion con el ID provisto no existe. ';

        IF(@fecha_inicio > @fecha_fin)
            SET @errores = @errores + 'La fecha de inicio es mayor a la de fin. ';

        IF(NOT EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria))
            SET @errores = @errores + 'No existe la empresa. ';

        IF(NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id = @id_parque))
            SET @errores = @errores + 'No existe el parque. ';

        IF LEN(@errores) > 0
            THROW 50431, @errores, 1;

        UPDATE concesiones.Concesion
        SET descripcion = @descripcion, fecha_inicio = @fecha_inicio, fecha_fin = @fecha_fin, id_empresa_concesionaria = @id_empresa_concesionaria
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO
-- Por logica de negocio no se permiten eliminar concesiones.

-- ---------------------------------------------
-- 4.  CANON
-- ---------------------------------------------

-- Alta

CREATE OR ALTER PROCEDURE concesiones.sp_crear_canon
        @periodo DATE,
        @monto DECIMAL(15,2),
        @fecha_pago DATE = NULL, --parametro opcional
        @fecha_lim_pago DATE,
        @id_concesion INT,
        @id_forma_pago INT = NULL-- parametro opcional al crear
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @errores VARCHAR(4000) = '';

        IF(@id_concesion NOT IN(SELECT id FROM concesiones.Concesion))
            SET @errores = @errores + 'No existe la concesion. ';

        IF(@id_forma_pago NOT IN(SELECT id FROM pagos.FormaPago))
            SET @errores = @errores + 'No existe la forma de pago. ';

        IF(@monto <= 0)
            SET @errores = @errores + 'Monto menor o igual 0. ';

        IF LEN(@errores) > 0
            THROW 50431, @errores, 1;

        INSERT INTO concesiones.Canon(periodo,monto,fecha_pago,fecha_lim_pago,id_concesion,id_forma_pago)
        VALUES (@periodo,@monto,@fecha_pago,@fecha_lim_pago,@id_concesion,@id_forma_pago);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Modificar
CREATE OR ALTER PROCEDURE concesiones.sp_modificar_canon
        @id INT,
        @periodo DATE,
        @monto DECIMAL(15,2),
        @fecha_pago DATE = NULL, --parametro opcional
        @fecha_lim_pago DATE,
        @id_concesion INT,
        @id_forma_pago INT = NULL-- parametro opcional al crear
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @errores VARCHAR(4000) = '';

        IF(@id_concesion NOT IN(SELECT id FROM concesiones.Concesion))
            SET @errores = @errores + 'No existe la concesion. ';

        IF(@id_forma_pago NOT IN(SELECT id FROM pagos.FormaPago))
            SET @errores = @errores + 'No existe la forma de pago. ';

        IF(@monto <= 0)
            SET @errores = @errores + 'Monto menor o igual 0. ';

        IF LEN(@errores) > 0
            THROW 50431, @errores, 1;

        UPDATE concesiones.Canon
        SET periodo = @periodo, monto = @monto, fecha_pago = @fecha_pago, fecha_lim_pago = @fecha_lim_pago, id_concesion = @id_concesion, id_forma_pago = @id_forma_pago
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO


-- Por logica de negocio no se permite eliminar Canon


-- ---------------------------------------------
-- 5.  OTROS
-- ---------------------------------------------
-- Crea una concesión y generar todos los períodos de canon entre fecha_inicio y fecha_fin
-- en una sola transacción atómica. Si cualquier paso falla, se deshace todo.

CREATE OR ALTER PROCEDURE concesiones.sp_generar_concesion_y_canon
    @descripcion VARCHAR(255),
    @fecha_inicio DATE,
    @fecha_fin DATE,
    @id_empresa_concesionaria INT,
    @id_parque INT,
    @monto_canon DECIMAL(15,2),
    @cantidad_dias_vencimiento INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
       
        IF @cantidad_dias_vencimiento IS NULL OR @cantidad_dias_vencimiento <= 0
            THROW 51000, '@cantidad_dias_vencimiento debe ser un entero positivo.', 1;

        BEGIN TRANSACTION;

        -- 1. Crear concesión
        EXEC concesiones.sp_crear_concesion
            @descripcion = @descripcion,
            @fecha_inicio = @fecha_inicio,
            @fecha_fin = @fecha_fin,
            @id_empresa_concesionaria = @id_empresa_concesionaria,
            @id_parque = @id_parque;

        
        DECLARE @id_concesion INT;
        SELECT TOP 1 @id_concesion = id
        FROM concesiones.Concesion
        WHERE descripcion = @descripcion
          AND fecha_inicio = @fecha_inicio
          AND fecha_fin = @fecha_fin
          AND id_empresa_concesionaria = @id_empresa_concesionaria
          AND id_parque = @id_parque
        ORDER BY id DESC;

        -- 2. Generar períodos de canon (mes completo desde fecha_inicio hasta fecha_fin)
        DECLARE @periodo_actual DATE = DATEFROMPARTS(YEAR(@fecha_inicio), MONTH(@fecha_inicio), 1);
        DECLARE @periodo_limite DATE = DATEFROMPARTS(YEAR(@fecha_fin), MONTH(@fecha_fin), 1);

        WHILE @periodo_actual <= @periodo_limite
        BEGIN
            DECLARE @fecha_lim_pago DATE = DATEADD(day, @cantidad_dias_vencimiento, @periodo_actual);

            EXEC concesiones.sp_crear_canon
                @periodo = @periodo_actual,
                @monto = @monto_canon,
                @fecha_lim_pago = @fecha_lim_pago,
                @id_concesion = @id_concesion;

            SET @periodo_actual = DATEADD(month, 1, @periodo_actual);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


-- Finalizar una concesion anticipadamente
CREATE OR ALTER PROCEDURE concesiones.sp_finalizar_concesion
    @fecha_fin DATE,
    @id_concesion INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id = @id_concesion)
            THROW 51000, 'La concesion con el ID provisto no existe.', 1;

        IF @fecha_fin < (SELECT TOP 1 periodo FROM concesiones.Canon
                          WHERE id_concesion = @id_concesion AND fecha_pago IS NOT NULL
                          ORDER BY periodo DESC)
            THROW 51000, '@fecha_fin no puede ser menor que la fecha del periodo del ultimo canon pago.', 1;

        UPDATE concesiones.Concesion SET fecha_fin = @fecha_fin WHERE id = @id_concesion;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
