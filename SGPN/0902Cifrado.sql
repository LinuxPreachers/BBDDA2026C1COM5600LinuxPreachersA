/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Cifrado, a través de modificacion de tablas y sp's
*/
USE LinuxPreachers;
GO

SELECT seguridad.fn_obtener_pass();


 -- Agregamos un campo para los datos cifrados


IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('empleados.Empleado') AND name = 'nro_doc_cifrado')
BEGIN
    ALTER TABLE empleados.Empleado ADD nro_doc_cifrado VARBINARY(256);
END;
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('reservas.Reembolso') AND name = 'cvu_cifrado')
BEGIN
ALTER TABLE reservas.Reembolso ADD cvu_cifrado VARBINARY(256);
END;
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('empleados.Guardaparque') AND name = 'nro_matricula_cifrado')
BEGIN
    ALTER TABLE empleados.Guardaparque ADD nro_matricula_cifrado VARBINARY(256);
END;
GO


--migrar datos existentes
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('empleados.Empleado') AND name = 'nro_doc')
BEGIN
    UPDATE empleados.Empleado
    SET nro_doc_cifrado = ENCRYPTBYPASSPHRASE(seguridad.fn_obtener_pass(), CAST(nro_doc AS varchar))
    WHERE nro_doc_cifrado IS NULL;
END;
GO 

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('reservas.Reembolso') AND name = 'cvu_cuenta_destino')
BEGIN
    UPDATE reservas.Reembolso
    SET cvu_cifrado = ENCRYPTBYPASSPHRASE(seguridad.fn_obtener_pass(), CAST(cvu_cuenta_destino AS varchar))
    WHERE cvu_cifrado IS NULL;
END;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('empleados.Guardaparque') AND name = 'nro_matricula')
BEGIN
    UPDATE empleados.Guardaparque
    SET nro_matricula_cifrado = ENCRYPTBYPASSPHRASE(seguridad.fn_obtener_pass(), CAST(nro_matricula AS varchar))
    WHERE nro_matricula_cifrado  IS NULL;
END;
GO


-- Eliminar datos sensibles sin cifrar


-- --------------------------------------------------------------------
--  dni
-- --------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'UQ_Empleado_Documento')
BEGIN
    ALTER TABLE empleados.Empleado DROP CONSTRAINT UQ_Empleado_Documento;
END;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('empleados.Empleado') AND name = 'nro_doc')
BEGIN
    ALTER TABLE empleados.Empleado DROP COLUMN nro_doc;
END;
GO

-- --------------------------------------------------------------------
-- cvu_cuenta_destino
-- --------------------------------------------------------------------


IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('reservas.Reembolso') AND name = 'cvu_cuenta_destino')
BEGIN
    ALTER TABLE reservas.Reembolso DROP CONSTRAINT CK_Reembolso_CVU;
    ALTER TABLE reservas.Reembolso DROP COLUMN cvu_cuenta_destino;
END;
GO

-- --------------------------------------------------------------------
--  nro_matricula 
-- --------------------------------------------------------------------
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'UQ_Guardaparque_nro_matricula')
BEGIN
    ALTER TABLE empleados.Guardaparque DROP CONSTRAINT UQ_Guardaparque_nro_matricula;
END;
GO


IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('empleados.Guardaparque') AND name = 'nro_matricula')
BEGIN
    ALTER TABLE empleados.Guardaparque DROP COLUMN nro_matricula;
END;
GO


--Actualizar logica Sp's

-- Sp reeombolso
-- SP para registrar el reembolso referido a una cancelación.
CREATE OR ALTER PROCEDURE reservas.sp_registrar_reembolso
    @id_cancelacion INT,
    @cvu_cuenta_destino VARCHAR(23) 
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @cvu_cifrado VARBINARY(256)

    IF NOT EXISTS (
        SELECT 1
        FROM reservas.Cancelacion
        WHERE id = @id_cancelacion
    )
        THROW 50330, 'La cancelación indicada no existe.', 1;


    IF EXISTS (
        SELECT 1
        FROM reservas.Reembolso
        WHERE id_cancelacion = @id_cancelacion
    )
        THROW 50331, 'Ya existe un reembolso para esta cancelación.', 1;

    IF (LEN(LTRIM(RTRIM(@cvu_cuenta_destino))) <> 22 OR @cvu_cuenta_destino LIKE '%[^0-9]%')
        THROW 50332, 'El CVU debe seguir el formato de 22 números.', 1;

    SET @cvu_cifrado = ENCRYPTBYPASSPHRASE(seguridad.fn_obtener_pass(), CAST(@cvu_cuenta_destino AS varchar))

    INSERT INTO reservas.Reembolso
    (fecha_y_hora, cvu_cifrado, id_cancelacion)
    VALUES
    (GETDATE(), @cvu_cifrado, @id_cancelacion);
END;
GO
-- Sp Empleado

-- Alta
CREATE OR ALTER PROCEDURE empleados.sp_crear_empleado
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @nro_doc INT,
    @id_tipo_documento INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(400) = '';
        DECLARE @nro_doc_cifrado VARBINARY(256);

        IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            SET @msj_errores += '- El nombre no puede estar vacío. ';

        IF (@apellido IS NULL OR LTRIM(RTRIM(@apellido)) = '')
            SET @msj_errores += '- El apellido no puede estar vacío. ';

        IF NOT EXISTS (SELECT 1 FROM empleados.TipoDocumento WHERE id = @id_tipo_documento)
            SET @msj_errores += '- El ID del Tipo de Documento especificado no existe. ';

        IF (LEN(@msj_errores) > 0)
            THROW 50106, @msj_errores, 1;

        SET @nro_doc_cifrado = ENCRYPTBYPASSPHRASE(seguridad.fn_obtener_pass(), CAST(@nro_doc AS varchar))

        INSERT INTO empleados.Empleado (nombre, apellido, nro_doc_cifrado, id_tipo_documento)
        VALUES (@nombre, @apellido, @nro_doc_cifrado, @id_tipo_documento);
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
    @id_tipo_documento INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(400) = '';
        DECLARE @nro_doc_cifrado VARBINARY(256);

        IF NOT EXISTS (SELECT 1 FROM empleados.Empleado WHERE id = @id)
            SET @msj_errores += '- El Empleado con el ID provisto no existe. ';

        IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
            SET @msj_errores += '- El nombre no puede estar vacío. ';

        IF (@apellido IS NULL OR LTRIM(RTRIM(@apellido)) = '')
            SET @msj_errores += '- El apellido no puede estar vacío. ';

        IF NOT EXISTS (SELECT 1 FROM empleados.TipoDocumento WHERE id = @id_tipo_documento)
            SET @msj_errores += '- El ID del Tipo de Documento especificado no existe. ';


        IF (LEN(@msj_errores) > 0)
            THROW 50107, @msj_errores, 1;

        SET @nro_doc_cifrado = ENCRYPTBYPASSPHRASE(seguridad.fn_obtener_pass(), CAST(@nro_doc AS varchar))

        UPDATE empleados.Empleado
        SET nombre = @nombre,
            apellido = @apellido,
            nro_doc_cifrado = @nro_doc_cifrado,
            id_tipo_documento = @id_tipo_documento
        WHERE id = @id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

--Sp Guardaparques
-- Alta
CREATE OR ALTER PROCEDURE empleados.sp_crear_guardaparque
    @nro_matricula INT,
    @id_empleado INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @msj_errores VARCHAR(400) = '';
        DECLARE @nro_matricula_cifrado VARBINARY(256);

        IF NOT EXISTS (SELECT 1 FROM empleados.Empleado WHERE id = @id_empleado)
            SET @msj_errores += '- El Empleado especificado no existe. ';

        IF EXISTS (SELECT 1 FROM empleados.Guardaparque WHERE id_empleado = @id_empleado)
            SET @msj_errores += '- El Empleado ya se encuentra registrado como Guardaparque. ';

        IF (LEN(@msj_errores) > 0)
            THROW 50118, @msj_errores, 1;

        SET @nro_matricula_cifrado = ENCRYPTBYPASSPHRASE(seguridad.fn_obtener_pass(), CAST(@nro_matricula AS varchar))

        INSERT INTO empleados.Guardaparque (nro_matricula_cifrado, id_empleado)
        VALUES (@nro_matricula_cifrado, @id_empleado);
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
            DECLARE @nro_matricula_cifrado VARBINARY(256);

        IF NOT EXISTS (SELECT 1 FROM empleados.Guardaparque WHERE id_empleado = @id_empleado)
            THROW 50119, 'El Guardaparque con el ID provisto no existe.', 1;

        SET @nro_matricula_cifrado = ENCRYPTBYPASSPHRASE(seguridad.fn_obtener_pass(), CAST(@nro_matricula AS varchar))

        UPDATE empleados.Guardaparque
        SET nro_matricula_cifrado = @nro_matricula_cifrado
        WHERE id_empleado = @id_empleado;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO


-- Test

-- 1. Test: Creación de empleado y lectura descifrada
DECLARE @id_tipo_doc_emp INT = (SELECT TOP 1 id FROM empleados.TipoDocumento);
DECLARE @doc_random INT = CAST(RAND()*10000000 AS INT);

BEGIN TRY
    PRINT '--- 1. ALTA EXITOSA EMPLEADO ---';

    EXEC empleados.sp_crear_empleado 
        @nombre = 'Juan', 
        @apellido = 'Perez', 
        @nro_doc = @doc_random, 
        @id_tipo_documento = @id_tipo_doc_emp;

    SELECT @doc_random AS 'El DNI es';
    -- Mostramos que la tabla no contiene el dni en texto plano
    SELECT * FROM empleados.Empleado WHERE nombre = 'Juan' AND apellido = 'Perez';

    -- Visualizar dni empleado descifrado
    SELECT 
        id, 
        nombre, 
        apellido,
        CAST(DECRYPTBYPASSPHRASE(seguridad.fn_obtener_pass(), nro_doc_cifrado) AS VARCHAR) AS nro_doc_descifrado,
        nro_doc_cifrado
    FROM empleados.Empleado
    WHERE nombre = 'Juan' AND apellido = 'Perez';

END TRY
BEGIN CATCH 
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO

-- 2. Test: Creación de guardaparque y lectura descifrada
DECLARE @id_emp_creado INT = (SELECT MAX(id) FROM empleados.Empleado);
DECLARE @matricula_random INT = CAST(RAND()*10000 AS INT);

BEGIN TRY
    PRINT '--- 2. ALTA EXITOSA GUARDAPARQUE ---';

    EXEC empleados.sp_crear_guardaparque 
        @nro_matricula = @matricula_random, 
        @id_empleado = @id_emp_creado;

    SELECT @matricula_random AS 'La Matricula es';

    -- Mostramos que la tabla no contiene la matricula en texto plano

    SELECT * FROM empleados.Guardaparque WHERE id_empleado = @id_emp_creado;

    -- Visualizar matricula descifrada
    SELECT 
        id_empleado,
        CAST(DECRYPTBYPASSPHRASE(seguridad.fn_obtener_pass(), nro_matricula_cifrado) AS VARCHAR) AS matricula_descifrada,
        nro_matricula_cifrado
    FROM empleados.Guardaparque
    WHERE id_empleado = @id_emp_creado;

END TRY
BEGIN CATCH 
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO

-- 3. Test: Registro de Reembolso y lectura descifrada
DECLARE @id_canc INT = (
    SELECT TOP 1 id FROM reservas.Cancelacion 
    WHERE id NOT IN (SELECT id_cancelacion FROM reservas.Reembolso)
);

DECLARE @cvu_prueba CHAR(22) = '1234567890123456789012';

BEGIN TRY
    IF @id_canc IS NOT NULL
    BEGIN
        PRINT '--- 4. ALTA EXITOSA REEMBOLSO ---';

        EXEC reservas.sp_registrar_reembolso 
            @id_cancelacion = @id_canc, 
            @cvu_cuenta_destino = @cvu_prueba;

        SELECT @cvu_prueba AS 'El CVU es';

        -- Mostramos que la tabla no contiene la matricula en texto plano

        SELECT * FROM reservas.Reembolso WHERE id_cancelacion = @id_canc;

         -- Visualizar cvu descifrado
        SELECT 
            id, 
            id_cancelacion,
            CAST(DECRYPTBYPASSPHRASE(seguridad.fn_obtener_pass(), cvu_cifrado) AS VARCHAR) AS cvu_descifrado,
            cvu_cifrado
        FROM reservas.Reembolso
        WHERE id_cancelacion = @id_canc;
    END
    ELSE
    BEGIN
        PRINT 'No hay cancelaciones disponibles para testear el alta de un reembolso.';
    END
END TRY
BEGIN CATCH 
    PRINT 'ERROR INESPERADO: ' + ERROR_MESSAGE(); 
END CATCH;
GO



-- REVERTIR CIFRADO (Volver las tablas y Sp's al estado anterior)

/*

--Agregamos campos que habiamos sacado

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('empleados.Empleado') AND name = 'nro_doc')
BEGIN
    ALTER TABLE empleados.Empleado ADD nro_doc INT;
END;
GO


IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('reservas.Reembolso') AND name = 'cvu_cuenta_destino')
BEGIN
ALTER TABLE reservas.Reembolso ADD cvu_cuenta_destino CHAR(22);
END;
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('empleados.Guardaparque') AND name = 'nro_matricula' )
BEGIN
    ALTER TABLE empleados.Guardaparque ADD nro_matricula INT;
END;
GO

--migrar datos existentes

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('empleados.Empleado') AND name = 'nro_doc_cifrado')
BEGIN
    UPDATE empleados.Empleado
    SET nro_doc = CAST(CAST(DECRYPTBYPASSPHRASE(seguridad.fn_obtener_pass(), nro_doc_cifrado) AS VARCHAR) AS INT)
    WHERE nro_doc_cifrado IS NOT NULL;
END;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('reservas.Reembolso') AND name = 'cvu_cifrado')
BEGIN
    UPDATE reservas.Reembolso
    SET cvu_cuenta_destino = CAST(DECRYPTBYPASSPHRASE(seguridad.fn_obtener_pass(), cvu_cifrado) AS VARCHAR)
    WHERE cvu_cifrado IS NOT NULL;
END;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('empleados.Guardaparque') AND name = 'nro_matricula_cifrado')
BEGIN
    UPDATE empleados.Guardaparque
    SET nro_matricula = CAST(CAST(DECRYPTBYPASSPHRASE(seguridad.fn_obtener_pass(), nro_matricula_cifrado) AS VARCHAR) AS INT)
    WHERE nro_matricula_cifrado IS NOT NULL ;
END;
GO


IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('empleados.Empleado') AND name = 'nro_doc_cifrado')
BEGIN
    ALTER TABLE empleados.Empleado DROP COLUMN nro_doc_cifrado;
END;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('reservas.Reembolso') AND name = 'cvu_cifrado')
BEGIN
ALTER TABLE reservas.Reembolso DROP COLUMN cvu_cifrado ;
END;
GO

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('empleados.Guardaparque') AND name = 'nro_matricula_cifrado')
BEGIN
    ALTER TABLE empleados.Guardaparque DROP COLUMN nro_matricula_cifrado ;
END;
GO




--- Empleado



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

--- Guardaparque



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


-- Reembolso

    

-- SP para registrar el reembolso referido a una cancelación.
CREATE OR ALTER PROCEDURE reservas.sp_registrar_reembolso
    @id_cancelacion INT,
    @cvu_cuenta_destino VARCHAR(23) -- Permite hasta 1 caracter para poder validar si se pasó de largo
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------
    -- Verificar existencia cancelación
    ------------------------------------------------------

    IF NOT EXISTS (
        SELECT 1
        FROM reservas.Cancelacion
        WHERE id = @id_cancelacion
    )
        THROW 50330, 'La cancelación indicada no existe.', 1;

    ------------------------------------------------------
    -- Verificar reembolso previo
    ------------------------------------------------------

    IF EXISTS (
        SELECT 1
        FROM reservas.Reembolso
        WHERE id_cancelacion = @id_cancelacion
    )
        THROW 50331, 'Ya existe un reembolso para esta cancelación.', 1;

    ------------------------------------------------------
    -- Verificar formato CVU
    ------------------------------------------------------

    IF (LEN(LTRIM(RTRIM(@cvu_cuenta_destino))) <> 22 OR @cvu_cuenta_destino LIKE '%[^0-9]%')
        THROW 50332, 'El CVU debe seguir el formato de 22 números.', 1;

    ------------------------------------------------------
    -- Registrar reembolso
    ------------------------------------------------------

    INSERT INTO reservas.Reembolso
    (fecha_y_hora, cvu_cuenta_destino, id_cancelacion)
    VALUES
    (GETDATE(), @cvu_cuenta_destino, @id_cancelacion);
END;
GO
*/
