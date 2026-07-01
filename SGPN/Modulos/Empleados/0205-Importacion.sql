/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Importacion registros de empleados.
*/

USE LinuxPreachers;
GO

-------------------------------
-- Creación del SP
-------------------------------

CREATE OR ALTER PROCEDURE empleados.sp_importar_guias
    @ruta VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @importacion VARCHAR(1000);

    DROP TABLE IF EXISTS #ImportacionGuias;

    CREATE TABLE #ImportacionGuias (
        id INT IDENTITY(1,1) PRIMARY KEY,
        apellido VARCHAR(100),
        nombre VARCHAR(100),
        tipo_doc CHAR(3),
        numero CHAR(10),
        n_registro VARCHAR(30),
        categoria VARCHAR(100)
    );

    -- Importación a la tabla temporal.
    -- De no utilizarse SQL dinámico, debería darse la ruta como un literal hardcodeado.
    BEGIN TRY
        SET @importacion = '
        BULK INSERT #ImportacionGuias
        FROM ''' + @ruta + '''
        WITH (
            FIELDTERMINATOR = '';'',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''ACP'',
            FIRSTROW = 2
        );';

        EXEC (@importacion);
    END TRY
    BEGIN CATCH
        THROW
            50340,
            'Fallo al abrir el archivo de importación. Revisar permisos de archivo o si otro proceso lo esta utilizando.',
            1;
    END CATCH;

    DECLARE @id_actual INT = 1;
    DECLARE @id_max INT = (SELECT MAX(id) FROM #ImportacionGuias);

    DECLARE @apellido VARCHAR(100);
    DECLARE @nombre VARCHAR(100);
    DECLARE @tipo_doc VARCHAR(100);
    DECLARE @numero CHAR(10);
    DECLARE @n_registro VARCHAR(30);
    DECLARE @categoria VARCHAR(100);

    DECLARE @id_tipo_documento TINYINT;
    DECLARE @id_especialidad SMALLINT;
    DECLARE @id_empleado INT;
    DECLARE @numero_doc INT;

    DECLARE @mensaje_error VARCHAR(4000);
    DECLARE @datos_fila VARCHAR(4000);

    -- Procesamiento registro por registro.
    WHILE @id_actual <= @id_max
    BEGIN

        BEGIN TRY

            SELECT
                @apellido = UPPER(LTRIM(RTRIM(apellido))),
                @nombre = UPPER(LTRIM(RTRIM(nombre))),
                @tipo_doc = UPPER(LTRIM(RTRIM(tipo_doc))),
                @numero = LTRIM(RTRIM(numero)),
                @n_registro = LTRIM(RTRIM(n_registro)),
                @categoria = UPPER(LTRIM(RTRIM(categoria)))
            FROM #ImportacionGuias
            WHERE id = @id_actual;

            -- Validaciones.
            IF (@apellido IS NULL OR @apellido = '')
                THROW 50130, 'Apellido vacío.', 1;

            IF (@nombre IS NULL OR @nombre = '')
                THROW 50131, 'Nombre vacío.', 1;

            IF (@tipo_doc IS NULL OR @tipo_doc = '')
                THROW 50132, 'Tipo de documento vacío.', 1;

            IF (@numero IS NULL OR @numero = '')
                THROW 50133, 'Número de documento vacío.', 1;

            IF (@n_registro IS NULL OR @n_registro = '')
                THROW 50134, 'Número de registro vacío.', 1;

            IF NOT (
                @n_registro LIKE 'RL-[0-9][0-9][0-9][0-9]-%-%'
                AND LEN(@n_registro) - LEN(REPLACE(@n_registro, '-', '')) = 3
                AND @n_registro NOT LIKE '%[^A-Z0-9-]%'
            )
                THROW 50135, 'Número de registro con formato incorrecto.', 1;

            IF (@categoria IS NULL OR @categoria = '')
                THROW 50136, 'Categoría vacía.', 1;

            SET @numero_doc = TRY_CONVERT(INT, @numero);

            IF (@numero_doc IS NULL)
                THROW 50137, 'Número de documento inválido.', 1;

            SET @id_tipo_documento = NULL;

            SELECT
                @id_tipo_documento = id
            FROM empleados.TipoDocumento
            WHERE UPPER(nombre) = @tipo_doc;

            IF (@id_tipo_documento IS NULL)
                THROW 50138, 'Tipo de documento inexistente.', 1;

            SET @id_especialidad = NULL;

            SELECT
                @id_especialidad = id
            FROM empleados.Especialidad
            WHERE UPPER(nombre) = @categoria;

            IF (@id_especialidad IS NULL)
                THROW 50139, 'Especialidad inexistente.', 1;

            SET @id_empleado = NULL;

            SELECT
                @id_empleado = id
            FROM empleados.Empleado
            WHERE id_tipo_documento = @id_tipo_documento
              AND nro_doc = @numero_doc;

            
            -- Empleado no existe
            IF (@id_empleado IS NULL)
            BEGIN

                EXEC empleados.sp_crear_empleado
                    @nombre = @nombre,
                    @apellido = @apellido,
                    @nro_doc = @numero_doc,
                    @id_tipo_documento = @id_tipo_documento;

                SELECT
                    @id_empleado = id
                FROM empleados.Empleado
                WHERE id_tipo_documento = @id_tipo_documento
                  AND nro_doc = @numero_doc;

                EXEC empleados.sp_crear_guia
                    @nro_registro = @n_registro,
                    @id_empleado = @id_empleado,
                    @id_especialidad = @id_especialidad;

            END

            
            -- Empleado existe
            ELSE
            BEGIN

                EXEC empleados.sp_modificar_empleado
                    @id = @id_empleado,
                    @nombre = @nombre,
                    @apellido = @apellido,
                    @nro_doc = @numero_doc,
                    @id_tipo_documento = @id_tipo_documento;

                IF EXISTS
                (
                    SELECT 1
                    FROM empleados.Guia
                    WHERE id_empleado = @id_empleado
                )
                BEGIN

                    EXEC empleados.sp_modificar_guia
                        @id_empleado = @id_empleado,
                        @nro_registro = @n_registro,
                        @id_especialidad = @id_especialidad;

                END
                ELSE
                BEGIN

                    EXEC empleados.sp_crear_guia
                        @nro_registro = @n_registro,
                        @id_empleado = @id_empleado,
                        @id_especialidad = @id_especialidad;

                END

            END

        END TRY
        BEGIN CATCH

            SET @mensaje_error = ERROR_MESSAGE();

            INSERT INTO empleados.ImportacionErrorLog
            (
                fila_origen,
                apellido,
                nombre,
                tipo_doc,
                numero,
                n_registro,
                categoria,
                mensaje_error
            )
            VALUES
            (
                @id_actual,
                @apellido,
                @nombre,
                @tipo_doc,
                @numero,
                @n_registro,
                @categoria,
                @mensaje_error
            );

        END CATCH;

        SET @id_actual = @id_actual + 1;
    END

    DROP TABLE IF EXISTS #ImportacionGuias;

    PRINT 'Proceso de importación finalizado. Revisar empleados.ImportacionErrorLog para verificar errores.';
END;
GO

-------------------------------
-- Ejecución
-------------------------------

EXEC empleados.sp_importar_guias 
    @ruta = '\\DESKTOP-KOIKGVK\Users\Carpeta publica\ArchivosImportacion\registro-de-guias-de-turismo.csv'
GO

-------------------------------
-- Comprobación
-------------------------------

/*
 * El archivo original posee 1352 registros (1353 con la cabecera).
 * Del total, 1203 se importan correctamente y 149 se registran en el log de errores
*/

SELECT 
    emp.id, 
    emp.nombre, 
    emp.apellido, 
    emp.nro_doc, 
    td.nombre AS nro_doc,
    g.nro_registro,
    esp.nombre AS especialidad,
    emp.activo 
FROM empleados.Empleado emp
JOIN empleados.TipoDocumento td
ON emp.id_tipo_documento = td.id
JOIN empleados.guia g
ON emp.id = g.id_empleado
JOIN empleados.Especialidad esp
ON g.id_especialidad = esp.id

SELECT * FROM empleados.ImportacionErrorLog
GO