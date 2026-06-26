/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Script: Importación del Directorio de Organizaciones Distinguidas (Concesiones)
*/

USE LinuxPreachers;
GO

-- SP para la importacion
CREATE OR ALTER PROCEDURE concesiones.sp_importar_directorio_empresas
    @ruta VARCHAR(500),
    @id_parque INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación de consistencia del Parque Nacional de destino
    IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id = @id_parque)
    BEGIN
        PRINT 'ERROR DE NEGOCIO: El Parque Nacional con el ID provisto no existe. Abortando importación.';
        RETURN;
    END;

    DECLARE @importacion VARCHAR(1500);

    DROP TABLE IF EXISTS #ImportacionDirectorio;

    -- Esta obligado a recibir todos los campos del csv 
    CREATE TABLE #ImportacionDirectorio (
        organizacion VARCHAR(100),
        rubro VARCHAR(100),
        subrubro VARCHAR(100),
        calle VARCHAR(100),
        numero VARCHAR(100),
        pais VARCHAR(100),
        provincia VARCHAR(100),
        ciudad VARCHAR(100),
        telefono VARCHAR(100),
        facebook VARCHAR(100),
        web VARCHAR(100),
        programa VARCHAR(100),
        fecha_distincion VARCHAR(100),
        fecha_revalidacion VARCHAR(100)
    );

    -- Ejecución de la carga masiva
    BEGIN TRY
        SET @importacion = '
        BULK INSERT #ImportacionDirectorio
        FROM ''' + @ruta + '''
        WITH (
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'', 
            CODEPAGE = ''65001'',
            FIRSTROW = 2
        );';

        EXEC (@importacion);
    END TRY
    BEGIN CATCH
        DECLARE @ErrorBulk VARCHAR(4000) = ERROR_MESSAGE();
        THROW 50340, @ErrorBulk, 1;
        RETURN;
    END CATCH;
    -- Ahora que ya cargamos los datos a la tabla temporal le agregamos el id 
    ALTER TABLE #ImportacionDirectorio ADD id INT IDENTITY(1,1) PRIMARY KEY;
    -- Variables de control del bucle
    DECLARE @id_actual INT = 1;
        -- identificamos el ultimo id que se le asigno al ultimo registro del csv
    DECLARE @id_max INT = (SELECT MAX(id) FROM #ImportacionDirectorio);

    -- Variables de mapeo de datos
    DECLARE @organizacion VARCHAR(500);
    DECLARE @rubro VARCHAR(255);
    DECLARE @subrubro VARCHAR(255);
    DECLARE @fecha_distincion VARCHAR(100);
    DECLARE @razon_social VARCHAR(200);
    DECLARE @descripcion VARCHAR(400);
    -- Variables operativas internas
    DECLARE @id_actividad_empresarial SMALLINT;
    DECLARE @id_empresa INT;
    DECLARE @cuit BIGINT;
    DECLARE @fecha_inicio DATE;
    
    -- Variable de error
    -- Procesamiento fila por fila con aislamiento de excepciones
    WHILE @id_actual <= @id_max
    BEGIN
        BEGIN TRY
            DECLARE @mensaje_error VARCHAR(4000) =' ' ;
            
            -- Extracción, limpieza posicional y remoción de comillas residuales del parser plano
            SELECT
                @organizacion = UPPER(LTRIM(RTRIM(REPLACE(organizacion, '"', '')))), -- Se los pone en mayuscula para mantener un estandar
                @rubro = UPPER(LTRIM(RTRIM(REPLACE(rubro, '"', '')))),
                @subrubro = UPPER(LTRIM(RTRIM(REPLACE(subrubro, '"', '')))),
                @fecha_distincion = LTRIM(RTRIM(REPLACE(fecha_distincion, '"', '')))
            FROM #ImportacionDirectorio
            WHERE id = @id_actual;

            -- Validaciones de reglas de negocio obligatorias
            IF (@organizacion IS NULL OR @organizacion = '' OR @organizacion = 'NA')
                SET @mensaje_error+= 'El campo organización/nombre de la empresa no posee un formato válido o está vacío.';

            IF (@rubro IS NULL OR @rubro = '' OR @rubro = 'NA')
                SET @mensaje_error+= 'El rubro empresarial especificado no es válido.';

            IF (@subrubro IS NULL OR @subrubro='' OR @rubro = 'NA')
                SET @mensaje_error+= 'El subrubro no está bien formado';

            IF (@fecha_distincion IS NULL OR @fecha_distincion='')
                SET @mensaje_error+= 'La fecha especificada no es valida';
            
            IF LEN(LTRIM(RTRIM(@mensaje_error))) > 0
                THROW 50130, @mensaje_error, 1;

            -- UPSERT - ActividadEmpresarial (Rubros)
            SET @id_actividad_empresarial = (SELECT id FROM concesiones.ActividadEmpresarial WHERE UPPER(nombre) = @rubro);

            IF (@id_actividad_empresarial IS NULL)
            
                BEGIN
                
                EXEC concesiones.sp_crear_actividad_empresarial 
                @nombre=@rubro,
                @descripcion=@subrubro


                SET @id_actividad_empresarial = (SELECT id FROM 
                                                concesiones.ActividadEmpresarial 
                                                WHERE UPPER(nombre) = @rubro);
            
                END

            ELSE
            
            BEGIN
                
                EXEC concesiones.sp_modificar_actividad_empresarial 
                    @id = @id_actividad_empresarial, 
                    @nombre = @rubro, 
                    @descripcion = @subrubro;
            END;


            -- UPSERT - EmpresaConcesionaria 
            SET @id_empresa = ( SELECT id 
                                FROM concesiones.EmpresaConcesionaria 
                                WHERE UPPER(nombre) = @organizacion);

            IF (@id_empresa IS NULL)
                BEGIN
                -- Se genera un cuit dependiendo de id actual ya que el archivo importado no cuenta con info sobre el cuit
                -- Se lo crea para que no haya problemas en la inserción.
                SET @cuit = 30000000000 + @id_actual;

                EXEC concesiones.sp_crear_empresa_concesionaria 
                    @nombre = @organizacion, 
                    @descripcion = 'EMPRESA IMPORTADA MASIVAMENTE VIA CSV', 
                    @cuit = @cuit, 
                    @razon_social = @organizacion, 
                    @id_actividad_empresarial = @id_actividad_empresarial;
                -- Como el archivo no tiene razon social especificada se le asigna el mismo nombre que la organizacion

                SET @id_empresa = (SELECT id FROM concesiones.EmpresaConcesionaria WHERE UPPER(nombre) = @organizacion);
                
                END

            ELSE

                BEGIN
                    -- Se recuperan los datos ya existentes ya que existen datos que no vienen procesados en el archivo como el cuit que son obligatorios en el update
                    SELECT @cuit = cuit, 
                       @razon_social = razon_social,
                       @descripcion = descripcion
                    FROM concesiones.EmpresaConcesionaria 
                     WHERE id = @id_empresa;

                    EXEC concesiones.sp_modificar_empresa_concesionaria 
                    @id = @id_empresa, 
                    @nombre = @organizacion, 
                    @descripcion = @descripcion, 
                    @cuit = @cuit, 
                    @razon_social = @razon_social, 
                    @id_actividad_empresarial = @id_actividad_empresarial;
            END;

            -- INSERT Concesión (Vinculación al Parque Nacional)
            IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id_empresa_concesionaria = @id_empresa AND id_parque = @id_parque)
            BEGIN
                -- Verificamos que se trate de una fecha bien formada antes de procesarla
                IF (ISDATE(@fecha_distincion) = 1)
                    SET @fecha_inicio = CAST(@fecha_distincion AS DATE);
                ELSE
                    SET @fecha_inicio = CAST(GETDATE() AS DATE);-- si no esta bien formada le asignamos la fecha actual (toma de decision de diseño)
                DECLARE @fecha_fin DATE=DATEADD(YEAR,5,@fecha_inicio);
                EXEC concesiones.sp_crear_concesion 
                @descripcion='CONTRATO GENERADO POR IMPORTACION MASIVA',
                @fecha_inicio=@fecha_inicio,
                @fecha_fin=@fecha_fin,
                @id_empresa_concesionaria=@id_empresa,
                @id_parque=@id_parque

            END;

        END TRY
        BEGIN CATCH
            -- Captura del error posicional sin interrumpir la secuencia general del lote masivo
            SET @mensaje_error = ERROR_MESSAGE();

            INSERT INTO concesiones.ImportacionErrorLog (fila_origen, organizacion, rubro, mensaje_error)
            VALUES (@id_actual, @organizacion, @rubro, @mensaje_error);
        END CATCH;

        SET @id_actual = @id_actual + 1;
    END;

    DROP TABLE IF EXISTS #ImportacionDirectorio;
    PRINT 'Proceso de importación finalizado. Verificar la tabla concesiones.ImportacionErrorLog para analizar registros con anomalías estructurales.';
END;
GO

-- Descomentar al ejecutar.
--EXEC concesiones.sp_importar_directorio_empresas
--    @ruta = '\\DESKTOP-KOIKGVK\Users\Carpeta publica\ArchivosImportacion\registro-organizaciones-distinguidas-sact.csv',
--    @id_parque = 1;