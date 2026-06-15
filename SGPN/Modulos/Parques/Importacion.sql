/*
 * Universidad: UNLaM
 * Materia: Bases de datos aplicadas
 * Comisión: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha:
 * Script: Importacion masiva de parques
*/

/* Deben ejecutarse por unica vez en la db antes de hacer la importacion
EXEC sp_configure 'show advanced options', 1; 
RECONFIGURE; 
EXEC sp_configure 'Ad Hoc Distributed Queries', 1; 
RECONFIGURE; 
*/

USE LinuxPreachers;
GO


-- 1. Crear la tabla de logs de errores si no existe en el esquema
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('parques.ImportacionErrorLog'))
BEGIN
    CREATE TABLE parques.ImportacionErrorLog (
        id INT IDENTITY(1,1) PRIMARY KEY,
        fecha_error DATETIME DEFAULT GETDATE(),
        fila_origen INT,
        datos_crudos VARCHAR(4000),
        mensaje_error VARCHAR(4000)
    );
END;
GO

-- 2. Creación del Stored Procedure de Importación Masiva
CREATE OR ALTER PROCEDURE parques.sp_importar_parques
AS
BEGIN
    SET NOCOUNT ON;

        -- variables Auxiliares
    DECLARE @id_parque_operativo INT;
    DECLARE @sup_ha_num DECIMAL(18,2);
    DECLARE @mensaje_error VARCHAR(4000);
    DECLARE @datos_fila VARCHAR(4000);


    -- Limpieza preventiva de la tabla temporal local en la sesión
    IF OBJECT_ID('tempdb..#ImportacionParques') IS NOT NULL
        DROP TABLE #ImportacionParques;

    -- Creación de la tabla temporal estructurada
    CREATE TABLE #ImportacionParques (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Provincia VARCHAR(255),
        AreaProtegida VARCHAR(255),
        SuperficieHA VARCHAR(100),
        Latitud VARCHAR(100),
        Longitud VARCHAR(100)
    );
    -- Carga estática directa desde la hoja "Sheet1" del Excel filtrando columnas
    BEGIN TRY
        INSERT INTO #ImportacionParques (Provincia, AreaProtegida, SuperficieHA, Latitud, Longitud)
        SELECT 
            [Provincia], 
            [Área protegida], 
            [Superficie (HA)], 
            [Latitud], 
            [Longitud]
        FROM OPENROWSET(
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0 Xml;Database=C:\Users\USUARIO\Downloads\Áreas protegidas de Argentina - Sistema de Información de Biodiversidad.xlsx;HDR=YES;', 
            'SELECT [Provincia], [Área protegida], [Superficie (HA)], [Latitud], [Longitud] FROM [Sheet1$]'
        );
    END TRY
    BEGIN CATCH
         SET @mensaje_error = 'Fallo crítico al conectar con el Excel. Asegúrese de que el archivo no esté abierto exclusivamente y de que los drivers OLEDB estén instalados. Error: ' + ERROR_MESSAGE();
        RAISERROR(@mensaje_error, 16, 1);
        RETURN;
    END CATCH;



    -- Variables para el control del bucle WHILE
    DECLARE @id_actual INT = 1;
    DECLARE @id_max INT = (SELECT MAX(Id) FROM #ImportacionParques);

    -- Variables por registro
    DECLARE @fila_prov VARCHAR(255);
    DECLARE @fila_area VARCHAR(255);
    DECLARE @fila_sup_ha VARCHAR(100);
    DECLARE @fila_lat VARCHAR(100);
    DECLARE @fila_long VARCHAR(100);

    -- Variables normalizadas
    DECLARE @nombre_parque VARCHAR(255);
    DECLARE @id_prov INT;
    DECLARE @sup_km2 DECIMAL(18,2);
    DECLARE @lat_dec DECIMAL(18,6);
    DECLARE @long_dec DECIMAL(18,6);
    DECLARE @id_tipo_parque INT;




    -- Bucle WHILE de procesamiento fila por fila
    WHILE @id_actual <= @id_max
    BEGIN
        BEGIN TRY
            -- Leer los datos de la fila actual
            SELECT 
                @fila_prov = LTRIM(RTRIM(Provincia)),
                @fila_area = LTRIM(RTRIM(AreaProtegida)),
                @fila_sup_ha = LTRIM(RTRIM(SuperficieHA)),
                @fila_lat = LTRIM(RTRIM(Latitud)),
                @fila_long= LTRIM(RTRIM(Longitud))
            FROM #ImportacionParques
            WHERE Id = @id_actual;

            -- 1. Validar nombre del área protegida
            IF (@fila_area IS NULL OR @fila_area = '')
                THROW 50001, 'El nombre del área protegida no puede estar vacío.', 1;

            SET @nombre_parque = @fila_area;

            -- 2. Normalizar Provincia
            IF (@fila_prov IS NULL OR @fila_prov = '')
                  THROW 50002, 'Falta la provincia', 1;
            ELSE
            BEGIN
                -- Buscar el ID de la provincia en tabla
                SELECT @id_prov = id 
                FROM parques.Provincia
                WHERE nombre = @fila_prov;

                IF (@id_prov IS NULL)
                       THROW 50003, 'La provincia no existe en la tabla de provincias.', 1;
            END;

            -- 3. Conversiones de datos
            -- Superficie (HA a km2)
            SET @sup_ha_num = TRY_CAST(REPLACE(@fila_sup_ha, ',', '.') AS DECIMAL(18,2));

            IF (@fila_sup_ha IS NOT NULL AND @sup_ha_num IS NULL)
                THROW 50005, 'Formato inválido de superficie en Hectáreas.', 1;
            
            -- Conversion HA-KM2: HA / 100.0
            SET @sup_km2 = @sup_ha_num / 100.0;

            -- Latitud y Longitud
            SET @lat_dec= TRY_CAST(REPLACE(@fila_lat, ',', '.') AS DECIMAL(18,6));
            SET @long_dec = TRY_CAST(REPLACE(@fila_long, ',', '.') AS DECIMAL(18,6));

            IF ((@fila_lat IS NOT NULL AND @fila_lat <> '0' AND @lat_dec IS NULL) OR 
                (@fila_long IS NOT NULL AND @fila_long<> '0' AND @long_dec IS NULL))
                THROW 50006, 'Formato numérico inválido en coordenadas', 1;

            -- Tipo de parque

            SET @id_tipo_parque = NULL;

            SELECT TOP 1 @id_tipo_parque = id
            FROM parques.TipoParque
            WHERE @nombre_parque LIKE descripcion + '%' ORDER BY LEN(descripcion) DESC;

            IF (@id_tipo_parque IS NULL)
                THROW 50007, 'No se pudo determinar el tipo de parque para el nombre proporcionado.', 1;               

            -- 4. Operación UPSERT

            SET @id_parque_operativo = NULL; -- Reinicia la variable

            SELECT @id_parque_operativo = id 
               FROM parques.Parque  WHERE nombre = @nombre_parque;

            IF (@id_parque_operativo IS NOT NULL)
            BEGIN
            -- UPDATE en parque
                UPDATE parques.Parque
                SET 
                    superficie_km2 = @sup_km2,
                    latitud = @lat_dec ,
                    longitud = @long_dec
                WHERE id = @id_parque_operativo;

                IF (@id_prov NOT IN (SELECT id_provincia FROM parques.ProvinciaParque WHERE id_parque = @id_parque_operativo) )
                BEGIN
                --INSERT en Parque-Provincia

                    EXEC parques.sp_crear_provincia_parque
                            @id_provincia = @id_prov,
                            @id_parque = @id_parque_operativo;

                END
            END
            ELSE
            BEGIN
                -- INSERT si el parque no existía

                    EXEC parques.sp_crear_parque
                        @nombre = @nombre_parque,
                        @superficie_km2 = @sup_km2,
                        @latitud = @lat_dec,
                        @longitud = @long_dec,
                        @id_tipo_parque = @id_tipo_parque;


                    SELECT @id_parque_operativo = id 
                        FROM parques.Parque WHERE nombre = @nombre_parque;

                -- INSERT en provincia-parque

                EXEC parques.sp_crear_provincia_parque
                        @id_provincia = @id_prov,
                        @id_parque = @id_parque_operativo;
                    
            END;

        END TRY

        ------------------------CATCH
        BEGIN CATCH

            --Registrar en log, ignorar esta fila y continuar con la siguiente.

            SET @mensaje_error = ERROR_MESSAGE();
            SET @datos_fila = 'Fila: ' + CAST(@id_actual AS VARCHAR(10)) + 
                ' | Prov: ' + ISNULL(@fila_prov, '') + 
                ' | Area: ' + ISNULL(@fila_area, '') + 
                ' | SupHA: ' + ISNULL(@fila_sup_ha, '');

            INSERT INTO parques.ImportacionErrorLog (fila_origen, datos_crudos, mensaje_error)
            VALUES (@id_actual, @datos_fila, @mensaje_error);
        END CATCH;

        -- Incrementar índice para evaluar la siguiente fila
        SET @id_actual = @id_actual + 1;
    END;

    -- 6. Limpieza formal de tablas temporales locales
    IF OBJECT_ID('tempdb..#ImportacionParques') IS NOT NULL
        DROP TABLE #ImportacionParques;

    PRINT 'Proceso de importación finalizado. Revisar la tabla parques.ImportacionErrorLog para verificar anomalías parciales.';
END;
GO