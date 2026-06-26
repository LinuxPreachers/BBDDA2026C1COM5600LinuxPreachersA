/*
 * Universidad: UNLaM
 * Materia: Bases de Datos Aplicada
 * Comision: 5600
 * Grupo: 02
 * Integrantes: Conforti, Jaime, Laurelli, Porras
 * Fecha: 2026-06-19
 * Script: Consumo de APIs desde SQL Server.
 * Objetivo: Crear Stored Procedures para consultar cotizaciones,
 *           feriados y clima desde APIs publicas.
 */

USE LinuxPreachers;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'apis')
BEGIN
    EXEC('CREATE SCHEMA apis');
END;
GO

/* =========================================================
   Permisos necesarios para consumir APIs desde SQL Server

   IMPORTANTE:
   Esto debe ejecutarse con un usuario con permisos de administrador.
   Es lo mismo que vimos en clase: habilita Ole Automation Procedures
   para poder usar MSXML2.XMLHTTP desde T-SQL.
   ========================================================= */
CREATE OR ALTER PROCEDURE apis.sp_habilitar_ole_automation
AS
BEGIN
    SET NOCOUNT ON;

    EXEC sp_configure 'show advanced options', 1;
    RECONFIGURE;

    EXEC sp_configure 'Ole Automation Procedures', 1;
    RECONFIGURE;
END;
GO

--   SP auxiliar para hacer llamadas GET a una API. La idea es centralizar el codigo repetido

CREATE OR ALTER PROCEDURE apis.sp_llamar_api_get
    @url VARCHAR(1000),
    @respuesta varchar(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Object INT;
    DECLARE @json TABLE(DATA varchar(MAX));

    DECLARE @status INT;
    DECLARE @statusText VARCHAR(255);

    EXEC apis.sp_habilitar_ole_automation;

    --EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT; -- Creamos una instancia del objeto OLE, que nos permite hacer los llamados.
    EXEC sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @Object OUT; -- Funciona para la API de climas mientras la otra no
    EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE'; -- Definimos algunas propiedades del objeto para hacer una llamada HTTP Get.
    EXEC sp_OAMethod @Object, 'SEND'; 

    EXEC sp_OAGetProperty @Object, 'status', @status OUT;
    EXEC sp_OAGetProperty @Object, 'statusText', @statusText OUT;

    INSERT INTO @json
        EXEC sp_OAGetProperty @Object, 'RESPONSETEXT';

    SELECT @respuesta = DATA
    FROM @json;

    EXEC sp_OADestroy @Object;

    IF @status <> 200
    BEGIN
        RAISERROR('La API no respondio correctamente. Status HTTP: %d - %s', 16, 1, @status, @statusText);
        RETURN;
    END;
END;
GO

/* =========================================================
   Cotizacion del dolar

   API usada:
   https://dolarapi.com/v1/dolares/{tipoDolar}
   https://dolarapi.com/v1/cotizaciones/

   Algunos valores posibles para @casa_dolar:
   oficial, blue, bolsa, contadoconliqui, mayorista, cripto, tarjeta
   ========================================================= */

CREATE OR ALTER PROCEDURE apis.sp_cotizacion_dolar_especif
    @casa_dolar VARCHAR(50) = 'oficial'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @url varchar(1000);
    DECLARE @datos varchar(MAX);

    SET @url = CONCAT('https://dolarapi.com/v1/dolares/', @casa_dolar);

    EXEC apis.sp_llamar_api_get
        @url = @url,
        @respuesta = @datos OUTPUT;

    SELECT
        'DolarAPI' AS fuente,
        @url AS url_consultada,
        moneda,
        casa,
        nombre,
        compra,
        venta,
        fechaActualizacion
    FROM OPENJSON(@datos)
    WITH (
        moneda VARCHAR(10) '$.moneda',
        casa VARCHAR(50) '$.casa',
        nombre VARCHAR(100) '$.nombre',
        compra DECIMAL(18,2) '$.compra',
        venta DECIMAL(18,2) '$.venta',
        fechaActualizacion DATETIMEOFFSET '$.fechaActualizacion'
    );
END;
GO

CREATE OR ALTER PROCEDURE apis.sp_cotizaciones_dolar_gral
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @url varchar(1000);
    DECLARE @datos varchar(MAX);

    SET @url = 'https://dolarapi.com/v1/dolares';

    EXEC apis.sp_llamar_api_get
        @url = @url,
        @respuesta = @datos OUTPUT;

    SELECT
        'DolarAPI' AS fuente,
        @url AS url_consultada,
        moneda,
        casa,
        nombre,
        compra,
        venta,
        fechaActualizacion
    FROM OPENJSON(@datos)
    WITH (
        moneda VARCHAR(10) '$.moneda',
        casa VARCHAR(50) '$.casa',
        nombre VARCHAR(100) '$.nombre',
        compra DECIMAL(18,2) '$.compra',
        venta DECIMAL(18,2) '$.venta',
        fechaActualizacion DATETIMEOFFSET '$.fechaActualizacion'
    );
END;
GO

CREATE OR ALTER PROCEDURE apis.sp_cotizaciones_principales
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @url_dolar VARCHAR(1000);
    DECLARE @url_otros VARCHAR(1000);
    DECLARE @datos_dolar VARCHAR(MAX);
    DECLARE @datos_otros VARCHAR(MAX);

    DECLARE @cotizaciones TABLE (
        fuente VARCHAR(30),
        url_consultada VARCHAR(1000),
        moneda VARCHAR(10),
        casa VARCHAR(50),
        nombre VARCHAR(100),
        compra DECIMAL(18,2),
        venta DECIMAL(18,2),
        fechaActualizacion DATETIMEOFFSET
    );

    SET @url_dolar = 'https://dolarapi.com/v1/dolares/';
    SET @url_otros = 'https://dolarapi.com/v1/cotizaciones/';

    EXEC apis.sp_llamar_api_get @url = @url_dolar, @respuesta = @datos_dolar OUTPUT;
    EXEC apis.sp_llamar_api_get @url = @url_otros, @respuesta = @datos_otros OUTPUT;

    INSERT INTO @cotizaciones
    SELECT
        'DolarAPI',
        @url_dolar,
        moneda,
        casa,
        nombre,
        compra,
        venta,
        fechaActualizacion
    FROM OPENJSON(@datos_dolar)
    WITH (
        moneda VARCHAR(10) '$.moneda',
        casa VARCHAR(50) '$.casa',
        nombre VARCHAR(100) '$.nombre',
        compra DECIMAL(18,2) '$.compra',
        venta DECIMAL(18,2) '$.venta',
        fechaActualizacion DATETIMEOFFSET '$.fechaActualizacion'
    );

    INSERT INTO @cotizaciones
    SELECT
        'DolarAPI',
        @url_otros,
        moneda,
        casa,
        nombre,
        compra,
        venta,
        fechaActualizacion
    FROM OPENJSON(@datos_otros)
    WITH (
        moneda VARCHAR(10) '$.moneda',
        casa VARCHAR(50) '$.casa',
        nombre VARCHAR(100) '$.nombre',
        compra DECIMAL(18,2) '$.compra',
        venta DECIMAL(18,2) '$.venta',
        fechaActualizacion DATETIMEOFFSET '$.fechaActualizacion'
    );

    SELECT *
    FROM @cotizaciones;
END;
GO

CREATE OR ALTER PROCEDURE apis.sp_cotizaciones_principales_temp
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @url_dolar VARCHAR(1000);
    DECLARE @url_otros VARCHAR(1000);
    DECLARE @datos_dolar VARCHAR(MAX);
    DECLARE @datos_otros VARCHAR(MAX);

    IF OBJECT_ID('tempdb..#cotizaciones_actuales') IS NULL
    BEGIN
        RETURN;
    END;

    SET @url_dolar = 'https://dolarapi.com/v1/dolares/';
    SET @url_otros = 'https://dolarapi.com/v1/cotizaciones/';

    EXEC apis.sp_llamar_api_get @url = @url_dolar, @respuesta = @datos_dolar OUTPUT;
    EXEC apis.sp_llamar_api_get @url = @url_otros, @respuesta = @datos_otros OUTPUT;

    INSERT INTO #cotizaciones_actuales
    SELECT
        'DolarAPI',
        @url_dolar,
        moneda,
        casa,
        nombre,
        compra,
        venta,
        fechaActualizacion
    FROM OPENJSON(@datos_dolar)
    WITH (
        moneda VARCHAR(10) '$.moneda',
        casa VARCHAR(50) '$.casa',
        nombre VARCHAR(100) '$.nombre',
        compra DECIMAL(18,2) '$.compra',
        venta DECIMAL(18,2) '$.venta',
        fechaActualizacion DATETIMEOFFSET '$.fechaActualizacion'
    );

    INSERT INTO #cotizaciones_actuales
    SELECT
        'DolarAPI',
        @url_otros,
        moneda,
        casa,
        nombre,
        compra,
        venta,
        fechaActualizacion
    FROM OPENJSON(@datos_otros)
    WITH (
        moneda VARCHAR(10) '$.moneda',
        casa VARCHAR(50) '$.casa',
        nombre VARCHAR(100) '$.nombre',
        compra DECIMAL(18,2) '$.compra',
        venta DECIMAL(18,2) '$.venta',
        fechaActualizacion DATETIMEOFFSET '$.fechaActualizacion'
    );
END;
GO

/* =========================================================
   Feriados por anio

   API usada:
   https://date.nager.at/api/v3/PublicHolidays/{anio}/AR
   ========================================================= */

CREATE OR ALTER PROCEDURE apis.sp_feriados
    @anio INT = NULL,
    @pais VARCHAR(5) = 'AR'
AS
BEGIN
    SET NOCOUNT ON;

    IF @anio IS NULL
        SET @anio = YEAR(GETDATE());

    DECLARE @url VARCHAR(1000);
    DECLARE @datos VARCHAR(MAX);

    SET @url = CONCAT('https://date.nager.at/api/v3/PublicHolidays/', @anio, '/', @pais);

    EXEC apis.sp_llamar_api_get
        @url = @url,
        @respuesta = @datos OUTPUT;

    SELECT
        'Nager.Date' AS fuente,
        @url AS url_consultada,
        fecha,
        nombre_local,
        nombre_ingles,
        codigo_pais,
        es_global,
        tipos_json
    FROM OPENJSON(@datos)
    WITH (
        fecha DATE '$.date',
        nombre_local varchar(150) '$.localName',
        nombre_ingles VARCHAR(150) '$.name',
        codigo_pais VARCHAR(5) '$.countryCode',
        es_global BIT '$.global',
        tipos_json NVARCHAR(MAX) '$.types' AS JSON
    )
    ORDER BY fecha;
END;
GO

/* =========================================================
   Jornadas lluviosas o de mal clima por coordenadas Historico

   API usada:
   Open-Meteo Historical Weather API
   https://archive-api.open-meteo.com/v1/archive

   Criterio usado:
   - Mala jornada si la precipitacion supera el umbral indicado.
   - Tambien se marca como mala jornada si el codigo WMO representa
     lluvia, tormenta, nieve o niebla.
   - Usa fechas pasadas mediante start_date y end_date.
   - Esta configurado en uso horario argentino.
   ========================================================= */

CREATE OR ALTER PROCEDURE apis.sp_clima_jornadas_malas_historico
    @latitud DECIMAL(9,6),
    @longitud DECIMAL(9,6),
    @fecha_desde DATE = NULL,
    @fecha_hasta DATE = NULL,
    @umbral_lluvia_mm DECIMAL(10,2) = 1.00,
    @solo_malas BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @url VARCHAR(1000);
    DECLARE @datos varchar(MAX);
    DECLARE @latitud_texto VARCHAR(30);
    DECLARE @longitud_texto VARCHAR(30);
    DECLARE @fecha_desde_texto VARCHAR(10);
    DECLARE @fecha_hasta_texto VARCHAR(10);

    -- Si no se informan fechas, por defecto toma los ultimos 30 dias
    IF @fecha_hasta IS NULL
        SET @fecha_hasta = CONVERT(DATE, GETDATE());

    IF @fecha_desde IS NULL
        SET @fecha_desde = DATEADD(DAY, -30, @fecha_hasta);

    IF @fecha_desde > @fecha_hasta
    BEGIN
        RAISERROR('La fecha desde no puede ser mayor que la fecha hasta.', 16, 1);
        RETURN;
    END;

    SET @latitud_texto = REPLACE(CONVERT(VARCHAR(30), @latitud), ',', '.');
    SET @longitud_texto = REPLACE(CONVERT(VARCHAR(30), @longitud), ',', '.');

    SET @fecha_desde_texto = CONVERT(VARCHAR(10), @fecha_desde, 23);
    SET @fecha_hasta_texto = CONVERT(VARCHAR(10), @fecha_hasta, 23);

    SET @url = CONCAT(
        'https://archive-api.open-meteo.com/v1/archive?',
        'latitude=', @latitud_texto,
        '&longitude=', @longitud_texto,
        '&start_date=', @fecha_desde_texto,
        '&end_date=', @fecha_hasta_texto,
        '&daily=weather_code,precipitation_sum,rain_sum',
        '&timezone=America%2FArgentina%2FBuenos_Aires'
    );

    EXEC apis.sp_llamar_api_get
        @url = @url,
        @respuesta = @datos OUTPUT;

    WITH Fechas AS (
        SELECT
            [key] AS indice,
            TRY_CONVERT(DATE, value) AS fecha
        FROM OPENJSON(@datos, '$.daily.time')
    ), Precipitacion AS (
        SELECT
            [key] AS indice,
            TRY_CONVERT(DECIMAL(10,2), value) AS precipitacion_mm
        FROM OPENJSON(@datos, '$.daily.precipitation_sum')
    ), Lluvia AS (
        SELECT
            [key] AS indice,
            TRY_CONVERT(DECIMAL(10,2), value) AS lluvia_mm
        FROM OPENJSON(@datos, '$.daily.rain_sum')
    ), Codigos AS (
        SELECT
            [key] AS indice,
            TRY_CONVERT(INT, value) AS codigo_clima
        FROM OPENJSON(@datos, '$.daily.weather_code')
    ), Resultado AS (
        SELECT
            'Open-Meteo Historical Weather API' AS fuente,
            @url AS url_consultada,
            F.fecha,
            C.codigo_clima,
            P.precipitacion_mm,
            L.lluvia_mm,
            CASE
                WHEN P.precipitacion_mm >= @umbral_lluvia_mm THEN 'Mala jornada'
                WHEN C.codigo_clima >= 20 THEN 'Mala jornada' 
                -- fuente codigos clima https://www.nodc.noaa.gov/archive/arc0021/0002199/1.1/data/0-data/HTML/WMO-CODE/WMO4677.HTM
                ELSE 'Jornada favorable'
            END AS estado_jornada,
            CASE
                WHEN C.codigo_clima BETWEEN 40 AND 49 THEN 'Niebla'
                WHEN C.codigo_clima BETWEEN 50 AND 59 THEN 'Llovizna'
                WHEN C.codigo_clima BETWEEN 60 AND 69 THEN 'Lluvia'
                WHEN C.codigo_clima BETWEEN 70 AND 99 THEN 'Precipitacion con chubascos o tormenta electrica'
                ELSE 'Sin mal clima relevante'
            END AS motivo
        FROM Fechas F
        LEFT JOIN Precipitacion P ON P.indice = F.indice
        LEFT JOIN Lluvia L ON L.indice = F.indice
        LEFT JOIN Codigos C ON C.indice = F.indice
    )
    SELECT *
    FROM Resultado
    WHERE @solo_malas = 0
       OR estado_jornada = 'Mala jornada'
    ORDER BY fecha;

END;
GO

/* =========================================================
   Jornadas lluviosas o de mal clima para un parque

   Usa las coordenadas guardadas en parques.Parque.
   ========================================================= */

CREATE OR ALTER PROCEDURE apis.sp_clima_parque_historico
    @id_parque INT,
    @fecha_desde DATE = NULL,
    @fecha_hasta DATE = NULL,
    @umbral_lluvia_mm DECIMAL(10,2) = 1.00,
    @solo_malas BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @latitud DECIMAL(9,6);
    DECLARE @longitud DECIMAL(9,6);

    SELECT
        @latitud = latitud,
        @longitud = longitud
    FROM parques.Parque
    WHERE id = @id_parque;

    IF @latitud IS NULL OR @longitud IS NULL
    BEGIN
        RAISERROR('No se encontro el parque indicado o no tiene coordenadas cargadas.', 16, 1);
        RETURN;
    END;

    EXEC apis.sp_clima_jornadas_malas_historico
        @latitud = @latitud,
        @longitud = @longitud,
        @fecha_desde = @fecha_desde,
        @fecha_hasta = @fecha_hasta,
        @umbral_lluvia_mm = @umbral_lluvia_mm,
        @solo_malas = @solo_malas;
END;
GO