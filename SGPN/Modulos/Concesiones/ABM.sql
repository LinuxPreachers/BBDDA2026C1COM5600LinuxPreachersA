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
        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            THROW 60100, 'El nombre ingresado para la Empresa no es válido.', 1;

        IF(@razon_social IS NULL OR LTRIM(RTRIM(@razon_social)) = '')
            THROW 60101, 'La razon social ingresada para la Empresa no es válida.', 1;

        IF(@cuit >= 99999999999 OR @cuit <= 10000000000)
            THROW 60102, 'CUIT inválido.', 1;

        IF(EXISTS(SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE @cuit = cuit))
            THROW 60103, 'CUIT ya cargado.', 1;

        IF( @id_actividad_empresarial NOT IN(SELECT id FROM concesiones.ActividadEmpresarial) )
            THROW 60104, 'No existe la Actividad', 1;

            
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
        IF NOT EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id = @id)
            THROW 60110, 'La Empresa con el ID provisto no existe.', 1;

        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            THROW 60111, 'El nombre ingresado para la Empresa no es válido.', 1;

        IF(@razon_social IS NULL OR LTRIM(RTRIM(@razon_social)) = '')
            THROW 60112, 'La razon social ingresada para la Empresa no es válida.', 1;

        IF(@cuit >= 99999999999 OR @cuit <= 10000000000)
            THROW 60113, 'CUIT inválido.', 1;

        IF( @id_actividad_empresarial NOT IN(SELECT id FROM concesiones.ActividadEmpresarial) )
            THROW 60114, 'No existe la Actividad', 1;

        UPDATE concesiones.EmpresaConcesionaria
        SET nombre = @nombre , descripcion = @descripcion, cuit = @cuit , razon_social = @razon_social, id_actividad_empresarial = @id_actividad_empresarial
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

        IF NOT EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id = @id)
            THROW 60120, 'La Empresa con el ID provisto no existe.', 1;

        IF EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id_empresa_concesionaria = @id)
            THROW 60121, 'La Empresa con el ID provisto tiene concesiones.', 1;

        DELETE  FROM  concesiones.EmpresaConcesionaria WHERE id = @id;

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
            THROW 60130, 'El nombre ingresado para la actividad empresarial no es válido.', 1;
            
        INSERT INTO concesiones.ActividadEmpresarial(nombre)
        VALUES (@nombre);
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
        IF NOT EXISTS (SELECT 1 FROM concesiones.ActividadEmpresarial WHERE id = @id)
            THROW 60131, 'La actividad empresarial con el ID provisto no existe.', 1;

        IF(@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            THROW 60132, 'El nombre ingresado para la actividad empresarial no es válido.', 2;

        UPDATE concesiones.ActividadEmpresarial
        SET nombre = @nombre, descripcion= @descripcion
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
        IF NOT EXISTS (SELECT 1 FROM concesiones.ActividadEmpresarial WHERE id = @id)
            THROW 60133, 'La actividad empresarial con el ID provisto no existe.', 1;

        IF EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id_actividad_empresarial = @id)
            THROW 60134, 'La Actividad con el ID provisto tiene Empresas.', 1;

        DELETE FROM ActividadEmpresarial WHERE id = @id;

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
    @fecha_inicio DATETIME,
    @fecha_fin DATETIME,
    @id_empresa_concesionaria INT,
    @id_parque INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF( @fecha_inicio > @fecha_fin)
            THROW 60200, 'La fecha de inicio es mayor a la de fin', 1;

        IF( NOT EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria) )
            THROW 60201, 'No existe la empresa', 1;

        IF( NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id = @id_parque) )
            THROW 60202, 'No existe el parque', 1;
            
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
        IF NOT EXISTS (SELECT 1 FROM concesiones.ActividadEmpresarial WHERE id = @id)
            THROW 60131, 'La actividad empresarial con el ID provisto no existe.', 1;

        IF( @fecha_inicio > @fecha_fin)
            THROW 60200, 'La fecha de inicio es mayor a la de fin', 1;

        IF( NOT EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id = @id_empresa_concesionaria) )
            THROW 60201, 'No existe la empresa', 1;

        IF( NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id = @id_parque) )
            THROW 60202, 'No existe el parque', 1;
            

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

CREATE OR ALTER PROCEDURE pagos.sp_crear_canon
        @periodo DATE,
        @monto DECIMAL(15,2),
        @fecha_pago DATE ,
        @id_concesion INT,
        @id_forma_pago INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        IF( @id_concesion NOT IN(SELECT id FROM concesiones.Concesion) )
            THROW 60031, 'No existe la concesion', 1;

        IF( @id_forma_pago NOT IN(SELECT id FROM pagos.FormaPago) )
            THROW 60032, 'No existe la forma de pago', 1;

        IF (@monto <= 0)
            THROW 60033, 'Monto menor o igual 0',1;
            
        INSERT INTO concesiones.Canon(periodo,monto,fecha_pago,id_concesion,id_forma_pago)
        VALUES (@periodo,@monto,@fecha_pago,@id_concesion,@id_forma_pago);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

-- Completar. Primero arreglar DER CANON-PAGO

-- Modificar
CREATE OR ALTER PROCEDURE pagos.sp_modificar_canon
        @id INT,
        @periodo DATE,
        @monto DECIMAL(15,2),
        @fecha_pago DATE ,
        @id_concesion INT,
        @id_forma_pago INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        IF( @id_concesion NOT IN(SELECT id FROM concesiones.Concesion) )
            THROW 60031, 'No existe la concesion', 1;

        IF( @id_forma_pago NOT IN(SELECT id FROM pagos.FormaPago) )
            THROW 60032, 'No existe la forma de pago', 1;

        IF (@monto <= 0)
            THROW 60033, 'Monto menor o igual 0',1;
            

        UPDATE concesiones.Canon
        SET periodo = @periodo, monto = @monto, fecha_pago = @fecha_pago, id_concesion = @id_concesion, id_forma_pago = @id_forma_pago
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO


-- Por logica de negocio no se permite eliminar Canon
